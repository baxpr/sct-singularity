#!/bin/bash
#
# Spinal cord fMRI processing pipeline.
#
# Image filenames are <geometry>_<content>.nii.gz
# Template content always marked as "template". Otherwise it's subject content

# Use first echo of mffe
cp mffe1.nii.gz mffe_mffe.nii.gz

# T2 sagittal
cp t2sag.nii.gz t2sag_t2sag.nii.gz

# mFFE processing
pipeline_mffe.sh

# T2SAG processing for vertebral labels, markers. Includes registration to mffe
pipeline_t2sag.sh

# Cord cross-sectional area
csa_calc.sh

# Registration to template
pipeline_templatereg.sh

# CSF region
pipeline_csf.sh

# Geom transforms
pipeline_transforms.sh

# Output QA PDF
# Redirect stdout/err for make_pdf.sh to hide a bunch of nibabel deprecation
# warnings caused by fsleyes 0.32.0. Earlier fsleyes 0.31.2 doesn't work
make_pdf.sh &> /dev/null
convert_pdf.sh

# Re-arrange output files for dax
organize_outputs.sh
