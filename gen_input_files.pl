#! /usr/bin/env perl

use feature qw(say);
use lib '.';
use strict;
use warnings;

use Data::Printer;
use FGB::Common;
use File::Spec::Functions qw(catfile);
use Getopt::Long;
use JSON;
use POSIX qw(locale_h);

# Assumptions:
#
#  1.  File words.txt is defined in current directory
#

my %opt = (
    force_regen=> 0,  #force regeneration of files when $opt{case} is given
    num_words  => 100,
    num_lines  => 10_000_000,
    case       => undef, # copy files from a specific case instead of generating files.
);

GetOptions (
    "num-words=i" => \$opt{num_words},
    "num-lines=i" => \$opt{num_lines},
    "case=s"      => \$opt{case}, # do not generate anything, just copy existing case
    "force-regen" => \$opt{force_regen},
)
  or die("Error in command line arguments\n");

my $param = FGB::Common::get_param();

# Generated random words were taken from two different sources:
#  1. https://www.randomlists.com/random-words
#  2. Local file: /usr/share/dict/american-english (99171 words)
my $case                 = $opt{case};

if ( (defined $case ) && ( !$opt{force_regen} )  ) {
    copy_case_info( $param, $case );
}
else {
    if ( (defined $case ) && $opt{force_regen} ) {
        copy_case_words_file_to_curdir( $param, $case );
        ( $opt{num_words}, $opt{num_lines} ) = read_case_params( $param, $case );
    }
    my ( $words1, $words2 ) = get_words( $param, $case, \%opt );

    say "generating $opt{num_lines} lines (words=$opt{num_words})..";
    write_file1( $param, $words2 );
    write_file2( $param, $words1, $words2, \%opt );
    write_BOC_regexp_file( $param, $words2 );
    FGB::Common::write_ikegami_regexp_file( $param, $words2 );
}


sub read_case_params {
    my ( $param, $case ) = @_;

    my $fn = catfile( $param->{case_dir}, $case, $param->{case_param_file_name} );
    open ( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
    my $str = do {local $/; <$fh>};
    close $fh;
    my $h = JSON::decode_json( $str );
    return ( $h->{"num-words"}, $h->{"num-lines"} );
}

sub copy_case_words_file_to_curdir {
    my ( $param, $case ) = @_;

    my $fn = catfile( $param->{case_dir}, $case, $param->{word_filename} );
    say "Copying file '$fn'.. to current dir";
    system "cp $fn .";
}

sub copy_case_info {
    my ( $param, $case ) = @_;

    my $case_dir = $param->{case_dir};
    my @keys =
      qw( 
            file1_name file1_name_collate_c file1_ikegami_regex_fn 
            file2_name file2_name_collate_c
            file1_regex_fn skip_fn word_filename 
    );
    my @files = @{ $param }{@keys};
    push @files, FGB::Common::get_alternate_filenames( $param );
    
    say "Copying files from case '$case'..";
    for (@files) {
        my $fn = catfile( $case_dir, $case, $_ );
        say "..$fn";
        system "cp $fn .";
    }
}

sub write_BOC_regexp_file {
    my ( $param, $words ) = @_;

    my $fn = $param->{file1_regex_fn};
    my $fn2 = FGB::Common::get_alternate_file1_regexp_fn( $param );
    my $regexp = '\\|' . (join "|", @$words) . '\\|';
    open( my $fh, '>', $fn ) or die "Could not open file '$fn': $!";
    print $fh $regexp;
    close $fh;
    open( my $fh2, '>', $fn2 ) or die "Could not open file '$fn2': $!";
    print $fh2 '^[^|]*' . $regexp;
    close $fh2;
}

sub write_file2 {
    my ( $param, $words1, $words2, $opt ) = @_;

    my $nlines = $opt->{num_lines};
    my $fn = $param->{file2_name};
    my $words_per_line = $param->{file2_words_per_line};
    my $field_no = $param->{file2_match_field_no};
    
    my $nwords1 = scalar @$words1;
    my $nwords2 = scalar @$words2;
    my @lines;
    for (1..$nlines) {
        my @words_line;
        my $key;
        for (1..$words_per_line) {
            my $word;
            if ( $_ != $field_no ) {
                my $index = int (rand $nwords1);
                $word = @{ $words1 }[$index];
            }
            else {
                my $index = int (rand($nwords1 + $nwords2) );
                if ( $index < $nwords2 ) {
                    $word = @{ $words2 }[$index];
                }
                else {
                    $word =  @{ $words1 }[$index - $nwords2];
                }
                $key = $word;
            }
            push @words_line, $word;
        }
        push @lines, [$key, (join "|", @words_line)];
    }
    @lines = map { $_->[1] } sort { $a->[0] cmp $b->[0] } @lines; 
    open( my $fh, '>', $fn ) or die "Could not open file '$fn': $!";
    print $fh (join "\n", @lines);
    close $fh;
}

sub write_file1 {
    my ( $param, $words ) = @_;

    {
        use locale;  # Use the default LC_COLLATE locale here:
        FGB::Common::write_sorted_array_to_file( $param->{file1_name}, $words );
    }
    # This file is only used by method 'Vasiliou2' (uses LC_COLLATE=C)
    FGB::Common::write_sorted_array_to_file( $param->{file1_name_collate_c}, $words );
    
    # Format file1.txt differently for some of the methods.
    # I.e., write the original file1.txt and a modified file1b.txt.
    # file1b.txt will be used by the methods that use regex search to find
    # the field match.
    my $fn2 = FGB::Common::get_alternate_file1_fn( $param );
    open( my $fh2, '>', $fn2 ) or die "Could not open file '$fn2': $!";
    print $fh2 (join "\n", map { '^[^|]*\|' . $_ . '\|'} sort @$words);
    close $fh2;
    
}

sub get_words {
    my ( $param, $case, $opt ) = @_;

    my $N = $opt->{num_words};
    my $fn = $param->{word_filename};
    open( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
    my @words = map {chomp $_; $_} <$fh>;
    close $fh;

    my @words1 = @words[$N..$#words];
    my @words2 = @words[0..($N - 1)];
    return ( \@words1, \@words2 );
}


