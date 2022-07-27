data "template_file" "docker_install" {
    template = file("${path.module}/config/docker_install.tmpl.yml")
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "VM-jenkins" {
  name                  = "VM-jenkins"
  location              = var.location
  resource_group_name   = var.resource_group-name
  network_interface_ids = [azurerm_network_interface.network-interface.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "Disks"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "jenkins"
  admin_username                  = "ndthanh"
  disable_password_authentication = true
  custom_data    = base64encode(data.template_file.docker_install.rendered)


  admin_ssh_key {
    username   = "ndthanh"
    public_key = tls_private_key.ssh-key.public_key_openssh
  }
}
