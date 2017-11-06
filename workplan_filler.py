#!/usr/bin/env python3

# Generate dated pages for "My Work Plan" booklet and insert the text into it.
#
# This software is not official. By using it you assume all risks and liabilities.

import sys
import yaml
from datetime import datetime
from subprocess import call

def parse_yml_file(filename):
    with open(filename, 'r') as stream:
        try:
            return(yaml.load(stream))
        except yaml.YAMLError as exc:
            print(exc)
            sys.exit(2)

def join_together(input):
    if(type(input) == list):
        return "\n".join(input)
    else:
        return input

def generate_pages(parsed_data):

    layout  = parse_yml_file('page_layout.yml');

    for idx in range(len(parsed_data)):
        entry           = parsed_data[idx]

        parsed_date     = datetime.strptime(entry['Date'], '%a, %Y_%m_%d')
        year            = parsed_date.year
        month           = parsed_date.month
        day             = parsed_date.day
        output_filename = 'WP_%4d_%02d_%02d.jpg' % (year, month, day)

        plan_text       = join_together( entry['Plan'] )
        done_text       = join_together( entry['Done'] )

        layout_page     = layout['coord'][idx % 2]

        (template_file, date_x_offset, date_y_offset, gap_1, gap_2, text_x_offset, plan_y_offset, done_y_offset) = \
            [ layout_page[k] for k in
                ('template_file','date_x_offset','date_y_offset','gap_1','gap_2','text_x_offset','plan_y_offset','done_y_offset')
            ]

        print('Generating %s ...' % output_filename)

        call([  'convert',      template_file,
                '-fill',        str( layout['font_colour'] ),
                '-pointsize',   str( layout['font_size'] ),
                '-draw',        ("text %d,%d '%02d%s%02d%s%4d'" % (date_x_offset, date_y_offset, day, ' ' * gap_1, month, ' ' * gap_2, year)),
                '-draw',        ("text %d,%d '%s'" % (text_x_offset, plan_y_offset, plan_text )),
                '-draw',        ("text %d,%d '%s'" % (text_x_offset, done_y_offset, done_text )),
                output_filename,
        ]);

if sys.argv[1:] :
    generate_pages( parse_yml_file(sys.argv[1]) )
else:
    print("Please provide your diary.yml filename as the first argument")
    sys.exit(1)

