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

# Geom transforms
pipeline_transforms.sh


exit 0



# Make horn- and level-specific gray matter ROI images
make_gm_rois.py ${FMRI}_moco_GM.nii.gz ${FMRI}_moco_LABEL.nii.gz 


# RETROICOR
# First split physlog into card and resp, and trim to match length of scan.
parse_physlog.py SCANPHYSLOG*.log 496 fmri.dcm
RetroTS.py -r physlog_respiratory.csv -c physlog_cardiac.csv -p 496 -n 1 \
    -v `cat volume_acquisition_time.txt` -cardiac_out 0 -prefix ricor
cleanup_physlog.py


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
	 -w warp_${FMRI}_moco_mean2${MFFE}.nii.gz \
	 -d i${MFFE}.nii.gz -o ${IMG}_imffespace.nii.gz

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_${FMRI}_moco_mean2${MFFE}.nii.gz warp_i${MFFE}_gw2PAM50_gw.nii.gz \
	 -d ${TDIR}/PAM50_t2s.nii.gz -o ${IMG}_PAM50space.nii.gz

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




