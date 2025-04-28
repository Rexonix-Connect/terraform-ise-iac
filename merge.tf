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
  # user defaults merged with module defaults in data.utils_deep_merge_yaml.defaults below
  # these defaults are part of user provided model data under root key "defaults"
  user_defaults = { "defaults" : try(yamldecode(data.utils_deep_merge_yaml.model.output)["defaults"], {}) }
  # output of data.utils_deep_merge_yaml.defaults below
  defaults      = yamldecode(data.utils_deep_merge_yaml.defaults.output)["defaults"]
  # output of data.utils_deep_merge_yaml.model.output below
  model         = yamldecode(data.utils_deep_merge_yaml.model.output)
}

# Merge all model sources into a single model
data "utils_deep_merge_yaml" "model" {
  input = concat( # join lists into one
    local.yaml_strings_directories,
    local.yaml_strings_files,
    local.model_strings
  )

  lifecycle {
    precondition {
      condition     = length(var.yaml_directories) != 0 || length(var.yaml_files) != 0 || length(keys(var.model)) != 0
      error_message = "Either `yaml_directories`,`yaml_files` or a non-empty `model` value must be provided."
    }
  }
}

# Merge the module's ise_defaults.yaml file with the user-provided defaults in model yaml files
# User-provided defaults override the module's defaults
data "utils_deep_merge_yaml" "defaults" {
  input = [
    file("${path.module}/defaults/ise_defaults.yaml"),
    yamlencode(local.user_defaults)
  ]
}
