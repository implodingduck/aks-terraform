variable "subscription_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "location" {
  type    = string
  default = "East US"
}

variable "cluster_admin_oids" {
  type = list(any)
}
