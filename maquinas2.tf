provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "Zsedcx.qwerty.123"
  vsphere_server = "vcenter.cloud.local"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = "Escuela"
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "pruebas"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = "172.19.2.104"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "DS_104"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "VLAN_102"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "vm-one"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "pruebas" {
  name             = "pruebas"
  num_cpus         = 2
  memory           = 4096
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Use a predefined vmware template has main disk
  disk {
    name = "pruebas.vmdk"
    size = "30"
    thin_provisioned = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "pruebas"
        domain    = "test.internal"
      }

      network_interface {
        ipv4_address    = "172.19.2.36"
        ipv4_netmask    = 24
        dns_server_list = ["8.8.8.8", "8.8.4.4"]
      }

      ipv4_gateway = "172.19.2.1"
    }
  }

  # Execute script on remote vm after this creation
  # Execute script on remote vm after this creation
#   provisioner "remote-exec" {
#     inline = [
#       "ping 172.19.2.1 -c 3 ",
#     ]
#   }
}