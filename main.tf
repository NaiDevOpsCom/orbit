# Create a new block storage volume
resource "openstack_blockstorage_volume_v3" "basic_volume" {
  name     = "basic-volume"
  size     = 10
  image_id = "a702f0cb-2081-416f-aff4-6969ddfba96c"   // do openstack image list to get a list of images
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

resource "local_file" "alvo-ssh-keys" {
	# content = tls_private_key.RSA.private_key_pem
	content = tls_private_key.ssh_key.private_key_pem
	filename = "orbit.pem"
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

data "template_file" "user_data" {
  template = file("${path.module}/do_stuff.sh")
}

# Create a compute instance
resource "openstack_compute_instance_v2" "basic" {
  name      = "basic"
  flavor_id = "3"
  key_pair  = openstack_compute_keypair_v2.default.name
  user_data = data.template_file.user_data.rendered
  #security_groups = [openstack_networking_secgroup_v2.secgroup_ssh.name]


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

# Create a firewall rule to allow SSH traffic on port 22
resource "openstack_fw_rule_v2" "allow_ssh" {
  name             = "allow-ssh"
  description      = "allow SSH traffic"
  action           = "allow"
  protocol         = "tcp"
  destination_port = "22"
  enabled          = "true"
}

# Create a firewall rule to allow HTTP traffic on port 80
resource "openstack_fw_rule_v2" "allow_http" {
  name             = "allow-http"
  description      = "Allow HTTP traffic"
  action           = "allow"
  protocol         = "tcp"
  destination_port = "80"
  enabled          = "true"
}

# resource "openstack_fw_rule_v2" "allow_react" {
#   name             = "allow-react"
#   description      = "Allow react traffic"
#   action           = "allow"
#   protocol         = "tcp"
#   destination_port = "3000"
#   enabled          = "true"
# }

# Create a firewall policy that includes both SSH and HTTP rules
resource "openstack_fw_policy_v2" "firewall_policy" {
  name = "allow_ssh_http_policy"

  rules = [
    openstack_fw_rule_v2.allow_ssh.id,
    openstack_fw_rule_v2.allow_http.id
    # openstack_fw_rule_v2.allow_react.id
  ]
}

resource "openstack_fw_policy_v2" "policy_2" {
  name = "firewall_egress_policy"

  rules = [
    # openstack_fw_rule_v2.rule_2.id,
  ]
}

# Create a firewall and apply the policyresource "openstack_fw_group_v2" "group_1" {
resource "openstack_fw_group_v2" "group_1" {
  name      = "firewall_group"
  ingress_firewall_policy_id = openstack_fw_policy_v2.firewall_policy.id
  # egress_firewall_policy_id = openstack_fw_policy_v2.policy_2.id
}


# -----------------------------------------still npt available in servercore API---------------------------------------------------------------------
#  Create a security group for the compute instance
# resource "openstack_networking_secgroup_v2" "secgroup_ssh" {
#   name = "ssh_secgroup"
# }

# # Allow SSH traffic on port 22
# resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = openstack_networking_secgroup_v2.secgroup_ssh.id
# }

# ----------------------------------------------------------------------------------------------------------------------------------------------------
