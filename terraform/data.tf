data "azurerm_resource_group" "rg-fleroux" {
  name = "rg-${var.project_name}${var.environnment_suffix}"
}

data "azurerm_key_vault" "kv-fleroux" {
  resource_group_name = data.azurerm_resource_group.rg-fleroux.name
  name = "kv-${var.project_name}"
}

data "azurerm_key_vault_secret" "database-login" {
  name         = "database-login"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}
data "azurerm_key_vault_secret" "database-password" {
  name         = "database-password"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}

data "azurerm_key_vault_secret" "pgadmin-login" {
  name         = "pgadmin-login"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}
data "azurerm_key_vault_secret" "pgadmin-password" {
  name         = "pgadmin-password"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}


data "azurerm_key_vault_secret" "access-token" {
  name         = "access-token"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}
data "azurerm_key_vault_secret" "refresh-token" {
  name         = "refresh-token"
  key_vault_id = data.azurerm_key_vault.kv-fleroux.id
}


