#! /usr/bin/env perl

use strict;
use warnings;

my $smallfile = '../../file1.txt';
my $bigfile   = '../../file2.txt';

my $outfile = 'out.txt';

open my $fh, '<', $smallfile or die "Can't open $smallfile: $!";

my %word = map { chomp; $_ => 1 } <$fh>;

open    $fh,     '<', $bigfile or die "Can't open $bigfile: $!";   
open my $fh_out, '>', $outfile or die "Can't open $outfile: $!";

while ( <$fh>)  {
    exists $word{ (/\|([^|]+)/)[0] } && print $fh_out $_;  

    # Or
    #exists $word{ (split /\|/)[1] } && print $fh_out $_;
}

close $fh_out;
close $fh;
