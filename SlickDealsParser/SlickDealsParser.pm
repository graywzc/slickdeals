package SlickDealsParser;

use DBI;
use strict;
use base qw(HTML::Parser);
use feature "switch";


sub new{
	my $class = shift;
	my $myself = HTML::Parser::new($class);
	$myself->{_tablename} = shift;
	return $myself;
}

sub start{
	my ($self, $tag, $attr) = @_;

	#print $tag." ".$attr->{class}."\n";

	if ($tag eq "tbody" && $attr->{id} eq "threadbits_forum_9")
	{
		#print "enter threadbits_forum_9\n";
		$self->{_in_forum9} = 1;
	}
	elsif ($self->{_in_forum9})
	{
		if ($tag eq "tr" && $attr->{id} =~ /sdpostrow_(\d+)/)
		{
			$self->{row_id} = $1;
		}
		elsif ($tag eq "td" && $attr->{id} =~ /td_threadstatusicon_(\d+)/)
		{
			$self->{deal_id} = $1;	
		}
		elsif ($tag eq "a" && $attr->{id} eq "thread_title_".$self->{deal_id})
		{
			#print "enter deal_title\n";
			$self->{_in_deal_title} = 1;	
		}
		elsif ($tag eq "img" && $attr->{alt} =~ /Votes: (\d+) Score: (-*\d+)/)
		{
			$self->{votes} = $1;	
			$self->{score} = $2;
		}
		elsif ($tag eq "td" && $attr->{id} eq "td_postdate_".$self->{deal_id})
		{
			$self->{_in_postdate} = 1;	
		}
		elsif ($tag eq "img" && $attr->{class} =~ /concat-cat-all (\w+)/)
		{
			$self->{category} = $1;	
		}

	}
	return;

sub ignore{
	if($tag eq "p" && $attr->{class} eq "outlet-price")
	{
		$self->{_in_outlet_price} = 1;	
	}
	elsif ($tag eq "span" && $attr->{class} eq "price")
	{
		$self->{_in_price} = 1;	
	}
	elsif ($tag eq "div" && $attr->{class} eq "desc std")
	{
	#print "enter desc std\n";
		$self->{_in_desc_std} = 1;	
	}
	elsif ($self->{_in_desc_std} && $tag eq "li")
	{
		$self->{_in_li} = 1;
		$self->{_desc_count} ++;
	}
	elsif ($tag eq "div" && $attr->{class} eq "f-fix" )
	{
		$self->{_in_f_fix} = 1;	
		$self->{_model} = "";
		$self->{_cond} = "";
		$self->{_price} = "";
		$self->{_processor} = "";
		$self->{_harddrive} = "";
		$self->{_memory} = "";
		$self->{_display} = "";
		$self->{_videocard} = "";
		#print "enter f-fix";
	}
	elsif ($tag eq "div" && $attr->{class} eq "price-box" )
	{
		$self->{_in_price_box} = 1;	
	}
	elsif ($tag eq "ul")
	{
		$self->{_in_ul} = 1;	
		$self->{_desc_count} = 0;
	}
	return;
	}
}

sub text{
	my ($self, $text) = @_;
	if ($self->{_in_forum9})
	{
		if ($self->{_in_deal_title})		
		{
			#print "process text of deal_title\n";
			chomp($text);
			$self->{title} .= $text;	
		}
		elsif ($self->{_in_postdate})
		{
			chomp($text);
			$text =~ s/[\n\s\t]+//g;
			#print $self->{count}++.$text."\n";
			$self->{date} .= $text;	
		}
	}

	return;

	sub ignore{
	if ($self->{_in_product_name} )
	{
	#print $text."\n";
		if	($self->{_in_a})
		{
			$self->{_model} = $text;
		}
		else
		{
			$self->{_cond} = $text;
		}
	}
	elsif($self->{_in_outlet_price} && $self->{_in_price})
	{
		$text =~ /\$([-+]?[0-9,]*\.?[0-9]+)/;	
		$self->{_price} =join("", split(",",$1));
	}
	elsif($self->{_in_desc_std} && $self->{_in_ul} && $self->{_in_li})
	{
	chomp($text);
	#print $self->{_desc_count}.": ".$text."\n";
		for ($self->{_desc_count})	
		{
			when (1) {$text = substr $text, 22; $self->{_processor} .= $text;}	
			when (3) {$self->{_harddrive} .= $text;}		
			when (4) {$self->{_memory} .= $text;}		
			when (5) {$self->{_display} .= $text;}		
			when (6) {$self->{_videocard} .= $text;}	
		}
	}
	return;
	}
}

