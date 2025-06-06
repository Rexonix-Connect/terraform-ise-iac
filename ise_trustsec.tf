#
# ################################################################################
#
# This file was automatically generated with ./gen/generate_module.py
#          Do not edit this file directly.
#          More information in repository README.md
#
# ################################################################################
#
#
# ==================================================================
# TRUSTSEC EGRESS MATRIX CELL 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | description | String | False | Description |
# | default_rule | String | False | Can be used only if sgacls not specified. |
# | matrix_cell_status | String | False | Matrix Cell Status |
# | sgacls | Set | False | List of TrustSec Security Groups ACLs |
# | source_sgt_id | String | True | Source Trustsec Security Group ID |
# | destination_sgt_id | String | True | Destination Trustsec Security Group ID |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_egress_matrix_cell = try(local.defaults.ise.trustsec.trustsec_egress_matrix_cell, {})

  # Trustsec Egress Matrix Cell (with defaults)
  trustsec_egress_matrix_cell = [for item in try(local.ise.trustsec.trustsec_egress_matrix_cell, []) : merge(
    local.defaults_trustsec_egress_matrix_cell, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec egress matrix cell
resource "ise_trustsec_egress_matrix_cell" "trustsec_egress_matrix_cell" {
  for_each = { for item in try(local.trustsec_egress_matrix_cell, []) : item.name => item }

  # General attributes
  description = try(each.value.description, null)
  default_rule = try(each.value.default_rule, null)
  matrix_cell_status = try(each.value.matrix_cell_status, null)
  sgacls = try(each.value.sgacls, null)
  source_sgt_id = try(each.value.source_sgt_id, null)
  destination_sgt_id = try(each.value.destination_sgt_id, null)
}
#
# ==================================================================
# TRUSTSEC IP TO SGT MAPPING 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the IP to SGT mapping |
# | description | String | False | Description |
# | deploy_to | String | False | Mandatory unless `mapping_group` is set or unless `deploy_type` is `ALL` |
# | deploy_type | String | False | Deploy Type |
# | host_name | String | False | Mandatory if `host_ip` is empty |
# | host_ip | String | False | Mandatory if `host_name` is empty |
# | sgt | String | False | Trustsec Security Group ID. Mandatory unless `mapping_group` is set |
# | mapping_group | String | False | IP to SGT Mapping Group ID. Mandatory unless `sgt` and `deploy_to` and `deploy_type` are set |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_ip_to_sgt_mapping = try(local.defaults.ise.trustsec.trustsec_ip_to_sgt_mapping, {})

  # Trustsec Ip To Sgt Mapping (with defaults)
  trustsec_ip_to_sgt_mapping = [for item in try(local.ise.trustsec.trustsec_ip_to_sgt_mapping, []) : merge(
    local.defaults_trustsec_ip_to_sgt_mapping, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec ip to sgt mapping
resource "ise_trustsec_ip_to_sgt_mapping" "trustsec_ip_to_sgt_mapping" {
  for_each = { for item in try(local.trustsec_ip_to_sgt_mapping, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  deploy_to = try(each.value.deploy_to, null)
  deploy_type = try(each.value.deploy_type, null)
  host_name = try(each.value.host_name, null)
  host_ip = try(each.value.host_ip, null)
  sgt = try(each.value.sgt, null)
  mapping_group = try(each.value.mapping_group, null)
}
#
# ==================================================================
# TRUSTSEC IP TO SGT MAPPING GROUP 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the IP to SGT mapping Group |
# | description | String | False | Description |
# | deploy_to | String | False | Mandatory unless `deploy_type` is `ALL` |
# | deploy_type | String | True | Deploy Type |
# | sgt | String | True | Trustsec Security Group ID |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_ip_to_sgt_mapping_group = try(local.defaults.ise.trustsec.trustsec_ip_to_sgt_mapping_group, {})

  # Trustsec Ip To Sgt Mapping Group (with defaults)
  trustsec_ip_to_sgt_mapping_group = [for item in try(local.ise.trustsec.trustsec_ip_to_sgt_mapping_group, []) : merge(
    local.defaults_trustsec_ip_to_sgt_mapping_group, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec ip to sgt mapping group
resource "ise_trustsec_ip_to_sgt_mapping_group" "trustsec_ip_to_sgt_mapping_group" {
  for_each = { for item in try(local.trustsec_ip_to_sgt_mapping_group, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  deploy_to = try(each.value.deploy_to, null)
  deploy_type = try(each.value.deploy_type, null)
  sgt = try(each.value.sgt, null)
}
#
# ==================================================================
# TRUSTSEC SECURITY GROUP ACL 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the security group ACL |
# | description | String | False | Description |
# | acl_content | String | True | Content of ACL |
# | ip_version | String | False | IP Version |
# | read_only | Bool | False | Read-only |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_security_group_acl = try(local.defaults.ise.trustsec.trustsec_security_group_acl, {})

  # Trustsec Security Group Acl (with defaults)
  trustsec_security_group_acl = [for item in try(local.ise.trustsec.trustsec_security_group_acl, []) : merge(
    local.defaults_trustsec_security_group_acl, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec security group acl
resource "ise_trustsec_security_group_acl" "trustsec_security_group_acl" {
  for_each = { for item in try(local.trustsec_security_group_acl, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  acl_content = try(each.value.acl_content, null)
  ip_version = try(each.value.ip_version, null)
  read_only = try(each.value.read_only, null)
  
  lifecycle {
    ignore_changes = [read_only]
  }
}
#
# ==================================================================
# SXP DOMAIN FILTER 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | False | Resource name |
# | description | String | False | Description |
# | subnet | String | False | Subnet for filter policy (hostname is not supported). At least one of subnet or sgt or vn should be defined |
# | sgt | String | False | SGT name or ID. At least one of subnet or sgt or vn should be defined |
# | vn | String | False | Virtual Network. At least one of subnet or sgt or vn should be defined |
# | domains | String | True | List of SXP Domains, separated with comma |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_sxp_domain_filter = try(local.defaults.ise.trustsec.sxp_domain_filter, {})

  # Sxp Domain Filter (with defaults)
  sxp_domain_filter = [for item in try(local.ise.trustsec.sxp_domain_filter, []) : merge(
    local.defaults_sxp_domain_filter, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create sxp domain filter
resource "ise_sxp_domain_filter" "sxp_domain_filter" {
  for_each = { for item in try(local.sxp_domain_filter, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  subnet = try(each.value.subnet, null)
  sgt = try(each.value.sgt, null)
  vn = try(each.value.vn, null)
  domains = try(each.value.domains, null)
  
  lifecycle {
    ignore_changes = [sgt]
  }
}
#
# ==================================================================
# TRUSTSEC SECURITY GROUP 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the security group |
# | description | String | False | Description |
# | value | Int64 | True | `-1` to auto-generate |
# | propogate_to_apic | Bool | False | Propagate to APIC (ACI) |
# | is_read_only | Bool | False | Read-only |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_security_group = try(local.defaults.ise.trustsec.trustsec_security_group, {})

  # Trustsec Security Group (with defaults)
  trustsec_security_group = [for item in try(local.ise.trustsec.trustsec_security_group, []) : merge(
    local.defaults_trustsec_security_group, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec security group
resource "ise_trustsec_security_group" "trustsec_security_group" {
  for_each = { for item in try(local.trustsec_security_group, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  value = try(each.value.value, null)
  propogate_to_apic = try(each.value.propogate_to_apic, null)
  is_read_only = try(each.value.is_read_only, null)
  
  lifecycle {
    ignore_changes = [is_read_only]
  }
}
#
# ==================================================================
# TRUSTSEC EGRESS MATRIX CELL DEFAULT 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | description | String | False | Description |
# | default_rule | String | False | Can be used only if sgacls not specified. Final Catch All Rule |
# | matrix_cell_status | String | False | Matrix Cell Status |
# | sgacls | Set | False | List of TrustSec Security Groups ACLs |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_trustsec_egress_matrix_cell_default = try(local.defaults.ise.trustsec.trustsec_egress_matrix_cell_default, {})

  # Trustsec Egress Matrix Cell Default (with defaults)
  trustsec_egress_matrix_cell_default = [for item in try(local.ise.trustsec.trustsec_egress_matrix_cell_default, []) : merge(
    local.defaults_trustsec_egress_matrix_cell_default, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create trustsec egress matrix cell default
resource "ise_trustsec_egress_matrix_cell_default" "trustsec_egress_matrix_cell_default" {
  for_each = { for item in try(local.trustsec_egress_matrix_cell_default, []) : item.name => item }

  # General attributes
  description = try(each.value.description, null)
  default_rule = try(each.value.default_rule, null)
  matrix_cell_status = try(each.value.matrix_cell_status, null)
  sgacls = try(each.value.sgacls, null)
}
