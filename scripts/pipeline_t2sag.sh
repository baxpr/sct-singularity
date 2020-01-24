#!/bin/bash

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

# Resample level ROIs to mffe space and get a list of the ones in FOV
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d mffe_mffe.nii.gz \
  -w warp_t2sag2mffe.nii.gz -x nn \
  -o mffe_cord_labeled.nii.gz
ulevels=$(get_unique_vals.py mffe_cord_labeled.nii.gz)

# Resample level ROIs to ipmffe space
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d ipmffe_mffe.nii.gz \
  -w warp_t2sag2mffe.nii.gz -x nn \
  -o ipmffe_cord_labeled.nii.gz

# Create body markers in ipmffe space for the in-FOV levels
sct_label_utils -i ipmffe_cord_labeled.nii.gz -vert-body ${ulevels} \
  -o ipmffe_cord_labeled_body.nii.gz
