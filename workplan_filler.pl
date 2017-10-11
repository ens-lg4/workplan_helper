#!/usr/bin/env perl

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

my @lines = (
    ['26/09/2017', "I am going to write my CV", "I did write my CV"],
    ['27/09/2017', "I am going to write a bunch of applications\nand send them around", "I did write quite a few\nand sent them around"],
);

my $date_x_offset = 130;
my $text_x_offset =  50;

foreach my $idx (0..scalar(@lines)-1) {
    my ($date_string, $plan_text, $done_text) = @{$lines[$idx]};

    my ($day,$month,$year) = split('/', $date_string);
    $plan_text ||= '';
    $done_text ||= '';

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

