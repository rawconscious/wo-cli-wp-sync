#!/bin/bash
if [ "$import_after_sync" == true ]
then
    sudo chown -R www-data:www-data wp-content
    sudo wp option set blog_public 0 --allow-root
    sudo wp option set siteurl "http://$project_local_domain" --allow-root
    sudo wp option set home "http://$project_local_domain" --allow-root

    if [[ -f $local_root/post-sync.sh ]]
    then
        . $local_root/post-sync.sh
    fi
fi