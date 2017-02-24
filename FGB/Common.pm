package FGB::Common;

use feature qw(say);
use strict;
use warnings;

my %param = (
    case_dir             => 'cases',
    file1_name           => 'file1.txt',
    file1_regex_fn       => 'regexp1.txt',
    file2_match_field_no => 2,
    file2_name           => 'file2.txt',
    file2_words_per_line => 3,
    output_file          => 'out.txt',
    regexp1_name         => 'regexp1.txt',
    skip_fn              => 'skip.txt',
    test_dir             => 'solutions',
    word_filename        => 'words.txt', 
);

sub get_param {
    return \%param;
}

sub get_alternate_file1_fn {
    my ( $param ) = @_;
    
    my $fn = $param->{file1_name};
    $fn =~ s/\.txt$//;
    $fn .= 'b.txt';

    return $fn;
}

sub get_alternate_file1_regexp_fn {
    my ( $param ) = @_;
    
    my $fn = $param->{file1_regex_fn};
    $fn =~ s/\.txt$//;
    $fn .= 'b.txt';

    return $fn;
}

sub get_alternate_filenames {
    my ( $param ) = @_;

    return (get_alternate_file1_fn( $param ), get_alternate_file1_regexp_fn( $param ));
}

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
