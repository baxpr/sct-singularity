#!/bin/bash
#
# T2SAG processing for vertebral labels, body markers
#
# Inputs
#   t2sag_t2sag.nii.gz                T2SAG image
#
# Outputs in t2sag space
#   t2sag_cord.nii.gz                 Cord "seg" from t2sag
#   t2sag_invt2sag.nii.gz             t2sag with inverted contrast, pseudo-T1
#   t2sag_cord_labeled.nii.gz         level label ROIs
#   t2sag_cord_labeled_discs.nii.gz   disc marker points
#   t2sag_mffe.nii.gz                 MFFE resampled to t2sag space
#
# Output warps
#   warp_t2sag2mffe.nii.gz            Warps between t2sag/mffe spaces
#   warp_mffe2t2sag.nii.gz
#
# Outputs in mffe space
#   mffe_t2sag.nii.gz                 MFFE resampled to t2sag space
#
# Outputs in padded iso mffe space
#   pimffe_cord_labeled.nii.gz        t2sag cord
#   pimffe_cord_labeled_body.nii.gz   t2sag body markers
#
# Outputs in iso mffe space
#   imffe_cord_labeled.nii.gz         t2sag cord
#   imffe_cord_labeled_body.nii.gz    t2sag body markers

# Get cord seg for the T2 sag
sct_deepseg_sc -i t2sag_t2sag.nii.gz -c t2
mv t2sag_t2sag_seg.nii.gz t2sag_cord.nii.gz

# Invert t2sag contrast so level-finding works better
invert_t2sag.py t2sag_t2sag.nii.gz t2sag_invt2sag.nii.gz

# Get vert labels on the inverted t2sag and list them
sct_label_vertebrae -i t2sag_invt2sag.nii.gz -s t2sag_cord.nii.gz -c t1
sct_label_utils -i t2sag_cord_labeled_discs.nii.gz -display 

# Register t2sag to mffe
sct_register_multimodal -i t2sag_t2sag.nii.gz -iseg t2sag_cord.nii.gz \
  -d mffe_mffe.nii.gz -dseg mffe_cord.nii.gz \
  -m mffe_mask${MASKSIZE}.nii.gz \
  -o mffe_t2sag.nii.gz \
  -owarp warp_t2sag2mffe.nii.gz
mv warp_mffe_mffe2t2sag_t2sag.nii.gz warp_mffe2t2sag.nii.gz
mv mffe_t2sag_inv.nii.gz t2sag_mffe.nii.gz

# Resample level ROIs to pimffe space
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d pimffe_mffe.nii.gz \
  -w warp_t2sag2mffe.nii.gz -x nn \
  -o pimffe_cord_labeled.nii.gz

# Create body markers in pimffe space
sct_label_utils -i pimffe_cord_labeled.nii.gz -vert-body 0 \
  -o pimffe_cord_labeled_body.nii.gz

# Crop body markers and level image back to imffe space
sct_crop_image -i pimffe_cord_labeled_body.nii.gz \
  -ref imffe_mffe.nii.gz -o imffe_cord_labeled_body.nii.gz
sct_crop_image -i pimffe_cord_labeled.nii.gz \
  -ref imffe_mffe.nii.gz -o imffe_cord_labeled.nii.gz
