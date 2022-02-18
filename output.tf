output "nextcloud_public_ip" {
  value = module.nextcloud.public_ip
}

output "nextcloud_db_user" {
  value = module.nextcloud.nextcloud_user_name
}

output "nextcloud_db_password" {
  value = var.nextcloud_password
}

output "nextcloud_admin" {
  value = module.nextcloud.nextcloud_admin
}

output "nextcloud_admin_pass" {
  value = module.nextcloud.nextcloud_admin_pass
}

output "mds_instance_ip" {
  value = module.mds-instance.private_ip
}

output "ssh_private_key" {
  value = local.private_key_to_show
}

output "object_storage_bucket" {
  value = var.object_storage_bucket
}
