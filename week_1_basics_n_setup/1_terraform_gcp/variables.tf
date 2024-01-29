variable "credentials" {
    default = "my-creds.json"
}

variable "project_id" {
    default = "terraform-412318"
}

variable "location_project" {
  default = "europe-west6"
}

variable "region" {
  default = "europe-west"
}

variable "region_bucket" {
    default = "EUROPE-WEST6"
}

variable "bq_data_set_name" {
  description = "Name of the BigQuery data set"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  default = "terraform-412318-demo-bucket"
}

variable "gcs_storage_class" {
  default = "STANDARD"
}