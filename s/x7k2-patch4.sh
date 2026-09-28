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
.stb-card img{display:block;width:200px;height:200px;object-fit:cover;border-radius:50%;margin:24px auto 0;box-shadow:0 2px 12px rgba(80,40,100,.14)}
.stb-card img.icon{width:auto;max-width:78%;height:auto;border-radius:0;object-fit:contain;box-shadow:none;margin:52px auto 30px}
.stb-card h3{font-family:Montserrat,sans-serif;font-size:17px;letter-spacing:.08em;text-transform:uppercase;color:#6b3f85;margin:16px 16px 6px}
.stb-card p{margin:0 18px 12px;font-size:15px;line-height:1.5;color:#555}
.stb-card .btn{display:inline-block;background:#9362a6;color:#fff;padding:9px 18px;border-radius:999px;font-family:Montserrat,sans-serif;font-weight:600;font-size:12px;letter-spacing:.08em;text-transform:uppercase}
.stb-info{background:#f6f1f9;border-radius:14px;padding:26px 30px;display:flex;gap:30px;justify-content:space-around;text-align:center;margin:0 15px 12px;flex-wrap:wrap}
.stb-info>div{min-width:220px}
.stb-info h4{font-family:Montserrat,sans-serif;font-size:13px;letter-spacing:.12em;text-transform:uppercase;color:#6b3f85;margin:0 0 8px}
.stb-info p{margin:0;font-size:16px;line-height:1.5;color:#444}.stb-info a{color:#6b3f85;text-decoration:none}
.stb-note{text-align:center;color:#666;font-size:14px;margin:0 15px 44px}.stb-note a{color:#6b3f85}
@media(max-width:900px){.stb-cards{grid-template-columns:1fr}.stb-hero{min-height:380px}.stb-hero h1{font-size:28px}}
/* v3: page background (old site's gingham) + kill theme section padding on the homepage */
.home #content{background:#f7f5f9 url(https://sweettsbakery.com/new/wp-content/uploads/stb/background.jpg) repeat center top !important}
.home .main-content > section.w-section, .home section.stb-row{padding-top:0 !important;padding-bottom:0 !important;margin-top:0 !important;margin-bottom:0 !important}
.home .main-content.header-space{padding-bottom:0}
.stb-hero{margin:0 0 40px}
.stb-cards{margin-bottom:30px}
.stb-info{background:rgba(255,255,255,.85)}
.stb-note{margin-bottom:56px}
/* v4: real gingham page background (theme paints white on .main-content), bigger header, bigger cards */
.home .main-content.full-width, .home .main-content{background:transparent !important}
.home #content{background:linear-gradient(rgba(255,255,255,.45),rgba(255,255,255,.45)),url(https://sweettsbakery.com/new/wp-content/uploads/2017/12/sweetTs-Bakery-back-final.jpg) center top / 520px repeat !important}
#header .header-wrapper{padding:14px 0 !important}
#header img.dark-logo, #header img.light-logo, #header .logo img{max-height:118px !important;height:auto !important;width:auto !important}
#header nav#top-nav ul.top-menu > li > a{font-size:15px !important;letter-spacing:.1em !important;padding:0 16px !important}
.stb-hero{min-height:520px}
.stb-hero h1{font-size:48px}
.stb-hero p{font-size:20px}
.stb-cards{gap:28px}
.stb-card img{width:240px;height:240px}
.stb-card h3{font-size:20px;margin-top:20px}
.stb-card p{font-size:16.5px;margin:0 22px 14px}
.stb-card .btn{font-size:13px;padding:11px 22px}
.stb-info p{font-size:17px}
@media(max-width:900px){.stb-hero h1{font-size:30px}.stb-card img{width:200px;height:200px}}
CSSEOF
WP="/opt/alt/php74/usr/bin/php /usr/local/bin/wp --path=$HOME/public_html/new"
$WP eval 'wp_update_custom_css_post(file_get_contents("/tmp/stb-patch.css")); echo "css bytes: ".strlen(wp_get_custom_css())."\n";'
$WP cache flush >/dev/null 2>&1 || true; rm -f /tmp/stb-patch.css
echo "PATCH-4-OK"
