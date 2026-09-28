<?php
// Rebuild pages on the copy from build.json (run via: wp eval-file build.php). Idempotent.
$J=json_decode(file_get_contents('/tmp/stb-build.json'),true); if(!$J) die("no build.json\n");
$enc=function($h){return base64_encode(rawurlencode($h));}; $dec=function($b){return rawurldecode(base64_decode($b));};
$log=[];
// --- CF7 order form
$cf7=get_posts(['post_type'=>'wpcf7_contact_form','title'=>'Order Inquiry','post_status'=>'any','numberposts'=>1]);
if($cf7){$cf7id=$cf7[0]->ID;} else {
  $cf7id=wp_insert_post(['post_type'=>'wpcf7_contact_form','post_title'=>'Order Inquiry','post_status'=>'publish','post_content'=>'']);
  $form="<label>Name [text* your-name]</label>\n<label>Email [email* your-email]</label>\n<label>Phone [tel* your-phone]</label>\n<label>Date needed by [date* date-needed]</label>\n<label>Number of people served [number people min:1]</label>\n<label>Occasion [text occasion]</label>\n<label>What are you interested in ordering?</label>\n[checkbox interest \"Wedding Cakes\" \"Specialty Cakes\" \"Cupcakes & Towers\" \"Cake Pops / Cake Bombs\" \"Baked Treats\" \"Party Trays\" \"Pies & Cheesecakes\" \"Decorated Cookies\" \"Gluten & Allergen Free\"]\n<label>Photos or ideas (jpg, png or pdf, max 5 MB) [file inspiration limit:5mb filetypes:jpg|jpeg|png|gif|pdf]</label>\n<label>Message [textarea your-message]</label>\n[acceptance mailing-list optional] Sign me up for the mailing list\n[submit \"Send inquiry\"]";
  update_post_meta($cf7id,'_form',$form);
  update_post_meta($cf7id,'_mail',['active'=>true,'subject'=>'[Order Inquiry] [your-name] – needed [date-needed]','sender'=>'Sweet T\'s Website <wordpress@sweettsbakery.com>','recipient'=>'info@sweettbakes.com','body'=>"Name: [your-name]\nEmail: [your-email]\nPhone: [your-phone]\nDate needed: [date-needed]\nServes: [people]\nOccasion: [occasion]\nInterested in: [interest]\nMailing list: [mailing-list]\n\nMessage:\n[your-message]\n\n-- Sent from the order inquiry form on sweettsbakery.com",'additional_headers'=>'Reply-To: [your-email]','attachments'=>'[inspiration]','use_html'=>false,'exclude_blank'=>false]);
  update_post_meta($cf7id,'_mail_2',['active'=>false]); update_post_meta($cf7id,'_messages',[]); update_post_meta($cf7id,'_additional_settings','');
  $log[]="cf7 form created #$cf7id";
}
// --- remove duplicate '-2' pages created by the earlier path bug (only when the original sibling exists)
$dups=0; foreach(get_posts(['post_type'=>'page','post_status'=>'any','numberposts'=>-1]) as $pg){ if(preg_match('/^(.*)-(\d)$/',$pg->post_name,$m)){ foreach(get_posts(['post_type'=>'page','name'=>$m[1],'post_status'=>'any','numberposts'=>5]) as $orig){ if($orig->post_parent==$pg->post_parent){ wp_delete_post($pg->ID,true); $dups++; break; } } } }
$log[]="duplicate cleanup: deleted $dups";
// --- pages
$created=0;$updated=0;$reparented=0;
foreach($J as $p){
  $path=($p['parent']?$p['parent'].'/':'').$p['slug'];
  $parent_id=0; if($p['parent']){ $pp=get_page_by_path($p['parent']); if(!$pp){ $pp=get_page_by_path('baked-goods/'.$p['parent']); } if(!$pp){$log[]="MISSING PARENT ".$p['parent']; continue;} $parent_id=$pp->ID; }
  $content=$p['content'];
  if($p['slug']==='order'){ // split raw html around {{CF7}} so the shortcode runs
    preg_match('#\[vc_raw_html\](.*?)\[/vc_raw_html\]#s',$content,$m); $html=$dec($m[1]); list($a,$b)=explode('{{CF7}}',$html,2);
    $content='[vc_row el_class="stb-row"][vc_column][vc_raw_html]'.$enc($a).'[/vc_raw_html][vc_column_text][contact-form-7 id="'.$cf7id.'" title="Order Inquiry"][/vc_column_text][vc_raw_html]'.$enc($b).'[/vc_raw_html][/vc_column][/vc_row]';
  }
  // resolve by slug + parent id (works at any depth), then by full path, then reparent a same-slug top-level page
  $ex=null; foreach(get_posts(['post_type'=>'page','name'=>$p['slug'],'post_status'=>'any','numberposts'=>5]) as $cand){ if((int)$cand->post_parent===(int)$parent_id){ $ex=$cand; break; } }
  if(!$ex) $ex=get_page_by_path($path);
  if(!$ex && $p['parent']){ $top=get_page_by_path($p['slug']); if($top && $top->post_parent==0 && !in_array($p['slug'],['galleries','custom-cakes','baked-goods'])){ $ex=$top; $reparented++; } }
  $data=['post_type'=>'page','post_status'=>'publish','post_name'=>$p['slug'],'post_title'=>$p['title'],'post_content'=>$content,'post_parent'=>$parent_id,'comment_status'=>'closed'];
  if($ex){ $data['ID']=$ex->ID; $id=wp_update_post($data,true); $updated++; } else { $id=wp_insert_post($data,true); $created++; }
  if(is_wp_error($id)){$log[]="ERR $path: ".$id->get_error_message(); continue;}
  update_post_meta($id,'_wp_page_template','default'); update_post_meta($id,'_wpb_vc_js_status','true');
  if(!empty($p['seo_title'])) update_post_meta($id,'_yoast_wpseo_title',$p['seo_title']);
  if(!empty($p['desc'])) update_post_meta($id,'_yoast_wpseo_metadesc',$p['desc']);
}
// --- homepage hours 10am → 8:30am inside raw html blocks
$home=get_page_by_path('home'); $hid=$home?$home->ID:(int)get_option('page_on_front');
if($hid){ $c=get_post_field('post_content',$hid); $n=0;
  $c2=preg_replace_callback('#\[vc_raw_html\](.*?)\[/vc_raw_html\]#s',function($m) use(&$n,$dec,$enc){ $h=$dec($m[1]); $h2=str_replace(['10am &ndash; 4pm','10am-4pm','10am – 4pm'],'8:30am &ndash; 4pm',$h); if($h2!==$h)$n++; return '[vc_raw_html]'.$enc($h2).'[/vc_raw_html]'; },$c);
  if($n){ wp_update_post(['ID'=>$hid,'post_content'=>$c2]); $log[]="homepage hours updated in $n block(s)"; } }
