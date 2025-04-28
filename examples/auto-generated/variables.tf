variable "ise_username" {
  description = "ISE username"
  type        = string
  sensitive   = true
}

variable "ise_password" {
  description = "ISE password"
  type        = string
  sensitive   = true
}

variable "ise_url" {
  description = "ISE URL (e.g., https://ise.example.com)"
  type        = string
}

variable "ise_insecure" {
  description = "Set to true to allow insecure connections to ISE"
  type        = bool
  default     = false
}
