# terraform-ise-iac

Terraform module to configure Cisco ISE (Identity Services Engine) from YAML files.

The module is generated from the resource definitions of the
[ISE Terraform provider](https://github.com/CiscoDevNet/terraform-provider-ise).
Each provider resource is a list in YAML, and each YAML key is the provider
attribute of the same name. A small hand-written layer (`gen/overrides.yaml`)
adds what the provider definitions do not describe: references by name, rule
order and object keys.

## Usage

```hcl
module "ise" {
  source = "github.com/rexonix-connect/terraform-ise-iac"

  yaml_directories = ["data"]
}
```

```yaml
# data/network_resources.yaml
ise:
  network_resources:
    network_device_group:
      - name: "Device Type#All Device Types#Switches"
        root_group: Device Type
    network_device:
      - name: switch1
        ips:
          - ipaddress: 10.0.0.1
            mask: 32
        network_device_groups: ["Device Type#All Device Types#Switches"]
        authentication_radius_shared_secret: !env RADIUS_SECRET
```

- Objects live under `ise.<section>.<resource>`, where the section is the file
  name of the generated module code (`ise_<section>.tf`). The header of each
  resource in these files lists all YAML keys.
- YAML can be split over many files and directories (`yaml_files`,
  `yaml_directories`), or passed as a Terraform value (`model`). Lists of the
  same resource from several files are combined.
- `!env NAME` reads a value from an environment variable, e.g. for secrets.
- `defaults` sets default values per resource, see `defaults/ise_defaults.yaml`.
- Complete examples: `examples/references` (hand-written) and
  `examples/auto-generated` (every resource, with the provider's example values).

### Checking YAML

Values under unknown YAML keys would be ignored, so the plan stops with a list of
unknown keys (typos, or keys of a newer module version), for example
`ise.network_resources.network_device[0].shared_secret`. The YAML may have only
the root keys `ise` and `defaults`, so YAML directories cannot be shared with
other modules.

`schema/ise-iac.schema.json` is a JSON Schema of the YAML model. It gives
completion and checks in editors, e.g. with the YAML extension for VS Code:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Rexonix-Connect/terraform-ise-iac/main/schema/ise-iac.schema.json
```

`gen/validate_yaml.py file.yaml ...` checks files against it without Terraform,
e.g. in CI pipelines (`pip install -r gen/requirements.txt`).

### References by name

ISE objects often point to other objects by ID. In YAML they can point by name
instead. The module turns the name into the ID of an object it creates, or looks
the name up in ISE (for example built-in objects). An ID can still be given
directly. Active Directory join points are the exception: the provider cannot
look them up by name, so a join point not managed by the module must be given
by ID (`join_point_id`).

| Resource | YAML key | Refers to |
|----------|----------|-----------|
| policy set, rules | `condition_name` (if `condition_type` is `ConditionReference`) | library condition |
| policy set, rules, library conditions | `children[].name` (if `condition_type` is `ConditionReference`) | library condition |
| rules | `policy_set_name` | policy set |
| `internal_user` | `identity_group_names` (list) | user identity group |
| `endpoint` | `group_name`, `profile_name` | endpoint identity group, profiler profile |
| `endpoint_identity_group` | `parent_endpoint_identity_group_name` | endpoint identity group |
| `active_directory_add_groups` | `name` | Active Directory join point |
| `active_directory_join_domain_with_all_nodes` | `join_point_name` | Active Directory join point |
| `trustsec_egress_matrix_cell` | `source_sgt_name`, `destination_sgt_name`, `matrix_name` | security group, matrix |
| `trustsec_ip_to_sgt_mapping(_group)` | `sgt_name`, `mapping_group_name` | security group, mapping group |
| `trustsec_ip_to_sgt_mapping(_group)` | `deploy_to` (if `deploy_type` is `ND` or `NDG`) | network device, network device group |
| policy set, rules, library conditions | `condition_attribute_value`, `attribute_value`, `children[].attribute_value` (if the attribute name is `EndPointPolicy`) | profiler profile |

In the last two rows the key itself takes either a name or an ID: values that
look like an ISE ID (a UUID) are used as they are.

Library conditions and endpoint identity groups can refer to objects of the same
type. The module creates them in tiers so that referenced objects exist first.
Up to 4 tiers are supported (`self_reference_tiers` in `gen/overrides.yaml`);
loops and deeper chains stop the plan with an error naming the objects.

### Rules and policy set order

Rules are identified by `policy_set_name` and `name`, so rule names can repeat
across policy sets. `rank` sets the order. ISE only accepts ranks in strict
sequence when objects are created, so the module creates rules and policy sets
without rank and then sets all ranks of a policy set at once
(`ise_*_update_ranks` resources). Objects without `rank` and default
objects keep their position.

### Secrets

ISE does not return secrets (passwords, shared secrets, keys), so the YAML value
is their only source. Changing a secret in YAML rotates it in ISE. After an
import of existing objects, the first apply sets the secrets given in YAML;
secrets left out of YAML are not touched. Use `!env` to keep secrets out of the
YAML files.

### Single objects

`license_tier_state`, `trustsec_egress_matrix_cell_default`,
`trustsec_egress_push_matrix` and `trustsec_work_process_settings` exist once per
ISE. In YAML they are a single object instead of a list.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.0 |
| [CiscoDevNet/ise](https://registry.terraform.io/providers/CiscoDevNet/ise) | ~> 0.5.0 |
| [netascode/utils](https://registry.terraform.io/providers/netascode/utils) | ~> 2.0 |
| [hashicorp/local](https://registry.terraform.io/providers/hashicorp/local) | >= 2.3.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `yaml_directories` | List of paths to directories containing YAML model files. | `list(string)` | `[]` |
| `yaml_files` | List of paths to YAML model files. | `list(string)` | `[]` |
| `model` | As an alternative to YAML model files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` |
| `write_default_values_file` | Write all default values (module and user defaults merged) to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` |

## Outputs

| Name | Description |
|------|-------------|
| `model` | Full model. |
| `defaults` | Default values. |
| `ids` | IDs of the objects managed by the module, by resource and object key, e.g. `module.ise.ids.network_access_policy_set["Wired"]`. |

# Development

All `ise_*.tf` files, `ids.tf`, `validation.tf`, `versions.tf`, `defaults/`,
`schema/` and `examples/auto-generated/` are generated. Change the generator
(`gen/generate_module.py`, `gen/templates/`) or the module customizations
(`gen/overrides.yaml`) and regenerate:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r gen/requirements.txt

# clone the provider release in gen/PROVIDER_VERSION and regenerate the module
./gen/generate_module.py

# other provider release, or a local provider checkout
./gen/generate_module.py --provider-version 0.5.1
./gen/generate_module.py --provider-source local --provider-path ../terraform-provider-ise
```

To move to a new provider release, change `gen/PROVIDER_VERSION` and regenerate.
The Provider Update workflow does this every week: it opens a pull request when
CiscoDevNet releases a newer provider. It generates and checks the module with
read-only access, and only a separate job that runs no provider code gets write
access to push the branch and open the pull request. It needs "Allow GitHub
Actions to create and approve pull requests" in the repository settings. With a
`PROVIDER_UPDATE_TOKEN` secret (a token with contents and pull request write
access) the Tests workflow also runs on its pull requests.

`schema/ise-iac.model.json` describes the module for tools such as the
extractor: resources, keys, references, ranks, tiers and the provider's API
paths.

`terraform` must be on the `PATH` to format the generated files. CI checks that
the generated files are up to date and runs `terraform validate` and an offline
`terraform plan` of both examples (no ISE needed, as all referenced objects are
created by the examples).
