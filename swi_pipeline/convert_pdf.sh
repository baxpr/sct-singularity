#!/bin/bash


INFO="${PROJECT} ${SUBJECT} ${SESSION} ${SCAN}"

KSQRT=$(get_ijk.py s mffe_mffe.nii.gz)

DS=$(date)


# Subject mffe + SWI
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( mffe_mffe.png -annotate +10+30 "Subject\nmFFE" \) \
\( mffe_swimag.png -annotate +10+30 "Subject\nSWI mag" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_mffe.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_mffe.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSagittal view in mFFE space" \
page_mffe.png


# Subject mffe + SWI, PAM50
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( PAM50_mffe.png -annotate +10+30 "Subject\nmFFE" \) \
\( PAM50_swimag.png -annotate +10+30 "Subject\nSWI mag" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_pam50.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_pam50.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSagittal view in PAM50 space" \
page_pam50.png


# SWI before filtering
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
before_slice*.png \
-border 10 -bordercolor white page_before.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_before.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSWI in mFFE space before filtering" \
page_before.png


# SWI after filtering
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
after_slice*.png \
-border 10 -bordercolor white page_after.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_after.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSWI in mFFE space after filtering" \
page_after.png


# SWI after filtering, mips
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
mip11_slice*.png \
-border 10 -bordercolor white page_mip11.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_mip11.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSWI, 5.5mm mIP" \
page_mip11.png

montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
mip21_slice*.png \
-border 10 -bordercolor white page_mip21.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_mip21.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nSWI, 10.5mm mIP" \
page_mip21.png


# Stitch together
convert \
  page_mffe.png \
  page_pam50.png \
  page_before.png \
  page_after.png \
  page_mip11.png \
  page_mip21.png \
  swi_report.pdf
