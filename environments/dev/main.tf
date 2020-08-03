# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
  env = "dev"
}

provider "google" {
  project = var.project
  credentials = "covid-19-ipv-sa.json"
}


module "bucket-data-bucket" {
  # source  = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v1.6.0"
  source = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "1.6.0"

  name       = "covid-19-ipv-data"
  project_id = var.project
  location   = "europe-west3"
  versioning = "true"
  # iam_members = [{
  #   role   = "roles/storage.viewer"
  #   member = "user:example-user@example.com"
  # }]
}

module "sql-db" {
  project_id = var.project
  region = "europe-west3"
  zone   = "a"
  database_version = "12"
  name = "covid-19-db-test-0"
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "3.1.0"
}

# module "vpc" {
#   source  = "../../modules/vpc"
#   project = var.project
#   env     = local.env
# }

# module "http_server" {
#   source  = "../../modules/http_server"
#   project = var.project
#   subnet  = module.vpc.subnet
# }

# module "firewall" {
#   source  = "../../modules/firewall"
#   project = var.project
#   subnet  = module.vpc.subnet
# }
