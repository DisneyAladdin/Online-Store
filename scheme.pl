use utf8;
use Encode;
use strict;
use warnings;
use URI::Escape;
use Time::HiRes qw(sleep);
use LWP::Simple;
use LWP::UserAgent;
use Mozilla::CA;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;
use Term::ANSIColor 2.00 qw(:pushpop);
# for E-mail
#use Authen::SASL;
#use MIME::Base64;
#use Net::SMTP;
use Data::Dumper;
#use Math::Round;
use Encode 'decode';

my $cmd= <<EOL;
osascript -e 'display notification "処理を開始しました．入力ファイルはinput.csvです．" with title "電脳せどり開始のお知らせ"'
EOL
my $a=`$cmd`;
print "$a";
print "\n\n".encode('utf-8','電脳せどりを開始しました')."\n\n";
my $limiter = 0;
my $num = 0;
open(F, "input.csv")||die "cannot open input.csv':$!\n";
open(W, "> output.csv")||die "cannot open output.csv':$!\n";

print W "JAN,NAME,PRICE,URL\n";
while(my $list = <F>){
  my $url = $list;
  chomp($url);
  my $domain;
  if ($url =~ /^(http|https):\/\/([-\w\.]+)\//){
		$domain = $1."://".$2;
  }
  if($domain eq 'http://www.chara-ani.com'){
    &cara($url,$limiter);
  }elsif($domain eq 'http://www.hobbystock.jp'){
    &hobby_stock($url,$limiter);
  }elsif($domain eq 'https://shop.faber-hobby.jp'){
    &faber($url,$limiter);
  }elsif($domain eq 'http://www.ksdenki.com'){
    &Ks($url,$limiter);
  }elsif($domain eq 'http://www.biccamera.com'){
    &big($url,$limiter);
  }elsif($domain eq 'https://online.nojima.co.jp'){
    &nojima($url,$limiter);
  }elsif($domain eq 'http://www.yamada-denkiweb.com'){
    &yamada($url,$limiter);
  }
}
close(F);
close(W);


print "\007";
$cmd= <<EOL;
osascript -e 'display notification "処理が完了しました．output.csvを確認してください．" with title "電脳せどり完了のお知らせ"'
EOL
$a=`$cmd`;
print "$a";
print "\n\n".encode('utf-8','処理を完了しました')."\n";






