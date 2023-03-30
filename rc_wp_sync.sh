#!/bin/bash

echo "enter the local project name: "; read project_name

echo "is /var/www/${project_name} the root local folder? ( y/n ): "; read local_root_yn

if [ "$local_root_yn" == "y" ]
then
    local_root=/var/www/$project_name
else
    echo "enter the local root folder path ( eg: /var/www/example) :"; read local_root
fi 

echo "is remote a prod or dev server? ( prod/dev ): "; read server

if [[ -f $local_root/$project_name-$server.sh ]]
then
    . $local_root/$project_name-$server.sh
else
    echo "is ${project_name} the remote ssh host? ( y/n ): "; read ssh_host_yn

    if [ "$ssh_host_yn" == "y" ]
    then
        ssh_host=$project_name
    else
        echo "enter the remote ssh host :"; read ssh_host
    fi

    echo "is /var/www/${project_name} the root remote folder? ( y/n ): "; read remote_root_yn

    if [ "$remote_root_yn" == "y" ]
    then
        remote_root=/var/www/$project_name
    else
        echo "enter the remote root folder path ( eg: /var/www/example/) :"; read remote_root
    fi

sudo touch $local_root/$project_name-$server.sh

sudo cat > $local_root/$project_name-$server.sh << EOF
    ssh_host=$ssh_host
    remote_root=$remote_root
EOF

fi



rc_uuid=$(date '+%Y-%m-%d-%H-%M-%S')-$( cat /proc/sys/kernel/random/uuid )

sudo ssh $ssh_host /bin/bash << EOF

cd $remote_root
sudo wp db export $rc_uuid.sql --allow-root

EOF

sudo scp $ssh_host:$remote_root/$rc_uuid.sql $local_root

sudo ssh $ssh_host /bin/bash << EOF

cd $remote_root
sudo rm $rc_uuid.sql

EOF

cd $local_root

echo "enter the project remote domain ( Example example.com):"
read project_remote_domain
echo "enter the project local domain with port ( Example localhost:8080):"
read project_local_domain

wp db import $rc_uuid.sql --allow-root

wp search-replace "https://www.$project_remote_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "http://www.$project_remote_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "https://$project_remote_domain" "http://$project_local_domain" --skip-columns=guid --allow-root
wp search-replace "http://$project_remote_domain" "http://$project_local_domain" --skip-columns=guid --allow-root

echo "Press 'y' to wp-content all items inside folder. Press 'n' to only sync uploads folder : "; read sync_folder_yn

if [ "$sync_folder_yn" == "y" ]
then
    sudo rsync -a $ssh_host:$remote_root/wp-content/ $local_root/wp-content/
else
    sudo rsync -a $ssh_host:$remote_root/wp-content/uploads/ $local_root/wp-content/uploads/
fi 

sudo chown -R www-data:www-data wp-content
sudo wp option set blog_public 0 --allow-root
sudo wp option set siteurl "http://$project_local_domain" --allow-root
sudo wp option set home "http://$project_local_domain" --allow-root





