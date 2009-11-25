#!/usr/bin/perl -w

# Generates a checkerboard image using Cairo.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 25 Nov 2009 

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring 
# rights to this work. 
# http://creativecommons.org/publicdomain/zero/1.0/

# Example
# ./checkerboard.pl --xcheckers 10 --ycheckers 10 --imagewidth 600 \
# --imageheight 300 --fgcolour '0 0 0'

use strict;

use Cairo;
use Filter::Arguments;

#argument processing
my $surf_width = Argument(alias=>'imagewidth', default=>'500');
my $surf_height = Argument(alias=>'imageheight', default=>'500');
my $checker_xcount = Argument(alias=>'xcheckers', default=>10);
my $checker_ycount = Argument(alias=>'ycheckers', default=>10);
my $colour_fg = Argument(alias=>'fgcolour', default=>"255 255 255");
my $colour_bg = Argument(alias=>'bgcolour', default=>"");
my $check_order = Argument(alias=>'checkorder', default=>"0");
my $output = Argument(alias=>'output', default=>"output.png");
#my ($debug) = Arguments(default=>"false");

#if ($debug eq "false") {$debug = 0};
Arguments::verify_usage();


my ($r2, $g2, $b2); #background colour, undefined for transparent
if ($colour_bg =~ /(\d+) +(\d+) +(\d+)/) {
    ($r2, $g2, $b2) = ($1, $2, $3);
}

#create the cairo surface and context
my $surface = Cairo::ImageSurface->create ('argb32', $surf_width, $surf_height);
my $cr = Cairo::Context->create ($surface);

my $checker_width = $surf_width/$checker_xcount;
my $checker_height = $surf_height/$checker_ycount;

#if checkorder == 0 fg in top left, else bg in top left
my $alt;
if ($check_order) {
    $alt = 0;
}else{
    $alt = 1;
}

$colour_fg =~ /(\d+) +(\d+) +(\d+)/;
my ($r, $g, $b) = ($1, $2, $3);

for (my $x = 0; $x < $surf_width; $x += $checker_width) {
    my $last_top = $alt;
    $alt = !$alt;
    for (my $y = 0; $y < $surf_height; $y += $checker_height) {
        $alt = !$alt;
        
        if ($alt) {
            $cr->rectangle ($x, $y, $checker_width, $checker_height);
            #if ($debug) {print STDERR "fg: $x $y $checker_width $checker_height $alt\n"};
            $cr->set_source_rgb ($r, $g, $b);
            $cr->fill;
        }elsif ((defined $r2) && (defined $g2) && (defined $b2)) {
            $cr->rectangle ($x, $y, $checker_width, $checker_height);
            #if ($debug) {print STDERR "bg: $x $y $checker_width $checker_height\n"};
            $cr->set_source_rgb ($r2, $g2, $b2);
            $cr->fill;
        }
    }
    $alt = !$last_top; #must change to opposite
}

$cr->show_page;

$surface->write_to_png ("$output");
