package FGB::Common;

use feature qw(say);
use strict;
use warnings;

my %param = (
    case_dir               => 'cases',
    case_param_file_name   => 'params.json',
    file1_name             => 'file1.txt',
    file1_regex_fn         => 'regexp1.txt',
    file1_ikegami_regex_fn => 'regexp_ikegami.txt',
    file2_match_field_no   => 2,
    file2_name             => 'file2.txt',
    file2_words_per_line   => 3,
    output_file            => 'out.txt',
    regexp1_name           => 'regexp1.txt',
    skip_fn                => 'skip.txt',
    test_dir               => 'solutions',
    word_filename          => 'words.txt', 
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

sub get_method_info {
    my ( $names ) = @_;

    my %h = (
        BOC1               => 'grep -E [loose]',
        BOC1B              => 'grep -E [strict]',
        BOC2               => 'LC_ALL grep -E [loose]',
        BOC2B              => 'LC_ALL grep -E [strict]',
        codeforester       => '[perl + split+dict]',
        codeforester_orig  => 'fgrep -f [loose]', 
        codeforester_origB => 'grep -E -f [strict]',
        dawg               => '[python + split+dict]',
        gregory1           => '[parallel + fgrep -f [loose]]',
        gregory1B          => '[parallel + grep -E -f [strict]]',
        hakon1             => '[perl + c]',
        ikegami            => 'grep -P',
        inian1             => '[awk + match($0,i) [loose]]',
        inian1B            => '[awk + match($0,i) [strict]]',
        inian2             => '[awk + index($0,i)]',
        inian3             => '[awk + split+dict]',
        inian4             => 'LC_ALL fgrep -f [loose]',
        inian4B            => 'LC_ALL grep -E -f [strict]',
        inian5             => '[LC_ALL awk + match($0,i) [loose]]',
        inian5B            => '[LC_ALL awk + match($0,i) [strict]]',
        inian6             => '[LC_ALL awk + split+dict]',
        jjoao              => '[compiled flex generated c code]',
        oliv               => '[python + compiled regex + re.search()]',
        Vasiliou           => '[join [requires sorted files]]',
        zdim               => '[perl + regexp+dict]',
        zdim2              => '[perl + split+dict]',
    );
    $h{$_} //= '' for @$names;
    return \%h;
}

1;