$log[]="pages: created $created, updated $updated (reparented $reparented)";
// --- junk
foreach(['sample-page'] as $s){ $x=get_page_by_path($s); if($x){ wp_delete_post($x->ID,true); $log[]="deleted /$s/"; } }
foreach(get_posts(['post_type'=>'post','numberposts'=>-1,'post_status'=>'any']) as $po){ if(stripos($po->post_title,'hello world')!==false){ wp_delete_post($po->ID,true); $log[]="deleted post '{$po->post_title}'"; } }
// --- menu
$menus=wp_get_nav_menus(); $menu=null; $locs=get_nav_menu_locations();
foreach($locs as $loc=>$mid){ if($mid){ $menu=wp_get_nav_menu_object($mid); $log[]="menu via location $loc: ".$menu->name; break; } }
if(!$menu && $menus){ $menu=$menus[0]; $log[]="menu: ".$menu->name; }
if($menu){
  foreach(wp_get_nav_menu_items($menu->term_id)?:[] as $it) wp_delete_post($it->ID,true);
  $U=home_url('/'); $add=function($title,$url,$parent=0) use($menu,$U){ return wp_update_nav_menu_item($menu->term_id,0,['menu-item-title'=>$title,'menu-item-url'=>rtrim($U,'/').$url,'menu-item-status'=>'publish','menu-item-type'=>'custom','menu-item-parent-id'=>$parent]); };
  $add('Home','/'); $add('Our Story','/our-story/');
  $bg=$add('Baked Goods','/baked-goods/'); foreach([['Baked Treats','/baked-goods/baked-treats/'],['Cupcakes','/baked-goods/cupcakes/'],['Cake Flavors','/baked-goods/cake-flavors/'],['Cake Pops / Cake Bombs','/baked-goods/cake-pops-cake-bombs/'],['Pies & Cheesecakes','/baked-goods/pies-and-cheesecakes/'],['Gluten & Allergen Free','/baked-goods/gluten-and-allergen-free/'],['Mini Desserts','/baked-goods/mini-desserts/']] as $c) $add($c[0],$c[1],$bg);
  $cc=$add('Custom Cakes','/custom-cakes/'); foreach([['Wedding','/custom-cakes/wedding/'],['Specialty Cakes','/custom-cakes/specialty-cakes/'],['Hand-Sculpted','/custom-cakes/hand-sculpted/'],['Baby','/custom-cakes/baby/'],['Kids','/custom-cakes/kids/'],['Hand-Painted','/custom-cakes/hand-painted/'],['Hand-Sculpted Figures','/custom-cakes/hand-sculpted-figures/'],['Cupcakes & Treats','/custom-cakes/cupcakes-and-treats/'],['Cake Tasting','/cake-tasting/'],['Pricing','/pricing-cakes/'],['Order Inquiry','/order/']] as $c) $add($c[0],$c[1],$cc);
  $add('Galleries','/galleries/'); $add('Order Online','/store/'); $add('News & Press','/news/'); $add('Contact Us','/contact-us/');
  $log[]="menu rebuilt: ".count(wp_get_nav_menu_items($menu->term_id))." items";
}
update_option('blog_public',0); flush_rewrite_rules(true); if(function_exists('wp_cache_flush')) wp_cache_flush();
echo implode("\n",$log)."\n";
// verify
foreach(['custom-cakes/wedding','baked-goods/baked-treats/muffins','galleries/specialty','pricing-cakes','order','news'] as $path){ $x=get_page_by_path($path); echo str_pad($path,40).($x?"OK #".$x->ID." ".get_permalink($x->ID):"MISSING")."\n"; }
echo "BUILD-PHP-OK\n";
