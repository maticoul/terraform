terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0"
    }
  }
}

##### Provider
provider "vsphere" {
  user           = var.provider_vsphere_user
  password       = var.provider_vsphere_password
  vsphere_server = var.provider_vsphere_host

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#provider "vsphere" {
#  user                 = "administrator@vsphere.local"
#  password             = "5ecur1p0rtM@"
#  vsphere_server       = "192.168.40.23:9443"
#  allow_unverified_ssl = true
#}

data "vsphere_datacenter" "datacenter" {
  name = var.deploy_vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.deploy_vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.deploy_vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.deploy_vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.guest_vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "master04" {
  name                 = "master04"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cores_per_socket = var.guest_num_cores_per_socket
  num_cpus             = var.guest_num_cpus 
  memory               = var.guest_memory 
#  guest_id             = "other5xLinux64Guest"
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  disk {
    label       = "disk.0"
    size        = "30"
  }
  
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  ovf_deploy {
    allow_unverified_ssl_cert = false
    local_ovf_path            = "/home/securiport/terraform/ova/flatcar_production_vmware_ova.ova"
    disk_provisioning         = "thin"
    ip_protocol               = "IPV4"
    ip_allocation_policy      = "STATIC_MANUAL"
    ovf_network_map = {
      "Network 1" = data.vsphere_network.network.id
      "Network 2" = data.vsphere_network.network.id
    }
  }
  extra_config = {
    "guestinfo.ignition.config.data.encoding" = "base64"
    "guestinfo.ignition.config.data" = "${base64encode(file("./ignition.json"))}"
  }

  connection {
    type        = "ssh"
    host        = "192.168.40.29"
    user        = "securiport"
    password    = "Securiport"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
#      "sleep 60"
      "wget https://downloads.python.org/pypy/pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo tar xf pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo mv pypy3.7-v7.3.3-linux64 /opt/bin/python"
    ]

  } 
}




 
 
  
