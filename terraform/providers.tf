###############################################################################
# providers.tf — wersje providerów i backend na Azure Blob Storage
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Stan Terraform przechowywany w Azure Blob Storage
  # (Storage Account stworzony przez bootstrap.sh)
  backend "azurerm" {
    resource_group_name  = "rg-petclinic-tfstate"
    storage_account_name = "stpetclinictfstate"
    container_name       = "tfstate"
    key                  = "petclinic.tfstate"
  }
}

provider "azurerm" {
  features {}
}
