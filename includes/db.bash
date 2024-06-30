#!/bin/bash


rc_uuid=$(date '+%Y-%m-%d-%H-%M-%S')-$( cat /proc/sys/kernel/random/uuid )

ssh $ssh_host /bin/bash << EOF

cd $remote_root
wp db export $rc_uuid.sql --allow-root

EOF

scp $ssh_host:$remote_root/$rc_uuid.sql $local_root

ssh $ssh_host /bin/bash << EOF

cd $remote_root
rm $rc_uuid.sql

EOF

echo "import_after_sync=$import_after_sync"
if [ "$import_after_sync" == true ]
then
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
fi