# Create a new block storage volume
resource "openstack_blockstorage_volume_v3" "basic_volume" {
  name     = "basic-volume"
  size     = 10
  image_id = "a702f0cb-2081-416f-aff4-6969ddfba96c"
}

# Create a new SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "openstack_compute_keypair_v2" "default" {
  name       = "terraform_keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create a new network (private network)
resource "openstack_networking_network_v2" "network_1" {
  name           = "tf_test_network"
  admin_state_up = "true"
}

# Create a new subnet within the network
resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

# Use the existing public network (data source)
data "openstack_networking_network_v2" "public_network" {
  name = "external-network"
}

# Create a router
resource "openstack_networking_router_v2" "router" {
  name                = "my_router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

# Attach the subnet to the router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

# Create a floating IP to assign to the instance
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = data.openstack_networking_network_v2.public_network.name
}

# Create a compute instance
resource "openstack_compute_instance_v2" "basic" {
  name      = "basic"
  flavor_id = "3"
  key_pair  = openstack_compute_keypair_v2.default.name

  metadata = {
    this = "that"
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.basic_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_1.name
  }
}

# Associate the floating IP with the instance
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.basic.id
  
  # Ensure the router interface is created before associating the floating IP
  depends_on = [openstack_networking_router_interface_v2.router_interface]
}

# Output the instance IP
output "instance_ip" {
  value = openstack_networking_floatingip_v2.fip_1.address
}

# Output the private key
output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}