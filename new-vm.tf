variable "nsxsegment" {
}

data "vsphere_datacenter" "datacenter" {
  name = "MyLabDC"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.nsxsegment
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu-Web-Template"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "vmfolder" {
  path          = "Web VMs"
}

resource "random_pet" "server" {
    length = 1
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Web-server-${random_pet.server.id}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.vmfolder.path
  num_cpus         = 1
  memory           = 2048
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = "16"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}

