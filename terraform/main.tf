terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  # Configuration options
  features {
  }
}



resource "azurerm_service_plan" "sp-fleroux" {
  name                = "sp-${var.project_name}${var.environnment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_postgresql_server" "pg-fleroux" {
  name                = "pg-${var.project_name}${var.environnment_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = data.azurerm_key_vault_secret.database-login.value
  administrator_login_password = data.azurerm_key_vault_secret.database-password.value
  version                      = "11"

  ssl_enforcement_enabled      = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  
}

resource "azurerm_postgresql_database" "pgdb-fleroux" {
  name                = var.database_name
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  server_name         = azurerm_postgresql_server.pg-fleroux.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "pgfw-fleroux" {
  name                = "allow-azure-resources"
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  server_name         = azurerm_postgresql_server.pg-fleroux.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_linux_web_app" "web-fleroux" {
  name                = "web-${var.project_name}${var.environnment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.sp-fleroux.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
  }

  app_settings = {
    // env
    "PORT"                      = var.app_port
    "DB_HOST"                   = azurerm_postgresql_server.pg-fleroux.fqdn
    "DB_USERNAME"               = "${data.azurerm_key_vault_secret.database-login.value}@${azurerm_postgresql_server.pg-fleroux.name}"
    "DB_PASSWORD"               = data.azurerm_key_vault_secret.database-password.value
    "DB_DATABASE"               = var.database_name
    "DB_DAILECT"                = "postgres"
    "DB_PORT"                   = var.database_port
    "ACCESS_TOKEN_SECRET"       = data.azurerm_key_vault_secret.access-token.value
    "REFRESH_TOKEN_SECRET"      = data.azurerm_key_vault_secret.refresh-token.value
    "ACCESS_TOKEN_EXPIRY"       = var.access_token_expiry
    "REFRESH_TOKEN_EXPIRY"      = var.refresh_token_expiry
    "REFRESH_TOKEN_COOKIE_NAME" = var.refresh_token_cookie_name
  }


}

resource "azurerm_container_group" "pgadmin" {
  name                = "aci-pgadmin-${var.project_name}${var.environnment_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-pgadmin-${var.project_name}${var.environnment_suffix}"
  os_type             = "Linux"

  container {
    name   = "pgadmin"
    image  = "dpage/pgadmin4:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "PGADMIN_DEFAULT_EMAIL"    = data.azurerm_key_vault_secret.pgadmin-login.value
      "PGADMIN_DEFAULT_PASSWORD" = data.azurerm_key_vault_secret.pgadmin-password.value
    }
  }

  # même si le container pgadmin n'est pas dépendant de postgres, il parait logique de dépendre de la création du serveur postgres
  depends_on = [
    azurerm_postgresql_server.pg-fleroux,
  ]


}

resource "azurerm_container_group" "adminer" {
  name                = "aci-adminer-${var.project_name}${var.environnment_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-adminer-${var.project_name}${var.environnment_suffix}"
  os_type             = "Linux"

  container {
    name   = "adminer"
    image  = "adminer:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  # même si le container pgadmin n'est pas dépendant de postgres, il parait logique de dépendre de la création du serveur postgres
  depends_on = [
    azurerm_postgresql_server.pg-fleroux,
  ]


}