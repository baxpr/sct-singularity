#!/bin/bash
#
# Compute cross sectional areas

sct_process_segmentation \
  -i mffe_cord.nii.gz \
  -o mffe_csa.csv \
  -perslice 1 \
  -angle-corr 1 \
  -vert $(get_level_range.py mffe_cord_labeled.nii.gz) \
  -vertfile mffe_cord_labeled.nii.gz
