resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_data_factory" "adf" {
  name                = var.adf_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_data_factory_pipeline" "pipeline" {
  name            = var.pipeline_name
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = var.activities_json
}
