#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Data::Printer;
use File::Spec::Functions qw(catfile);
use Getopt::Long;

my %opt = (
    num_lines => 1_000_000,
    case     => undef,
);
GetOptions (
    "num_lines=i" => \$opt{num_lines},
    "case=s"      => \$opt{case},
)
  or die("Error in command line arguments\n");


# Generated random words from site: https://www.randomlists.com/random-words
my $word_filename        = 'words.txt'; # 75 random words
my $case                 = $opt{case};
my $case_dir             = 'cases';
my $num_match_words      = 5;
my $num_file2_lines      = $opt{num_lines};
my $file2_words_per_line = 3;
my $file2_match_field_no = 2;
my $file1_filename       = 'file1.txt';
my $file2_filename       = 'file2.txt';
my $file1_regex_fn       = 'regexp1.txt';

my ( $words1, $words2 ) = get_words(
    $word_filename, $num_match_words, $case, $case_dir
);

if ( defined $case ) {
    copy_case_info( $case, $case_dir );
}
else {
    say "generating $num_file2_lines lines..";
    write_file1( $file1_filename, $words2 );
    write_file2(
        $file2_filename, $words1, $words2, $num_file2_lines,
        $file2_words_per_line, $file2_match_field_no
    );
    write_BOC_regexp_file( $file1_regex_fn, $words2 );
}


sub copy_case_info {
    my ( $case, $case_dir ) = @_;

    my @files = qw(file1.txt file2.txt regexp1.txt);
    say "Copying files from case '$case'..";
    for (@files) {
        my $fn = catfile( $case_dir, $case, $_ );
        say "..$fn";
        system "cp $fn .";
    }
}

sub write_BOC_regexp_file {
    my ( $fn, $words ) = @_;

    open( my $fh, '>', $fn ) or die "Could not open file '$fn': $!";
    print $fh '\\|' . (join "|", @$words) . '\\|';
    close $fh;
}

sub write_file2 {
    my ( $fn, $words1, $words2, $nlines, $words_per_line, $field_no ) = @_;


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
    my ( $fn, $words ) = @_;

    open( my $fh, '>', $fn ) or die "Could not open file '$fn': $!";
    print $fh (join "\n", sort @$words);
    close $fh;
}

sub get_words {
    my ( $fn, $N, $case, $case_dir ) = @_;

    if ( defined $case ) {
        $fn = catfile( $case_dir, $case, $fn );
    }
    open( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
    my @words = map {chomp $_; $_} <$fh>;
    close $fh;
    
    my @words1 = @words[$N..$#words];
    my @words2 = @words[0..($N - 1)];
    return ( \@words1, \@words2 );
}


