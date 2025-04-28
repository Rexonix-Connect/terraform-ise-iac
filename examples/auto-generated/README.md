# Auto-Generated Example for Terraform ISE Module

This directory contains an auto-generated example for this module. The example demonstrates how to configure Cisco Identity Services Engine (ISE) using Terraform with default and example values auto-generated from terraform-ise-provider template files.

## Overview

The files in this directory were automatically generated using the `gen/generate_module.py` script. These examples are intended to provide a starting point for configuring Cisco ISE with Terraform. These are not recommended values. These are not intended to work.

## Files

- **`main.tf`**: Defines the Terraform provider and module configuration.
- **`variables.tf`**: Declares the input variables required for the example.
- **`terraform.tfvars`**: Provides example values for the input variables.
- **`model-data/`**: Contains YAML files with example configurations for various Cisco ISE components, such as system settings, network resources, network access, identity management, and device administration. This is auto-generated from terraform-ise-provider templates.
- **`user-defaults`**: Contains default user configurations for all resources. This is also auto-generated from terraform-ise-provider templates.

## Usage

1. Ensure you have the Terraform CLI installed.  
2. Update the `terraform.tfvars` file with your Cisco ISE credentials and URL.  
3. Initialize Terraform:  
    ```bash
    terraform init
    ```
4. Validate the configuration:  
    ```bash
    terraform validate
    ```
5. Apply the configuration:  
    ```bash
    terraform apply
    ```
