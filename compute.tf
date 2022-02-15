# Defining VM Volume
resource "libvirt_volume" "compute-qcow2" {
  name = "compute.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./images/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data_compute" {
  template = file("${path.module}/cloud_init/cloud_init_compute.cfg")
}

data "template_file" "network_config_compute" {
  template = file("${path.module}/cloud_init/network_config_compute.cfg")
}


resource "libvirt_cloudinit_disk" "commoninit_compute" {
  name           = "commoninit_compute.iso"
  user_data      = data.template_file.user_data_compute.rendered
  network_config = data.template_file.network_config_compute.rendered
  pool           = "default"
}

# Define KVM domain to create
resource "libvirt_domain" "compute" {
  name   = "compute"
  memory = "12288"
  vcpu   = 12

  cloudinit = libvirt_cloudinit_disk.commoninit_compute.id


  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.compute-qcow2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

