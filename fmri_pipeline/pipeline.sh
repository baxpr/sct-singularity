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

# fMRI
cp fmri.nii.gz fmri_fmri.nii.gz

# MFFE processing
pipeline_mffe.sh

# T2SAG processing for vertebral labels, markers. Includes registration to mffe
pipeline_t2sag.sh

# Cord cross-sectional area
csa_calc.sh

# Registration to template
pipeline_templatereg.sh

# fMRI processing
pipeline_fmri.sh

# Geom transforms
pipeline_transforms.sh

# Get fmri vol acq time
get_voltime.py

# Generate RETROICOR regressors
parse_physlog.py
RetroTS.py -r physlog_respiratory.csv -c physlog_cardiac.csv -p 496 -n 1 \
    -v `cat volume_acquisition_time.txt` -cardiac_out 0 -prefix ricor
cleanup_physlog.py

# Regression-based cleanup of confounds
regress.py

# Create filtered data image
make_filtered_fmri.py

# Compute connectivity images
compute_connectivity_slice.py

# Resample connectivity images
resample_conn.sh

# Output QA PDF
# Redirect stdout/err for make_pdf.sh to hide a bunch of nibabel deprecation
# warnings caused by fsleyes 0.32.0. Earlier fsleyes 0.31.2 doesn't work
plot_motion.py
make_pdf.sh &> /dev/null
convert_pdf.sh

# Re-arrange output files for dax
organize_outputs.sh

