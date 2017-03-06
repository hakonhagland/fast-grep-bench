#! /usr/bin/env perl

use strict;
use warnings;
use Inline C => './search.c';

my $smallfile = '../../file1.txt';
my $bigfile   = '../../file2.txt';

open my $fh, '<', $smallfile or die "Can't open $smallfile: $!";

my %word = map { chomp; $_ => 1 } <$fh>;

search( $bigfile, \%word );
