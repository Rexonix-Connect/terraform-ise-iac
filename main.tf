locals {
  # Alias to user-provided model data processed in merge.tf
  ise = try(local.model.ise, {})
}
