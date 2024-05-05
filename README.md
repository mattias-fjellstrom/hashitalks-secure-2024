# HashiTalks Secure 2024

This repository contains sample Terraform configuration for setting up HCP Boundary with HCP Vault for securely accessing resources in AWS.

## Summary

This sample sets up a VPC in AWS with a public and a private subnet. In the private subnet an EC2 instance and a serverless Aurora cluster is set up. In both of the subnets a Boundary worker EC2 instance is deployed. An HCP Boundary cluster and an HCP Vault cluster is also set up. The HCP Vault cluster is placed in a HVN that is peered with the AWS VPC to provide private access to Vault from AWS.

## Instructions

Follow the steps below to set up the sample infrastructure.

1. Go to the [01](./01/) directory and create a file named `<something>.auto.tfvars` (e.g. `main.auto.tfvars`) with the following content:
    ```hcl
    aws_region                  = "eu-central-1" # see variables.tf for valid regions
    aws_vpc_cidr_block          = "10.0.0.0/16" # replace if you want
    hcp_boundary_admin_password = "MySecretPasswordForBoundary123" # replace me
    hcp_virtual_network_cidr    = "192.168.100.0/24" # replace if you want (must not coincide with the aws_vpc_cidr_block variable)
1. While in the [01](./01/) directory run `terraform apply`, the apply will take approximately 10 minutes.
1. Go to the [02](./02/) directory and create a file named `<something>.auto.tfvars` (e.g. `main.auto.tfvars`) with the following content:
    ```hcl
    aws_rds_master_password     = "MySecretPasswordForRdsDatabase123" # replace me
    aws_region                  = "eu-central-1" # use same values as in the first Terraform configuration
    entra_id_domain             = "<your custom domain>" # your Entra ID custom domain name
    github_organization         = "<organization name>" # name of your github organization
    hcp_boundary_admin_password = "MySecretPasswordForBoundary123" # use same values as in the first Terraform configuration
    hcp_virtual_network_cidr    = "192.168.100.0/24" # use same values as in the first Terraform configuration
    hcp_vault_admin_token       = "<token from ../01/vault.env>"
    ```
1. While in the [02](./02/) directory run `terraform apply`, the apply will take approximately 15 minutes.

## Cleanup

Note, due to an issue with the Vault database secrets engine you must manually clear away any leases and disable the secrets engine before you run `terraform destroy`.

1. Export the values from [01/vault.env](./01/vault.env) as environment variables.
1. Run `vault lease revoke -force -prefix database/`
1. Run `vault secrets disable database`

Now you can proceed with destroying the infrastructure:

1. While in the [02](./02) directory, run `terraform destroy`. Wait for the destroy operation to finish.
1. Go to the [01](./01) directory and run `terraform destroy`. Wait for the destroy operation to finish.

Remove any other resources you no longer need (AWS credentials, GitHub repos, Entra ID users, etc.)