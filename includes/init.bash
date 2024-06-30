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

load_new_vars=true
if [[ -f $local_root/$project_name-$server.sh ]]
then
    echo "found a project file."
    echo $( cat "$local_root/$project_name-$server.sh" )
    echo "proceed with these ? ( y/n ) "; read use_vars_file
    if [ "$use_vars_file" == "y" ]
    then
        load_new_vars=false
        . $local_root/$project_name-$server.sh
    fi      
fi

if [ "$load_new_vars" = true ]
then
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

    echo "import after sync? ( y/n ): "; read import_after_sync

    if [ "$import_after_sync" == "n" ]
    then
        import_after_sync=false
    else
        import_after_sync=true
    fi

    touch $local_root/$project_name-$server.sh

    cat > $local_root/$project_name-$server.sh << EOF
    ssh_host=$ssh_host
    remote_root=$remote_root
    import_after_sync=$import_after_sync
EOF

fi