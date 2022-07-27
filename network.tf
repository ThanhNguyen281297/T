# Create when done exists 
# create group
resource "azurerm_resource_group" "group-asia" {
  name     = "group-asia"
  location = "East Asia"
}


#create virtual network
resource "azurerm_virtual_network" "virtual-network-asia" {
  name                = "virtual-network-asia"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group-name
}

#create subnet
resource "azurerm_subnet" "asia-subnet" {
  name                 = "asia-subnet"
  resource_group_name  = var.resource_group-name
  virtual_network_name = azurerm_virtual_network.virtual-network-asia.name
  address_prefixes     = ["10.0.1.0/24"]
}

# create public IP
resource "azurerm_public_ip" "asia-pubic-ip" {
  name                = "asia-pubic-ip"
  location            = var.location
  resource_group_name = var.resource_group-name
  allocation_method   = "Dynamic"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "network-security" {
  name                = "network-security"
  location            = var.location
  resource_group_name = var.resource_group-name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8989"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins_Out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8989"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "network-interface" {
  name                = "network-interface"
  location            = var.location
  resource_group_name = var.resource_group-name

  ip_configuration {
    name                          = "network-interface-ip"
    subnet_id                     = azurerm_subnet.asia-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.asia-pubic-ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "security-to-network" {
  network_interface_id      = azurerm_network_interface.network-interface.id
  network_security_group_id = azurerm_network_security_group.network-security.id
}

















