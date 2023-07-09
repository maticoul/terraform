terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0"
    }
  }
}

provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "5ecur1p0rtM@"
  vsphere_server       = "192.168.40.23:9443"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "Securiport"
}

data "vsphere_datastore" "datastore" {
  name          = "DATAS"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Securiport"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "192.168.40.17"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "master01" {
  name                 = "master01"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cores_per_socket = 3
  num_cpus             = 6
  memory               = 4096
  #guest_id             = "other5xLinux64Guest"
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
    "guestinfo.ignition.config.data" = "ewogICJpZ25pdGlvbiI6IHsKICAgICJjb25maWciOiB7fSwKICAgICJ0aW1lb3V0cyI6IHt9LAogICAgInZlcnNpb24iOiAiMi4xLjAiCiAgfSwKICAibmV0d29ya2QiOiB7CiAgICAidW5pdHMiOiBbCiAgICAgIHsKICAgICAgICAiY29udGVudHMiOiAiW01hdGNoXVxuTmFtZT1lbnMxOTJcblxuW05ldHdvcmtdXG5ETlM9OC44LjguOFxuQWRkcmVzcz0xOTIuMTY4LjQwLjI4LzI0XG5HYXRld2F5PTE5Mi4xNjguNDAuMSIsCiAgICAgICAgIm5hbWUiOiAiMDAtZW5zMzIubmV0d29yayIKICAgICAgfQogICAgXQogIH0sCiAgInBhc3N3ZCI6IHsKICAgICJ1c2VycyI6IFsKICAgICAgewogICAgICAgICJuYW1lIjogInNlY3VyaXBvcnQiLAogICAgICAgICJwYXNzd29yZEhhc2giOiAiJDEkS3JQLlk2bDEkMlhPWXRNN3Y1NEJ2WVl1SE01NkxzLiIsCiAgICAgICAgInNzaEF1dGhvcml6ZWRLZXlzIjogWwogICAgICAgICAgInNzaC1yc2EgQUFBQUIzTnphQzF5YzJFQUFBQURBUUFCQUFBQ0FRRHJYUytBVm05UGFsWDh1TW5yaG4zbWI3Z09uK1FSSlZjUWloZ2xRUGYyQkYrenMzRmdkZ1VPeVR1Rm43N3F0dTFnU0ZNeTdYNVMwM3RBRUxOU2txcHlUNkVwUVgwRW4xUzEycGUvT1dWcGZmclNZejVFaDQ3VW5Xbk9jWDQwUkVpYk0zenBxZmE0OFIyd0NTSlpsbWEyOFA5amZrU09mK1E2bzRGcGwxblk1bnRsK0pma0F4RjNVZzhjMzRWZHdRMHhaNUhLREVma24ybjQ5K3h0U3NEdHVzZlNUVzluQytnV25BTzBWYVB2aE1sTVRVVkpscmJZUWEyb2Vvb1FSVTBPdXRLU3NqWk12Y3Q0Zjd1RUo4T09UcVlqVzlReWhPSEtFakpMVDJvZW5HeXJQc0prd3krTVhLRFdxajEwelFNRVJadkUyT3g4dkprQXlyMWQ3RFVtUzl3NHBYdlBXSWR5ZGcxUnphUTljcjM4enZhcmY0QzRtNVNBc2NvdDdvSFVDRVVsN0FFUkxzVlRBQ0hPOU9IRXdJc3VMcGVFcFNPd3V3QlhZTXE2dWZ2T2tML0ZYVzR4Wi94Q2RuZHI2dnJhU3l3eXQ0Y1JvZGw2M3lYWEk4enNaQXI1a0g5UTBGeEw4aUlybzRTa09VRkRwMUNWREJBY3Y1dWcxUWFWZjg0SnlqY3FmY3FreEJaVHc5Z2FBWUVxcFdaeWNFVEl6ZUFUaTlzZWRBOUkzVGdvV0tRajFROXBCdzFVUmp6UVR0UWhpc3kvdzJtOUJudnZ6aWNTS3p4UERudktyWmJCUjJBUytCcjVJcjJta3BJQnBaUjA2UE5XMitYT2NlTWZrK3gvUkhCU3JWaWNqdUl1TEEwcmM3REhZZVdHTEEwNk5jMTA3NXZiQ0NtaDZ3PT0gc2VjdXJpcG9ydEBwc29ubyIKICAgICAgICBdLAogICAgICAgICJncm91cHMiOiBbCiAgICAgICAgICAic3VkbyIsCiAgICAgICAgICAiZG9ja2VyIgogICAgICAgIF0sCiAgICAgICAgInNoZWxsIjogIi9iaW4vYmFzaCIKICAgICAgfQogICAgXQogIH0sCiAgInN0b3JhZ2UiOiB7CiAgICAiZmlsZXMiOiBbCiAgICAgIHsKICAgICAgICAiZmlsZXN5c3RlbSI6ICJyb290IiwKICAgICAgICAib3ZlcndyaXRlIjogdHJ1ZSwKICAgICAgICAicGF0aCI6ICIvZXRjL2hvc3RuYW1lIiwKICAgICAgICAiY29udGVudHMiOiB7CiAgICAgICAgICAic291cmNlIjogImRhdGE6LGV0Y2QwNiIKICAgICAgICB9LAogICAgICAgICJtb2RlIjogNDIwCiAgICAgIH0KICAgIF0KICB9Cn0="
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
      "wget https://downloads.python.org/pypy/pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo tar xf pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo mv pypy3.7-v7.3.3-linux64 /opt/bin/python"
    ]

  }

}


## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "etcd07" {
  name                 = "flatcar01"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cores_per_socket = 3
  num_cpus             = 6
  memory               = 4096
  guest_id             = "other5xLinux64Guest"
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
      "guestinfo.ignition.config.data" = "ewogICJpZ25pdGlvbiI6IHsKICAgICJjb25maWciOiB7fSwKICAgICJ0aW1lb3V0cyI6IHt9LAogICAgInZlcnNpb24iOiAiMi4xLjAiCiAgfSwKICAibmV0d29ya2QiOiB7CiAgICAidW5pdHMiOiBbCiAgICAgIHsKICAgICAgICAiY29udGVudHMiOiAiW01hdGNoXVxuTmFtZT1lbnMxOTJcblxuW05ldHdvcmtdXG5ETlM9OC44LjguOFxuQWRkcmVzcz0xOTIuMTY4LjQwLjI5LzI0XG5HYXRld2F5PTE5Mi4xNjguNDAuMSIsCiAgICAgICAgIm5hbWUiOiAiMDAtZW5zMzIubmV0d29yayIKICAgICAgfQogICAgXQogIH0sCiAgInBhc3N3ZCI6IHsKICAgICJ1c2VycyI6IFsKICAgICAgewogICAgICAgICJuYW1lIjogInNlY3VyaXBvcnQiLAogICAgICAgICJwYXNzd29yZEhhc2giOiAiJDEkS3JQLlk2bDEkMlhPWXRNN3Y1NEJ2WVl1SE01NkxzLiIsCiAgICAgICAgInNzaEF1dGhvcml6ZWRLZXlzIjogWwogICAgICAgICAgInNzaC1yc2EgQUFBQUIzTnphQzF5YzJFQUFBQURBUUFCQUFBQ0FRRHJYUytBVm05UGFsWDh1TW5yaG4zbWI3Z09uK1FSSlZjUWloZ2xRUGYyQkYrenMzRmdkZ1VPeVR1Rm43N3F0dTFnU0ZNeTdYNVMwM3RBRUxOU2txcHlUNkVwUVgwRW4xUzEycGUvT1dWcGZmclNZejVFaDQ3VW5Xbk9jWDQwUkVpYk0zenBxZmE0OFIyd0NTSlpsbWEyOFA5amZrU09mK1E2bzRGcGwxblk1bnRsK0pma0F4RjNVZzhjMzRWZHdRMHhaNUhLREVma24ybjQ5K3h0U3NEdHVzZlNUVzluQytnV25BTzBWYVB2aE1sTVRVVkpscmJZUWEyb2Vvb1FSVTBPdXRLU3NqWk12Y3Q0Zjd1RUo4T09UcVlqVzlReWhPSEtFakpMVDJvZW5HeXJQc0prd3krTVhLRFdxajEwelFNRVJadkUyT3g4dkprQXlyMWQ3RFVtUzl3NHBYdlBXSWR5ZGcxUnphUTljcjM4enZhcmY0QzRtNVNBc2NvdDdvSFVDRVVsN0FFUkxzVlRBQ0hPOU9IRXdJc3VMcGVFcFNPd3V3QlhZTXE2dWZ2T2tML0ZYVzR4Wi94Q2RuZHI2dnJhU3l3eXQ0Y1JvZGw2M3lYWEk4enNaQXI1a0g5UTBGeEw4aUlybzRTa09VRkRwMUNWREJBY3Y1dWcxUWFWZjg0SnlqY3FmY3FreEJaVHc5Z2FBWUVxcFdaeWNFVEl6ZUFUaTlzZWRBOUkzVGdvV0tRajFROXBCdzFVUmp6UVR0UWhpc3kvdzJtOUJudnZ6aWNTS3p4UERudktyWmJCUjJBUytCcjVJcjJta3BJQnBaUjA2UE5XMitYT2NlTWZrK3gvUkhCU3JWaWNqdUl1TEEwcmM3REhZZVdHTEEwNk5jMTA3NXZiQ0NtaDZ3PT0gc2VjdXJpcG9ydEBwc29ubyIKICAgICAgICBdLAogICAgICAgICJncm91cHMiOiBbCiAgICAgICAgICAic3VkbyIsCiAgICAgICAgICAiZG9ja2VyIgogICAgICAgIF0sCiAgICAgICAgInNoZWxsIjogIi9iaW4vYmFzaCIKICAgICAgfQogICAgXQogIH0sCiAgInN0b3JhZ2UiOiB7CiAgICAiZmlsZXMiOiBbCiAgICAgIHsKICAgICAgICAiZmlsZXN5c3RlbSI6ICJyb290IiwKICAgICAgICAib3ZlcndyaXRlIjogdHJ1ZSwKICAgICAgICAicGF0aCI6ICIvZXRjL2hvc3RuYW1lIiwKICAgICAgICAiY29udGVudHMiOiB7CiAgICAgICAgICAic291cmNlIjogImRhdGE6LGV0Y2QwNyIKICAgICAgICB9LAogICAgICAgICJtb2RlIjogNDIwCiAgICAgIH0KICAgIF0KICB9Cn0="
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
      "wget https://downloads.python.org/pypy/pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo tar xf pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo mv pypy3.7-v7.3.3-linux64 /opt/bin/python"
    ]

  }

 }
 
 ## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "etcd07" {
  name                 = "flatcar01"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cores_per_socket = 3
  num_cpus             = 6
  memory               = 4096
  guest_id             = "other5xLinux64Guest"
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
    "guestinfo.ignition.config.data" = "ewogICJpZ25pdGlvbiI6IHsKICAgICJjb25maWciOiB7fSwKICAgICJ0aW1lb3V0cyI6IHt9LAogICAgInZlcnNpb24iOiAiMi4xLjAiCiAgfSwKICAibmV0d29ya2QiOiB7CiAgICAidW5pdHMiOiBbCiAgICAgIHsKICAgICAgICAiY29udGVudHMiOiAiW01hdGNoXVxuTmFtZT1lbnMzMlxuXG5bTmV0d29ya11cbkROUz04LjguOC44XG5BZGRyZXNzPTE5Mi4xNjguNDAuNjAvMjRcbkdhdGV3YXk9MTkyLjE2OC40MC4xIiwKICAgICAgICAibmFtZSI6ICIwMC1lbnMzMi5uZXR3b3JrIgogICAgICB9CiAgICBdCiAgfSwKICAicGFzc3dkIjogewogICAgInVzZXJzIjogWwogICAgICB7CiAgICAgICAgIm5hbWUiOiAic2VjdXJpcG9ydCIsCiAgICAgICAgInBhc3N3b3JkSGFzaCI6ICIkMSRLclAuWTZsMSQyWE9ZdE03djU0QnZZWXVITTU2THMuIiwKICAgICAgICAic3NoQXV0aG9yaXplZEtleXMiOiBbCiAgICAgICAgICAic3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFEclhTK0FWbTlQYWxYOHVNbnJobjNtYjdnT24rUVJKVmNRaWhnbFFQZjJCRit6czNGZ2RnVU95VHVGbjc3cXR1MWdTRk15N1g1UzAzdEFFTE5Ta3FweVQ2RXBRWDBFbjFTMTJwZS9PV1ZwZmZyU1l6NUVoNDdVblduT2NYNDBSRWliTTN6cHFmYTQ4UjJ3Q1NKWmxtYTI4UDlqZmtTT2YrUTZvNEZwbDFuWTVudGwrSmZrQXhGM1VnOGMzNFZkd1EweFo1SEtERWZrbjJuNDkreHRTc0R0dXNmU1RXOW5DK2dXbkFPMFZhUHZoTWxNVFVWSmxyYllRYTJvZW9vUVJVME91dEtTc2paTXZjdDRmN3VFSjhPT1RxWWpXOVF5aE9IS0VqSkxUMm9lbkd5clBzSmt3eStNWEtEV3FqMTB6UU1FUlp2RTJPeDh2SmtBeXIxZDdEVW1TOXc0cFh2UFdJZHlkZzFSemFROWNyMzh6dmFyZjRDNG01U0FzY290N29IVUNFVWw3QUVSTHNWVEFDSE85T0hFd0lzdUxwZUVwU093dXdCWFlNcTZ1ZnZPa0wvRlhXNHhaL3hDZG5kcjZ2cmFTeXd5dDRjUm9kbDYzeVhYSTh6c1pBcjVrSDlRMEZ4TDhpSXJvNFNrT1VGRHAxQ1ZEQkFjdjV1ZzFRYVZmODRKeWpjcWZjcWt4QlpUdzlnYUFZRXFwV1p5Y0VUSXplQVRpOXNlZEE5STNUZ29XS1FqMVE5cEJ3MVVSanpRVHRRaGlzeS93Mm05Qm52dnppY1NLenhQRG52S3JaYkJSMkFTK0JyNUlyMm1rcElCcFpSMDZQTlcyK1hPY2VNZmsreC9SSEJTclZpY2p1SXVMQTByYzdESFllV0dMQTA2TmMxMDc1dmJDQ21oNnc9PSBzZWN1cmlwb3J0QHBzb25vIgogICAgICAgIF0sCiAgICAgICAgImdyb3VwcyI6IFsKICAgICAgICAgICJzdWRvIiwKICAgICAgICAgICJkb2NrZXIiCiAgICAgICAgXSwKICAgICAgICAic2hlbGwiOiAiL2Jpbi9iYXNoIgogICAgICB9CiAgICBdCiAgfSwKICAic3RvcmFnZSI6IHsKICAgICJmaWxlcyI6IFsKICAgICAgewogICAgICAgICJmaWxlc3lzdGVtIjogInJvb3QiLAogICAgICAgICJvdmVyd3JpdGUiOiB0cnVlLAogICAgICAgICJwYXRoIjogIi9ldGMvaG9zdG5hbWUiLAogICAgICAgICJjb250ZW50cyI6IHsKICAgICAgICAgICJzb3VyY2UiOiAiZGF0YTosZXRjZDAxIgogICAgICAgIH0sCiAgICAgICAgIm1vZGUiOiA0MjAKICAgICAgfQogICAgXQogIH0KfQ=="
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
      "wget https://downloads.python.org/pypy/pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo tar xf pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo mv pypy3.7-v7.3.3-linux64 /opt/bin/python"
    ]

  }
 }
 
 
 
 ## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "etcd07" {
  name                 = "flatcar01"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cores_per_socket = 3
  num_cpus             = 6
  memory               = 4096
  guest_id             = "other5xLinux64Guest"
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  disk {
    label       = "disk0"
    size        = "30"
    thin_provisioned = true
  }
  