sub end{
	my ($self, $tag) = @_;
	
	if ($self->{_in_forum9})
	{
		if ($tag eq "a" && $self->{_in_deal_title})	
		{
			$self->{_in_deal_title} = 0;	
		}
		elsif ($tag eq "tr")
		{
			# exit the current deal	

			# process date
			my $istoday = 0;
			my $postdate = $self->{date};
			if ($postdate =~ /^Today/)
			{
				my $year = `date +%Y`;
				my $month = `date +%m`;
				my $day = `date +%d`;
				chomp($year);
				chomp($month);
				chomp($day);
				$self->{date} = $year."-".$month."-".$day;
				$istoday = 1;
			}
			elsif ($postdate =~ /^Yesterday/)
			{
				my $year = `date --date="yesterday" +%Y`;
				my $month = `date --date="yesterday" +%m`;
				my $day = `date --date="yesterday" +%d`;
				chomp($year);
				chomp($month);
				chomp($day);
				$self->{date} = $year."-".$month."-".$day;
			}
			elsif ($postdate =~ /(\d\d)-(\d\d)-(\d\d\d\d)/)
			{
				$self->{date} = $3."-".$1."-".$2;
			}
			else
			{
				die "date can't not be processed! \n";	
			}
			#process time
			if ($postdate =~ /(\d\d):(\d\d)([AP]M)/)
			{
				if ($3 eq "P")	
				{
					$1 += 12;		
				}
				$self->{time} = $1.":".$2.":00";
			}
			else
			{
				die "time can't not be processed! \n";	
			}

			
			# process title, limit it to 180 character
			# eliminate \' in it
			$self->{title} = substr $self->{title},0,180;	
			$self->{title} =~ s/\'//g;
			$self->{title} =~ s/\"//g;
			# a dirty fix for special characters
			$self->{title} =~ /([A-Za-z0-9-\s,:\.\$!\@#\%^\&\*\(\)\+=|\/\\\?<>\`\~\;\[\]\{\}]+)/;
			$self->{title} = $1;
			
			
			# assemble link
			$self->{link} = "http://slickdeals.net/forums/showthread.php?t=".$self->{deal_id};

			# print this deal
			#print "postdate: $postdate, date: $self->{date}, row_id: $self->{row_id}, deal_id: $self->{deal_id}, title: $self->{title}, votes: $self->{votes}, score: $self->{score}\n";

			# insert or update table and send notification
			my $tablename = $self->{_tablename};
			my $sql = "insert into $tablename values (
			'$self->{date}',
			'$self->{time}',
			'$self->{deal_id}',
			'$self->{category}',
			'$self->{title}',
			'$self->{link}',
			'$self->{votes}',
			'$self->{score}',
			'no'
			)";
			
			my	$sth = $main::dbh->prepare($sql);
			if(! (defined $sth->execute))
			{
				# update votes and scores			
				#print "update $tablename set 
				#		votes='$self->{votes}',
				#		score='$self->{score}' where
				#		id = '$self->{deal_id}'
				#		";
				$sql = "update $tablename set 
						votes='$self->{votes}',
						score='$self->{score}' where
						id = '$self->{deal_id}'
						";
				$sth =  $main::dbh->prepare($sql);
				$sth->execute or die "Can't find the existing item.\n"
			}
#
#			# send notification if hot
#			$sql = "select notified,score from $tablename where id = '$self->{deal_id}'";
#			$sth = $main::dbh->prepare($sql);
#			$sth->execute or die "can't access 'notified'!\n";
#			my @row = $sth->fetchrow_array;
#			if ("no" eq $row[0] && ($row[1] > 10 && $istoday))
#			{
#				#print "row0: $row[0], row1: $row[1]\n";
#				print "postdate: $postdate, date: $self->{date}, row_id: $self->{row_id}, deal_id: $self->{deal_id}, title: $self->{title}, votes: $self->{votes}, score: $self->{score}\n";
#				# send notification	
#				my $receiver = 'graywzc.test@gmail.com';
#				my $subject = "[SlickDeals] ".$self->{title};
#				my $content = "\ndate $self->{date}\nid $self->{deal_id}\ntitle $self->{title}\nurl $self->{link}\nvotes $self->{votes} score $self->{score}";
#				my @args = ("/home/graywzc/order_script/perl_mechanize/sendmailto",$receiver,$subject,$content);
#				system(@args) == 0 or die "system @args failed: $?";
#
#
#
#				# change flag "notified"
#				$sql = "update $tablename set 
#						notified='yes' where
#						id = '$self->{deal_id}'
#						";
#				$sth =  $main::dbh->prepare($sql);
#				$sth->execute or die "Can't find the existing item.\n"
#			}
			
			$self->{category} = "";
			$self->{title} = "";
			$self->{date} = "";
			$self->{time} = "";
			$self->{deal_id} = "";
			$self->{link} = "";
			$self->{votes} = "";
			$self->{score} = "";
		}
		elsif ($tag eq "tbody")
		{
			$self->{_in_forum9} = 0;	
		}
		elsif ($self->{_in_postdate})
		{
			if ($tag eq "td")	
			{
				$self->{_in_postdate} = 0;	
			}
		}
	}

	return;
sub ignore{
	if ($tag eq "h2" && $self->{_in_product_name})
	{
		#print "exit product-name\n";
		$self->{_in_product_name} = 0;
	}
	elsif($tag eq "a" && $self->{_in_a})
	{
		$self->{_in_a} = 0;	
	}
	elsif($tag eq "p" && $self->{_in_outlet_price})
	{
		$self->{_in_outlet_price} = 0;	
	}
	elsif($tag eq "span" && $self->{_in_price} )
	{
		$self->{_in_price} = 0;		
	}
	elsif($tag eq "div" && $self->{_in_desc_std})
	{
	#print "exit desc std\n";
		$self->{_in_desc_std} = 0;	
	}
	elsif($tag eq "div" && $self->{_in_f_fix} && !$self->{_in_desc_std} && !$self->{_in_price_box})
	{
		$self->{_in_f_fix} = 0;	
		#print "model: ".$self->{_model}.",";
		#print "cond: ".$self->{_cond}.",";
		#print "price: ".$self->{_price}.",";
		#print "processor: ".$self->{_processor}.",";
		#print "harddrive: ".$self->{_harddrive}.",";
		#print "memory: ".$self->{_memory}.",";
		#print "display: ".$self->{_display}.",";
		#print "videocard: ".$self->{_videocard}."\n";
		my $tablename = $self->{_tablename};

		my $year = `date +%Y`;
		my $month = `date +%m`;
		my $day = `date +%d`;
		my $hour = `date +%H`;
		my $min = `date +%M`;
		my $sec = `date +%S`;
		chomp($year);
		chomp($month);
		chomp($day);
		chomp($hour);
		chomp($min);
		chomp($sec);
		my $today = $year."-".$month."-".$day;
		my $thistime = $hour.":".$min.":".$sec;

		my	$sql = "insert into $tablename values ('$today','$thistime', 
		'',
		'$self->{_model}',
		'$self->{_cond}',
		'$self->{_price}',
		'$self->{_processor}',
		'$self->{_harddrive}',
		'$self->{_memory}',
		'$self->{_display}',
		'$self->{_videocard}'
		)";

		my	$sth = $main::dbh->prepare($sql);
		if(! (defined $sth->execute))
		{
			# update the stoptime
			$sql = "update $tablename set stoptime='$thistime' where 
						date = '$today' and
						model = '$self->{_model}' and
						cond = '$self->{_cond}' and
						price > $self->{_price}-0.01 and price <$self->{_price}+0.01 and 
						processor = '$self->{_processor}' 
						";
			#print "update to $thistime \n";
			#print $sql."\n";
			$sth =  $main::dbh->prepare($sql);
			$sth->execute or warn "Can't find the existing item.\n"
		}

	}
	elsif($tag eq "div" && $self->{_in_price_box})
	{
		$self->{_in_price_box} = 0;	
	}
	elsif($tag eq "ul" && $self->{_in_ul})
	{
		$self->{_in_ul} = 0;	
	}
	elsif($tag eq "li" && $self->{_in_li})
	{
		$self->{_in_li} = 0;	
	}


	return;
	}
}

1;

