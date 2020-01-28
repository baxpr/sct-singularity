#!/bin/bash


INFO="${PROJECT} ${SUBJECT} ${SESSION} ${SCAN}"

KSQRT=$(get_ijk.py s mffe_mffe.nii.gz)

DS=$(date)


# Levels
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( t2sag_levels.png -annotate +10+30 "Levels" \) \
\( mffe_levels.png -annotate +10+30 "on mFFE" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_levels.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_levels.png -resize 1194x1354 \) -geometry +0+0 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nLevel-finding" \
page_levels.png


# Subject GM overlaid on mffe, template
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( registration_cor_mffe.png -annotate +10+30 "Subject\nmFFE,\nRed =\n  Subj GM" \) \
\( registration_cor_template.png -annotate +10+30 "PAM50\ntemplate" \) \
\( registration_cor_levels.png -annotate +10+30 "Subject and template \nlevels" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_cor.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_cor.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nCoronal view in template space" \
page_cor.png


# Segmentation
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
segmentation_slice*.png \
-border 10 -bordercolor white page_seg.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_seg.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSubject segmentation on mFFE" \
page_seg.png


# Template registration
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
templateregistration_slice*.png \
-border 10 -bordercolor white page_template.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_template.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSubject segmentation on template" \
page_template.png


# Stitch together
convert \
  page_levels.png \
  page_cor.png \
  page_seg.png \
  page_template.png \
  mffe_report.pdf
