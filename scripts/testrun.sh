#!/bin/bash

export PATH=/wkdir/scripts:/wkdir/scripts/external/afni:${PATH}

fmri_pipeline_launch.sh \
--outdir ../OUTPUTS \
--mffe_dir ../INPUTS/mffe_dir \
--t2sag_niigz ../INPUTS/t2sag.nii.gz \
--fmri_niigz ../INPUTS/fmri.nii.gz \
--fmri_dcm ../INPUTS/fmri.dcm \
--physlog_dcm ../INPUTS/physlog.dcm \
--initcenter 3 \
--masksize 30 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
