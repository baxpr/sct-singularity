#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

# Image filenames are <geometry>_<content>.nii.gz
# Template content always marked as "template". Otherwise it's subject content

# Use first echo of mffe
cp mffe1.nii.gz mffe_mffe.nii.gz

# T2 sagittal
cp t2sag.nii.gz t2sag_t2sag.nii.gz

# fMRI
cp fmri.nii.gz fmri_fmri.nii.gz

# MFFE processing
pipeline_mffe.sh

# T2SAG processing for vertebral labels, markers. Includes registration to mffe
pipeline_t2sag.sh

# Registration to template
pipeline_templatereg.sh

# fMRI processing
pipeline_fmri.sh

# Generate RETROICOR regressors
parse_physlog.py SCANPHYSLOG*.log 496 fmri.dcm
RetroTS.py -r physlog_respiratory.csv -c physlog_cardiac.csv -p 496 -n 1 \
    -v `cat volume_acquisition_time.txt` -cardiac_out 0 -prefix ricor
cleanup_physlog.py

# Geom transforms
pipeline_transforms.sh


# Regression-based cleanup of confounds
regress.py

# Compute connectivity images
compute_connectivity_slice.py
compute_connectivity_level.py

# Resample connectivity images to mffe and template space
for IMG in \
  connectivity_r_slice \
  connectivity_z_slice \
  connectivity_r_level \
  connectivity_z_level \
  ; do

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_fmri2mffe.nii.gz \
	 -d imffe_mffe.nii.gz -o imffe_${IMG}.nii.gz

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
	 -d PAM50_template_t2s_cropped.nii.gz -o PAM50_${IMG}.nii.gz

 done


 # Output QA PDF
 xvfb-run --server-num=$(($$ + 99)) \
 --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
 make_pdf.sh

 convert_pdf.sh
 


# Retroicor:
# 
# Motion correction first: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2833099/
#
# Barry 2014 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4120419/
#
# Another procedure using FSL / PNM https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5315056/
#     popp, pnm_evs




