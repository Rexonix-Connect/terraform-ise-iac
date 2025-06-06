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
# CERTIFICATE AUTHENTICATION PROFILE 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the certificate profile |
# | description | String | False | Description |
# | allowed_as_user_name | Bool | False | Allow as username |
# | external_identity_store_name | String | False | Referred IDStore name for the Certificate Profile or `[not applicable]` in case no identity store is chosen |
# | certificate_attribute_name | String | False | Attribute name of the Certificate Profile - used only when CERTIFICATE is chosen in `username_from`. |
# | match_mode | String | False | Match mode of the Certificate Profile. Allowed values: NEVER, RESOLVE_IDENTITY_AMBIGUITY, BINARY_COMPARISON |
# | username_from | String | False | The attribute in the certificate where the user name should be taken from. Allowed values: `CERTIFICATE` (for a specific attribute as defined in certificateAttributeName), `UPN` (for using any Subject or Alternative Name Attributes in the Certificate - an option only in AD) |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_certificate_authentication_profile = try(local.defaults.ise.identity_management.certificate_authentication_profile, {})

  # Certificate Authentication Profile (with defaults)
  certificate_authentication_profile = [for item in try(local.ise.identity_management.certificate_authentication_profile, []) : merge(
    local.defaults_certificate_authentication_profile, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create certificate authentication profile
resource "ise_certificate_authentication_profile" "certificate_authentication_profile" {
  for_each = { for item in try(local.certificate_authentication_profile, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  allowed_as_user_name = try(each.value.allowed_as_user_name, null)
  external_identity_store_name = try(each.value.external_identity_store_name, null)
  certificate_attribute_name = try(each.value.certificate_attribute_name, null)
  match_mode = try(each.value.match_mode, null)
  username_from = try(each.value.username_from, null)
}
#
# ==================================================================
# IDENTITY SOURCE SEQUENCE 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the identity source sequence |
# | description | String | False | Description |
# | break_on_store_fail | Bool | True | Do not access other stores in the sequence if a selected identity store cannot be accessed for authentication |
# | certificate_authentication_profile | String | True | Certificate Authentication Profile, empty if doesn't exist |
# | identity_sources | List | True |  |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_identity_source_sequence = try(local.defaults.ise.identity_management.identity_source_sequence, {})

  # Identity Source Sequence (with defaults)
  identity_source_sequence = [for item in try(local.ise.identity_management.identity_source_sequence, []) : merge(
    local.defaults_identity_source_sequence, # defaults
    item, # original item
    { # Nested merges for complex attributes
      identity_sources = [for i in try(item.identity_sources, []) : merge(
        try(local.defaults_identity_source_sequence.identity_sources, {}),
        i
      )]
    }
  )]
}

# Create identity source sequence
resource "ise_identity_source_sequence" "identity_source_sequence" {
  for_each = { for item in try(local.identity_source_sequence, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  break_on_store_fail = try(each.value.break_on_store_fail, null)
  certificate_authentication_profile = try(each.value.certificate_authentication_profile, null)
  identity_sources = try([for i in each.value.identity_sources : {
    name = try(i.name, null),
    order = try(i.order, null)
  }], null)
}
#
# ==================================================================
# ENDPOINT 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the endpoint |
# | description | String | False | Description |
# | mac | String | True | MAC address of the endpoint |
# | group_id | String | False | Identity Group ID |
# | profile_id | String | False | Profile ID |
# | static_profile_assignment | Bool | True | Static Profile Assignment |
# | static_profile_assignment_defined | Bool | False | Static Profile Assignment Defined |
# | static_group_assignment | Bool | True | Static Group Assignment |
# | static_group_assignment_defined | Bool | False | staticGroupAssignmentDefined |
# | custom_attributes | Map | False | Custom Attributes |
# | identity_store | String | False | Identity Store |
# | identity_store_id | String | False | Identity Store Id |
# | portal_user | String | False | Portal User |
# | mdm_server_name | String | False | Mdm Server Name |
# | mdm_reachable | Bool | False | Mdm Reachable |
# | mdm_enrolled | Bool | False | Mdm Enrolled |
# | mdm_compliance_status | Bool | False | Mdm Compliance Status |
# | mdm_os | String | False | Mdm OS |
# | mdm_manufacturer | String | False | Mdm Manufacturer |
# | mdm_model | String | False | Mdm Model |
# | mdm_serial | String | False | Mdm Serial |
# | mdm_encrypted | Bool | False | Mdm Encrypted |
# | mdm_pinlock | Bool | False | Mdm Pinlock |
# | mdm_jail_broken | Bool | False | Mdm JailBroken |
# | mdm_imei | String | False | Mdm IMEI |
# | mdm_phone_number | String | False | Mdm PhoneNumber |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_endpoint = try(local.defaults.ise.identity_management.endpoint, {})

  # Endpoint (with defaults)
  endpoint = [for item in try(local.ise.identity_management.endpoint, []) : merge(
    local.defaults_endpoint, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create endpoint
resource "ise_endpoint" "endpoint" {
  for_each = { for item in try(local.endpoint, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  mac = try(each.value.mac, null)
  group_id = try(each.value.group_id, null)
  profile_id = try(each.value.profile_id, null)
  static_profile_assignment = try(each.value.static_profile_assignment, null)
  static_profile_assignment_defined = try(each.value.static_profile_assignment_defined, null)
  static_group_assignment = try(each.value.static_group_assignment, null)
  static_group_assignment_defined = try(each.value.static_group_assignment_defined, null)
  custom_attributes = try(each.value.custom_attributes, null)
  identity_store = try(each.value.identity_store, null)
  identity_store_id = try(each.value.identity_store_id, null)
  portal_user = try(each.value.portal_user, null)
  mdm_server_name = try(each.value.mdm_server_name, null)
  mdm_reachable = try(each.value.mdm_reachable, null)
  mdm_enrolled = try(each.value.mdm_enrolled, null)
  mdm_compliance_status = try(each.value.mdm_compliance_status, null)
  mdm_os = try(each.value.mdm_os, null)
  mdm_manufacturer = try(each.value.mdm_manufacturer, null)
  mdm_model = try(each.value.mdm_model, null)
  mdm_serial = try(each.value.mdm_serial, null)
  mdm_encrypted = try(each.value.mdm_encrypted, null)
  mdm_pinlock = try(each.value.mdm_pinlock, null)
  mdm_jail_broken = try(each.value.mdm_jail_broken, null)
  mdm_imei = try(each.value.mdm_imei, null)
  mdm_phone_number = try(each.value.mdm_phone_number, null)
}
#
# ==================================================================
# ACTIVE DIRECTORY JOIN DOMAIN WITH ALL NODES 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | join_point_id | String | False | Active Directory Join Point ID |
# | additional_data | List | True |  |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_active_directory_join_domain_with_all_nodes = try(local.defaults.ise.identity_management.active_directory_join_domain_with_all_nodes, {})

  # Active Directory Join Domain With All Nodes (with defaults)
  active_directory_join_domain_with_all_nodes = [for item in try(local.ise.identity_management.active_directory_join_domain_with_all_nodes, []) : merge(
    local.defaults_active_directory_join_domain_with_all_nodes, # defaults
    item, # original item
    { # Nested merges for complex attributes
      additional_data = [for i in try(item.additional_data, []) : merge(
        try(local.defaults_active_directory_join_domain_with_all_nodes.additional_data, {}),
        i
      )]
    }
  )]
}

# Create active directory join domain with all nodes
resource "ise_active_directory_join_domain_with_all_nodes" "active_directory_join_domain_with_all_nodes" {
  for_each = { for item in try(local.active_directory_join_domain_with_all_nodes, []) : item.name => item }

  # General attributes
  join_point_id = try(each.value.join_point_id, null)
  additional_data = try([for i in each.value.additional_data : {
    name = try(i.name, null),
    value = try(i.value, null)
  }], null)
}
#
# ==================================================================
# INTERNAL USER 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the internal user |
# | password | String | True | The password of the internal user |
# | change_password | Bool | False | Requires the user to change the password |
# | email | String | False | Email address |
# | account_name_alias | String | False | The Account Name Alias will be used to send email notifications about password expiration. This field is only supported from ISE 3.2. |
# | enable_password | String | False | This field is added in ISE 2.0 to support TACACS+ |
# | enabled | Bool | False | Whether the user is enabled/disabled |
# | password_never_expires | Bool | False | Set to `true` to indicate the user password never expires. This will not apply to Users who are also ISE Admins. This field is only supported from ISE 3.2. |
# | first_name | String | False | First name of the internal user |
# | last_name | String | False | Last name of the internal user |
# | identity_groups | String | False | Comma separated list of identity group IDs. |
# | custom_attributes | String | False | Key value map |
# | password_id_store | String | False | The ID store where the internal user's password is kept |
# | description | String | False | Description |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_internal_user = try(local.defaults.ise.identity_management.internal_user, {})

  # Internal User (with defaults)
  internal_user = [for item in try(local.ise.identity_management.internal_user, []) : merge(
    local.defaults_internal_user, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create internal user
resource "ise_internal_user" "internal_user" {
  for_each = { for item in try(local.internal_user, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  password = sensitive(try(each.value.password, null))
  change_password = sensitive(try(each.value.change_password, null))
  email = try(each.value.email, null)
  account_name_alias = try(each.value.account_name_alias, null)
  enable_password = sensitive(try(each.value.enable_password, null))
  enabled = try(each.value.enabled, null)
  password_never_expires = try(each.value.password_never_expires, null)
  first_name = try(each.value.first_name, null)
  last_name = try(each.value.last_name, null)
  identity_groups = try(each.value.identity_groups, null)
  custom_attributes = try(each.value.custom_attributes, null)
  password_id_store = try(each.value.password_id_store, null)
  description = try(each.value.description, null)
  
  lifecycle {
    ignore_changes = [password, enable_password]
  }
}
#
# ==================================================================
# USER IDENTITY GROUP 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the user identity group |
# | description | String | False | Description |
# | parent | String | False | Parent user identity group, e.g. `NAC Group:NAC:IdentityGroups:User Identity Groups` |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_user_identity_group = try(local.defaults.ise.identity_management.user_identity_group, {})

  # User Identity Group (with defaults)
  user_identity_group = [for item in try(local.ise.identity_management.user_identity_group, []) : merge(
    local.defaults_user_identity_group, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create user identity group
resource "ise_user_identity_group" "user_identity_group" {
  for_each = { for item in try(local.user_identity_group, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  parent = try(each.value.parent, null)
}
#
# ==================================================================
# ACTIVE DIRECTORY JOIN POINT 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the active directory join point |
# | description | String | False | Join point description |
# | domain | String | True | AD domain associated with the join point |
# | ad_scopes_names | String | False | String that contains the names of the scopes that the active directory belongs to. Names are separated by comma. |
# | enable_domain_allowed_list | Bool | False |  |
# | groups | List | False | List of AD Groups |
# | attributes | List | False | List of AD attributes |
# | rewrite_rules | List | False | List of Rewrite rules |
# | enable_rewrites | Bool | False | Enable Rewrites |
# | enable_pass_change | Bool | False | Enable Password Change |
# | enable_machine_auth | Bool | False | Enable Machine Authentication |
# | enable_machine_access | Bool | False | Enable Machine Access |
# | enable_dialin_permission_check | Bool | False | Enable Dial In Permission Check |
# | plaintext_auth | Bool | False | Plain Text Authentication |
# | aging_time | Int64 | False | Aging Time |
# | enable_callback_for_dialin_client | Bool | False | Enable Callback For Dial In Client |
# | identity_not_in_ad_behaviour | String | False | Identity Not In AD Behaviour |
# | unreachable_domains_behaviour | String | False | Unreachable Domains Behaviour |
# | schema | String | False | Schema |
# | first_name | String | False | User info attribute |
# | department | String | False | User info attribute |
# | last_name | String | False | User info attribute |
# | organizational_unit | String | False | User info attribute |
# | job_title | String | False | User info attribute |
# | locality | String | False | User info attribute |
# | email | String | False | User info attribute |
# | state_or_province | String | False | User info attribute |
# | telephone | String | False | User info attribute |
# | country | String | False | User info attribute |
# | street_address | String | False | User info attribute |
# | enable_failed_auth_protection | Bool | False | Enable prevent AD account lockout due to too many bad password attempts |
# | failed_auth_threshold | Int64 | False | Number of bad password attempts |
# | auth_protection_type | String | False | Enable prevent AD account lockout for WIRELESS/WIRED/BOTH |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_active_directory_join_point = try(local.defaults.ise.identity_management.active_directory_join_point, {})

  # Active Directory Join Point (with defaults)
  active_directory_join_point = [for item in try(local.ise.identity_management.active_directory_join_point, []) : merge(
    local.defaults_active_directory_join_point, # defaults
    item, # original item
    { # Nested merges for complex attributes
      groups = [for i in try(item.groups, []) : merge(
        try(local.defaults_active_directory_join_point.groups, {}),
        i
      )]
      attributes = [for i in try(item.attributes, []) : merge(
        try(local.defaults_active_directory_join_point.attributes, {}),
        i
      )]
      rewrite_rules = [for i in try(item.rewrite_rules, []) : merge(
        try(local.defaults_active_directory_join_point.rewrite_rules, {}),
        i
      )]
    }
  )]
}

# Create active directory join point
resource "ise_active_directory_join_point" "active_directory_join_point" {
  for_each = { for item in try(local.active_directory_join_point, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  domain = try(each.value.domain, null)
  ad_scopes_names = try(each.value.ad_scopes_names, null)
  enable_domain_allowed_list = try(each.value.enable_domain_allowed_list, null)
  groups = try([for i in each.value.groups : {
    name = try(i.name, null),
    sid = try(i.sid, null),
    type = try(i.type, null)
  }], null)
  attributes = try([for i in each.value.attributes : {
    name = try(i.name, null),
    type = try(i.type, null),
    internal_name = try(i.internal_name, null),
    default_value = try(i.default_value, null)
  }], null)
  rewrite_rules = try([for i in each.value.rewrite_rules : {
    row_id = try(i.row_id, null),
    rewrite_match = try(i.rewrite_match, null),
    rewrite_result = try(i.rewrite_result, null)
  }], null)
  enable_rewrites = try(each.value.enable_rewrites, null)
  enable_pass_change = try(each.value.enable_pass_change, null)
  enable_machine_auth = try(each.value.enable_machine_auth, null)
  enable_machine_access = try(each.value.enable_machine_access, null)
  enable_dialin_permission_check = try(each.value.enable_dialin_permission_check, null)
  plaintext_auth = try(each.value.plaintext_auth, null)
  aging_time = try(each.value.aging_time, null)
  enable_callback_for_dialin_client = try(each.value.enable_callback_for_dialin_client, null)
  identity_not_in_ad_behaviour = try(each.value.identity_not_in_ad_behaviour, null)
  unreachable_domains_behaviour = try(each.value.unreachable_domains_behaviour, null)
  schema = try(each.value.schema, null)
  first_name = try(each.value.first_name, null)
  department = try(each.value.department, null)
  last_name = try(each.value.last_name, null)
  organizational_unit = try(each.value.organizational_unit, null)
  job_title = try(each.value.job_title, null)
  locality = try(each.value.locality, null)
  email = try(each.value.email, null)
  state_or_province = try(each.value.state_or_province, null)
  telephone = try(each.value.telephone, null)
  country = try(each.value.country, null)
  street_address = try(each.value.street_address, null)
  enable_failed_auth_protection = try(each.value.enable_failed_auth_protection, null)
  failed_auth_threshold = try(each.value.failed_auth_threshold, null)
  auth_protection_type = try(each.value.auth_protection_type, null)
}
#
# ==================================================================
# ACTIVE DIRECTORY ADD GROUPS 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | join_point_id | String | False | Active Directory Join Point ID |
# | name | String | True | The name of the active directory join point |
# | description | String | False | Join point Description |
# | domain | String | True | AD domain associated with the join point |
# | ad_scopes_names | String | False | String that contains the names of the scopes that the active directory belongs to. Names are separated by comm |
# | enable_domain_allowed_list | Bool | False |  |
# | groups | List | False | List of AD Groups |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_active_directory_add_groups = try(local.defaults.ise.identity_management.active_directory_add_groups, {})

  # Active Directory Add Groups (with defaults)
  active_directory_add_groups = [for item in try(local.ise.identity_management.active_directory_add_groups, []) : merge(
    local.defaults_active_directory_add_groups, # defaults
    item, # original item
    { # Nested merges for complex attributes
      groups = [for i in try(item.groups, []) : merge(
        try(local.defaults_active_directory_add_groups.groups, {}),
        i
      )]
    }
  )]
}

# Create active directory add groups
resource "ise_active_directory_add_groups" "active_directory_add_groups" {
  for_each = { for item in try(local.active_directory_add_groups, []) : item.name => item }

  # General attributes
  join_point_id = try(each.value.join_point_id, null)
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  domain = try(each.value.domain, null)
  ad_scopes_names = try(each.value.ad_scopes_names, null)
  enable_domain_allowed_list = try(each.value.enable_domain_allowed_list, null)
  groups = try([for i in each.value.groups : {
    name = try(i.name, null),
    sid = try(i.sid, null),
    type = try(i.type, null)
  }], null)
}
#
# ==================================================================
# ENDPOINT IDENTITY GROUP 
# ==================================================================
#
# | Attribute Name | Type | Required | Description |
# |--------------|------|----------|-------------|
# | name | String | True | The name of the endpoint identity group |
# | description | String | False | Description |
# | system_defined | Bool | False | System defined endpoint identity group |
# | parent_endpoint_identity_group_id | String | False | Parent endpoint identity group ID |
#

locals {
  # Get defaults from configuration or empty map if not present
  defaults_endpoint_identity_group = try(local.defaults.ise.identity_management.endpoint_identity_group, {})

  # Endpoint Identity Group (with defaults)
  endpoint_identity_group = [for item in try(local.ise.identity_management.endpoint_identity_group, []) : merge(
    local.defaults_endpoint_identity_group, # defaults
    item, # original item
    { # Nested merges for complex attributes
    }
  )]
}

# Create endpoint identity group
resource "ise_endpoint_identity_group" "endpoint_identity_group" {
  for_each = { for item in try(local.endpoint_identity_group, []) : item.name => item }

  # General attributes
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  system_defined = try(each.value.system_defined, null)
  parent_endpoint_identity_group_id = try(each.value.parent_endpoint_identity_group_id, null)
}
