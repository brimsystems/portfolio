variable "location" {
    description = "Project Location"
    default = "US"
}

variable "bq_dataset_name" {
    description = "My BigQuery Dataset Name"
    default = "demo_dataset"
}

variable "gcs_bucket_name" {
    description = "My Storage Bucket Name"
    default = "project-bee6fd45-a594-4900-b80"
}

variable "gcs_storage_class" {
    description = "Bucket Storage Class"
    default = "STANDARD"
}