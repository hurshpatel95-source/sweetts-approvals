set -e; cd ~/public_html/new
cat > /tmp/stb-patch.css <<'CSSEOF'
/* Sweet T's Bakeshop — homepage v2 (hero slideshow + cards + info strip). Customizer → Additional CSS. Brand purple #9362a6 / #6b3f85. */
.stb-hero{position:relative;min-height:460px;display:flex;align-items:center;justify-content:center;color:#fff;text-align:center;overflow:hidden;margin:0 0 36px}
.stb-slides{position:absolute;inset:0}
.stb-slides div{position:absolute;inset:0;background-size:cover;background-position:center;opacity:0;animation:stbfade 18s infinite}
.stb-slides div:nth-child(1){animation-name:stbfadefirst}
.stb-slides div:nth-child(2){animation-delay:6s}
.stb-slides div:nth-child(3){animation-delay:12s}
@keyframes stbfade{0%{opacity:0}6%{opacity:1}33%{opacity:1}40%{opacity:0}100%{opacity:0}}
@keyframes stbfadefirst{0%{opacity:1}33%{opacity:1}40%{opacity:0}94%{opacity:0}100%{opacity:1}}
.stb-hero::before{content:"";position:absolute;inset:0;background:linear-gradient(rgba(60,30,80,.35),rgba(60,30,80,.6));z-index:1}
.stb-hero-content{position:relative;z-index:2;max-width:780px;padding:48px 20px}
.stb-hero h1{font-family:Montserrat,sans-serif;font-size:40px;line-height:1.15;letter-spacing:.02em;margin:0 0 12px;color:#fff;text-transform:none}
.stb-hero p{font-size:18px;margin:0 0 22px;color:#fff}
.stb-hero a{display:inline-block;margin:6px;padding:13px 26px;border-radius:999px;font-family:Montserrat,sans-serif;font-weight:600;font-size:13px;letter-spacing:.08em;text-transform:uppercase;text-decoration:none}
.stb-hero a.primary{background:#9362a6;color:#fff}.stb-hero a.secondary{background:#fff;color:#6b3f85}
.stb-cards{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;margin:0 15px 26px}
.stb-card{display:block;background:#fff;border-radius:14px;box-shadow:0 4px 18px rgba(80,40,100,.10);padding:0 0 22px;text-align:center;color:#444;text-decoration:none;overflow:hidden;transition:transform .15s}
a.stb-card:hover{transform:translateY(-3px)}
.stb-card img{width:100%;height:210px;object-fit:cover;display:block}
.stb-card img.icon{height:170px;object-fit:contain;padding:22px 0 0;background:#faf7fc}
.stb-card h3{font-family:Montserrat,sans-serif;font-size:17px;letter-spacing:.08em;text-transform:uppercase;color:#6b3f85;margin:16px 16px 6px}
.stb-card p{margin:0 18px 12px;font-size:15px;line-height:1.5;color:#555}
.stb-card .btn{display:inline-block;background:#9362a6;color:#fff;padding:9px 18px;border-radius:999px;font-family:Montserrat,sans-serif;font-weight:600;font-size:12px;letter-spacing:.08em;text-transform:uppercase}
.stb-info{background:#f6f1f9;border-radius:14px;padding:26px 30px;display:flex;gap:30px;justify-content:space-around;text-align:center;margin:0 15px 12px;flex-wrap:wrap}
.stb-info>div{min-width:220px}
.stb-info h4{font-family:Montserrat,sans-serif;font-size:13px;letter-spacing:.12em;text-transform:uppercase;color:#6b3f85;margin:0 0 8px}
.stb-info p{margin:0;font-size:16px;line-height:1.5;color:#444}.stb-info a{color:#6b3f85;text-decoration:none}
.stb-note{text-align:center;color:#666;font-size:14px;margin:0 15px 44px}.stb-note a{color:#6b3f85}
@media(max-width:900px){.stb-cards{grid-template-columns:1fr}.stb-hero{min-height:380px}.stb-hero h1{font-size:28px}}
CSSEOF
WP="/opt/alt/php74/usr/bin/php /usr/local/bin/wp --path=$HOME/public_html/new"
echo "== 1. copy old-site banners into the copy"; mkdir -p wp-content/uploads/stb
for f in slide1.jpg Specialty-Backdrop1.jpg wedding-slide.jpg; do cp -f ~/public_html/assets/uploads/images/$f wp-content/uploads/stb/ && echo "  $f"; done
echo "== 2. css"; $WP eval 'wp_update_custom_css_post(file_get_contents("/tmp/stb-patch.css")); echo "  css bytes: ".strlen(wp_get_custom_css())."\n";'
echo "== 3. rebuild homepage"; HOME_ID=$($WP option get page_on_front); [ -f ~/home-$HOME_ID-original.txt ] || { echo "no original backup"; exit 4; }
HOME_ID=$HOME_ID /opt/alt/php74/usr/bin/php -r '
$id=getenv("HOME_ID"); $orig=file_get_contents(getenv("HOME")."/home-".$id."-original.txt");
$row1=substr($orig,0,strpos($orig,"[/vc_row]")+9);
$U="https://sweettsbakery.com/new"; $up="$U/wp-content/uploads";
$enc=function($h){return base64_encode(rawurlencode($h));};
$hero="<section class=\"stb-hero\"><div class=\"stb-slides\"><div style=\"background-image:url($up/stb/slide1.jpg)\"></div><div style=\"background-image:url($up/stb/Specialty-Backdrop1.jpg)\"></div><div style=\"background-image:url($up/stb/wedding-slide.jpg)\"></div></div><div class=\"stb-hero-content\"><h1>Award-Winning Custom Cakes &amp; Baked Goods in Haddonfield, NJ</h1><p>Wedding, birthday and hand-sculpted cakes, cupcakes, French macarons and treats &mdash; everything made from scratch by sisters Toni &amp; Chrissy.</p><a class=\"primary\" href=\"$U/store/\">Order Online</a> <a class=\"secondary\" href=\"$U/custom-cakes/\">Custom Cakes</a></div></section>";
$cards="<div class=\"stb-cards\">"
."<a class=\"stb-card\" href=\"$U/baked-goods/\"><img src=\"$up/2016/03/cupcake-cake.jpg\" alt=\"Cupcakes and baked treats\"><h3>Baked Goods</h3><p>Cupcakes, scones, muffins, macarons, pies and more &mdash; baked fresh every morning.</p><span class=\"btn\">View the menu</span></a>"
."<a class=\"stb-card\" href=\"$U/custom-cakes/\"><img src=\"$up/2016/03/IMG_4303-1.jpg\" alt=\"Custom tiered cake\"><h3>Custom Cakes</h3><p>Wedding, birthday, baby shower and hand-sculpted cakes. Please allow at least 2 weeks for custom orders.</p><span class=\"btn\">See our cakes</span></a>"
."<a class=\"stb-card\" href=\"$U/store/\"><img src=\"$up/2016/03/BakedTreats_BundtCake.jpg\" alt=\"Order cakes online\"><h3>Order Online</h3><p>Standard cakes, the holiday menu, daily items and gift cards &mdash; order ahead for pickup.</p><span class=\"btn\">Order online</span></a>"
."<a class=\"stb-card\" href=\"$U/galleries/\"><img src=\"$up/stb/Specialty-Backdrop1.jpg\" alt=\"Sculpted specialty cakes\"><h3>Galleries</h3><p>Sculpted, hand-painted, wedding, baby and kids cakes we have made.</p><span class=\"btn\">View our work</span></a>"
."<div class=\"stb-card\"><img class=\"icon\" src=\"$up/2016/03/home_barista.png\" alt=\"Full barista on site\"><h3>Full Barista on Site</h3><p>Proudly serving freshly brewed La Colombe coffee and espresso drinks, Tuesday through Saturday.</p></div>"
."<a class=\"stb-card\" href=\"$U/cake-pickup-and-driving-instructions/\"><img class=\"icon\" src=\"$up/2022/05/Screen-Shot-2022-05-27-at-4.54.01-PM-2.png\" alt=\"Cake pickup and directions\"><h3>Cake Pickup &amp; Directions</h3><p>How to pick up and transport your cake safely, plus GPS directions to Kings Court.</p><span class=\"btn\">Instructions</span></a>"
."</div>";
$info="<div class=\"stb-info\"><div><h4>Visit</h4><p>14 Kings Court, Haddonfield, NJ 08033<br><small>GPS: 1 Ellis St.</small></p></div><div><h4>Hours</h4><p>Tuesday &ndash; Saturday 10am &ndash; 4pm<br>Closed Sunday &amp; Monday</p></div><div><h4>Call / Email</h4><p><a href=\"tel:8564280222\">856.428.0222</a><br><a href=\"mailto:info@sweettbakes.com\">info@sweettbakes.com</a></p></div></div><p class=\"stb-note\">Holiday hours and weekly specials are posted on <a href=\"https://www.instagram.com/sweettsbakeshop/\" target=\"_blank\" rel=\"noopener\">Instagram</a>.</p>";
$row=function($h) use($enc){return "[vc_row][vc_column][vc_raw_html]".$enc($h)."[/vc_raw_html][/vc_column][/vc_row]\n";};
$new=$row1."\n".str_replace("[vc_row]","[vc_row full_width=\"stretch_row_content_no_spaces\"]",$row($hero)).$row($cards).$row($info);
file_put_contents("/tmp/home-new.txt",$new); echo "  new content: ".strlen($new)." bytes\n";'
$WP post update $HOME_ID --post_content="$(cat /tmp/home-new.txt)"
$WP cache flush >/dev/null 2>&1 || true; rm -f /tmp/home-new.txt /tmp/stb-patch.css ~/public_html/new/stb-home-original.txt
echo "PATCH-2-OK"
