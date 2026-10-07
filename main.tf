locals {
  # Alias to user-provided model data processed in merge.tf
  ise = try(local.model.ise, {})
  # ISE object IDs (UUIDs); values of references given in place of an ID that
  # match this pattern are used as IDs, others are resolved as names
  id_regexp = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
}
