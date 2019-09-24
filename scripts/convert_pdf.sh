#!/bin/bash

PROJECT=TESTPROJ
SUBJECT=TESTSUBJ
SESSION=TESTSESS
SCAN=TESTSCAN

INFO="${PROJECT} ${SUBJECT} ${SESSION} ${SCAN}"

KSQRT=$(get_ijk.py s mffe1.nii.gz)


# Subject GM overlaid on mffe, fmri, template
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
\( registration_cor_mffe.png -annotate +10+30 "Subject\nmFFE,\nRed =\n  Subj GM" \) \
\( registration_cor_fmri.png -annotate +10+30 "Subject\nmean fMRI" \) \
\( registration_cor_template.png -annotate +10+30 "PAM50\ntemplate" \) \
-tile 2x -quality 100 -background white -gravity center \
-border 10 -bordercolor white page_cor.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_cor.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "Coronal view\n${INFO}" \
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
-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "ROIS by level\n${INFO}" \
page_roi.png


# Segmentation
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
segmentation_slice*.png \
-border 10 -bordercolor white page_seg.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_seg.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "Segmentation on mFFE\n${INFO}" \
page_seg.png


# fMRI registration
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
fmriregistration_slice*.png \
-border 10 -bordercolor white page_fmri.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_fmri.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "mFFE segmentation on fMRI\n${INFO}" \
page_fmri.png


# Template registration
montage -mode concatenate \
-stroke white -fill white -pointsize 20 \
-tile ${KSQRT}x -quality 100 -background white -gravity center \
templateregistration_slice*.png \
-border 10 -bordercolor white page_template.png

convert \
-size 1224x1584 xc:white \
-gravity center \( page_template.png -resize 1194x1354 \) -geometry +0+60 -composite \
-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
-gravity NorthWest -pointsize 24 -annotate +15+20 "mFFE segmentation on template\n${INFO}" \
page_template.png


# Connectivity maps
for r in 0 1 2 3 ; do
	
	montage -mode concatenate \
	-stroke white -fill white -pointsize 20 \
	-tile ${KSQRT}x -quality 100 -background white -gravity center \
	connectivity_r_roi${r}_slice*.png \
	-border 10 -bordercolor white page_roi${r}.png

	convert \
	-size 1224x1584 xc:white \
	-gravity center \( page_roi${r}.png -resize 1194x1354 \) -geometry +0+60 -composite \
	-gravity SouthEast -pointsize 24 -annotate +15+10 "$(date)" \
	-gravity NorthWest -pointsize 24 -annotate +15+20 "Connectivity of ROI ${r} within slice\n${INFO}" \
	page_roi${r}.png
	
done
