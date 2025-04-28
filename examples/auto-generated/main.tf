terraform {
  required_providers {
    ise = {
      source = "CiscoDevNet/ise"
    }
  }
}

provider "ise" {
  username = var.ise_username
  password = var.ise_password
  url      = var.ise_url
  insecure = var.ise_insecure
  
}

module "ise" {
  source  = "../.."
  # source  = "github.com/rexonix-connect/terraform-ise-iac"
  
  # Use the extracted YAML files from the ise-config-extractor
  yaml_directories = ["model-data", "user-defaults"]

}