#!/usr/bin/env perl

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

use strict;
use warnings;

my $params = {  # specific parameters that may need tuning when either template files or the font changes:

    'font_colour'   => 'green',
    'font_size'     => 40,

    'coord' => [
        {       # geometric params for the odd pages:
            'template_file' => 'templates/WorkPlan_page1.jpg',
            'date_x_offset' => 130,
            'date_y_offset' => 330,
            'gap_1'         =>   8,
            'gap_2'         =>   9,
            'text_x_offset' =>  50,
            'plan_y_offset' => 500,
            'done_y_offset' => 920,

        },
        {       # geometric params for the even pages:
            'template_file' => 'templates/WorkPlan_page2.jpg',
            'date_x_offset' => 130,
            'date_y_offset' => 105,
            'gap_1'         =>   8,
            'gap_2'         =>   9,
            'text_x_offset' =>  50,
            'plan_y_offset' => 270,
            'done_y_offset' => 730,
        },
    ],
};

sub parse_diary_file {
    my $filename = shift @_;

    my (@test_data, $state, $entry);

    open(my $diary_file, '<', $filename) or die "Could not open $filename, please investigate";
    while(my $line=<$diary_file>) {
        chomp $line;
        if($line=~/^(?:Mon|Tue|Wed|Thu|Fri),\s*(\d{4})\_(\d+)\_(\d+):/) {
            if($entry) {   # flush any previously recorded data
                push @test_data, $entry;
            }
            $entry = { 'date' => [ $1, $2, $3 ], 'plan' => [], 'done' => [] };
            $state = undef;

        } elsif($line eq 'Plan:') {
            $state = 'plan';

        } elsif($line eq 'Done:') {
            $state = 'done';

        } elsif($line!~/^#/) {  # (commented out lines should be skipped by the parser)
            if($state) {    # keep adding lines to the current state's buffer:
                push @{$entry->{$state}}, $line;
            } else {
                die "No valid state, check your format";
            }
        }
    }
    close $diary_file;

    if($entry) {   # flush any previously recorded data
        push @test_data, $entry;
    }

    return \@test_data;
}


sub generate_pages {
    my $parsed_data = shift @_;


    foreach my $idx (0..scalar(@$parsed_data)-1) {
        my $entry               = $parsed_data->[$idx];
        my ($year,$month,$day)  = @{$entry->{'date'}};

        my ($template_file, $date_x_offset, $date_y_offset, $gap_1, $gap_2, $text_x_offset, $plan_y_offset, $done_y_offset)
            = @{$params->{'coord'}[ $idx % 2 ]}
                {'template_file','date_x_offset','date_y_offset','gap_1','gap_2','text_x_offset','plan_y_offset','done_y_offset'};

        my $output_filename = sprintf("WP_%4d_%02d_%02d.jpg", $year, $month, $day);

        print "Generating $output_filename...\n";

        system( 'convert',
                $template_file,
                -fill       => $params->{'font_colour'},
                -pointsize  => $params->{'font_size'},
                -draw => sprintf("text %d,%d '%02d%s%02d%s%4d'", $date_x_offset, $date_y_offset, $day, ' 'x$gap_1, $month, ' 'x$gap_2, $year),
                -draw => sprintf("text %d,%d '%s'", $text_x_offset, $plan_y_offset, join("\n", @{$entry->{'plan'}}) ),
                -draw => sprintf("text %d,%d '%s'", $text_x_offset, $done_y_offset, join("\n", @{$entry->{'done'}}) ),
                $output_filename,
        );
    }
}

my $filename = $ARGV[0] || 'test_diary.txt';
my $parsed_data = parse_diary_file( $filename );
generate_pages( $parsed_data );

