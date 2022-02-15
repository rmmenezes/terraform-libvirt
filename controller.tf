# Defining VM Volume
resource "libvirt_volume" "controller-qcow2" {
  name = "controller.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./images/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Defining VM Volume
resource "libvirt_volume" "controller-2-qcow2" {
  name = "controller-2.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  format = "qcow2"
}


data "template_file" "user_data_controller" {
  template = file("${path.module}/cloud_init/cloud_init_controller.cfg")
}

data "template_file" "network_config_controller" {
  template = file("${path.module}/cloud_init//network_config_controller.cfg")
}


resource "libvirt_cloudinit_disk" "commoninit_controller" {
  name           = "commoninit_controller.iso"
  user_data      = data.template_file.user_data_controller.rendered
  network_config = data.template_file.network_config_controller.rendered
  pool           = "default"
}


# Define KVM domain to create
resource "libvirt_domain" "controller" {
  name   = "controller"
  memory = "12288"
  vcpu   = 12

  cloudinit = libvirt_cloudinit_disk.commoninit_controller.id

  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.controller-qcow2.id}"
  }

  disk {
    volume_id = "${libvirt_volume.controller-2-qcow2.id}"
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

