#!/bin/bash


INFO="${PROJECT} ${SUBJECT} ${SESSION} ${SCAN}"

KSQRT=$(get_ijk.py s mffe1.nii.gz)

DS=$(date)

# ROI signals before and after filtering
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
roisignal_Lventral_slice1.png \
roisignal_Lventral_slice3.png \
roisignal_Lventral_slice5.png \
roisignal_Lventral_slice7.png \
roisignal_Lventral_slice9.png \
roisignal_Lventral_slice11.png \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_roisignals.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_roisignals.png -resize 1194x1354 \) -geometry +0+0 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nROI signals" \
page_roisignals.png


# Levels
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( t2sag_levels.png -annotate +10+30 "Levels" \) \
\( fmri_levels.png -annotate +10+30 "on mean fMRI" \) \
\( movement.png \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_levels.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_levels.png -resize 1194x1354 \) -geometry +0+0 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nLevel-finding and fMRI movement" \
page_levels.png


# Subject GM overlaid on mffe, fmri, template
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( registration_cor_mffe.png -annotate +10+30 "Subject\nmFFE,\nRed =\n  Subj GM" \) \
\( registration_cor_fmri.png -annotate +10+30 "Subject\nmean fMRI" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_cor.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_cor.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nCoronal view in template space" \
page_cor.png


# ROIs by level
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
roi_slice*.png \
-border 10 -bordercolor white page_roi.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_roi.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nROIS by level" \
page_roi.png


# fMRI registration
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
fmriregistration_slice*.png \
-border 10 -bordercolor white page_fmri.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_fmri.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\nmFFE segmentation on fMRI" \
page_fmri.png


# Connectivity maps, slice
for roi in Rdorsal Rventral Ldorsal Lventral ; do
	
  montage -mode concatenate \
  -stroke white -fill white -pointsize 20 \
  -tile ${KSQRT}x -quality 100 -background white -gravity center \
  R_${roi}_slice*.png \
  -border 10 -bordercolor white page_roi_${roi}.png

  convert \
  -size 1224x1584 xc:white \
  -gravity center \( page_roi_${roi}.png -resize 1194x1354 \) -geometry +0+60 -composite \
  -gravity SouthEast -pointsize 24 -annotate +15+10 "$DS" \
  -gravity NorthWest -pointsize 24 -annotate +15+20 "${INFO}\n${roi} connectivity (R) within slice" \
  page_roi_${roi}.png

done


# Stitch together
convert \
  page_levels.png \
  page_cor.png \
  page_fmri.png \
  page_roi.png \
  page_roisignals.png \
  page_roi_*.png \
  fmri_report.pdf
