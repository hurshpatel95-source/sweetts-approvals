set -e
cd ~/public_html/new
NEWURL="https://sweettsbakery.com/new"; OLDURL="https://sweettsbakeshop.mobi"; PREFIX=wp_3z2t2jvypb_
[ -f ~/sweetts-import.sql ] || { echo "db file missing"; exit 5; }
DBPASS=$(php -r '$c=file_get_contents(getenv("HOME")."/public_html/_app/config/database.php");preg_match("/\[.password.\]\s*=\s*.([^\x27\"]+)/",$c,$p);echo $p[1];')
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
cat > wp-config.php <<WPC
<?php
define('DB_NAME', 'sweettba_wp');
define('DB_USER', 'sweettba_cms');
define('DB_PASSWORD', '$DBPASS');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
$SALTS
\$table_prefix = '$PREFIX';
define('WP_HOME', '$NEWURL');
define('WP_SITEURL', '$NEWURL');
define('WP_DEBUG', false);
define('DISALLOW_FILE_EDIT', true);
define('WP_MEMORY_LIMIT', '256M');
if ( ! defined( 'ABSPATH' ) ) define( 'ABSPATH', __DIR__ . '/' );
require_once ABSPATH . 'wp-settings.php';
WPC
chmod 640 wp-config.php; echo "wp-config written"
mysql -u sweettba_cms -p"$DBPASS" sweettba_wp < ~/sweetts-import.sql && rm -f ~/sweetts-import.sql && echo "database imported"
WP="/opt/cpanel/ea-php83/root/usr/bin/php /usr/local/bin/wp --path=$HOME/public_html/new --skip-plugins --skip-themes"
echo "tables: $($WP db query 'SHOW TABLES' --skip-column-names | wc -l)"
$WP search-replace "$OLDURL" "$NEWURL" --all-tables --format=count
$WP search-replace "http://sweettsbakeshop.mobi" "$NEWURL" --all-tables --format=count
$WP option update home "$NEWURL"; $WP option update siteurl "$NEWURL"; $WP option update blog_public 0
$WP plugin deactivate wordfence || true
$WP cache flush || true; $WP rewrite flush --hard || true
echo "core $($WP core version) | theme $($WP theme list --status=active --field=name) | home $($WP option get home)"
echo "SERVER-STEP-OK"
