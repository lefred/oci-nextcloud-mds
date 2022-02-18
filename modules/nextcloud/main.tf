## DATASOURCE
# Init Script Files

locals {
  php_script            = "~/install_php.sh"
  shell_script          = "~/install_shell.sh"
  nextcloud_script      = "~/install_nextcloud.sh"
  security_script       = "~/configure_local_security.sh"
  create_nextcloud_db   = "~/create_nextcloud_db.sh"
  fault_domains_per_ad  = 3
}


data "template_file" "install_php" {
  template = file("${path.module}/scripts/install_php.sh")
}

data "template_file" "install_shell" {
  template = file("${path.module}/scripts/install_shell.sh")

  vars = {
    mysql_version         = var.mysql_version,
    user                  = var.vm_user
  }
}

data "template_file" "install_nextcloud" {
  template = file("${path.module}/scripts/install_nextcloud.sh")

  vars = {
    nextcloud_version       = var.nextcloud_version
    nextcloud_password      = var.nextcloud_password
    mds_ip                  = var.mds_ip
    nextcloud_name          = var.nextcloud_name
    nextcloud_database      = var.nextcloud_database
    nextcloud_admin         = var.nextcloud_admin
    nextcloud_admin_pass    = var.nextcloud_admin_pass
    object_storage_bucket   = var.object_storage_bucket
    object_storage_hostname = var.object_storage_hostname
    object_storage_region   = var.object_storage_region
    object_storage_key      = var.object_storage_key 
    object_storage_secret   = var.object_storage_secret
  }
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

data "template_file" "create_nextcloud_db" {
  template = file("${path.module}/scripts/create_nextcloud_db.sh")
  count    = var.nb_of_webserver
  vars = {
    admin_password        = var.admin_password
    admin_username        = var.admin_username
    nextcloud_password    = var.nextcloud_password
    mds_ip                = var.mds_ip
    nextcloud_name        = var.nextcloud_name
    nextcloud_database    = var.nextcloud_database
  }
}


resource "oci_core_instance" "NextCloud" {
  count               = var.nb_of_webserver
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}${count.index+1}"
  shape               = var.shape
  availability_domain = var.use_AD == false ? var.availability_domains[0] : var.availability_domains[count.index%length(var.availability_domains)]
  fault_domain        = var.use_AD == true ? "FAULT-DOMAIN-1" : "FAULT-DOMAIN-${(count.index  % local.fault_domains_per_ad) +1}"

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus = var.flex_shape_ocpus
    }
  }


  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}${count.index+1}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.display_name}${count.index+1}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_nextcloud.rendered
    destination = local.nextcloud_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

 provisioner "file" {
    content     = data.template_file.create_nextcloud_db[count.index].rendered
    destination = local.create_nextcloud_db

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_shell.rendered
    destination = local.shell_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }

    inline = [
       "chmod +x ${local.php_script}",
       "sudo ${local.php_script}",
       "chmod +x ${local.shell_script}",
       "sudo ${local.shell_script}",
       "chmod +x ${local.create_nextcloud_db}",
       "sudo ${local.create_nextcloud_db}",
       "chmod +x ${local.nextcloud_script}",
       "sudo ${local.nextcloud_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}"
    ]

   }

  timeouts {
    create = "10m"

  }
}
