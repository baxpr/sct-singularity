#!/bin/bash

# Imported from environment
#   INITCENTER
#   MASKSIZE
#   SCTDIR

# Location of spinal cord template
TDIR=${SCTDIR}/data/PAM50/template

# Sum mffe echoes
sct_maths -i mffe_e1.nii.gz -add mffe_e2.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -add mffe_e3.nii.gz -o mffe.nii.gz
rm tmp.nii.gz

# Segment cord on mffe, AC suggestion
sct_propseg -i mffe_e1.nii.gz -c t2 -radius 4 -CSF

# Deepseg pipeline
sct_deepseg_sc -i mffe.nii.gz -c t2
sct_deepseg_gm -i mffe.nii.gz
sct_maths -i mffe_seg.nii.gz -sub mffe_gmseg.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -thr 0 -o mffe_wmseg.nii.gz
rm tmp.nii.gz
sct_maths -i mffe_gmseg.nii.gz -add mffe_seg.nii.gz -o mffe_gw.nii.gz
