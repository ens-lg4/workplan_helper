#!/usr/bin/env perl

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

use strict;
use warnings;
use YAML 'LoadFile';


sub parse_yml_file {
    my $filename = shift @_;

    return LoadFile( $filename );
}


sub generate_pages {
    my $parsed_data = shift @_;

    my $layout = parse_yml_file( 'page_layout.yml' );

    foreach my $idx (0..scalar(@$parsed_data)-1) {
        my $entry               = $parsed_data->[$idx];

        my $unparsed_date       = $entry->{'Date'};
        my ($year,$month,$day);
        if($unparsed_date=~/^(?:Mon|Tue|Wed|Thu|Fri),\s*(\d{4})\_(\d+)\_(\d+)/) {
            ($year,$month,$day) = ($1, $2, $3);
        }
        my $plan_text           = (ref($entry->{'Plan'}) eq 'ARRAY') ? join("\n", @{$entry->{'Plan'}}) : $entry->{'Plan'};
        my $done_text           = (ref($entry->{'Done'}) eq 'ARRAY') ? join("\n", @{$entry->{'Done'}}) : $entry->{'Done'};

        my ($template_file, $date_x_offset, $date_y_offset, $gap_1, $gap_2, $text_x_offset, $plan_y_offset, $done_y_offset)
            = @{$layout->{'coord'}[ $idx % 2 ]}
                {'template_file','date_x_offset','date_y_offset','gap_1','gap_2','text_x_offset','plan_y_offset','done_y_offset'};

        my $output_filename = sprintf("WP_%4d_%02d_%02d.jpg", $year, $month, $day);

        print "Generating $output_filename...\n";

        system( 'convert',
                $template_file,
                -fill       => $layout->{'font_colour'},
                -pointsize  => $layout->{'font_size'},
                -draw => sprintf("text %d,%d '%02d%s%02d%s%4d'", $date_x_offset, $date_y_offset, $day, ' 'x$gap_1, $month, ' 'x$gap_2, $year),
                -draw => sprintf("text %d,%d '%s'", $text_x_offset, $plan_y_offset, $plan_text ),
                -draw => sprintf("text %d,%d '%s'", $text_x_offset, $done_y_offset, $done_text ),
                $output_filename,
        );
    }
}


if(scalar(@ARGV) == 1) {
    generate_pages( parse_yml_file( $ARGV[0] ) );
} else {
    die "Please provide your diary.yml filename as the first argument\n";
}

