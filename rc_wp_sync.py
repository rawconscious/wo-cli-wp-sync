#!/usr/bin/env python3

import os
import subprocess
import uuid
from datetime import datetime

def main():
    project_name = input("Enter the local project name: ")

    local_root_yn = input(f"Is /var/www/{project_name} the root local folder? (y/n): ")
    if local_root_yn == 'y':
        local_root = f"/var/www/{project_name}"
    else:
        local_root = input("Enter the local root folder path (e.g., /var/www/example): ")

    server = input("Is remote a prod or dev server? (prod/dev): ")

    config_file = f"{local_root}/{project_name}-{server}.sh"
    if os.path.isfile(config_file):
        with open(config_file) as f:
            exec(f.read())
    else:
        ssh_host_yn = input(f"Is {project_name} the remote ssh host? (y/n): ")
        if ssh_host_yn == 'y':
            ssh_host = project_name
        else:
            ssh_host = input("Enter the remote ssh host: ")

        remote_root_yn = input(f"Is /var/www/{project_name} the root remote folder? (y/n): ")
        if remote_root_yn == 'y':
            remote_root = f"/var/www/{project_name}"
        else:
            remote_root = input("Enter the remote root folder path (e.g., /var/www/example/): ")

        with open(config_file, 'w') as f:
            f.write(f"ssh_host={ssh_host}\n")
            f.write(f"remote_root={remote_root}\n")

    rc_uuid = f"{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}-{uuid.uuid4()}"

    ssh_command(ssh_host, f"cd {remote_root} && sudo wp db export {rc_uuid}.sql --allow-root")
    subprocess.run(["sudo", "scp", f"{ssh_host}:{remote_root}/{rc_uuid}.sql", local_root])

    ssh_command(ssh_host, f"cd {remote_root} && sudo rm {rc_uuid}.sql")

    os.chdir(local_root)

    project_remote_domain = input("Enter the project remote domain (Example example.com):")
    project_local_domain = input("Enter the project local domain with port (Example localhost:8080):")

    subprocess.run(["wp", "db", "import", f"{rc_uuid}.sql", "--allow-root"])

    for protocol in ["https", "http"]:
        for prefix in ["www.", ""]:
            subprocess.run(["wp", "search-replace", f"{protocol}://{prefix}{project_remote_domain}", f"http://{project_local_domain}", "--skip-columns=guid", "--allow-root"])

    sync_folder_yn = input("Press 'y' to sync all items inside the wp-content folder. Press 'n' to only sync the uploads folder: ")

    if sync_folder_yn == 'y':
        subprocess.run(["sudo", "rsync", "-a", f"{ssh_host}:{remote_root}/wp-content/", f"{local_root}/wp-content/"])
    else:
        subprocess.run(["sudo", "rsync", "-a", f"{ssh_host}:{remote_root}/wp-content/uploads/", f"{local_root}/wp-content/uploads/"])

    subprocess.run(["sudo", "chown", "-R", "www-data:www-data", "wp-content"])
    subprocess.run(["sudo", "wp", "option", "set", "blog_public", "0", "--allow-root"])
    subprocess.run(["sudo", "wp", "option", "set", "siteurl", f"http://{project_local_domain}", "--allow-root"])
    subprocess.run(["sudo", "wp", "option", "set", "home", f"http://{project_local_domain}", "--allow-root"])

    post_sync_script = f"{local_root}/post-sync.sh"
    if os.path.isfile(post_sync_script):
        with open(post_sync_script) as f:
            exec(f.read())

def ssh_command(ssh_host, command):
    subprocess.run(["sudo", "ssh", ssh_host, "/bin/bash", "-c", command])

if __name__ == "__main__":
    main()

