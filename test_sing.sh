#!/bin/bash

singularity run \
--app fmri_pipeline \
--bind `pwd`:/wkdir \
baxpr-sct-fmri-master-v1.0.0.simg \
--outdir OUTPUTS \
--mffe_dir INPUTS/mffe_dir \
--t2sag_niigz INPUTS/t2sag.nii.gz \
--fmri_niigz INPUTS/fmri.nii.gz \
--fmri_dcm INPUTS/fmri.dcm \
--physlog INPUTS/SCANPHYSLOG.log \
--masksize 30 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
