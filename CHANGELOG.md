## 0.1.0 (unreleased)

- Initial release
- Generate the module for ISE provider `0.5.0` (`~> 0.5.0`), adding endpoint custom attributes, network access dictionary attributes, TrustSec matrices, TrustSec work process settings and SXP connections, VPNs and local bindings
- Refer to other objects by name instead of ID (policy sets, library conditions, identity groups, Active Directory join points, security groups, TrustSec matrices and mapping groups); names of objects not managed by the module are looked up in ISE
- Create library conditions and endpoint identity groups that use objects of the same type in tiers, up to 4 levels
- Identify rules by policy set and rule name, and apply `rank` of rules and policy sets through the provider's bulk rank resources; the single and bulk rank resources are no longer configured directly
- `license_tier_state`, `trustsec_egress_matrix_cell_default`, `trustsec_egress_push_matrix` and `trustsec_work_process_settings` are single YAML objects instead of lists
- Switch YAML merging from `cloudposse/utils` to `netascode/utils` provider functions (requires Terraform 1.8), which adds `!env` tags to read values from environment variables
- **Behavior change:** lists of the same resource in several YAML files are now combined (entries whose simple values are all equal are merged into one). Before, the list in the last file replaced the lists in earlier files
- Secrets (passwords, shared secrets, keys) are no longer in `ignore_changes`: changing them in YAML rotates them in ISE
- Fix defaults of nested lists (applied to each list item) and nested lists set to empty lists when not configured
- Fix provider example values such as `OFF` read as booleans
- Generator: command line options for the provider source, release and git ref, a fixed local provider source, stable output order, removal of stale generated files and `terraform fmt` of generated files
