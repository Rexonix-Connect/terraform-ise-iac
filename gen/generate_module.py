#!/usr/bin/env python3
"""
ISE Infrastructure as Code Module Generator

This script generates Terraform HCL configurations for the terraform-ise-iac module
based on the YAML definitions from the terraform-provider-ise repository.
"""

import os
import yaml
from pathlib import Path
import re
import subprocess
from jinja2 import Environment, FileSystemLoader, StrictUndefined
import logging
from rich.logging import RichHandler
from typing import Any, Dict, List, Set, Optional

# Paths
SCRIPT_DIR: Path = Path(os.path.dirname(os.path.realpath(__file__)))
#
SENSITIVE_ATTRIBUTES_REGEXP: re.Pattern = re.compile(
    r"^("
    r".*password|"
    r".*key|"
    r".*shared_secret|"
    r".*username|"
    r".*snmp.*community"
    r")$"
)
# Provider source code
PROVIDER_DIR: Path = SCRIPT_DIR / "terraform-provider-ise"
DEFAULT_PROVIDER_SOURCE_TYPE: str = "git"
DEFAULT_PROVIDER_SOURCE_PATH: str = (
    "https://github.com/CiscoDevNet/terraform-provider-ise"
)
DEFAULT_PROVIDER_GIT_BRANCH: str = "main"
# File generation
TEMPLATES_DIR: Path = SCRIPT_DIR / "templates"
MODULE_DIR: Path = SCRIPT_DIR / ".."
DEFAULTS_DIR: Path = MODULE_DIR / "defaults"
EXAMPLES_DIR: Path = MODULE_DIR / "examples"
EXAMPLE_DEFAULTS_DATA_DIR: Path = EXAMPLES_DIR / "auto-generated" / "user-defaults"
EXAMPLE_MODEL_DATA_DIR: Path = EXAMPLES_DIR / "auto-generated" / "model-data"
DEFAULTS_FILENAME: str = "ise_defaults.yaml"
DEFAULT_RESOURCE_TEMPLATE: str = "resource_default.tf.j2"
GENERATE_FILE_BANNER: str = """#
# ################################################################################
#
# This file was automatically generated with ./gen/generate_module.py
#          Do not edit this file directly.
#          More information in repository README.md
#
# ################################################################################
#
"""


logging.basicConfig(
    level=logging.INFO, format="%(message)s", datefmt="[%X]", handlers=[RichHandler()]
)
logger = logging.getLogger("ise-nac-generator")


def snake_case(s: str) -> str:
    """Convert camelCase to snake_case"""
    s1 = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", s)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", s1).lower()


def ensure_name_in_attribute(attr: Dict[str, Any]) -> Dict[str, Any]:
    """Ensure the name attribute is present in the attribute dictionary."""
    if "name" not in attr:
        attr_name = attr.get("tf_name", snake_case(attr.get("model_name", "")))
        if not attr_name:
            logger.warning(f"Could not derive attribute name for attribute: {attr}")
        attr["name"] = attr_name
    return attr


def is_hardcoded_attribute(attr: Dict[str, Any]) -> bool:
    """Check if the attribute is hardcoded based on key presence."""
    if "value" in attr:
        logger.warning(f"Attribute is hard-coded thus ignored: {attr}")
        return True
    return False


def is_ignore_changes_attribute(attr: Dict[str, Any]) -> bool:
    """Check if attribute should be included in ignore_changes lifecycle option."""
    if "write_only" in attr and attr["write_only"]:
        logger.info(
            f"Attribute {attr['name']} is write-only thus marked for ignore_changes."
        )
        return True
    if "write_changes_only" in attr and attr["write_changes_only"]:
        logger.info(
            f"Attribute {attr['name']} is write_changes_only thus marked for ignore_changes."
        )
        return True
    return False


def is_named_attribute(attr: Dict[str, Any]) -> bool:
    """Check if the attribute has a name."""
    if not ("name" in attr and attr["name"]):
        logger.warning(f"Attribute is missing a valid name: {attr}")
        return False
    return True


def is_sensitive_attribute(attr: Dict[str, Any]) -> bool:
    """Check if the attribute is sensitive based on its name."""
    if SENSITIVE_ATTRIBUTES_REGEXP.match(attr["name"]) is not None:
        logger.info(f"Attribute {attr['name']} is considered sensitive.")
        return True
    return False


def process_attributes(
    attrs: List[Dict[str, Any]], attr_keys: Set[str]
) -> List[Dict[str, Any]]:
    """Process attributes to match expected format"""
    processed = []
    for attr in attrs:
        attr = ensure_name_in_attribute(attr)

        if is_hardcoded_attribute(attr):
            continue

        if not is_named_attribute(attr):
            continue

        nested_attributes = process_attributes(attr.get("attributes", []), attr_keys)

        processed.append(
            {
                "sensitive": is_sensitive_attribute(attr),
                "ignore_changes": is_ignore_changes_attribute(attr),
                **{
                    attr_key: attr[attr_key]
                    for attr_key in attr_keys
                    if attr_key in attr
                },
                "nested_attributes": nested_attributes,
            }
        )
    return processed


