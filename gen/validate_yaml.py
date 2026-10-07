#!/usr/bin/env python3
"""
Validate YAML model files against the module's JSON Schema (schema/ise-iac.schema.json).

Each file is checked on its own. Values with the !env tag are accepted as strings.
Exit code 1 if any file has errors.
"""

import json
import sys
from pathlib import Path
from typing import List

import click
import jsonschema
import yaml

SCHEMA_FILE: Path = Path(__file__).resolve().parent.parent / "schema" / "ise-iac.schema.json"


class ModelLoader(yaml.SafeLoader):
    """YAML loader accepting the !env tag of the netascode/utils provider."""


ModelLoader.add_constructor("!env", lambda loader, node: loader.construct_scalar(node))


@click.command()
@click.argument("files", nargs=-1, required=True, type=click.Path(exists=True, dir_okay=False))
@click.option("--schema", "schema_file", default=str(SCHEMA_FILE), show_default=True)
def main(files: List[str], schema_file: str) -> None:
    """Validate YAML model FILES against the module's JSON Schema."""
    validator = jsonschema.Draft202012Validator(json.loads(Path(schema_file).read_text()))
    failed = False
    for file in files:
        with open(file) as f:
            data = yaml.load(f, Loader=ModelLoader) or {}
        errors = sorted(validator.iter_errors(data), key=lambda e: list(e.absolute_path))
        for error in errors:
            location = "/".join(str(p) for p in error.absolute_path) or "<root>"
            click.echo(f"{file}: {location}: {error.message}")
        failed = failed or bool(errors)
    if not failed:
        click.echo(f"{len(files)} file(s) valid")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
