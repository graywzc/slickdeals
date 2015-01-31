#! /usr/bin/perl
# key word search 
use DBI;
use strict;

# buffer max lenght
my $buffermax = 100;

my $dbh = DBI->connect('dbi:mysql:deals','graywzc','2326838') 
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

# 1. get all entries from the table keywordsearch, loop over each item
my $keywordsearch = "keywordsearch";
my $sql = "select email,keyword,exclude,buffer from $keywordsearch";
my $getsubscr = $dbh->prepare($sql);
$getsubscr->execute or die "can't get subscriptions !\n";

while (my $subscr = $getsubscr->fetch)
{
	my $email = $subscr->[0];
	my $keyword = $subscr->[1];
	my $exclude = $subscr->[2];
	my $buffer = $subscr->[3];

# 1.1 get the keyword, and process the keyword
	my @keywords = split(/\W/, $keyword);

# process the exclude
	my @excludes = split(/\|/, $exclude);

# 1.2 run the query to get the results
	foreach (@keywords) 
	{
		#$sql = "select date,title,link,votes,score,notified,id from $tablename where (date='$today' or date='$yesterday') and title like '%$_%'"; 
		$sql = "select date,title,link,votes,score,notified,id,category from $tablename where date='$today' and score>4 and title like '%$_%'"; 
		foreach (@excludes)
		{
			$sql = $sql." and title not like '%$_%'";	
		}

		print "sql: $sql\n";

		my $getdeal = $dbh->prepare($sql);
		$getdeal->execute or die "can't get deals!\n";

# 1.3 compare each id to the buffer, if it's new send notification
		while (my $record = $getdeal->fetch)
		{
			#print $record->[0]."-".$record->[1]."-".$record->[3]."-".$record->[4]."-".$record->[5]."\n";
			my $deal_id = $record->[6];
			
			unless($buffer =~ /$deal_id/)
			{
				# add deal_id to the end of the buffer, if overflow warn out		
				(length($buffer) < ($buffermax - 7)) or warn "buffer overflow for $email with keyword $keyword!";
				$buffer = $buffer.$deal_id;
				$sql = "update $keywordsearch set buffer='$buffer' where email='$email' and keyword='$keyword'";
				my $updatebuffer = $dbh->prepare($sql);
				$updatebuffer->execute or die "can't update buffer!\n";

				# send notification
				my $subject = "[SlickDeals] ".$record->[1];
				my $content = "\ntitle $record->[1]\nurl $record->[2]\ncategory $record->[7] votes $record->[3] score	$record->[4]\ndate $record->[0]";
				my @args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$email,$subject,$content);
				system(@args) == 0 or die "system @args failed: $?";
				
			}

		}

		
	}
	
}

