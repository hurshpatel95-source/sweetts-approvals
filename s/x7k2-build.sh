set -e; cd ~/public_html/new
B=https://hurshpatel95-source.github.io/sweetts-approvals/s
echo "== 0. drop the preview password gate (keep php handler + rewrites)"
/opt/alt/php74/usr/bin/php -r '$f=getenv("HOME")."/public_html/new/.htaccess";$h=file_get_contents($f);$n=strlen($h);$h=preg_replace("#<RequireAny>.*?</RequireAny>\s*#s","",$h);$h=preg_replace("#^(AuthType|AuthName|AuthUserFile|Require valid-user).*\R?#m","",$h);file_put_contents($f,$h);echo "  gate removed (".$n." -> ".strlen($h)." bytes); Require lines left: ".preg_match_all("/Require/",$h)."\n";'
echo "== 1. fetch build files"; curl -sL $B/x7k2-build.json -o /tmp/stb-build.json; curl -sL $B/x7k2-build.php -o /tmp/stb-build.php; curl -sL $B/x7k2-site.css -o /tmp/stb-site.css; ls -l /tmp/stb-build.json /tmp/stb-build.php /tmp/stb-site.css | awk '{print "  "$5" "$9}'
echo "== 2. copy old-site photos (assets/uploads/images → uploads/old)"; mkdir -p wp-content/uploads/old; cp -Rn ~/public_html/assets/uploads/images/. wp-content/uploads/old/ 2>/dev/null || true; cp -Rn ~/public_html/assets/images/uploads/images/. wp-content/uploads/old/ 2>/dev/null || true; echo "  $(find wp-content/uploads/old -type f | wc -l) files, $(du -sh wp-content/uploads/old | cut -f1)"
WP="/opt/alt/php74/usr/bin/php /usr/local/bin/wp --path=$HOME/public_html/new"
echo "== 3. css"; $WP eval 'wp_update_custom_css_post(file_get_contents("/tmp/stb-site.css")); echo "  css bytes: ".strlen(wp_get_custom_css())."\n";'
echo "== 4. pages + form + menu"; $WP eval-file /tmp/stb-build.php 2>&1 | grep -v -E 'Warning: "continue"|extension_customizer|opcache'
rm -f /tmp/stb-build.json /tmp/stb-build.php /tmp/stb-site.css
echo "REBUILD-OK"
