set -e; cd ~/public_html/new
cat > /tmp/stb-patch.css <<'CSSEOF'
/* Sweet T's Bakeshop — Option A desktop tidy-up
   Where: WP Admin → Appearance → Customize → Additional CSS  (STAGING first)
   Theme: Flora (Wyde) 1.2.8 + WPBakery. Overrides only; no theme files touched. Delete this block to revert.
   Brand: purple #9362a6 (theme), dark purple #6b3f85, Montserrat headings / Lato body (already loaded by theme). */

/* 1. Homepage tiles: cards instead of dotted boxes ------------------------ */
.home section.no-padding .col.col-3[class*="vc_custom_"] {
  border: 0 !important;
  padding: 0 15px !important;
  margin-bottom: 30px;
}
.home section.no-padding .col.col-3 .col-inner {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 4px 18px rgba(80, 40, 100, .10);
  padding: 22px 22px 24px;
  height: 100%;
  text-align: center;
}
/* 3-across on desktop so 6 tiles = 2 clean rows (no orphan) */
@media (min-width: 992px) {
  .home section.no-padding .col.col-3 {
    width: 33.3333% !important;
    flex: 0 0 33.3333% !important;
    max-width: 33.3333% !important;
  }
}

/* 1b. Hide the gingham tile background image; equal-height cards */
.home section.no-padding .col .section-background { display: none !important; }
.home section.no-padding .row { display: flex; flex-wrap: wrap; align-items: stretch; }

/* 2. Photos: rounded rectangles, consistent height, no circles ----------- */
.home section.no-padding .col-inner img {
  border-radius: 12px !important;
  width: 100% !important;
  height: 220px;
  object-fit: cover;
  display: block;
  margin: 0 auto 6px;
}

/* 3. Tile headings ------------------------------------------------------- */
.home section.no-padding .col-inner h3 {
  font-size: 19px;
  letter-spacing: .08em;
  margin: 0 0 14px;
  color: #6b3f85;
}

/* 4. Kill the purple "highlighter" text blocks -------------------------- */
.home .col-inner span[style*="purple"],
.home .col-inner span[style*="128, 0, 128"] {
  background: transparent !important;
  color: #555 !important;
  font-size: 15px !important;
  font-weight: 400 !important;
}

