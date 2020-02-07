#!/bin/bash
#
# Prepare inputs for the pipeline and launch it. For later processing we will assume 
# the filenames that are created here. We will also assume specific filenames produced
# by the mffe_pipeline (see below where all inputs are simply copied to the working dir)

# Where is sct installed?
export SCTDIR=/opt/sct

# Location of template
export TDIR=${SCTDIR}/data/PAM50/template

# Default inputs
export MASKSIZE=30
export FMRI_VOLTIMESEC=fromDICOM
export PHYSLOG_HZ=496
export CONFOUND_PCS=5
export FMRI_REG_PARAM="step=1,type=seg,algo=slicereg:step=2,type=im,algo=rigid,metric=CC,slicewise=1"


# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --outdir)
      export OUTDIR=$(realpath "$2")
      shift ; shift ;;
    --fmri_niigz)
      export FMRI_NIIGZ=$(realpath "$2")
      shift ; shift ;;
    --fmri_dcm)
      export FMRI_DCM=$(realpath "$2")
      shift ; shift ;;
    --physlog)
      export PHYSLOG=$(realpath "$2")
      shift ; shift ;;
    --fmri_voltimesec)
      export FMRI_VOLTIMESEC="$2"
      shift ; shift ;;
    --physlog_hz)
      export PHYSLOG_HZ="$2"
      shift ; shift ;;
    --confound_pcs)
      export CONFOUND_PCS="$2"
      shift ; shift ;;
    --masksize)
      export MASKSIZE="$2"
      shift ; shift ;;
    --fmri_reg_param)
      export FMRI_REG_PARAM="$2"
      shift ; shift ;;
    --mffe_dir)
      export MFFE_DIR="$2"
      shift ; shift ;;
    --t2sag_dir)
      export T2SAG_DIR="$2"
      shift ; shift ;;
    --cord_dir)
      export CORD_DIR="$2"
      shift ; shift ;;
    --gm_dir)
      export GM_DIR="$2"
      shift ; shift ;;
    --wm_dir)
      export WM_DIR="$2"
      shift ; shift ;;
    --csf_dir)
      export CSF_DIR="$2"
      shift ; shift ;;
    --cord_labeled_dir)
      export CORD_LABELED_DIR="$2"
      shift ; shift ;;
    --warps_dir)
      export WARPS_DIR="$2"
      shift ; shift ;;
    --project)
      export PROJECT="$2"
      shift ; shift ;;
    --subject)
      export SUBJECT="$2"
      shift ; shift ;;
    --session)
      export SESSION="$2"
      shift ; shift ;;
    --scan)
      export SCAN="$2"
      shift ; shift ;;
    *)
      shift ;;
  esac
done

echo PROJECT           = "${PROJECT}"
echo SUBJECT           = "${SUBJECT}"
echo SESSION           = "${SESSION}"
echo SCAN              = "${SCAN}"
echo OUTDIR            = "${OUTDIR}"
echo MFFE_DIR          = "${MFFE_DIR}"
echo T2SAG_DIR         = "${T2SAG_DIR}"
echo CORD_DIR          = "${CORD_DIR}"
echo GM_DIR            = "${GM_DIR}"
echo WM_DIR            = "${WM_DIR}"
echo CSF_DIR           = "${CSF_DIR}"
echo CORD_LABELED_DIR  = "${CORD_LABELED_DIR}"
echo WARPS_DIR         = "${WARPS_DIR}"
echo FMRI_NIIGZ        = "${FMRI_NIIGZ}"
echo FMRI_DCM          = "${FMRI_DCM}"
echo FMRI_VOLTIMESEC   = "${FMRI_VOLTIMESEC}"
echo PHYSLOG           = "${PHYSLOG}"
echo PHYSLOG_HZ        = "${PHYSLOG_HZ}"
echo CONFOUND_PCS      = "${CONFOUND_PCS}"
echo MASKSIZE          = "${MASKSIZE}"
echo FMRI_REG_PARAM    = "${FMRI_REG_PARAM}"


# Copy inputs files to working dir OUTDIR
cp "${FMRI_NIIGZ}" "${OUTDIR}"/fmri.nii.gz
cp "${FMRI_DCM}" "${OUTDIR}"/fmri.dcm
cp "${PHYSLOG}" "${OUTDIR}"/SCANPHYSLOG.log

for d in "${MFFE_DIR}" "${T2SAG_DIR}" "${CORD_DIR}" "${GM_DIR}" "${WM_DIR}" \
    "${CSF_DIR}" "${CORD_LABELED_DIR}" "${WARPS_DIR}" ; do
  cp "${d}"/*.nii.gz "${OUTDIR}"
done


# Launch the pipeline
cd "${OUTDIR}"
pipeline.sh


