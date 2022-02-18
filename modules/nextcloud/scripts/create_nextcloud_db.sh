#!/bin/bash



mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE DATABASE ${nextcloud_database};"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER ${nextcloud_name} identified with 'mysql_native_password' by '${nextcloud_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${nextcloud_database}.* TO ${nextcloud_name};"

echo "NextCloud User created !"
echo "NEXTCLOUD USER = ${nextcloud_name}"
