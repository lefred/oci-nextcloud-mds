#!/bin/bash
#set -x

if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then
  dnf -y install @php:7.4
  dnf -y install  php-gd php-xml php-pdo php-mysqlnd php-mbstring php-json php-pecl-zip php-intl php-process
else
  echo "ERROR: PLEASE USE OL8 !!"
  exit 1
fi

sed -i s/128M/1024M/ /etc/php.ini

echo "PHP successfully installed !"

dnf --enablerepo=ol8_developer_EPEL -y install certbot mod_ssl

echo "Certbot has been installed !"
