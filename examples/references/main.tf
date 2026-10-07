terraform {
  required_providers {
    ise = {
      source = "CiscoDevNet/ise"
    }
  }
}

# Connection details are read from the ISE_URL, ISE_USERNAME and ISE_PASSWORD
# environment variables
provider "ise" {}

module "ise" {
  source = "../.."

  yaml_files = ["ise.yaml"]
}
