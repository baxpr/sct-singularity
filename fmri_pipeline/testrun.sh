#!/bin/bash

export PATH=/wkdir/fmri_pipeline:/wkdir/fmri_pipeline/external/afni:${PATH}

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
fmri_pipeline_launch.sh \
--outdir ../OUTPUTS_fmri \
--mffe_dir ../INPUTS_fmri/mffe_dir \
--t2sag_niigz ../INPUTS_fmri/t2sag.nii.gz \
--fmri_niigz ../INPUTS_fmri/fmri.nii.gz \
--fmri_dcm ../INPUTS_fmri/fmri.dcm \
--fmri_voltimesec fromDICOM \
--physlog ../INPUTS_fmri/SCANPHYSLOG.log \
--physlog_hz 496 \
--confound_pcs 5 \
--masksize 30 \
--mffe_dir ../OUTPUTS_mffe/MFFE \
--t2sag_dir ../OUTPUTS_mffe/T2SAG \
--cord_dir ../OUTPUTS_mffe/CORD \
--gm_dir ../OUTPUTS_mffe/GM \
--wm_dir ../OUTPUTS_mffe/WM \
--csf_dir ../OUTPUTS_mffe/CSF \
--cord_labeled_dir ../OUTPUTS_mffe/CORD_LABELED \
--warps_dir ../OUTPUTS_mffe/WARPS \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN


