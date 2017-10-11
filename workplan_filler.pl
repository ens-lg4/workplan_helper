#!/usr/bin/env perl

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

use strict;
use warnings;

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

        } else {
            if($state) {
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

    my $date_x_offset = 130;
    my $text_x_offset =  50;

    foreach my $idx (0..scalar(@$parsed_data)-1) {
        my $entry               = $parsed_data->[$idx];
        my ($year,$month,$day)  = @{$entry->{'date'}};
        my $plan_text           = join("\n", @{$entry->{'plan'}});
        my $done_text           = join("\n", @{$entry->{'done'}});

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

my $filename = $ARGV[0] || 'test_diary.txt';
my $parsed_data = parse_diary_file( $filename );
generate_pages( $parsed_data );

