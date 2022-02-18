#!/bin/bash
#set -x

cd /var/www
wget https://download.nextcloud.com/server/releases/nextcloud-${nextcloud_version}.zip
unzip nextcloud-${nextcloud_version}.zip 
rm html -rf
mv nextcloud html
chown apache. -R html
rm -f nextcloud-${nextcloud_version}.zip

cd /var/www/html
sudo -u apache php occ maintenance:install --database "mysql" --database-name "${nextcloud_database}" \
--database-user "${nextcloud_name}" --database-pass "${nextcloud_password}" --admin-user "${nextcloud_admin}" \
--admin-pass "${nextcloud_admin_pass}" --database-host "${mds_ip}"

sudo -u apache php occ app:enable files_external
sudo -u apache php occ files_external:create -c bucket=${object_storage_bucket} -c hostname=${object_storage_hostname} -c region=${object_storage_region} -c use_ssl=true -c use_path_style=true -c legacy_auth=false -c key=${object_storage_key} -c secret=${object_storage_secret} OCI amazons3 amazons3::accesskey

public_ip=$(curl ifconfig.me)
sed -i "s/localhost/$public_ip/" config/config.php 
chcon --type httpd_sys_rw_content_t /var/www/html/config/config.php

