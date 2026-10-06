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
  `yaml_directories`), or passed as a Terraform value (`model`).
- `!env NAME` reads a value from an environment variable, e.g. for secrets.
- `defaults` sets default values per resource, see `defaults/ise_defaults.yaml`.
- Complete examples: `examples/references` (hand-written) and
  `examples/auto-generated` (every resource, with the provider's example values).

### References by name

ISE objects often point to other objects by ID. In YAML they can point by name
instead. The module turns the name into the ID of an object it creates, or looks
the name up in ISE (for example built-in objects). An ID can still be given
directly.

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

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `yaml_directories` | List of paths to directories containing YAML model files. | `list(string)` | `[]` |
| `yaml_files` | List of paths to YAML model files. | `list(string)` | `[]` |
| `model` | As an alternative to YAML model files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `model` | Full model. |
| `defaults` | Default values. |

# Development

All `ise_*.tf` files, `versions.tf`, `defaults/` and `examples/auto-generated/`
are generated. Change the generator (`gen/generate_module.py`, `gen/templates/`)
or the module customizations (`gen/overrides.yaml`) and regenerate:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r gen/requirements.txt

# clone provider tag v0.5.0 and regenerate the module
./gen/generate_module.py

# other provider release, or a local provider checkout
./gen/generate_module.py --provider-version 0.5.1
./gen/generate_module.py --provider-source local --provider-path ../terraform-provider-ise
```

`terraform` must be on the `PATH` to format the generated files. CI checks that
the generated files are up to date and runs `terraform validate` and an offline
`terraform plan` of both examples (no ISE needed, as all referenced objects are
created by the examples).
