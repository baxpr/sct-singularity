#!/bin/bash
#
# fMRI processing
#
# Inputs
#   fmri_fmri.nii.gz     fmri 4D images
#   mffe_mffe.nii.gz     mffe for registration
#   mffe_cord.nii.gz     mffe cord for registration
#   mffe_mask??.nii.gz   mffe space mask for registration
#
# Outputs
#   fmri_fmri0.nii.gz           first vol of fmri
#   fmri_centerline.nii.gz      fmri centerline
#   fmri_centerline.csv         
#   fmri_mask??.nii.gz          fmri space registration mask for moco
#   fmri_moco.nii.gz            motion-corrected fmri
#   fmri_moco_mean.nii.gz       mean of moco fmri over time
#   fmri_moco_params_X.nii.gz   movement params
#   fmri_moco_params_Y.nii.gz   
#   fmri_moco_params.tsv        movement params averaged over vol
#   fmri_cord.nii.gz            cord "seg" computed on mean fmri
#   warp_fmri2mffe.nii.gz       warps between fmri and mffe space
#   warp_mffe2fmri.nii.gz
#   mffe_moco_mean.nii.gz       mean moco fmri warped to mffe space
#   fmri_mffe.nii.gz            mffe warped to fmri space


# Extract first fmri volume, find centerline, make fmri space mask
sct_image -keep-vol 0 -i fmri_fmri.nii.gz -o fmri_fmri0.nii.gz
sct_get_centerline -c t2s -i fmri_fmri0.nii.gz
mv fmri_fmri0_centerline.nii.gz fmri_centerline.nii.gz
mv fmri_fmri0_centerline.csv fmri_centerline.csv
sct_create_mask -i fmri_fmri0.nii.gz -p centerline,fmri_centerline.nii.gz -size ${MASKSIZE}mm \
-o fmri_mask${MASKSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m fmri_mask${MASKSIZE}.nii.gz -i fmri_fmri.nii.gz 
mv fmri_fmri_moco.nii.gz fmri_moco.nii.gz
mv fmri_fmri_moco_mean.nii.gz fmri_moco_mean.nii.gz
mv fmri_fmri_moco_params_X.nii.gz fmri_moco_params_X.nii.gz
mv fmri_fmri_moco_params_Y.nii.gz fmri_moco_params_Y.nii.gz
mv fmri_fmri_moco_params.tsv fmri_moco_params.tsv
rm fmri_fmri_T????.nii.gz

# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i fmri_moco_mean.nii.gz -c t2s
mv fmri_moco_mean_seg.nii.gz fmri_cord.nii.gz

# Register mean fMRI to mFFE
sct_register_multimodal \
-i fmri_moco_mean.nii.gz -iseg fmri_cord.nii.gz \
-d mffe_mffe.nii.gz -dseg mffe_cord.nii.gz \
-m mffe_mask${MASKSIZE}.nii.gz \
-param step=1,type=seg,algo=slicereg,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=rigid,metric=CC,slicewise=1 \
step=3,type=im,algo=slicereg,metric=CC

#step=2,type=im,algo=rigid,metric=CC
#step=2,type=im,algo=rigid,metric=CC,slicewise=1
#step=2,type=im,algo=slicereg,metric=CC

mv warp_fmri_moco_mean2mffe_mffe.nii.gz warp_fmri2mffe.nii.gz
mv warp_mffe_mffe2fmri_moco_mean.nii.gz warp_mffe2fmri.nii.gz
mv fmri_moco_mean_reg.nii.gz mffe_moco_mean.nii.gz
mv mffe_mffe_reg.nii.gz fmri_mffe.nii.gz

