
variable "project" {
  description = "hardy-symbol-235210"
}

variable "region" {
  description = "Region"
  default     = "europe-north1"
}

variable "zone" {
  description = "Region"
  default     = "europe-north1-c"
}

variable "public_key_path" {
  description = "/root/.ssh/id_rsa"
}

variable "machine_type" {
  default = "g1-small"
}

variable "disk_size_gb" {
  default = "20"
}

