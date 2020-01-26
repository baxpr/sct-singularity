#!/bin/bash
#
# Various image transforms between spaces

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

# Warp mean fmri, mffe, gm, ROIs to template space
sct_apply_transfo -i fmri_moco_mean.nii.gz \
-w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz  -o PAM50_moco_mean.nii.gz

sct_apply_transfo -i mffe_mffe.nii.gz \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz  -o PAM50_mffe.nii.gz

sct_apply_transfo -i mffe_gm.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_gm.nii.gz


# Warp template CSF to fmri space and mffe space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM502mffe.nii.gz warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_csf.nii.gz

sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM502mffe.nii.gz \
-d mffe_mffe.nii.gz -o mffe_csf.nii.gz


# Get mffe GM/WM/label/centerline in fmri space
sct_apply_transfo -i ipmffe_gm.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_gm.nii.gz

sct_apply_transfo -i ipmffe_wm.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_wm.nii.gz

sct_apply_transfo -i ipmffe_cord_labeled.nii.gz -x nn \
-w warp_mffe2fmri.nii.gz \
-d fmri_moco_mean.nii.gz -o fmri_cord_labeled.nii.gz


# Make horn- and level-specific gray matter ROI images
make_gm_rois.py fmri_gm.nii.gz fmri_cord_labeled.nii.gz


# Warp ROI labels to template space and mffe space
sct_apply_transfo -i fmri_gmcutlabel.nii.gz -x nn \
-w warp_fmri2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_template_t2s_cropped.nii.gz -o PAM50_gmcutlabel.nii.gz

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


