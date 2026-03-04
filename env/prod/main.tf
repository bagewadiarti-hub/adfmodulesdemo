module "adf_prod" {
  source = "../../modules/adf"

  resource_group_name = "adf-prod-rg"
  location            = "westus2"
  adf_name            = "adf-prod-arti"
  pipeline_name       = "demo-pipeline"

  activities_json = <<JSON
[
  {
    "name": "WaitActivity",
    "type": "Wait",
    "typeProperties": {
      "waitTimeInSeconds": 30
    }
  }
]
JSON
}
