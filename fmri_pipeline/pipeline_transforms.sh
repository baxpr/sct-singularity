#!/bin/bash
#
# Various image transforms between spaces


# Warp mean fmri to template space
sct_apply_transfo -i fmri_moco_mean.nii.gz \
-w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_mffe.nii.gz  -o PAM50_moco_mean.nii.gz


# Get mffe GM/WM/label/csf in fmri space
sct_apply_transfo -i ipmffe_gm.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_gm.nii.gz

sct_apply_transfo -i ipmffe_wm.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_wm.nii.gz

sct_apply_transfo -i ipmffe_csf.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_csf.nii.gz

sct_apply_transfo -i ipmffe_cord_labeled.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_cord_labeled.nii.gz


# Make horn- and level-specific gray matter ROI images
make_gm_rois.py fmri_gm.nii.gz fmri_cord_labeled.nii.gz


# Warp ROI labels to template space and mffe space
sct_apply_transfo -i fmri_gmcutlabel.nii.gz -x nn \
-w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_mffe.nii.gz -o PAM50_gmcutlabel.nii.gz

sct_apply_transfo -i fmri_gmcutlabel.nii.gz  -x nn \
-w warp_fmri2mffe.nii.gz \
-d mffe_mffe.nii.gz -o mffe_gmcutlabel.nii.gz

sct_apply_transfo -i fmri_gmcutlabel.nii.gz  -x nn \
-w warp_fmri2mffe.nii.gz \
-d ipmffe_mffe.nii.gz -o ipmffe_gmcutlabel.nii.gz


# Make "not-spine" ROI in fmri space (combine CSF and seg, dilate, invert)
sct_maths -i fmri_cord.nii.gz -add fmri_csf.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -dilate 5,5,1 -o fmri_spine.nii.gz
sct_maths -i fmri_spine.nii.gz -mul -1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -add 1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o  fmri_notspine.nii.gz
rm tmp.nii.gz


