terraform {
  required_version = ">= 1.3.0"

  required_providers {
    ise = {
      source  = "CiscoDevNet/ise"
      version = ">= 0.2.7"
    }
    utils = {
      source = "cloudposse/utils"
      version = ">=1.29.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}
