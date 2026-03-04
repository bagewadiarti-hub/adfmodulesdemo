terraform {
  backend "azurerm" {
    resource_group_name  = "tf-rg"
    storage_account_name = "tfstorageprod177"
    container_name       = "tfstate"
    key                  = "adf-${terraform.workspace}.tfstate"
  }
}
