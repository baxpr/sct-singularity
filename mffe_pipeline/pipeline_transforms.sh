#!/bin/bash
#
# Various image transforms between spaces


# Warp template t2s to mffe space
sct_apply_transfo -i ${TDIR}/PAM50_t2s.nii.gz \
-w warp_PAM502mffe.nii.gz \
-d mffe_mffe.nii.gz -o mffe_template_t2s.nii.gz


# Warp mask to template space and trim template space images to actual FOV
sct_apply_transfo -i mffe_mask${MASKSIZE}.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d ${TDIR}/PAM50_t2s.nii.gz -o PAM50_mask${MASKSIZE}.nii.gz

sct_crop_image -i ${TDIR}/PAM50_t2s.nii.gz \
-m PAM50_mask${MASKSIZE}.nii.gz \
-o PAM50_template_t2s_cropped.nii.gz


# Transform subject CSF to PAM50
sct_apply_transfo -i mffe_csf.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_csf.nii.gz

# And also to ipmffe
sct_resample -i mffe_csf.nii.gz -ref ipmffe_mffe.nii.gz -x nn -o ipmffe_csf.nii.gz


# Crop a couple of "extended" PAM50 space images to the cropped space
sct_crop_image -i PAM50_synt2.nii.gz \
-ref PAM50_template_t2s_cropped.nii.gz \
-o PAM50_synt2.nii.gz

sct_crop_image -i PAM50_cord_labeled.nii.gz \
-ref PAM50_template_t2s_cropped.nii.gz \
-o PAM50_cord_labeled.nii.gz

sct_crop_image -i "${TDIR}"/PAM50_levels.nii.gz \
-ref PAM50_template_t2s_cropped.nii.gz \
-o PAM50_template_cord_labeled.nii.gz


# Warp mffe, gm, ROIs to template space
sct_apply_transfo -i mffe_mffe.nii.gz \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz  -o PAM50_mffe.nii.gz

sct_apply_transfo -i mffe_gm.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_gm.nii.gz

sct_apply_transfo -i mffe_wm.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_wm.nii.gz

sct_apply_transfo -i mffe_cord.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_cord.nii.gz

