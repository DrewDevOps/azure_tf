# Overview

This Terraform module provisions a basic network infrastructure in
Microsoft Azure. It uses variables and local values to deploy:
- A Resource Group
- A Virtual Network (VNet)
- Multiple Subnets (with auto-generated CIDR ranges)

It is designed to be concise, reusable, and environment-driven, allowing
you to easily deploy into different environments like dev, test, or
prod.

# Resources Deployed

Additionally, the module can deploy and associate Network Security
Groups (NSGs) to each subnet with basic rules.

The following resources are deployed with this module:

  -------------------------------------------------------------------------
  Resource Type           Name Pattern              Description
  ----------------------- ------------------------- -----------------------
  Resource Group          \<env\>-network-rg        Container for network
                                                    resources

  Virtual Network (VNet)  \<env\>-vnet              Virtual network with
                                                    custom address space

  Subnets                 \<env\>-\<name\>-subnet   Auto-CIDR subnets
                                                    dynamically created

  Network Security Group  \<env\>-\<subnet\>-nsg    NSG with default rules
  (NSG)                                             attached to each subnet
  -------------------------------------------------------------------------

# Key Features

- Environment-based naming (e.g., dev-vnet, prod-vnet)
- Dynamic subnet creation with cidrsubnet()
- Index-based subnet CIDR generation to reduce manual input
- Single module that supports multiple subnets per VNet

# Input Variables

  -----------------------------------------------------------------------
  Variable                Type                    Description
  ----------------------- ----------------------- -----------------------
  env                     string                  Name of the environment
                                                  (e.g., dev, prod)

  location                string                  Azure region

  vnet_address_space      list(string)            Address space for the
                                                  VNet

  subnet_names            list(string)            List of subnet names to
                                                  be created
  -----------------------------------------------------------------------

# Example Usage

module \"network\" {\
source = \"./azure_tf\"\
env = \"dev\"\
location = \"East US\"\
vnet_address_space = \[\"10.0.0.0/16\"\]\
subnet_names = \[\"frontend\", \"backend\", \"database\"\]\
}

This will deploy:
- Resource Group: dev-network-rg
- Virtual Network: dev-vnet with address space 10.0.0.0/16
- Subnets:
- dev-frontend-subnet → 10.0.1.0/24
- dev-backend-subnet → 10.0.2.0/24
- dev-database-subnet → 10.0.3.0/24

The subnet CIDRs are derived automatically using cidrsubnet().

# Outputs

  -----------------------------------------------------------------------
  Output                              Description
  ----------------------------------- -----------------------------------
  vnet_id                             The ID of the virtual network

  subnet_ids                          A map of subnet names to their
                                      Azure IDs
  -----------------------------------------------------------------------

# Cleanup

To destroy the resources:

terraform destroy
