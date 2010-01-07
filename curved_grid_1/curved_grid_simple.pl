#!/usr/bin/perl -w

# Renders some transformed horizontal lines.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 4 Jan 2010

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring 
# rights to this work. 
# http://creativecommons.org/publicdomain/zero/1.0/

# Example
# ./curved_grid_simple.pl --double --fgcolour '0 200 0'

use strict;

use Cairo;
use Filter::Arguments;

my $PI = 3.14159265;

#argument processing
my $surf_width = Argument(alias=>'imagewidth', default=>'500');
my $surf_height = Argument(alias=>'imageheight', default=>'500');
my $quad_lines = Argument(alias=>'lines', default=>'4');
my $colour_fg = Argument(alias=>'fgcolour', default=>'0 0 0');

my $single = Argument(alias=>'single', default=>'1');
my $double = Argument(alias=>'double', default=>'0');
my $quad = Argument(alias=>'quad', default=>'0');

my $circle = Argument(alias=>'circle', default=>'0');
my $output = Argument(alias=>'output', default=>"output.png");

Arguments::verify_usage();

$colour_fg =~ /(\d+) +(\d+) +(\d+)/;
my ($r, $g, $b) = ($1, $2, $3);

#if --lines = 2 then those 2 lines are on the boarder.
$quad_lines = 2 if ($quad_lines < 2);
my $inc = $surf_width / ($quad_lines-1);

#create the cairo surface and context
my $surface = Cairo::ImageSurface->create ('argb32', $surf_width, $surf_height); #PNG
#my $surface = Cairo::SvgSurface->create ("$output", $surf_width, $surf_height); #SVG
my $cr = Cairo::Context->create ($surface);

#background (rather than transparent)
#$cr->rectangle (0, 0, $surf_width, $surf_height);
#$cr->set_source_rgb (255, 255, 255);
#$cr->fill;

$cr->set_source_rgb ($r, $g, $b);
$cr->set_line_width (1);

#bottom left quadrant
for (my $i = 0; $i <= $surf_height; $i += $inc) {
    $cr->move_to (0, $i);
    $cr->line_to ($i, $surf_height);
    $cr->stroke ();
}

#top right quadrant
if ($double || $quad) {
    for (my $i = 0; $i <= $surf_width; $i += $inc) {
        $cr->move_to ($i, 0);
        $cr->line_to ($surf_width, $i);
        $cr->stroke ();
    }
}

#other two quadrants
if ($quad) {
    for (my $i = 0; $i <= $surf_width; $i += $inc) {
        $cr->move_to (0, $i);
        $cr->line_to ($surf_width - $i, 0);
        $cr->stroke ();
    }

    for (my $i = 0; $i <= $surf_height; $i += $inc) {
        $cr->move_to ($i, $surf_height);
        $cr->line_to ($surf_width, $surf_height - $i);
        $cr->stroke ();
    }
}

if ($circle) {
    $cr->set_source_rgba (255, 0, 0, 0.5);
    $cr->set_line_width (5);
    $cr->arc ($surf_width, 0, $surf_width, $PI/2, $PI);
    $cr->stroke ();
}

$cr->show_page;

$surface->write_to_png ("$output"); #PNG
#nothing needed for SVG
