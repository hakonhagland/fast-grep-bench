package FGB::Common;

use feature qw(say);
use strict;
use warnings;

sub get_skip_test_names {
    my $fn     = 'skip.txt';
    my @skip_names = ();
    if ( -f $fn ) {
        open ( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
        while (<$fh>) {
            chomp;
            push @skip_names, $_ if /./;
        }
        close $fh;
    }
    my %skip = map { $_ => 1 } @skip_names;
    return \%skip;
}

1;
