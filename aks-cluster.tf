resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = var.resource_group_name
  location = "westus"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B4ms"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_postgresql_server" "postgres" {
  name                = var.db_server_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  version                      = "11"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "postgres_db" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.default.name
  server_name         = azurerm_postgresql_server.postgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  provisioner "local-exec" {
    command = "sh setup_db.sh $USERNAME $PASSWORD $SERVER $DB $USERTOCREATE $USERPASSWORD"
    interpreter = ["/usr/bin/env", "bash", "-c"]
    environment = {
      USERNAME = var.administrator_login
      PASSWORD = var.administrator_login_password
      SERVER = var.db_server_name
      DB = var.db_name
      USERTOCREATE = var.db_user
      USERPASSWORD = var.db_user_password
    }
  }
}