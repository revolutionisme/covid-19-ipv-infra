gcloud services enable cloudbuild.googleapis.com compute.googleapis.com sqladmin.googleapis.com
export GOOGLE_APPLICATION_CREDENTIALS=covid-19-ipv-sa.json
terraform plan
terraform apply
