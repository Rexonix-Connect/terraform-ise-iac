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
