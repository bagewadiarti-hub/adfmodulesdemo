resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_data_factory" "adf" {
  name                = var.adf_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# ---------------------------------
# HTTP Linked Service (v3 Correct - Final)
# ---------------------------------
resource "azurerm_data_factory_linked_service_web" "http_ls" {
  name                = "http-linked-service"
  data_factory_id     = azurerm_data_factory.adf.id
  url                 = "https://jsonplaceholder.typicode.com"
  authentication_type = "Anonymous"
}

# ---------------------------------
# Fetch + Process Pipeline
# ---------------------------------
resource "azurerm_data_factory_pipeline" "fetch_pipeline" {
  name            = "fetch-process-pipeline"
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = jsonencode([
    {
      name = "FetchFromAPI"
      type = "WebActivity"
      typeProperties = {
        url    = "https://jsonplaceholder.typicode.com/posts"
        method = "GET"
      }
    },
    {
      name = "ProcessingStep"
      type = "Wait"
      dependsOn = [
        {
          activity = "FetchFromAPI"
          dependencyConditions = ["Succeeded"]
        }
      ]
      typeProperties = {
        waitTimeInSeconds = 15
      }
    }
  ])
}

# ---------------------------------
# 5 Minute Trigger
# ---------------------------------
resource "azurerm_data_factory_trigger_schedule" "five_min_trigger" {
  name            = "every-5-min-trigger"
  data_factory_id = azurerm_data_factory.adf.id

  frequency = "Minute"
  interval  = 5

  pipeline {
    name = azurerm_data_factory_pipeline.fetch_pipeline.name
  }
}
