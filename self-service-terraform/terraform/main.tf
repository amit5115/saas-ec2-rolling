provider "google" {
  project = var.project_id
  region  = var.region
}

# locals {
#   config = yamldecode(file(var.config_file))
#   env    = local.config.environments[var.environment]
# }

locals {
  raw = yamldecode(file(var.config_file))

  environments = {
    for env, cfg in local.raw.environments :
    env => {
      instances = {
        for name, inst in cfg.instances :
        name => {
          zone = inst.zone
          tags = inst.tags
        }
      }
    }
  }

  instances = local.environments[var.environment].instances
}




# resource "google_compute_instance" "vm" {
#   count        = local.env.vm_count
#   name         = "${var.environment}-vm-${count.index}"
#   machine_type = var.vm_size
#   zone         = local.env.zone

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-12"
#       size  = var.disk_size
#     }
#   }

#   network_interface {
#     network = "default"
#     access_config {}
#   }

#   tags = local.env.tags

#   lifecycle {
#     prevent_destroy = false
#   }

#   metadata = {
#     enable-oslogin = "TRUE"
#   }
# }

resource "google_compute_instance" "vm" {
  for_each = local.instances

  name         = each.key
  machine_type = var.vm_size
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = each.value.tags

  lifecycle {
    prevent_destroy = false
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