sub nojima{
  my $url = shift;
  my $limiter = shift;
  my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";
  # LWPを使ってサイトにアクセスし、HTMLの内容を取得する
  my $ua = LWP::UserAgent->new('agent' => $user_agent);
  my $res = $ua->get($url);
  my $content = $res->content;
  my $html = $content;
  #print $html;
  my @n1 = split(/<div class="cmdty_iteminfo">/,$html,16);
  for(my $i=1; $i<=15; $i++){
	$num++;
	sleep(1);
	print "\n";
	print BOLD GREEN "No.".$num."\n";
	my $sub_html = $n1[$i];
	#URL
	my @n2 = split(/<a href="/,$sub_html,2);
	my $n3 = $n2[1];
	my @n4 = split(/">/,$n3,2);
	my $sub_url = 'https://online.nojima.co.jp'.$n4[0];	
	#name
	my @n5 = split(/<strong>/,$sub_html,2);
	my $n12 = $n5[1];
	my @n13 = split(/<\/strong>/,$n12,2);
	my $name = $n13[0];
	$name =~ s/<span>//g;
	$name =~ s/<\/span>//g;
	$name =~ s/&nbsp;//g;
	$name =~ s/[\s　]+//g;
	#$name = encode('utf-8',$name);
	#price
	my @n6 = split(/<span id="praiceh"><\/span><span class="price">/,$sub_html,2);
	my $n7 = $n6[1];
	my @n8 = split(/<span class='taxfont'>/,$n7,2);
	my $price = $n8[0];
	$price =~ s/,//g;
	my $PRICE = decode('UTF-8', $price);
	$PRICE =~ s/円//g;
	$price = $PRICE;
	#JAN
	$res = $ua->get($sub_url);
	$content = $res->content;
	my @n9 = split(/<span itemprop="identifier"><span>/,$content,2);
	my $n10 = $n9[1];
	my @n11 = split(/<\/span>/,$n10,2);
	my $JAN = $n11[0];

	if($JAN ne 'No-JANcode'){
	  print $name."\n";
	  print "JAN: ".$JAN."   price: ".$price."\n";
	  print W $JAN.",".$name.",".$price.",".encode('utf-8',$sub_url)."\n";
	}


	
  }
}








# caraani
sub cara{
  my $url     = shift;
  my $limiter = shift;
  my $html;
  #my $num;
  $html = get($url);
  my @n1 = split(/<div class="productInfo">/,$html,21);
  for(my $i=1; $i<=20; $i++){
    $num++;
    print "\n";
    print BOLD GREEN "No.".$num."\n";
    my $sub_html = $n1[$i];
    # name
    my @n2 = split(/<a href="details\.aspx\?prdid=/,$sub_html,2);
    my $n3 = $n2[1];
    my @n4 = split(/</,$n3,2);
    my $n5 = $n4[0];
    my @n6 = split(/>/,$n5,2);
    my $name = $n6[1];
    # price
    my @n5 = split(/<span class="salePrice">￥/,$sub_html,2);
    my $n6 = $n5[1];
    my @n7 = split(/\(/,$n6,2);
    my $price = $n7[0];
    $price =~ s/,//g;

    # sub_url
    my @n8 = split(/<a href="details\.aspx\?prdid=/,$sub_html,2);
    my $n9 = $n8[1];
    my @n10= split(/"/,$n9,2);
    my $n11 = $n10[0];
    my $sub_url = 'http://www.chara-ani.com/details.aspx?prdid='.$n11.'/';

    my $JAN = &JAN_search($name);
    if($JAN ne 'No-JANcode'){
    	print encode('utf-8',$name)."\n";
    	print "JAN: ".$JAN."   price: ".$price."\n";
    	&save($JAN,$price,$sub_url,$name);
    	sleep(0.3);
    }
  }
}




sub hobby_stock{
    my $url     = shift;
    my $limiter = shift;
    my $html;
    #my $num;

    $html = get($url);
    my @n1 = split(/<div class="unit animate_item">/,$html,25);
    for(my $i=1; $i<=24; $i++){
      $num++;
      print "\n";
      print BOLD GREEN "No.".$num."\n";
      my $sub_html = $n1[$i];
      # url
      my @n2 = split(/<a href="/,$sub_html,2);
      my $n3 = $n2[1];
      my @n4 = split(/"/,$n3,2);
      my $n5 = $n4[0];
      my $sub_url = 'http://www.hobbystock.jp'.$n5;
      my $page_html = get($sub_url);

      # name and JAN
      my @n5 = split(/<meta name="keywords" content="/,$page_html,2);
      my $n6 = $n5[1];
      my @n7 = split(/,/,$n6,3);
      my $name = $n7[0];
      my $JAN  = $n7[1];

 
      # price
      my @n8 = split(/<p>販売価格（税込）： <ins>/,$page_html,2);
      my $n9 = $n8[1];
      my @n10= split(/円/,$n9,2);
      my $price = $n10[0];
      $price =~ s/,//g;
      
 
     #my $JAN = &JAN_search($name);
     if($JAN ne 'No-JANcode'){
         print encode('utf-8',$name)."\n";
         print "JAN=".$JAN." price=".$price." sub_url=".$sub_url."\n";
         &JAN_amazon($JAN,$price,$sub_url,$name);
         sleep(2);
     }
   }

}










sub faber{
    my $url     = shift;
    my $limiter = shift;
    my $html;
    
    $html = get($url);
    my @n1 = split(/<!--★画像★-->/,$html,53);
    for(my $i=1; $i<=53; $i++){
        $num++;
        print "\n";
        print BOLD GREEN "Num=".$num."\n";
        my $sub_html = $n1[$i];
        # url
        my @n2 = split(/<a href="/,$sub_html,2);
        my $n3 = $n2[1];
        my @n4 = split(/"/,$n3,2);
        my $n5 = $n4[0];
        my $sub_url = 'https://shop.faber-hobby.jp'.$n5;
        my $page_html = get($sub_url);
        
        # name and JAN
        my @n5 = split(/alt="/,$sub_html,2);
        my $n6 = $n5[1];
        my @n7 = split(/"/,$n6,2);
        my $name = $n7[0];
        
        
        # price
        my @n8 = split(/<span style="font-weight: bold; color: #dd0000;">/,$sub_html,2);
        my $n9 = $n8[1];
        my @n10= split(/円</,$n9,2);
        my $price = $n10[0];
        $price =~ s/,//g;
        


	# JAN
	my @n11 = split(/JANコード：<\/dt><dd itemprop="gtin13">/,$page_html,2);
	my $n12 = $n11[1];
	my @n13 = split(/</,$n12,2);
	my $JAN = $n13[0];
	

        
        #my $JAN = &JAN_search($name);
        if($JAN ne 'No-JANcode'){
            print encode('utf-8',$name)."\n";
            print "JAN=".$JAN." price=".$price."\n";
            &save($JAN,$price,$sub_url,$name);
            sleep(1);
        }
    }
    
}





sub Ks{
    my $url     = shift;
    my $limiter = shift;
    my $html = get($url);
    my @n1 = split(/<div class="img_">/,$html,97);
    for(my $i=1; $i<=96; $i++){
        $num++;
        print "\n";
        print BOLD GREEN $num."\n";
        my $sub_html = $n1[$i];
        # url
        my @n2 = split(/<a href="\/shop\/g\/g/,$sub_html,2);
        my $n3 = $n2[1];
        my @n4 = split(/"/,$n3,2);
        my $n5 = $n4[0];
        my $sub_url = 'http://www.ksdenki.com/shop/g/g'.$n5;
        
        # name and JAN
        my @n5 = split(/title="/,$sub_html,2);
        my $n6 = $n5[1];
        my @n7 = split(/"/,$n6,2);
        my $name = $n7[0];
	$name =~ s/&nbsp;//g;        
        
        # price
        my @n8 = split(/<span class="carousel_list_tax_price_wrapper_"><span class="carousel_list_price_">/,$sub_html,2);
        my $n9 = $n8[1];
        my @n10= split(/円/,$n9,2);
        my $price = $n10[0];
        $price =~ s/,//g;
        
        # JAN
        my @n11 = split(/shop\/g\/g/,$sub_url,2);
        my $n12 = $n11[1];
        my @n13 = split(/\//,$n12,2);
        my $JAN = $n13[0];
        
        
        if($JAN ne 'No-JANcode'){
            print encode('utf-8',$name)."\n";
            print "JAN=".$JAN." price=".$price."\n";
            &save($JAN,$price,$sub_url,$name);
        sleep(1);
        }
    }
    
}




sub big{
    my $url     = shift;
    my $limiter = shift;
    my $num;
    my $html = get($url);
    my @n1 = split(/<li class="prod_box sku/,$html,101);
    for(my $i=1; $i<=100; $i++){
        $num++;
        print "\n";
        print BOLD GREEN $num."\n";
        my $sub_html = $n1[$i];
        # url
        my @n2 = split(/class="cssopa" href="/,$sub_html,2);
        my $n3 = $n2[1];
        my @n4 = split(/"/,$n3,2);
        my $sub_url = $n4[0];
        #my $sub_url = 'http://www.ksdenki.com/shop/g/g'.$n5;
        
        # name and JAN
        my @n5 = split(/data-item-name="/,$sub_html,2);
        my $n6 = $n5[1];
        my @n7 = split(/"/,$n6,2);
        my $name = $n7[0];
        $name =~ s/&nbsp;//g;
        
        # price
        my @n8 = split(/<p class="bcs_tax">税込：/,$sub_html,2);
        my $n9 = $n8[1];
        my @n10= split(/円/,$n9,2);
        my $price = $n10[0];
        $price =~ s/,//g;
        
        # JAN
	sleep(2);
	my $page_html = get($sub_url);
	$page_html =~ s/[\s　]+//g;
        my @n11 = split(/<th>JANコード<\/th><td>/,$page_html,2);
        my $n12 = $n11[1];
        my @n13 = split(/<\/td>/,$n12,2);
        my $JAN = $n13[0];
	$JAN =~ s/<td>//g;
	$JAN =~ s/\t//g;
	chomp($JAN);
        
        
        if($JAN ne 'No-JANcode'){
            print encode('utf-8',$name)."\n";
            print "JAN=".$JAN." price=".$price." sub_url=".$sub_url."\n";
            &JAN_amazon($JAN,$price,$sub_url,$name);
            sleep(1);
        }
    }
    
}





sub yamada{
    my $url     = shift;
    my $limiter = shift;
    #my $num;
    my $html = get($url);
    my @n1 = split(/<div class="item-wrapper">/,$html,21);
    for(my $i=1; $i<=20; $i++){
        $num++;
        print "\n";
        print BOLD GREEN $num."\n";
        my $sub_html = $n1[$i];
        # url
        my @n2 = split(/<a href="/,$sub_html,2);
        my $n3 = $n2[1];
        my @n4 = split(/"/,$n3,2);
        my $n5 = $n4[0];
        my $sub_url = 'http://www.yamada-denkiweb.com'.$n5;
        
        # name
        my @n5 = split(/alt="/,$sub_html,2);
        my $n6 = $n5[1];
        my @n7 = split(/"/,$n6,2);
        my $name = $n7[0];
        #$name =~ s/&nbsp;//g;
        
        # price
	my $price_front = '<span class="subject-tax">\(税込 &yen;';
	my $price_back  = '\)';
        my @n8 = split(/$price_front/,$sub_html,2);
        my $n9 = $n8[1];
        my @n10= split(/$price_back/,$n9,2);
        my $price = $n10[0];
        $price =~ s/,//g;
        
        # JAN
	sleep(0.8);
	my $page_html = get($sub_url);
        my @n11 = split(/<th>JAN<\/th>/,$page_html,2);
        my $n12 = $n11[1];
        my @n13 = split(/<\/td>/,$n12,2);
        my $JAN = $n13[0];
	$JAN =~ s/<td>//g;
	$JAN =~ s/[\s　]+//g;
        
        
        if($JAN ne 'No-JANcode'){
            print encode('utf-8',$name)."\n";
            print "JAN=".$JAN." price=".$price."\n";
            &save($JAN,$price,$sub_url,$name);
        }
    }
    
}







sub JAN_search{
  my $name  = shift;
  my $query = $name;
  my $url   = 'http://askillers.com/jan/?index=1&word='.$query;
  my $html  = get($url);
  my $q;
  if($html =~ 'JAN/EAN:'){
	$q = 1;
  }else{
	$q = 0;
  }
  
  if($q == 1){
  	my @n1    = split(/JAN\/EAN:/,$html,2);
  	my $n2    = $n1[1];
 	my @n3    = split(/</,$n2,2);
  	my $JAN   = $n3[0];
  	return $JAN;
  }else{
        return 'No-JANcode';
  }
}








sub JAN_amazon{
  my $JAN            = shift;
  my $price          = shift;
  my $limiter        = shift;
  my $sub_url        = shift;
  my $name           = shift;
  my $amazon_url = 'https://www.amazon.co.jp/s/ref=nb_sb_noss?__mk_ja_JP=カタカナ&url=search-alias%3Daps&field-keywords='.$JAN;
  # IE8のフリをする
  my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";
  # LWPを使ってサイトにアクセスし、HTMLの内容を取得する
  my $ua = LWP::UserAgent->new('agent' => $user_agent);
  my $res = $ua->get($amazon_url);
  sleep(1);
  my $content = $res->content;
  my $html = $content;

  my $amazon_price;
  my $ASIN;
  my $fac = 'a';
  my $ele = 'b';
  my $review;
  my $evaluation;
  my $Brand_new;
  my $Used;

  # ASIN
  if($html=~'data-asin="'){
  	my @n1 = split(/data-asin="/,$html,2);
  	my $n2 = $n1[1];
  	my @n3 = split(/"/,$n2,2);
  	$ASIN  = $n3[0];
  }
  # Review
  if($html =~ '#customerReviews">'){
	my @rev = split(/#customerReviews">/,$html,2);
	my $rev2= $rev[1];
	my @rev3= split(/</,$rev2,2);
	$review = $rev3[0];
  }else{
	$review = 0;
  }
  # evaluation
  if($html =~ '<span class="a-icon-alt">5つ星のうち '){
	my @eva = split(/<span class="a-icon-alt">5つ星のうち /,$html,2);
	my $eva2= $eva[1];
	my @eva3= split(/</,$eva2,2);
	$evaluation = $eva3[0];
  }else{
	$evaluation = 0;
  }
  # Exhibit
  if($html =~ '新品<span class="a-letter-space"></span><span class="a-color-secondary">'){
	my @ex = split(/新品<span class="a-letter-space"><\/span><span class="a-color-secondary">/,$html,2);
	my $ex2= $ex[1];
	my @ex3= split(/</,$ex2,2);
	$Brand_new = $ex3[0];
	$Brand_new =~ s/出品//g;
	$Brand_new =~ s/ //g;
        $Brand_new =~ s/\(//g;
	$Brand_new =~ s/\)//g;
  }else{
	$Brand_new = 0;
  }

  if($html =~ '中古品<span class="a-letter-space"></span><span class="a-color-secondary">'){
	my @ex4 = split(/中古品<span class="a-letter-space"><\/span><span class="a-color-secondary">/,$html,2);
	my $ex5 = $ex4[1];
	my @ex6 = split(/</,$ex5,2);
	$Used   = $ex6[0];
	$Used   =~ s/出品//g;
	$Used   =~ s/ //g;
	$Used   =~ s/\(//g;
	$Used   =~ s/\)//g;

  }else{
	$Used   = 0;
  }

  # amazon_price
  if($html =~ '<span class="a-size-base a-color-price a-text-bold">'){
	 $fac = '<span class="a-size-base a-color-price a-text-bold">';
  }elsif($html =~ '<span class="a-size-base a-color-price s-price a-text-bold">'){
	 $fac = '<span class="a-size-base a-color-price s-price a-text-bold">';
  }
  if($fac ne 'a'){
	my @n4 = split(/$fac/,$html,2);
  	my $n5 = $n4[1];
  	my @n6  = split(/</,$n5,2);
  	my $n7 = $n6[0];
  	$n7 =~ s/,//g;
	my @n8 = split(/ /,$n7);
  	$amazon_price = $n8[1];
  	print GREEN "ASIN: ".$ASIN."   Amazon_price: ".$amazon_price."   REVIEW: ".$review."\n";
	
        my @n20 = split(/<a class="a-link-normal a-text-normal" target="_blank" href="/,$html,2);
	my $n21 = $n20[1];
        my @n22 = split(/"/,$n21,2);
        my $amazon_page_url = $n22[0];
  	my $mono_url = 'http://mnrate.com/item/aid/'.$ASIN;
  	my $difference = $price - $amazon_price;
        my $R_difference = $amazon_price*0.1 + $difference;
    		&save($JAN,$ASIN,$mono_url,$review,$evaluation,$price,$amazon_price,$difference,$R_difference,$sub_url,$amazon_url,$name,$Brand_new,$Used);
	}else{
	print  RED encode('utf-8','amazonに登録されていない商品です')."\n";
   	}
  my $SleepNum = rand(3);
  sleep($SleepNum);	 
}














sub mono{
	my $JAN            = shift;
	my $price          = shift;
	my $limiter        = shift;
	my $sub_url        = shift;
	my $name           = shift;
	my $mono_url = 'http://www.mnrate.com/search?I=All&kwd='.$JAN;
	# IE8のフリをする
	#my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";
	# LWPを使ってサイトにアクセスし、HTMLの内容を取得する
	#my $ua = LWP::UserAgent->new('agent' => $user_agent);
	#my $res = $ua->get($mono_url);
	#my $content = $res->content;
	#my $html = $content;
	my $html = get($mono_url);
	my $rank_top = 100000;
	my $ASIN;


	# 検索結果が２以上の時
	if($html =~ '<span class="_total_result">'){
		my @n1 = split('<span class="_total_result">',$html);
		my $n2 = $n1[1];
		my @n3 = split('</span>',$n2);
		my $total_result = $n3[0];
		$total_result =~ s/[\s　]+//g;
		$total_result = int($total_result);
		# ランキングを取得	
		my @n4 = split('<li class="item_summary_list_item">',$html);
		for(my $i=1; $i<=$total_result; $i++){
			my $sub_html = $n4[$i];
			my @n5 = split('<span class="_ranking_item_color">',$sub_html);
			my $n6 = $n5[1];
			my @n7 = split('</span>',$n6);
			my $rank = $n7[0];
			$rank =~ s/[\s　]+//g;
			
			my @n8 = split('href="http:\/\/mnrate.com\/item\/aid\/',$sub_html);
			my $n9 = $n8[1];
			my @n10 = split('"',$n9);
			my $sub_ASIN = $n10[0];
			

			if($rank ne 'ありません'){
				$rank = int($rank);
			}else{
				$rank = 99999;
			}
			# ランキングが上位のASINを取得			
			if($rank_top > $rank){
				$rank_top = $rank;
	 			$ASIN     = $sub_ASIN;
			}	
		}
	}else{
	# 検索結果が一つに絞れるとき
		my @n11 = split('asin: "',$html,2);
		my $n12 = $n11[1];
		my @n13 = split('"',$n12);
		$ASIN = $13[0];
		
		my @n14 = split('class="_ranking_item_color">',$html);
		my $n15 = $n14[1];
		my @n16 = split('</span>',$n15);
		$rank_top = $n16[0];
		$rank_top = int($rank_top);
	}

	print "mono_url=".$mono_url."  ASIN=".$ASIN."  RANK=".$rank_top."\n";
	print $html	 

	

}

		







sub save{
  my $JAN             = shift;
  my $price           = shift;
  my $sub_url         = shift;
  my $name            = shift;

  my $q = 0;
  if($q == 0){
    print W $JAN.",".encode('utf-8',$name).",".$price.",".encode('utf-8',$sub_url)."\n";
  }
}
