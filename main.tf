terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "4.50.0"
      }
    }
}

provider "google" {
  credentials = file("creds.json")
  project = "cd7-gcp-20230124-pablocazallas"
  region = "europe-southwest1"
  zone = "europe-southwest1-a"
}

resource "google_compute_network" "cd7_gcp_vpc_network" {
    name = "cd7-gcp-terranet"
}

resource "google_compute_address" "cd7_gcp_static_address" {
    name = "cd7-gcp-static-address"
}

resource "random_string" "randstr" {
    length = 16
    special = false
    upper = false
}

resource "google_storage_bucket" "cd7_gcp_bucket" {
    name = "cd7-gcp-terrastorage-${random_string.randstr.result}"
    location = "europe-southwest1"   
}

resource "google_compute_instance" "cd7_gcp_vm" {

    depends_on = [
      google_compute_network.cd7_gcp_vpc_network,
      google_compute_address.cd7_gcp_static_address
    ]

    name = "cd7-gcp-terra-vm"
    machine_type = "e2-micro"

    boot_disk {
        auto_delete = false
        mode = "READ_ONLY"
        initialize_params {
          image = "projects/cd7-gcp-20230124-pablocazallas/global/images/cd7-gcp-apache-imagedisk"
        }
    }

    network_interface {
      network = google_compute_network.cd7_gcp_vpc_network.name
      access_config {
        nat_ip = google_compute_address.cd7_gcp_static_address.address
      }
    }

}
