#! /usr/bin/env perl

use strict;
use warnings;

my $smallfile = '../../file1.txt';
my $bigfile   = '../../file2.txt';

open my $fh, '<', $smallfile or die "Can't open $smallfile: $!";

my %word = map { chomp; $_ => 1 } <$fh>;

open    $fh,     '<', $bigfile or die "Can't open $bigfile: $!";   

while ( <$fh>)  {
    # exists $word{ (/\|([^|]+)/)[0] } && print;  

    # Or
    exists $word{ (split /\|/)[1] } && print;
}

close $fh;
