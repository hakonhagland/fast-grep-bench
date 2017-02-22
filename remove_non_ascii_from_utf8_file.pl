#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Data::Printer;

my $fn = shift @ARGV;

open ( my $fh, '<:utf8', $fn ) or die "Could not open file '$fn': $!";
while( <$fh> ) {
    chomp;
    s/[^A-Za-z]//g; 
    say;
}
close $fh;
