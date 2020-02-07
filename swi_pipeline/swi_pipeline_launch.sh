#!/bin/bash
#
# Prepare inputs for the pipeline and launch it. For later processing we will assume 
# the filenames that are created here.

# Where is sct installed?
export SCTDIR=/opt/sct

# Default inputs
export MASKSIZE=30
export SWI_REG_PARAM="step=1,type=seg,algo=slicereg:step=2,type=im,algo=rigid,metric=CC,slicewise=1"

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --outdir)
      export OUTDIR=$(realpath "$2")
      shift; shift ;;
    --masksize)
      export MASKSIZE="$2"
      shift; shift ;;
    --template_reg_param)
      export SWI_REG_PARAM="$2"
      shift; shift ;;
    --swi_dir)
      export SWI_DIR="$2"
      shift ; shift ;;
    --mffe_dir)
      export MFFE_DIR="$2"
      shift ; shift ;;
    --warps_dir)
      export WARPS_DIR="$2"
      shift ; shift ;;
    --project)
      export PROJECT="$2"
      shift; shift ;;
    --subject)
      export SUBJECT="$2"
      shift; shift ;;
    --session)
      export SESSION="$2"
      shift; shift ;;
    --scan)
      export SCAN="$2"
      shift; shift ;;
    *)
      shift ;;
  esac
done

echo PROJECT            = "${PROJECT}"
echo SUBJECT            = "${SUBJECT}"
echo SESSION            = "${SESSION}"
echo SCAN               = "${SCAN}"
echo SWI_DIR            = "${SWI_DIR}"
echo MFFE_DIR           = "${MFFE_DIR}"
echo WARPS_DIR          = "${WARPS_DIR}"
echo OUTDIR             = "${OUTDIR}"
echo MASKSIZE           = "${MASKSIZE}"
echo SWI_REG_PARAM      = "${SWI_REG_PARAM}"


# Figure out mag and phase filenames and copy/rename to working dir OUTDIR
num_ph=$(ls -d ${SWI_DIR}/*_ph.nii.gz | wc -l)
if [ "${num_ph}" -ne 1 ] ; then
	printf '%s\n' "Wrong number of phase files in ${SWI_DIR}" >&2
	exit 1
fi
ph_niigz=$(ls -d ${SWI_DIR}/*_ph.nii.gz)
mag_niigz=${SWI_DIR}/$(basename ${ph_niigz} _ph.nii.gz).nii.gz
num_mag=$(ls -d ${mag_niigz} | wc -l)
if [ "${num_mag}" -ne 1 ] ; then
	printf '%s\n' "Wrong number of magnitude files in ${SWI_DIR}" >&2
	exit 1
fi
cp "${mag_niigz}" "${OUTDIR}"/mag.nii.gz
cp "${ph_niigz}" "${OUTDIR}"/ph.nii.gz

# Copy remaining inputs
cp "${MFFE_DIR}"/* "${OUTDIR}"
cp "${WARPS_DIR}"/* "${OUTDIR}"


# Launch the pipeline
cd "${OUTDIR}"
pipeline.sh


