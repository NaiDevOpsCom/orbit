# Output the instance IP
output "instance_ip" {
  value = openstack_networking_floatingip_v2.fip_1.address
}

