variable "project_id" {}
variable "region" {}
# variable "environment" {}
# variable "vm_size" {}
# variable "disk_size" {}
# variable "config_file" {
#   description = "Path to YAML config file"
#   type        = string
# }

variable "environment" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "config_file" {
  type = string
}
