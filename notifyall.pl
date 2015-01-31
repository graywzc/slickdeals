#! /usr/bin/perl
# notify all about the hot deals (score > 9)
use DBI;
use strict;


$main::dbh = DBI->connect('dbi:mysql:deals','graywzc','2326838') 
or die "Connection Error: $DBI::errstr\n";


my $year = `date +%Y`;
my $month = `date +%m`;
my $day = `date +%d`;
chomp($year);
chomp($month);
chomp($day);
my $today = $year."-".$month."-".$day;

$year = `date --date="yesterday" +%Y`;
$month = `date --date="yesterday" +%m`;
$day = `date --date="yesterday" +%d`;
chomp($year);
chomp($month);
chomp($day);
my $yesterday = $year."-".$month."-".$day;

my $tablename = "sdTbl";

# need title, date, title, link, votes, score, 
my $sql = "select date,title,link,votes,score,notified,id,category from $tablename where date='$today' or date='$yesterday'"; 
#my $sql = "select date,title,link,votes,score,notified,id from $tablename where date='$today'"; 
#my $sql = "select date,title,link,votes,score,notified,id from $tablename where date='$yesterday'"; 

my $sth = $main::dbh->prepare($sql);
$sth->execute or die "can't access 'notified'!\n";


while (my $record = $sth->fetch)
{
		print $record->[0]."-".$record->[1]."-".$record->[3]."-".$record->[4]."-".$record->[5]."\n";
	if ($record->[5] eq "no" && $record->[4] >= 10)
	{
		print $record->[0]."-".$record->[1]."-".$record->[3]."-".$record->[4]."-".$record->[5]."\n";
		my $receiver = 'graywzc.deal@gmail.com';
		my $subject = "[SlickDeals] ".$record->[1];
		my $content = "\ntitle $record->[1]\nurl $record->[2]\ncategory $record->[7] votes $record->[3] score $record->[4]\ndate $record->[0]";
		my @args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";


		$receiver = 'yuanzhuli@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'jiaodong02@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'chaojin.cu@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'gglemon@ymail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'yujiali@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'laixiaolue@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'zhaoseattle@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'shan.yuanming@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'looksmall@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'gglemon@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		$receiver = 'rsshriram2000@gmail.com';
		@args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
		system(@args) == 0 or die "system @args failed: $?";

		
		# change flag "notified"
		$sql = "update $tablename set 
				notified='yes' where
				id = '$record->[6]'
				";
		$sth =  $main::dbh->prepare($sql);
		$sth->execute or die "Can't find the existing item.\n"

	}
}

