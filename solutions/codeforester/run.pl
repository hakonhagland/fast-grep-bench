#! /usr/bin/env perl

use strict;
use warnings;

my $small_file = '../../file1.txt';
my $big_file   = '../../file2.txt';

my ($small_fp, $big_fp, %small_hash, $field);

open($small_fp, "<", $small_file) || die "Can't open $small_file: " . $!;
open($big_fp, "<", $big_file)     || die "Can't open $big_file: "   . $!;

# store contents of small file in a hash
while (<$small_fp>) {
  chomp;
  $small_hash{$_} = undef;
}
close($small_fp);

# loop through big file and find matches
while (<$big_fp>) {
  # no need for chomp
  $field = (split(/\|/, $_))[1];
  if (defined($field) && exists($small_hash{$field})) {
    printf("%s", $_);
  }
}

close($big_fp);


