#!/bin/bash


# Subject GM overlaid on mffe, fmri, template
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( registration_cor_mffe.png -annotate +10+30 "MFFE" \) \
\( registration_cor_fmri.png -annotate +10+30 "FMRI" \) \
\( registration_cor_template.png -annotate +10+30 "TEMPLATE" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page1.png

