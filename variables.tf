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
