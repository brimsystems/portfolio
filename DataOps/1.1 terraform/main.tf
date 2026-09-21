terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.23.0"
    }
  }
}

provider "google" {
    credentials = "./keys/my-creds.json"
  project = "project-bee6fd45-a594-4900-b80"
  region  = "us-central1"
}

resource "google_storage_bucket" "terra-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true

    uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "terradataset" {
  dataset_id = var.bq_dataset_name
  location = var.location
}