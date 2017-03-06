#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Data::Printer;
use FGB::Common;

my $param = FGB::Common::get_param();
my $fn = $param->{file1_name};
open ( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
chomp(my @words = <$fh>);
FGB::Common::write_ikegami_regexp_file( $param, \@words );
