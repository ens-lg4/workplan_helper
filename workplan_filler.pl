#!/usr/bin/env perl

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

use strict;
use warnings;

sub parse_diary_file {
    my $filename = shift @_;

    my (@test_data, $state, $entry_date, $entry_plan, $entry_done);

    open(my $diary_file, '<', $filename) or die "Could not open $filename, please investigate";
    while(my $line=<$diary_file>) {
        chomp $line;
        if($line=~/^(?:Mon|Tue|Wed|Thu|Fri),\s*(\d{4})\_(\d+)\_(\d+):/) {
            if($entry_date) {   # flush any previously recorded data
                push @test_data, [$entry_date, join("\n", @$entry_plan), join("\n", @$entry_done)];
            }
            $entry_date = [ $1, $2, $3 ];
            $entry_plan = [];
            $entry_done = [];
            $state = undef;

        } elsif($line eq 'Plan:') {
            $state = 'plan';

        } elsif($line eq 'Done:') {
            $state = 'done';

        } else {
            if($state eq 'plan') {
                push $entry_plan, $line;
            } elsif($state eq 'done') {
                push $entry_done, $line;
            } else {
                die "No valid state, check your format";
            }
        }
    }
    close $diary_file;

    if($entry_date) {   # flush any previously recorded data
        push @test_data, [$entry_date, join("\n", @$entry_plan), join("\n", @$entry_done)];
    }

    return \@test_data;
}


sub generate_pages {
    my $parsed_data = shift @_;

    my $date_x_offset = 130;
    my $text_x_offset =  50;

    foreach my $idx (0..scalar(@$parsed_data)-1) {
        my ($date_array, $plan_text, $done_text) = @{$parsed_data->[$idx]};

        my ($year,$month,$day) = @$date_array;

        my ($template_file, $date_y_offset, $plan_y_offset, $done_y_offset) = ($idx % 2)
            ? ('templates/WorkPlan_page2.jpg', 105, 270, 730)
            : ('templates/WorkPlan_page1.jpg', 330, 500, 920);

        my $output_filename = sprintf("WP_%4d_%02d_%02d.jpg", $year, $month, $day);

        print "Generating $output_filename...\n";

        system( 'convert',
                $template_file,
                -fill => 'green',
                -pointsize => 40, 
                -draw => sprintf("text $date_x_offset,$date_y_offset '%02d%8s%02d%9s%4d'", $day, '', $month, '', $year),
                -draw => sprintf("text $text_x_offset,$plan_y_offset '$plan_text'"),
                -draw => sprintf("text $text_x_offset,$done_y_offset '$done_text'"),
                $output_filename,
        );
    }
}

my $parsed_data = parse_diary_file( 'test_diary.txt' );
generate_pages( $parsed_data );

