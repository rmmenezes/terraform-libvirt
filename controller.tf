# Defining VM Volume
resource "libvirt_volume" "controller-qcow2" {
  name = "controller.qcow2"
  pool = "default" # List storage pools using virsh pool-list
#  source = "https://cloud.debian.org/images/cloud/OpenStack/testing/debian-testing-openstack-amd64.qcow2"
  source = "/home/server01/images_iso/debian-testing-openstack-amd64.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "controller" {
  name   = "controller"
  memory = "4048"
  vcpu   = 4

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

