variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}

variable "resource_group_name" { 
    description = "Name of resource group."
}

variable "cluster_name" {
    description = "value"
}

variable "administrator_login" {
  description = "Username of administrator login."
}

variable "administrator_login_password" {
  description = "Administrator password."
}

variable "db_user" {
  description = "Username of db login."
}

variable "db_user_password" {
  description = "DB user password."
}

variable "db_server_name" {
  description = "Name of database server."
}

variable "db_name" {
  description = "Name of database."
}