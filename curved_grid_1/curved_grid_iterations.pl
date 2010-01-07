#!/usr/bin/perl -w

# Generates a kind of curved grid.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 4 Jan 2010

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring 
# rights to this work. 
# http://creativecommons.org/publicdomain/zero/1.0/

# Example
# ./curved_grid_iterations.pl --lines 8 --circle

use strict;

use Cairo;
use Filter::Arguments;

my $PI = 3.14159265;

#argument processing
my $surf_width = Argument(alias=>'imagewidth', default=>'500');
my $surf_height = Argument(alias=>'imageheight', default=>'500');
my $quad_lines = Argument(alias=>'lines', default=>'4');
#my $inc = Argument(alias=>'inc', default=>'20');
my $colour_fg = Argument(alias=>'fgcolour', default=>'0 0 0');

my $single = Argument(alias=>'single', default=>'1');
my $double = Argument(alias=>'double', default=>'0');
my $quad = Argument(alias=>'quad', default=>'0');

my $circle = Argument(alias=>'circle', default=>'0');
my $output = Argument(alias=>'output', default=>"output.svg");

Arguments::verify_usage();

$colour_fg =~ /(\d+) +(\d+) +(\d+)/;
my ($r, $g, $b) = ($1, $2, $3);

#if --lines = 2 then those 2 lines are on the boarder.
$quad_lines = 2 if ($quad_lines < 2);

#create the cairo surface and context
#my $surface = Cairo::ImageSurface->create ('argb32', $surf_width, $surf_height);
my $surface = Cairo::SvgSurface->create ("$output", $surf_width, $surf_height);
my $cr = Cairo::Context->create ($surface);


for (my $it = 2; $it <= $quad_lines; $it++) {
    my $inc = $surf_width / ($it-1);
    
    $cr->set_source_rgba ($r, $g, $b, ($it / $quad_lines));
    $cr->set_line_width ((1-($it / $quad_lines))*10);
    for (my $i = 0; $i <= $surf_height; $i += $inc) {
        $cr->move_to (0, $i);
        $cr->line_to ($i, $surf_height);
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

#$surface->write_to_svg ("$output");
