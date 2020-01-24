#!/bin/bash

# Resample connectivity images to mffe and PAM50 spaces
for IMG in R_slice Z_slice ; do

     sct_apply_transfo -i fmri_${IMG}.nii.gz \
	 -w warp_fmri2mffe.nii.gz \
	 -d mffe_mffe.nii.gz -o mffe_${IMG}.nii.gz

     sct_apply_transfo -i fmri_${IMG}.nii.gz \
	 -w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
	 -d PAM50_template_t2s_cropped.nii.gz -o PAM50_${IMG}.nii.gz

 done
