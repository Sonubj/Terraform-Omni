#==============================================================================================================================
#========================================================OMNI-SCRIPT==========================================================
#============================================================================================================================

#Configure the Azure provider

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}



#===============================================================================================================================
#=============================================AUNTHENICATE USING SERVICE PRINCIPAL==============================================
#==============================================================================================================================

provider "azurerm" {

  skip_provider_registration = true
  subscription_id = "848a9243-4d4c-402b-8c7f-0b6d29ae6a6a"
  client_id       = "2b7a82bb-a914-4b80-8e0a-42c7f752e4a9"
  client_secret   = "g.j8Q~IdKKUOFr0P-MEgMUk~drOeIgF~KSUjgajM"
  tenant_id       = "53f9d213-5534-4788-ac8a-56e81fb1cbc6"
  features{}

}




#=============================================================================================================================
#===========================================USE EXISTING RESOURCE-GROUP========================================================
#==============================================================================================================================

data "azurerm_resource_group" "test" {
  name     = var.resource_group
}

#==============================================================================================================================
#=================================================CREATION OF VNET=============================================================
#===============================================================================================================================

#creating vnet

resource "azurerm_virtual_network" "vnet" {
  name = var.Vnet_name
  address_space       = var.vnet_address_space_range
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
}

#===============================================================================================================================
#===============================================CREATION OF SUBNETS(5)==========================================================
#===============================================================================================================================

#creating default subnet

resource "azurerm_subnet" "default_subnet" {
  name = "default"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]


}

#creating 1st subnet

resource "azurerm_subnet" "subnet1" {
  name = "vnet-sn-apim-uat"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_address_prefixes_range
}

#creating 2nd subnet

resource "azurerm_subnet" "subnet2" {
  name = "vnet-sn-cosmos-pe"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet2_address_prefixes_range
}

#creating 3rd subnet

resource "azurerm_subnet" "subnet3" {
  name = "vnet-sn-mssql-pe"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet3_address_prefixes_range
}

#creating 4th subnet

resource "azurerm_subnet" "subnet4" {
  name = "vnet-sn-redis-pe"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet4_address_prefixes_range
}

#creating 5th subnet

resource "azurerm_subnet" "subnet5" {
  name = "vnet-sn-webapp-uat"
  resource_group_name  = "${data.azurerm_resource_group.test.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet5_address_prefixes_range
}



#===============================================================================================================================
#============================================CREATION OF PUBLIC IP==============================================================
#===============================================================================================================================



#creating public IP for bastion

resource "azurerm_public_ip" "omnipip" {
  name = var.public_ip
  location = "${data.azurerm_resource_group.test.location}"
  resource_group_name= "${data.azurerm_resource_group.test.name}"
  allocation_method = "Static"
  sku               = "Standard"
}




#==============================================================================================================================
#============================================CREATION OF REDIS CACHE===========================================================
#===============================================================================================================================


#Creating Redis-Cache

resource "azurerm_redis_cache" "example" {
  name = var.rediscache_name
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  public_network_access_enabled = false

  redis_configuration {
  }
}


#===============================================================================================================================
#===========================================CREATION OF COSMOS DB ACCOUNT=======================================================
#===============================================================================================================================


#creating cosmos db-account

resource "azurerm_cosmosdb_account" "example" {
  name                      = var.cosmosdb_account_name
  location                  = "${data.azurerm_resource_group.test.location}"
  resource_group_name       = "${data.azurerm_resource_group.test.name}"
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
  }
  geo_location{
    location = "${data.azurerm_resource_group.test.location}"
    failover_priority = 0
  }
}


#===============================================================================================================================
#============================================CREATION OF ACR REGISTRY===========================================================
#===============================================================================================================================

#Creating container registry

resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = "${data.azurerm_resource_group.test.name}"
  location                 = "${data.azurerm_resource_group.test.location}"
  sku                      = "Basic"
  admin_enabled            = true
}

#==============================================================================================================================
#========================================CREATION OF API MANAGEMENT=============================================================
#===============================================================================================================================

#Creating API Managment

resource "azurerm_api_management" "example" {
  name                = "omni-uat-apim"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"

  sku_name = "Developer_1"
}

#===============================================================================================================================
#==================================================CREATION OF STORAGE ACCOUNT==================================================
#==============================================================================================================================

#Creating storage account
resource "azurerm_storage_account" "example" {
  name                     = var.storageaccount_name
  resource_group_name      = "${data.azurerm_resource_group.test.name}"
  location                 = "${data.azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


#Creating blob containers

#resource "azurerm_storage_container" "{Blob}" {
#  name                  = "{Blob}"
#  storage_account_name  = azurerm_storage_account.example.name
#  container_access_type = "private"
#}

#===============================================================================================================================
#==================================================CREATION OF APP SERVICE PLAN================================================
#===============================================================================================================================

#Creating of app service plan
resource "azurerm_app_service_plan" "example" {
  name                = "testservice"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "P1v3"
  }
}

#===============================================================================================================================
#==================================================CREATION OF APP SERVICES================================================
#===============================================================================================================================


# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "${var.app_service_object[count.index]}-azure-web"
  count                 = 12
  location              = "${data.azurerm_resource_group.test.location}"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
  service_plan_id       = azurerm_app_service_plan.example.id
  https_only            = true


site_config {
    always_on      = "true"

    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/myimage"
      docker_image_tag = "latest"
      dotnet_version   = "6.0"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    # Settings for private Container Registires
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password

  }

}



#===============================================================================================================================
#=====================================CREATION OF FUNCTION APP=================================================================
#==============================================================================================================================

#Creating of function app

resource "azurerm_function_app" "example" {
  name                       = "function1omni"
  location                   = "${data.azurerm_resource_group.test.location}"
  resource_group_name        = "${data.azurerm_resource_group.test.name}"
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

site_config {
      always_on                 = true
      linux_fx_version          = "DOCKER|${azurerm_container_registry.acr.login_server}/pingtrigger:test"
    }




  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    # Settings for private Container Registires
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password

  }

}

#===============================================================================================================================
#=========================================CREATION NAT GATEWAY==================================================================
#===============================================================================================================================

#Creating Nat GATEWAY

resource "azurerm_nat_gateway" "example" {
  name                = var.natgateway_name
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  sku_name            = "Standard"
}

#Associating with public IP
resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.example.id
  public_ip_address_id = azurerm_public_ip.omnipip.id

}

#Associating with subnet

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.subnet5.id
  nat_gateway_id = azurerm_nat_gateway.example.id
}

#===============================================================================================================================
#=============================================CREATION OF APPLICATION INSIGHT===================================================
#===============================================================================================================================


#Creating application insight


resource "azurerm_log_analytics_workspace" "example" {
  name                = "workspace-test"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "tf-test-appinsights"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "web"
}

output "instrumentation_key" {
  value = azurerm_application_insights.example.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.example.app_id
  sensitive = true
}


