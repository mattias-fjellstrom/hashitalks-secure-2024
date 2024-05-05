# HashiTalks Secure 2024

> This is the accompanying repository for my session **Unlocking Privileged Access Management: HCP Boundary with Terraform** from [HashiTalks Secure 2024](https://events.hashicorp.com/hashitalkssecure).
>
> The setup of my exact demo scenario has many prerequisites for it to be successful, thus you should use this repository as a guide to see how things are set up in Boundary using Terraform. No demo can be directly applicable to your specific real-world scenario, so be inspired but adjust the samples to your situation!

This repository contains sample Terraform configuration for setting up HCP Boundary with HCP Vault for securely accessing resources in AWS.

## Summary

This sample sets up a VPC in AWS with a public and a private subnet. In the private subnet an EC2 instance and a serverless Aurora cluster is set up. In both of the subnets a Boundary worker EC2 instance is deployed. An HCP Boundary cluster and an HCP Vault cluster is also set up. The HCP Vault cluster is placed in a HVN that is peered with the AWS VPC to provide private access to Vault from AWS.

To access the EC2 instance in the private subnet Boundary uses a multi-hop session where the traffic goes through both of the workers. Vault injects an SSH certificate into the session so that the users can successfully SSH into the instance. The users never see the SSH credentials, and the certificates are expired when the session ends.

To access the Aurora instance running in the private subnet Boundary once again uses multi-hop sessions. There are two different targets set up for the Aurora postgres database. The first target is a read target and the other is a write target. For both targets Vault is brokering credentials to the user in the session. Vault configures a user as needed in the database, communicating privately with the database over the peering connection between HCP and AWS. For the read target a read-only user is created and credentials for this user is provided into the session. Likewise, for the write target a user with write-credentials is created and the credentials are provided into the session. Note that in this case Vault is doing credential brokering, and the user is able to see the brokered credentials.
