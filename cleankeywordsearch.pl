#! /usr/bin/perl
# clean the table keywordsearch
use DBI;
use strict;

my $dbh = DBI->connect('dbi:mysql:deals','graywzc','2326838') 
or die "Connection Error: $DBI::errstr\n";

my $keywordsearch = "keywordsearch";
my $sql = "update $keywordsearch set buffer=''";
my $getsubscr = $dbh->prepare($sql);
$getsubscr->execute or die "can't set subscriptions !\n";
