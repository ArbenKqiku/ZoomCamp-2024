terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
    }
  }
}

# we are defining the provider, namely the path to the GCP, and we're adding the credentials to access
provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
  zone        = var.location_project
}

# this is the resource that we would like to implement
# demo-bucket is the name for terraform
resource "google_storage_bucket" "demo-bucket" {
  # this name needs to be unique for all GCP buckets in existence, not only years
  # that's why we added the project id before the name, to make it unique
  name          = var.gcs_bucket_name
  location      = var.region_bucket
  force_destroy = true

  /*
condition: The condition block sets the age of the object. In this case, the age is set to 1, 
which typically represents the number of days since the object's creation.
action: The action block specifies the type of action to be taken when the condition is met. 
In this code, the action type is set to "AbortIncompleteMultipartUpload". 
This means that if an incomplete multipart upload has been in progress for the specified age (1 day in this case), 
it will be automatically aborted.
*/

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# create a big query dataset
resource "google_bigquery_dataset" "demo-dataset" {
  dataset_id = var.bq_data_set_name
  location   = var.location_project
}