#  firmware = "efi" ou "bios"

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
    "guestinfo.ignition.config.data" = "ewogICJpZ25pdGlvbiI6IHsKICAgICJjb25maWciOiB7fSwKICAgICJ0aW1lb3V0cyI6IHt9LAogICAgInZlcnNpb24iOiAiMi4xLjAiCiAgfSwKICAibmV0d29ya2QiOiB7CiAgICAidW5pdHMiOiBbCiAgICAgIHsKICAgICAgICAiY29udGVudHMiOiAiW01hdGNoXVxuTmFtZT1lbnMxOTJcblxuW05ldHdvcmtdXG5ETlM9OC44LjguOFxuQWRkcmVzcz0xOTIuMTY4LjQwLjMwLzI0XG5HYXRld2F5PTE5Mi4xNjguNDAuMSIsCiAgICAgICAgIm5hbWUiOiAiMDAtZW5zMzIubmV0d29yayIKICAgICAgfQogICAgXQogIH0sCiAgInBhc3N3ZCI6IHsKICAgICJ1c2VycyI6IFsKICAgICAgewogICAgICAgICJuYW1lIjogInNlY3VyaXBvcnQiLAogICAgICAgICJwYXNzd29yZEhhc2giOiAiJDEkS3JQLlk2bDEkMlhPWXRNN3Y1NEJ2WVl1SE01NkxzLiIsCiAgICAgICAgInNzaEF1dGhvcml6ZWRLZXlzIjogWwogICAgICAgICAgInNzaC1yc2EgQUFBQUIzTnphQzF5YzJFQUFBQURBUUFCQUFBQ0FRRHJYUytBVm05UGFsWDh1TW5yaG4zbWI3Z09uK1FSSlZjUWloZ2xRUGYyQkYrenMzRmdkZ1VPeVR1Rm43N3F0dTFnU0ZNeTdYNVMwM3RBRUxOU2txcHlUNkVwUVgwRW4xUzEycGUvT1dWcGZmclNZejVFaDQ3VW5Xbk9jWDQwUkVpYk0zenBxZmE0OFIyd0NTSlpsbWEyOFA5amZrU09mK1E2bzRGcGwxblk1bnRsK0pma0F4RjNVZzhjMzRWZHdRMHhaNUhLREVma24ybjQ5K3h0U3NEdHVzZlNUVzluQytnV25BTzBWYVB2aE1sTVRVVkpscmJZUWEyb2Vvb1FSVTBPdXRLU3NqWk12Y3Q0Zjd1RUo4T09UcVlqVzlReWhPSEtFakpMVDJvZW5HeXJQc0prd3krTVhLRFdxajEwelFNRVJadkUyT3g4dkprQXlyMWQ3RFVtUzl3NHBYdlBXSWR5ZGcxUnphUTljcjM4enZhcmY0QzRtNVNBc2NvdDdvSFVDRVVsN0FFUkxzVlRBQ0hPOU9IRXdJc3VMcGVFcFNPd3V3QlhZTXE2dWZ2T2tML0ZYVzR4Wi94Q2RuZHI2dnJhU3l3eXQ0Y1JvZGw2M3lYWEk4enNaQXI1a0g5UTBGeEw4aUlybzRTa09VRkRwMUNWREJBY3Y1dWcxUWFWZjg0SnlqY3FmY3FreEJaVHc5Z2FBWUVxcFdaeWNFVEl6ZUFUaTlzZWRBOUkzVGdvV0tRajFROXBCdzFVUmp6UVR0UWhpc3kvdzJtOUJudnZ6aWNTS3p4UERudktyWmJCUjJBUytCcjVJcjJta3BJQnBaUjA2UE5XMitYT2NlTWZrK3gvUkhCU3JWaWNqdUl1TEEwcmM3REhZZVdHTEEwNk5jMTA3NXZiQ0NtaDZ3PT0gc2VjdXJpcG9ydEBwc29ubyIKICAgICAgICBdLAogICAgICAgICJncm91cHMiOiBbCiAgICAgICAgICAic3VkbyIsCiAgICAgICAgICAiZG9ja2VyIgogICAgICAgIF0sCiAgICAgICAgInNoZWxsIjogIi9iaW4vYmFzaCIKICAgICAgfQogICAgXQogIH0sCiAgInN0b3JhZ2UiOiB7CiAgICAiZmlsZXMiOiBbCiAgICAgIHsKICAgICAgICAiZmlsZXN5c3RlbSI6ICJyb290IiwKICAgICAgICAib3ZlcndyaXRlIjogdHJ1ZSwKICAgICAgICAicGF0aCI6ICIvZXRjL2hvc3RuYW1lIiwKICAgICAgICAiY29udGVudHMiOiB7CiAgICAgICAgICAic291cmNlIjogImRhdGE6LGV0Y2QwOCIKICAgICAgICB9LAogICAgICAgICJtb2RlIjogNDIwCiAgICAgIH0KICAgIF0KICB9Cn0="  
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
      "wget https://downloads.python.org/pypy/pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo tar xf pypy3.7-v7.3.3-linux64.tar.bz2",
      "sudo mv pypy3.7-v7.3.3-linux64 /opt/bin/python"
    ]

  }

}
 
 
  