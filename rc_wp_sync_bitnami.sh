#!/bin/bash

echo "enter the project name:"
read project_name

rc_uuid=$(date '+%Y-%m-%d-%H-%M-%S')-$( cat /proc/sys/kernel/random/uuid )

sudo ssh $project_name 'bash -s' << EOF

cd /bitnami/wordpress
sudo wp db export $rc_uuid.sql

EOF

sudo scp $project_name:/bitnami/wordpress/$rc_uuid.sql /var/www/$project_name/

sudo ssh $project_name 'bash -s' << EOF

cd /bitnami/wordpress
sudo rm $rc_uuid.sql

EOF

cd /var/www/$project_name/

echo "enter the project root domain ( Example example.com):"
read project_root_domain
echo "enter the project local domain with port ( Example localhost:8080):"
read project_local_domain

sudo wp db import $rc_uuid.sql --allow-root

sudo wp search-replace "https://www.$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
sudo wp search-replace "http://www.$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
sudo wp search-replace "https://$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
sudo wp search-replace "http://$project_root_domain" "http://$project_local_domain" --skip-columns=guid --allow-root


echo "Press 'y' to wp-content all items inside folder. Press 'n' to only sync uploads folder : "; read sync_folder_yn

if [ "$sync_folder_yn" = "${sync_folder_yn#[Yy]}" ]
then
    sudo rsync -a $project_name:/bitnami/wordpress/wp-content/ /var/www/$project_name/wp-content/
else
    sudo rsync -a $project_name:/bitnami/wordpress/wp-content/uploads/ /var/www/$project_name/wp-content/uploads/
fi 

sudo chown -R www-data:www-data wp-content

sudo wp option set blog_public 0 --allow-root


