# Provider
provider_vsphere_host     = "192.168.40.23:9443"
provider_vsphere_user     = "Administrator@vsphere.local"
provider_vsphere_password = "5ecur1p0rtM@"

# Infrastructure
deploy_vsphere_datacenter = "Datacenter"
deploy_vsphere_cluster    = "K8S"
deploy_vsphere_datastore  = "DATAS SRVK8S01"
deploy_vsphere_network    = "DPG Backend"
deploy_vsphere_host       = "192.168.40.17"

# Guest
guest_vsphere_network = "VM Network"
guest_name_prefix     = "k8s-prod"
guest_template        = "Node-k8s-tmpl"
guest_num_cores_per_socket    = "4"
guest_num_cpus        = "6"
guest_memory          = "4096"
guest_ipv4_netmask    = "24"
guest_ipv4_gateway    = "10.0.0.1"
guest_dns_servers     = "10.0.0.50"
guest_dns_suffix      = "test.corp"
guest_domain          = "test.corp"
guest_ssh_user        = "flatcar"
guest_ssh_password    = "flatcar1!"
guest_ssh_key_private = "~/.ssh/id_rsa"
guest_ssh_key_public  = "~/.ssh/id_rsa.pub"

# Master(s)
master_ips = {
  "0" = "10.0.0.200"
  "1" = "10.0.0.201"
  "2" = "10.0.0.202"
}

# Worker(s)
worker_ips = {
  "0" = "10.0.0..211"
  "1" = "10.0.0.212"
  "2" = "10.0.0.213"
  "3" = "10.0.0..214"
}
