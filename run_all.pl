#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Cwd;
use Getopt::Long;
use Data::Printer;
use List::Util qw(max shuffle);

GetOptions (
    "verbose"    => \my $verbose,
    "check"      => \my $check,
    "expected=i" => \my $expected_no_lines,
) or die("Error in command line arguments\n");

my $test_dir    = 'solutions';
my $output_file = 'out.txt';
my $wc_expected = $expected_no_lines; # expected number of output lines

my $tests = get_test_names( $test_dir );

chdir $test_dir;
my $cmd = 'run.sh';
my @times;
for my $case (@$tests) {
    my $savedir = getcwd();
    chdir $case;
    say "Running '$case'..";
    my $output = `bash -c "{ time -p $cmd; } 2>&1"`;
    my ($user, $sys, $real ) = get_run_times( $output );
    print_timings( $user, $sys, $real ) if $verbose;
    check_output_is_ok( $output_file, $wc_expected, $verbose, $check );
    print "\n" if $verbose;
    push @times, $user + $sys;
    chdir $savedir;
}

say "Done.\n";

print_summary( $tests, \@times );

sub print_timings {
    my ( $user, $sys, $real ) = @_;

    say "..finished in $real seconds"
      . " ( user: $user, sys: $sys )"; 

}

sub get_run_times {
    my ( $output ) = @_;

    my ( $real, $user, $sys ) = $output =~ /^(?:real|user|sys)\s*(\S+)/mg;

    return ($user, $sys, $real );
}

sub print_summary {
    my ( $tests, $times ) = @_;

    my $N = max map length, @$tests;
    say "Summary";
    say "-------";

    printf "%-${N}s : %.4gs\n", $_->[0], $_->[1] for
      sort { $a->[1] <=> $b->[1] }
      map [$tests->[$_], $times->[$_]], 0..$#$tests; 
}

sub check_output_is_ok {
    my ( $fn, $expected, $verbose, $check ) = @_;
    my $count = 0;
    open ( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
    $count++ while <$fh>;
    close $fh;
    if ( $verbose ) {
        print "..no of output lines: $count";
        if ( $check ) {
            my $ok_str = ( $count == $expected ) ? "ok" : "not ok";
            print " ( $ok_str )";
        }
        print "\n";
    }
}

sub get_test_names {
    my ( $dir ) = @_;
    
    my $curdir = getcwd();
    chdir $dir;
    my @tests = List::Util::shuffle grep { -d } <*>; 
    chdir $curdir;
    return \@tests;
}
