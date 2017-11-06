# workplan_helper

It is a simple script that may be useful for those officially unemployed in the UK
who are registered with a local JobCentre and need to maintain and show a record
of their continuous efforts to look for a job.

In case you find composing a simple YAML file an easier task than filling in
the so-called "My Work Plan" booklet, you are welcome to use this script.

Naturally, I cannot be held accountable for any misuse of this software
as my original intention was to simplify the tedious data entry, and to practice Python.

Running the script with your diary file on a Linux/OSX machine with ImageMagick installed
is supposed to generate a bunch of .jpg files, one filled-in page in portrait orientation
per image file. If you then print them together in 2*A5 booklet mode (OSX printer drivers
can do that out of the box), you'll get the output pretty close to the original booklet.
The main noticeable difference would be the lack of page numbers.

NB: If you discover that the format or the page layout of "My Work Plan" has changed,
you may need to re-scan the two recurring pages of the "My Work Plan" booklet
and tweak the page_layout.yml file to reflect those changes.

Feel free to tweak other parameters in page_layout.ym (such as font size/colour) or add your own.
