#!/bin/bash
#
# Test fmri

singularity run \
--app fmri_pipeline \
--bind `pwd`:/wkdir \
baxpr-sct-singularity-master-v?.?.?.simg \
--outdir OUTPUTS_fmri \
--fmri_niigz INPUTS_fmri/fmri.nii.gz \
--fmri_dcm INPUTS_fmri/fmri.dcm \
--physlog INPUTS_fmri/SCANPHYSLOG.log \
--fmri_voltimesec fromDICOM \
--physlog_hz 496 \
--confound_pcs 6 \
--mffe_dir OUTPUTS_mffe/MFFE \
--t2sag_dir OUTPUTS_mffe/T2SAG \
--cord_dir OUTPUTS_mffe/CORD \
--gm_dir OUTPUTS_mffe/GM \
--wm_dir OUTPUTS_mffe/WM \
--csf_dir OUTPUTS_mffe/CSF \
--cord_labeled_dir OUTPUTS_mffe/CORD_LABELED \
--warps_dir OUTPUTS_mffe/WARPS \
--masksize 30 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
