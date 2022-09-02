#!/bin/bash
#
# on source server
# ---------------- 
# wp db export
# mv db_name.sql ~/sql/
#
# on destination server
# ---------------------
# scp lolly:~/bitnami_wordpress-2022-09-01-f457d3d.sql /var/www/lolly/
# cd /var/www/lolly && wp db import bitnami_wordpress-2022-09-01-f457d3d.sql --allow-root
# wp search-replace 'https://www.lolly.com' 'http://localhost:8105' --skip-columns=guid --allow-root
# wp search-replace 'http://www.lolly.com' 'http://localhost:8105' --skip-columns=guid --allow-root
# wp search-replace 'https://lolly.com' 'http://localhost:8105' --skip-columns=guid --allow-root
# wp search-replace 'http://lolly.com' 'http://localhost:8105' --skip-columns=guid --allow-root
# rsync -a lolly:/bitnami/wordpress/wp-content/uploads/ /var/www/lolly/wp-content/uploads/