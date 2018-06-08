#!/usr/bin/perl

# this script doing job like uniq -c
# default output of uniq is
# 	<Spaces> count <Space> pattern <Enter>
#
# and uniqc.pl output as 
#	pattern <Tab> count <Enter>
#
# which is much easier for downstream parser

use strict ;

my $lastidx = <> ;
chomp ($lastidx) ;
my $n = 1 ;

while (<>) {
    chomp ;
    if ($lastidx ne $_ ) {
	print "$lastidx\t$n\n" ;
	$n = 0 ;
    } 

    $n++ ;
    print "$_\t$n\n" if (eof) ;
    $lastidx = $_ ;
}
