terraform {
 backend "gcs" {
   bucket  = "qwiklabs-gcp-03-77d50d025fc0"
   prefix  = "tfstate"
 }
}
