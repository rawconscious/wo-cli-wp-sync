#!/bin/bash

echo "localroot=$local_root"
echo "remoteroot=$remote_root"
echo "Press 'y' to wp-content all items inside folder. Press 'n' to only sync uploads folder : "; read sync_folder_yn

if [[ ! -d "$local_root/wp-content/" ]]
then
    mkdir $local_root/wp-content/
fi

if [[ ! -d "$local_root/wp-content/uploads/" ]]
then
    mkdir $local_root/wp-content/uploads/
fi

if [ "$sync_folder_yn" == "y" ]
then
    rsync  $ssh_host:$remote_root/wp-content/ $local_root/wp-content/
else
    rsync  $ssh_host:$remote_root/wp-content/uploads/ $local_root/wp-content/uploads/
fi 
