#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Cwd;
use Getopt::Long;
use Data::Printer;
use FGB::Common;
use List::Util qw(max shuffle);
use Number::Bytes::Human qw(format_bytes);
use Sys::Info;

GetOptions (
    "verbose"       => \my $verbose,
    "check"         => \my $check,
    "single-case=s" => \my $case,
    "expected=i"    => \my $expected_no_lines,
) or die("Error in command line arguments\n");

my $test_dir    = 'solutions';
my $output_file = 'out.txt';
my $wc_expected = $expected_no_lines; # expected number of output lines

my $tests       = get_test_names( $test_dir, $case );

my $file2_size  = get_file2_size();
my $num_cpus    = Sys::Info->new()->device( CPU => () )->count;

chdir $test_dir;
my $cmd = 'run.sh';
my @times;
for my $case (@$tests) {
    my $savedir = getcwd();
    chdir $case;
    say "Running '$case'..";
    my $arg = get_cmd_args( $case, $file2_size, $num_cpus );
    my $output = `bash -c "{ time -p $cmd $arg; } 2>&1"`;
    my ($user, $sys, $real ) = get_run_times( $output );
    print_timings( $user, $sys, $real ) if $verbose;
    check_output_is_ok( $output_file, $wc_expected, $verbose, $check );
    print "\n" if $verbose;
    push @times, $real;
    #push @times, $user + $sys; # this is wrong when using Gnu parallel
    chdir $savedir;
}

say "Done.\n";

print_summary( $tests, \@times );

sub get_file2_size {
    return -s "file2.txt";
}

sub get_cmd_args {
    my ( $case, $file2_size, $ncpus ) = @_;
    my $arg = '';
    if ( $case eq "gregory1" ) {
        my $block_size = $file2_size / $ncpus;
        $arg = Number::Bytes::Human::format_bytes( $block_size );
    }
    return $arg;
}

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
    my ( $dir, $case ) = @_;

    my @tests;
    if ( defined $case ) {
        @tests = ( $case );
    }
    else {
        my $skip = FGB::Common::get_skip_test_names( );
        my $curdir = getcwd();
        chdir $dir;
        @tests = List::Util::shuffle grep { -d && (!exists $skip->{$_}) } <*>; 
        chdir $curdir;
    }
    return \@tests;
}
