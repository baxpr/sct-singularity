#!/bin/bash
#
# Various image transforms between spaces
#
# Inputs
warp_PAM502mffe.nii.gz
warp_mffe2PAM50.nii.gz
mffe_mask${MASKSIZE}.nii.gz
#
# Outputs
#   mffe_template_t2s.nii.gz            template t2s in mffe space
#   PAM50_template_t2s_cropped.nii.gz   template t2s in PAM50 space, cropped to subject FOV
#   PAM50_mask${MASKSIZE}.nii.gz        mffe mask in template space
#   PAM50_moco_mean.nii.gz              fmri moco data in PAM50 space
#   PAM50_mffe.nii.gz                   mffe in PAM50 space
#   PAM50_gm.nii.gz                     subject gray matter mask in PAM50 space


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

# FIXME We are here. Sort out CSF, GMcutlabel, etc

sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${FMRI}_moco_GMcutlabel_PAM50space.nii.gz


# ROIs to mffe space
sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz \
-d i${MFFE}_gw.nii.gz -o ${FMRI}_moco_GMcutlabel_imffespace.nii.gz


# Warp template CSF to fmri space and mffe space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2i${MFFE}_gw.nii.gz warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_CSF.nii.gz

sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2i${MFFE}_gw.nii.gz \
-d i${MFFE}_gw.nii.gz -o i${MFFE}_CSF.nii.gz


# Get mffe GM/WM/label/centerline in fmri space
sct_apply_transfo -i i${MFFE}_gmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_GM.nii.gz

sct_apply_transfo -i i${MFFE}_wmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_WM.nii.gz

sct_apply_transfo -i ${T2SAG}_seg_labeled_imffespace.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_LABEL.nii.gz


# Make "not-spine" ROI in fmri space (combine CSF and seg, dilate, invert)
sct_maths -i fmri_cord.nii.gz -add ${FMRI}_moco_CSF.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -dilate 5,5,1 -o ${FMRI}_moco_SPINE.nii.gz
sct_maths -i ${FMRI}_moco_SPINE.nii.gz -mul -1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -add 1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o  ${FMRI}_moco_NOTSPINE.nii.gz
rm tmp.nii.gz