/* 5. Tile links become buttons ----------------------------------------- */
.home section.no-padding .col-inner p > a,
.home section.no-padding .col-inner h4 > a,
.home section.no-padding .col-inner a[href*="company.site"],
.home section.no-padding .col-inner a[href*="/store"] {
  display: inline-block;
  background: #9362a6;
  color: #fff !important;
  padding: 10px 20px;
  border-radius: 999px;
  font-family: Montserrat, sans-serif;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: .06em;
  text-transform: uppercase;
  text-decoration: none !important;
  margin-top: 8px;
}
.home section.no-padding .col-inner a:has(img) { background: none; padding: 0; }
/* inline-styled spans inside links (editor leftovers) must inherit the button colour, or purple-on-purple = invisible */
.home section.no-padding .col-inner p > a *,
.home section.no-padding .col-inner h4 > a * { color: inherit !important; background: transparent !important; }
/* tile headings that are links (ONLINE ORDERING, CAKE PICKUP) stay headings, not buttons */
.home section.no-padding .col-inner h3 a,
.home section.no-padding .col-inner h3 a * { background: transparent !important; color: #6b3f85 !important; padding: 0 !important; display: inline !important; }
.home section.no-padding .col-inner p > a { margin: 6px 3px; }

/* 6. Allow pinch-zoom (viewport meta is in theme header; this is the CSS half) */
body { touch-action: manipulation; }

/* 7. Hours / address strip + hero (added as WPBakery rows on staging; these style them) */
.stb-hero {
  position: relative; min-height: 440px; display: flex; align-items: center; justify-content: center;
  background-size: cover; background-position: center; color: #fff; text-align: center; margin-bottom: 40px;
}
.stb-hero::before { content: ""; position: absolute; inset: 0; background: linear-gradient(rgba(60,30,80,.45), rgba(60,30,80,.65)); }
.stb-hero > div { position: relative; max-width: 760px; padding: 40px 20px; }
.stb-hero h1 { font-family: Montserrat, sans-serif; font-size: 40px; line-height: 1.15; letter-spacing: .02em; margin: 0 0 12px; color: #fff; }
.stb-hero p { font-size: 18px; margin: 0 0 22px; color: #fff; }
.stb-hero a { display: inline-block; margin: 6px; padding: 13px 26px; border-radius: 999px; font-family: Montserrat, sans-serif; font-weight: 600; font-size: 13px; letter-spacing: .08em; text-transform: uppercase; text-decoration: none; }
.stb-hero a.primary { background: #9362a6; color: #fff; }
.stb-hero a.secondary { background: #fff; color: #6b3f85; }
.stb-info { background: #f6f1f9; border-radius: 14px; padding: 26px 30px; display: flex; gap: 30px; justify-content: space-around; text-align: center; margin: 10px 15px 40px; flex-wrap: wrap; }
.stb-info > div { min-width: 220px; }
.stb-info h4 { font-family: Montserrat, sans-serif; font-size: 13px; letter-spacing: .12em; text-transform: uppercase; color: #6b3f85; margin: 0 0 8px; }
.stb-info p { margin: 0; font-size: 16px; line-height: 1.5; color: #444; }
CSSEOF
WP="/opt/alt/php74/usr/bin/php /usr/local/bin/wp --path=$HOME/public_html/new"
echo "== 1. custom css -> Customizer (Additional CSS)"
$WP eval 'wp_update_custom_css_post(file_get_contents("/tmp/stb-patch.css")); echo "css bytes: ".strlen(wp_get_custom_css())."\n";'
echo "== 2. front page"
HOME_ID=$($WP option get page_on_front); echo "front page id: $HOME_ID"
$WP post get $HOME_ID --field=post_content > ~/home-$HOME_ID-original.txt; echo "original saved: $(wc -c < ~/home-$HOME_ID-original.txt) bytes"
cp ~/home-$HOME_ID-original.txt ~/public_html/new/stb-home-original.txt
echo "== 3. hero + info rows"
HOME_ID=$HOME_ID /opt/alt/php74/usr/bin/php -r '
$id=getenv("HOME_ID"); $orig=file_get_contents(getenv("HOME")."/home-".$id."-original.txt");
if(strpos($orig,"stb-hero")!==false){echo "already patched\n";exit(0);}
$img="https://sweettsbakery.com/new/wp-content/uploads/2016/03/IMG_4303-1.jpg";
$hero="<section class=\"stb-hero\" style=\"background-image:url(".$img.")\"><div><h1>Award-Winning Custom Cakes &amp; Baked Goods in Haddonfield, NJ</h1><p>Wedding, birthday and hand-sculpted cakes, cupcakes, French macarons and treats &mdash; everything made from scratch by sisters Toni &amp; Chrissy.</p><a class=\"primary\" href=\"/new/store/\">Order Online</a> <a class=\"secondary\" href=\"/new/custom-cakes/\">Custom Cakes</a></div></section>";
$info="<div class=\"stb-info\"><div><h4>Visit</h4><p>14 Kings Court, Haddonfield, NJ 08033<br><small>GPS: 1 Ellis St.</small></p></div><div><h4>Hours</h4><p>Tuesday &ndash; Saturday 10am &ndash; 4pm<br>Closed Sunday &amp; Monday</p></div><div><h4>Call / Email</h4><p><a href=\"tel:8564280222\">856.428.0222</a><br><a href=\"mailto:info@sweettbakes.com\">info@sweettbakes.com</a></p></div></div>";
$enc=function($h){return base64_encode(rawurlencode($h));};
$heroRow="[vc_row full_width=\"stretch_row_content_no_spaces\"][vc_column][vc_raw_html]".$enc($hero)."[/vc_raw_html][/vc_column][/vc_row]\n";
$infoRow="\n[vc_row][vc_column][vc_raw_html]".$enc($info)."[/vc_raw_html][/vc_column][/vc_row]";
file_put_contents("/tmp/home-new.txt",$heroRow.$orig.$infoRow); echo "new content: ".strlen($heroRow.$orig.$infoRow)." bytes\n";'
[ -f /tmp/home-new.txt ] && $WP post update $HOME_ID --post_content="$(cat /tmp/home-new.txt)"
$WP cache flush >/dev/null 2>&1 || true; rm -f /tmp/home-new.txt /tmp/stb-patch.css
echo "PATCH-1-OK"
