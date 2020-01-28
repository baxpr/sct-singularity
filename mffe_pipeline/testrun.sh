#!/bin/bash

export PATH=/wkdir/mffe_pipeline:${PATH}

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
mffe_pipeline_launch.sh \
--outdir ../OUTPUTS \
--mffe_dir ../INPUTS/mffe_dir \
--t2sag_niigz ../INPUTS/t2sag.nii.gz \
--masksize 30 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
