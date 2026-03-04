module "adf_dev" {
  source = "../../modules/adf"

  resource_group_name = "adf-dev-rg"
  location            = "westus2"
  adf_name            = "adf-dev-arti"
  pipeline_name       = "demo-pipeline"

  activities_json = <<JSON
[
  {
    "name": "WaitActivity",
    "type": "Wait",
    "typeProperties": {
      "waitTimeInSeconds": 10
    }
  }
]
JSON
}
