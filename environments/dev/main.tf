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

# TODO: Setup network configuration to permit application to access db, start with 0.0.0.0
# TODOL Setup biggern instances for DB
module "sql-db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  project_id = var.project
  region = "europe-west3"
  zone   = "a"
  name = "covid-19"
  user_name = "dbadmin"
  db_name = "covid_19_db"
  database_version = "POSTGRES_12"
  version = "3.1.0"
}

resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "covid-19-db-conn-string"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret-basic.id
  secret_data = "postgresql+psycopg2://dbadmin:${module.sql-db.generated_user_password}@${module.sql-db.public_ip_address}:5432/covid_19_db"
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