def get_provider_code(
    provider_dir: Path,
    source_type: str = DEFAULT_PROVIDER_SOURCE_TYPE,
    source_path: str = DEFAULT_PROVIDER_SOURCE_PATH,
    git_branch: str = DEFAULT_PROVIDER_GIT_BRANCH,
) -> None:
    """Retrieve the provider code from remote git or local repository"""
    try:
        if source_type == "git":
            if provider_dir.exists():
                subprocess.run(["rm", "-rf", str(provider_dir)], check=True)
            subprocess.run(
                ["git", "clone", "-b", git_branch, source_path, str(provider_dir)],
                check=True,
            )
        elif source_type == "local":
            if provider_dir.exists():
                for item in provider_dir.iterdir():
                    if item.is_dir():
                        subprocess.run(["rm", "-rf", str(item)], check=True)
                    else:
                        item.unlink()
            subprocess.run(["cp", "-r", source_path, str(provider_dir)], check=True)
        else:
            raise ValueError("Unsupported source type. Use 'git' or 'local'.")
    except subprocess.CalledProcessError as e:
        logger.error(f"Error running shell command: {e}")
        raise
    except Exception as e:
        logger.error(f"Error in get_provider_code: {e}")
        raise


def load_yaml_definitions(provider_dir: Path) -> Dict[str, Any]:
    """Load all YAML definitions from the provider repo"""
    definitions_dir: Path = provider_dir / "gen" / "definitions"
    definitions: Dict[str, Any] = {}
    try:
        for yaml_file in definitions_dir.glob("*.yaml"):
            try:
                with yaml_file.open("r") as f:
                    definition = yaml.safe_load(f)
                    if definition:
                        definitions[yaml_file.stem] = definition
                    else:
                        logger.warning(f"No definition found in {yaml_file}")
            except Exception as e:
                logger.error(f"Failed to load {yaml_file}: {e}")
    except Exception as e:
        logger.error(f"Error loading YAML definitions: {e}")
        raise
    return definitions


def get_all_attribute_keys_for_definitions(definitions: Dict[str, Any]) -> Set[str]:
    """Retrieve all attribute keys from definitions."""
    all_attribute_keys: Set[str] = set(["name"])
    for definition_name, definition in definitions.items():
        for attr in definition.get("attributes", []):
            for key in attr.keys():
                all_attribute_keys.add(key)
    return all_attribute_keys


def process_resource_definitions(definitions: Dict[str, Any]) -> Dict[str, Any]:
    """Process resource definitions for further use"""
    all_attribute_keys = get_all_attribute_keys_for_definitions(definitions)
    # print(all_attribute_keys) # TODO: remove
    no_resources = []
    for definition_name, definition in definitions.items():
        logger.info(f"Processing {definition_name}...")
        if definition.get("no_resource", False):  # TODO: review
            logger.warning(f"No resource defined for {definition_name}.")
            no_resources.append(definition_name)
            continue
        definition["processed_attributes"] = process_attributes(
            definition.get("attributes", []), all_attribute_keys
        )
        definition["ignore_changes_attributes"] = [
            attr["name"]
            for attr in definition["processed_attributes"]
            if attr["ignore_changes"]
        ]
    # remove no_resources # TODO: review
    for res in no_resources:
        del definitions[res]
    return definitions


def generate_file(
    output_path: Path,
    filename: str,
    output_text: Optional[str] = None,
    output_yaml: Optional[Dict[str, Any]] = None,
) -> None:
    """Generate a file with the specified output path and content."""
    output_path.mkdir(parents=True, exist_ok=True)
    output_filename = output_path / filename
    try:
        with output_filename.open("w") as f:
            f.write(GENERATE_FILE_BANNER)
            if output_text:
                f.write(output_text)
            elif output_yaml:
                yaml.dump(output_yaml, f)
        logger.info(f"Generated {output_filename}")
    except Exception as e:
        logger.error(f"Failed to write {output_filename}: {e}")


def generate_module_files(definitions: Dict[str, Any]) -> None:
    """Generate module files based on definitions"""
    # Group definitions by category
    category_resources = {}
    for resource_name, definition in definitions.items():
        category = definition.get("doc_category", "Other").lower().replace(" ", "_")
        if category not in category_resources:
            category_resources[category] = []

        category_resources[category].append(
            {"name": resource_name, "definition": definition}
        )

    env = Environment(
        loader=FileSystemLoader(TEMPLATES_DIR),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
        undefined=StrictUndefined,
    )
    template = env.get_template(DEFAULT_RESOURCE_TEMPLATE)

    # Generate files by category
    for category, resources in category_resources.items():
        rendered_resources = {}
        for resource in resources:
            resource_name = resource["name"]
            resource_content = template.render(
                {"resource": resource, "category": category},
            )
            # Add to the grouped resources under 'default' key
            if "default" not in rendered_resources:
                rendered_resources["default"] = ""
            rendered_resources["default"] += resource_content

        file_content = "\n\n".join(rendered_resources.values())
        generate_file(
            output_path=MODULE_DIR,
            filename=f"ise_{category}.tf",
            output_text=file_content,
        )


