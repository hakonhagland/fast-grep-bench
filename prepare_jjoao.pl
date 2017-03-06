#! /usr/bin/env perl

use feature qw(say);
use strict;
use warnings;

use Data::Printer;

chdir 'solutions/jjoao';

system "build_flex.sh";
system "compile.sh";
