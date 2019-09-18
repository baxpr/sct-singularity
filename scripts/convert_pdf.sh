#!/bin/bash


# Subject GM overlaid on mffe, fmri, template
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( registration_cor_mffe.png -annotate +10+30 "Subject\nmFFE,\nRed =\n  Subj GM" \) \
\( registration_cor_fmri.png -annotate +10+30 "Subject\nmean fMRI" \) \
\( registration_cor_template.png -annotate +10+30 "PAM50\ntemplate" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page1.png

# Slicewise reports on mFFE
KSQRT=$(get_ijk.py s mffe1.nii.gz)

montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
roi_slice*.png \
-border 10 -bordercolor white page2.png