def generate_example_model_files(definitions: Dict[str, Any]) -> None:
    """Generate example model files based on definitions, group them by files as per doc_category"""

    # Generate example data
    example_model_data = {}
    for resource_name, definition in definitions.items():
        category = definition.get("doc_category", "Other").lower().replace(" ", "_")
        if category not in example_model_data:
            example_model_data[category] = {}
        if resource_name not in example_model_data[category]:
            example_model_data[category][resource_name] = []
        resource_object = {}
        for attr in definition["processed_attributes"]:
            if attr["type"] == "List":
                resource_object[attr["name"]] = list()
                nested_resource_object = {}
                for sub_attr in attr["nested_attributes"]:
                    nested_resource_object[sub_attr["name"]] = sub_attr.get(
                        "example", None
                    )
                resource_object[attr["name"]].append(nested_resource_object)
            elif attr["type"] == "Set":
                resource_object[attr["name"]] = list()
                resource_object[attr["name"]].append(attr.get("example", None))
            elif attr["type"] in ["String", "Int64", "Bool"]:
                resource_object[attr["name"]] = attr.get("example", None)
            elif attr["type"] == "Map":
                if "example" not in attr:
                    continue
                resource_object[attr["name"]] = {}
                s = attr["example"].strip("{}").replace('"', "")
                k, v = [item.strip() for item in s.split("=")]
                resource_object[attr["name"]][k] = v
            else:
                logger.warning(
                    f"Unsupported attribute type. {category} / {resource_name} / {attr['name']} / {attr['type']}"
                )
        example_model_data[category][resource_name].append(resource_object)

    # Write example files
    for category, resources in example_model_data.items():
        file_name = f"ise_{category}.yaml"
        output_data = {"ise": {category: resources}}
        generate_file(
            output_path=EXAMPLE_MODEL_DATA_DIR,
            filename=file_name,
            output_yaml=output_data,
        )


def generate_defaults_data(definitions: Dict[str, Any]) -> Dict[str, Any]:
    """Generate default values for all resources, grouped by category. Only include attributes with valid default_value."""
    defaults_data = {}
    for resource_name, definition in definitions.items():
        category = definition.get("doc_category", "Other").lower().replace(" ", "_")
        if category not in defaults_data:
            defaults_data[category] = {}
        if resource_name not in defaults_data[category]:
            defaults_data[category][resource_name] = {}
        resource_object = {}
        for attr in definition["processed_attributes"]:
            default = attr.get("default_value", None)
            if default is None or (isinstance(default, str) and default.strip() == ""):
                continue  # skip attributes without valid default_value
            if attr["type"] == "List":
                nested_resource_object = {}
                for sub_attr in attr["nested_attributes"]:
                    sub_default = sub_attr.get("default_value", None)
                    if sub_default is not None and (
                        not isinstance(sub_default, str) or sub_default.strip() != ""
                    ):
                        nested_resource_object[sub_attr["name"]] = sub_default
                if nested_resource_object:
                    resource_object[attr["name"]] = [nested_resource_object]
            elif attr["type"] == "Set":
                resource_object[attr["name"]] = [default]
            elif attr["type"] in ["String", "Int64", "Bool"]:
                resource_object[attr["name"]] = default
            elif attr["type"] == "Map":
                resource_object[attr["name"]] = {}
                if isinstance(default, str):
                    s = default.strip("{} ").replace('"', "")
                    if s and "=" in s:
                        k, v = [item.strip() for item in s.split("=")]
                        resource_object[attr["name"]][k] = v
            else:
                logger.warning(
                    f"Unsupported attribute type. {category} / {resource_name} / {attr['name']} / {attr['type']}"
                )
        if resource_object:
            defaults_data[category][resource_name] = resource_object

    # Return finalized defaults data
    return {"defaults": {"ise": defaults_data}}


def generate_defaults_files(defaults_data: Dict[str, Any]) -> None:
    """Generate defaults files for all resources."""
    for defaults_dir in (DEFAULTS_DIR, EXAMPLE_DEFAULTS_DATA_DIR):
        generate_file(
            output_path=defaults_dir,
            filename=DEFAULTS_FILENAME,
            output_yaml=defaults_data,
        )


def main() -> None:
    """Main function"""
    # Get provider code into terraform-provider-ise subdirectory
    logger.info("Get provider code into subdirectory...")
    get_provider_code(PROVIDER_DIR)

    # Load YAML definitions
    logger.info("Loading YAML definitions from provider repository...")
    definitions = load_yaml_definitions(PROVIDER_DIR)
    logger.info("Processing resource definitions...")
    processed_definitions = process_resource_definitions(definitions)

    # Generate module files
    logger.info("Generating module files...")
    generate_module_files(processed_definitions)

    # Generate example model files
    logger.info("Generating example model files...")
    generate_example_model_files(processed_definitions)

    # Generate defaults data
    logger.info("Generating defaults data...")
    defaults_data = generate_defaults_data(processed_definitions)

    # Generate defaults files
    logger.info("Generating defaults files...")
    generate_defaults_files(defaults_data)


if __name__ == "__main__":
    main()
