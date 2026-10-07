locals {
  # input from directory containing yaml files
  yaml_strings_directories = flatten([
    for dir in var.yaml_directories : [
      for file in fileset(".", "${dir}/*.{yml,yaml}") : file(file)
    ]
  ])
  # input from yaml files
  yaml_strings_files = [
    for file in var.yaml_files : file(file)
  ]
  # input from model string
  model_strings = length(keys(var.model)) != 0 ? [yamlencode(var.model)] : []
  # all model sources merged into a single model
  model = yamldecode(provider::utils::yaml_merge(concat(
    local.yaml_strings_directories,
    local.yaml_strings_files,
    local.model_strings
  )))
  # user defaults are part of user provided model data under root key "defaults"
  user_defaults = { "defaults" : try(local.model["defaults"], {}) }
  # module defaults (defaults/ise_defaults.yaml) merged with user defaults,
  # user defaults override the module defaults
  defaults_string = provider::utils::yaml_merge([
    file("${path.module}/defaults/ise_defaults.yaml"),
    yamlencode(local.user_defaults)
  ])
  defaults = yamldecode(local.defaults_string)["defaults"]
}

# Optionally write all default values (module and user defaults merged) to a file
resource "local_sensitive_file" "defaults" {
  count    = var.write_default_values_file != "" ? 1 : 0
  content  = local.defaults_string
  filename = var.write_default_values_file
}

resource "terraform_data" "validation" {
  lifecycle {
    precondition {
      condition     = length(var.yaml_directories) != 0 || length(var.yaml_files) != 0 || length(keys(var.model)) != 0
      error_message = "Either `yaml_directories`,`yaml_files` or a non-empty `model` value must be provided."
    }
  }
}
