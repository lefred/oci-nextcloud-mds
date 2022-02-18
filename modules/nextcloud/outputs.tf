output "id" {
  value = oci_core_instance.NextCloud.*.id
}

output "public_ip" {
  value = join(", ", oci_core_instance.NextCloud.*.public_ip)
}

output "nextcloud_user_name" {
  value = var.nextcloud_name
}

output "nextcloud_host_name" {
  value = oci_core_instance.NextCloud.*.display_name
}

output "nextcloud_admin" {
  value = var.nextcloud_admin
}

output "nextcloud_admin_pass" {
  value = var.nextcloud_admin_pass
}

