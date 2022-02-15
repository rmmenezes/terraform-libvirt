# Defining VM Volume
resource "libvirt_volume" "controller-qcow2" {
  name = "controller.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./images/focal-server-cloudimg-amd64.img"
  format = "img"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = "default"
}


# Define KVM domain to create
resource "libvirt_domain" "controller" {
  name   = "controller"
  memory = "12288"
  vcpu   = 12

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.controller-qcow2.id}"
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

