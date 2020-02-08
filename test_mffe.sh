#!/bin/bash
#
# Test mffe

singularity run \
--app mffe_pipeline \
--bind `pwd`:/wkdir \
baxpr-sct-singularity-master-v3.0.0.simg \
--outdir OUTPUTS_mffe \
--mffe_dir INPUTS_mffe/mffe_dir \
--t2sag_niigz INPUTS_mffe/t2sag.nii.gz \
--masksize 30 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
