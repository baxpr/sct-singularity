#!/bin/bash

# Resample connectivity images to mffe and PAM50 spaces
for metric in R Z ; do
  for roi in Rdorsal Rventral Ldorsal Lventral ; do

     sct_apply_transfo -i fmri_${metric}_${roi}_inslice.nii.gz \
	 -w warp_fmri2mffe.nii.gz \
	 -d mffe_mffe.nii.gz -o mffe_${metric}_${roi}_inslice.nii.gz

     sct_apply_transfo -i fmri_${metric}_${roi}_inslice.nii.gz \
	 -w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
	 -d PAM50_mffe.nii.gz -o PAM50_${metric}_${roi}_inslice.nii.gz

  done
 done
