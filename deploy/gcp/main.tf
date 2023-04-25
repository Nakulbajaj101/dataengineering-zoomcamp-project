terraform {
  backend "gcs" {
     bucket  = "de-zoomcamp-terraform"
     prefix  = "terraform/state/project-covid.tfstate"
  }
  required_version = "1.3.9"
  
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "4.53.1"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
}

resource "google_storage_bucket" "covid_19_bucket" {
    name = "${local.my_covid_bucket}_${var.project}"
    public_access_prevention = "enforced"
    storage_class = var.storage_class
    uniform_bucket_level_access = true
    location = var.region

    versioning {
      enabled = true
    }

    lifecycle_rule {
      action {
        type = "Delete"
      }
      condition {
        age = var.bucket_age
      }
    }

    force_destroy = true
}

resource "google_storage_bucket" "covid_19_bucket_flows" {
    name = "${local.my_covid_flows_bucket}_${var.project}"
    public_access_prevention = "enforced"
    storage_class = var.storage_class
    uniform_bucket_level_access = true
    location = var.region

    versioning {
      enabled = true
    }

    lifecycle_rule {
      action {
        type = "Delete"
      }
      condition {
        age = var.bucket_age
      }
    }

    force_destroy = true
}

resource "google_storage_bucket_iam_policy" "covid_data_flows_bucket_policy" {
  bucket = google_storage_bucket.covid_19_bucket_flows.name
  policy_data = jsonencode(
            {
               bindings = [
                   {
                       members = [
                           "projectEditor:dataengineeringzoomcamp-2023",
                           "projectOwner:dataengineeringzoomcamp-2023",
                        ]
                       role    = "roles/storage.legacyBucketOwner"
                    },
                   {
                       members = [
                           "projectViewer:dataengineeringzoomcamp-2023",
                           "serviceAccount:de-zoomcamp-project-prefect@dataengineeringzoomcamp-2023.iam.gserviceaccount.com"
                        ]
                       role    = "roles/storage.legacyBucketReader"
                    },
                   {
                       members = [
                           "projectEditor:dataengineeringzoomcamp-2023",
                           "projectOwner:dataengineeringzoomcamp-2023",
                           "serviceAccount:de-zoomcamp-project-prefect@dataengineeringzoomcamp-2023.iam.gserviceaccount.com"
                        ]
                       role    = "roles/storage.legacyBucketWriter"
                    },
                   {
                       members = [
                           "projectViewer:dataengineeringzoomcamp-2023",
                        ]
                       role    = "roles/storage.legacyObjectReader"
                    },
                ]
            }
        )
}


resource "google_storage_bucket_iam_policy" "covid_data_bucket_policy" {
  bucket = google_storage_bucket.covid_19_bucket.name
  policy_data = jsonencode(
            {
               bindings = [
                   {
                       members = [
                           "projectEditor:dataengineeringzoomcamp-2023",
                           "projectOwner:dataengineeringzoomcamp-2023",
                        ]
                       role    = "roles/storage.legacyBucketOwner"
                    },
                   {
                       members = [
                           "projectViewer:dataengineeringzoomcamp-2023",
                           "serviceAccount:de-zoomcamp-project-prefect@dataengineeringzoomcamp-2023.iam.gserviceaccount.com"
                        ]
                       role    = "roles/storage.legacyBucketReader"
                    },
                   {
                       members = [
                           "projectEditor:dataengineeringzoomcamp-2023",
                           "projectOwner:dataengineeringzoomcamp-2023",
                           "serviceAccount:de-zoomcamp-project-prefect@dataengineeringzoomcamp-2023.iam.gserviceaccount.com"
                        ]
                       role    = "roles/storage.legacyBucketWriter"
                    },
                   {
                       members = [
                           "projectViewer:dataengineeringzoomcamp-2023",
                        ]
                       role    = "roles/storage.legacyObjectReader"
                    },
                ]
            }
        )
}

resource "google_bigquery_dataset" "covid_dataset" {
  dataset_id = var.covid_dataset
  description = "This is the covid cases dataset"
  location = var.region
  project = var.project
}

resource "google_bigquery_dataset_iam_member" "covid_data_editor" {
  dataset_id = google_bigquery_dataset.covid_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:de-zoomcamp-project-prefect@dataengineeringzoomcamp-2023.iam.gserviceaccount.com"
}
