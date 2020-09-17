locals {
  env = "prod"
}

provider "google-beta" {
  credentials = file("covid-19-ipv-sa.json")
  project = var.project
}

module "bucket-data-bucket" {
  source = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"

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
  tier = "db-custom-4-15360"
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