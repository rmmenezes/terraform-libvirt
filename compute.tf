# Defining VM Volume
resource "libvirt_volume" "compute-qcow2" {
  name = "compute.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./images/focal-server-cloudimg-amd64.img"
  format = "img"
}

# Define KVM domain to create
resource "libvirt_domain" "compute" {
  name   = "compute"
  memory = "12288"
  vcpu   = 12

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

