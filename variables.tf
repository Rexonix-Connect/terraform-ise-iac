variable "yaml_directories" {
  description = "List of paths to directories containing YAML model files."
  type        = list(string)
  default     = []
}

variable "yaml_files" {
  description = "List of paths to YAML model files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML model files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
}

variable "write_default_values_file" {
  description = "Write all default values (module and user defaults merged) to a YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}

variable "manage_ranks" {
  description = "Apply the `rank` of rules and policy sets with the provider's bulk rank resources (`ise_*_update_ranks`). When false, ranks in YAML are accepted but not applied, and ISE keeps its order. ISE provider 0.5.0 can copy the conditions of one rule into the next rule while it sets ranks, so set this to false with that provider to leave existing rules untouched."
  type        = bool
  default     = true
}
