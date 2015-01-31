#! /usr/bin/perl
BEGIN{push (@INC, "/home/graywzc/order_script/slickdeals/");}
use WWW::Mechanize;
use HTML::Parser;
use DBI;
use SlickDealsParser::SlickDealsParser;
use strict;

$main::dbh = DBI->connect('dbi:mysql:deals','graywzc','2326838') 
or die "Connection Error: $DBI::errstr\n";

#my	$sql = "describe lenovo_tp_x";
#my	$sth = $main::dbh->prepare($sql);
#$sth->execute;
#print `date`;
#my $count=0;
#while ($count<3)
#{
		
	#$count++;

#print `date`;
	#print "url: $url \n";

my $mech = WWW::Mechanize->new();
my $url = 'http://slickdeals.net/forums/forumdisplay.php?f=9&order=desc&perpage=80&sort=lastpost';
#my $url = '"http://slickdeals.net/forums/forumdisplay.php?f=9"';
$mech->get( $url );
my $c = $mech->content;
my $parser = SlickDealsParser->new("sdTbl");
#my $parser = SlickDealsParser->new("sdTest");
#$parser->parse_file("example1013.html");
$parser->parse($c);

#sleep 10;

#}
#print `date`;

# pass the latest page and add new items
#my $mech = WWW::Mechanize->new();
#my $url = '"http://outlet.lenovo.com/laptops/thinkpad/x-series.html?limit=all"';
#$mech->get( $url );
#my $c = $mech->content;

#my $parser = LenovoParser->new('lenovo_tp_t');
#$parser->parse_file("example1009.html");
#$parser->parse($c);


# go over the list to update the stop time


#
#
#sub ignore{
#my $mech = WWW::Mechanize->new();
#
##$url = 'http://www.dealsea.com';
#my $url = 'http://www.dealsea.com';
##my $url = 'http://www.dealsea.com/search?q=monitor';
#
#$mech->get( $url );
#my $c = $mech->content;
##print $c;
#
#my $count=0;
#
##while ($c =~ /<strong><a href="(.*?)">(.*?) ([0-9]*\.?[0-9]+)" .*? L(E|C)D Monitor \$([0-9]+.*?)<\/a>, <\/strong>(.*?)</g)
##while ($c =~ /<strong><a href="(.*?)">([a-zA-Z0-9]*?L(E|C)D Monitor[a-zA-Z0-9]*?)<\/a>, <\/strong>(.*?)</g)
##while ($c =~ /<strong><a href="(.*?)">([a-zA-Z0-9"\$ ]*?L(E|C)D Monitor[a-zA-Z0-9"\$ ]*?)<\/a>, <\/strong>([a-zA-Z]+ [0-9]+)</g)
##while ($c =~ /<strong><a href="([\/a-z0-9\-]*)">([a-zA-Z0-9"+\$ ]*?L(E|C)D Monitor[a-zA-Z0-9"+\$ ]*?)<\/a>, <\/strong>/g)
#while ($c =~ /<strong><a href="([\/a-z0-9\-]*)">([a-zA-Z0-9"+\$\.\-& ]*L[EC]D[a-zA-Z\- ]+Monitor[a-zA-Z0-9"+\$\.\-& ]*)<\/a>, <\/strong>([a-zA-Z]* [0-9]*)</gi)
#{	
#	my $link = $1;
#	#my $brand = $2;
#	my $content = $2;
#	my $date = $3;
#
#	$content =~ /\$([0-9]+)/;
#	my $price = $1;
#
#	$content =~ /([0-9]*\.?[0-9]+)"/;
#	my $size = $1;
#
#	my $brand;
#	if ($content =~ /(ASUS|Acer|ViewSonic|DELL|HP)/i)
#	{
#		$brand = uc $1;
#	}
#	else
#	{
#		$brand = "UNKNOWN";
#	}
#
#	$content =~ /(L[EC]D)/;
#	my $cate = $1;
#
#	my $year = `date +%Y`;
#	my $month = `date +%m`;
#	my $day = `date +%d`;
#	chomp($year);
#	chomp($month);
#	chomp($day);
#	my $today = $year."-".$month."-".$day;
#	#print "count: $count, link: $link, brand: $brand, size: $size, date: $date, price: $price \n";
#	#$count++;
#
#	#$sql = "select * from dealseahot where name = '$product'";
#	#$sth = $dbh->prepare($sql);
#	#$sth->execute or die "SQL Select Error: $DBI::errstr\n";
#	
#	#@items = $sth->fetchrow_array;
#
#	#print "count: $count, link: $link, content: $content, date: $date\n";
#	#print "count: $count, link: $link, content: $content\n";
#	#print "today: $year $month $day $today\n";
#
#	my	$sql = "insert into dealsea_monitor values ('$today', '$brand', '$cate', $size, $price )";
#	my	$sth = $dbh->prepare($sql);
#	if($sth->execute)
#	{
#		my $subject = "[DealSea] ".$brand." ".$cate." Monitor ".$size.'" $'.$price;
#		my $url1 = $url.$link;
#		my @args = ("/home/graywzc/order_script/perl_mechanize/sendmailtome",$subject,$url1);
#		system(@args) == 0 or die "system @args failed: $?";
#	}
#
#	#my @thedate = split(/ +/,$2);
#
#	#my @today = split(/ +/,`date`);
#	#print $today[1]." ".$today[2]." ".$thedate[0]." ".$thedate[1]."\n";
#	
##	if ($today[1] eq $thedate[0])
##	{
##		print "month is ok\n";
##	}
##
##	if ($today[2] == $thedate[1])
##	{
##		print "date is ok\n";	
##	}
##print "date:".$date."\n";
##print "product:".$product."\n";
#
#	#print "dealsea has ".$1."\nThe date is ".$2.", today is ".$today."\n";
#	#if (($today[1] eq $thedate[0]) && ($today[2] == $thedate[1]))
#	#{
#
#	#	my @args = ("/home/graywzc/order_script/perl_mechanize/sendmailtome",$name,$product,$url);
#	#	system(@args) == 0 or die "system @args failed: $?";
#	#}
#}
#}
#
