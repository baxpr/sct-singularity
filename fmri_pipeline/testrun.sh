#!/bin/bash

export PATH=/wkdir/fmri_pipeline:/wkdir/fmri_pipeline/external/afni:${PATH}

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
fmri_pipeline_launch.sh \
--outdir ../OUTPUTS \
--mffe_dir ../INPUTS_fmri/mffe_dir \
--t2sag_niigz ../INPUTS_fmri/t2sag.nii.gz \
--fmri_niigz ../INPUTS_fmri/fmri.nii.gz \
--fmri_dcm ../INPUTS_fmri/fmri.dcm \
--fmri_voltimesec fromDICOM \
--physlog ../INPUTS_fmri/SCANPHYSLOG.log \
--physlog_hz 496 \
--confound_pcs 5 \
--masksize 30 \
--mffe_dir ../INPUTS_fmri/MFFE \
--t2sag_dir ../INPUTS_fmri/T2SAG \
--cord_dir ../INPUTS_fmri/CORD \
--gm_dir ../INPUTS_fmri/GM \
--wm_dir ../INPUTS_fmri/WM \
--csf_dir ../INPUTS_fmri/CSF \
--cord_labeled_dir ../INPUTS_fmri/CORD_LABELED \
--warps_dir ../INPUTS_fmri/WARPS \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN


