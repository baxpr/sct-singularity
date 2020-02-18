#!/bin/bash
#
# Prepare inputs for the pipeline and launch it. For later processing we will assume 
# the filenames that are created here.

# Where is sct installed?
export SCTDIR=/opt/sct

# Location of template
export TDIR=${SCTDIR}/data/PAM50/template

# Default inputs
export MASKSIZE=30
export TEMPLATE_REG_PARAM="step=0,type=label,dof=Tx_Ty_Tz_Sz:step=1,type=seg,algo=centermass:step=2,type=im,algo=syn"
export CSF_METHOD="template"

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --outdir)
      export OUTDIR=$(realpath "$2")
      shift; shift ;;
    --mffe_dir)
      export MFFE_DIR=$(realpath "$2")
      shift; shift ;;
    --t2sag_niigz)
      export T2SAG_NIIGZ=$(realpath "$2")
      shift; shift ;;
    --masksize)
      export MASKSIZE="$2"
      shift; shift ;;
    --template_reg_param)
      export TEMPLATE_REG_PARAM="$2"
      shift; shift ;;
    --csf_method)
      export CSF_METHOD="$2"
      shift; shift ;;
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
echo OUTDIR             = "${OUTDIR}"
echo MFFE_DIR           = "${MFFE_DIR}"
echo T2SAG_NIIGZ        = "${T2SAG_NIIGZ}"
echo MASKSIZE           = "${MASKSIZE}"
echo TEMPLATE_REG_PARAM = "${TEMPLATE_REG_PARAM}"
echo CSF_METHOD         = "${CSF_METHOD}"


# Copy most files to working dir OUTDIR
cp "${T2SAG_NIIGZ}" "${OUTDIR}"/t2sag.nii.gz

# Find, verify, copy the multiple echoes of the MFFE
NUM_E1=`ls -d "${MFFE_DIR}"/*_e1.nii.gz | wc -l`
NUM_E2=`ls -d "${MFFE_DIR}"/*_e2.nii.gz | wc -l`
NUM_E3=`ls -d "${MFFE_DIR}"/*_e3.nii.gz | wc -l`
if [ "${NUM_E1}" -ne 1 ] ; then
	printf '%s\n' "Wrong number of echo 1 files in MFFE" >&2
	exit 1
fi
if [ "${NUM_E2}" -ne 1 ] ; then
	printf '%s\n' "Wrong number of echo 2 files in MFFE" >&2
	exit 1
fi
if [ "${NUM_E3}" -ne 1 ] ; then
	printf '%s\n' "Wrong number of echo 3 files in MFFE" >&2
	exit 1
fi
cp "${MFFE_DIR}"/*_e1.nii.gz "${OUTDIR}"/mffe1.nii.gz
cp "${MFFE_DIR}"/*_e2.nii.gz "${OUTDIR}"/mffe2.nii.gz
cp "${MFFE_DIR}"/*_e3.nii.gz "${OUTDIR}"/mffe3.nii.gz


# Launch the pipeline
cd "${OUTDIR}"
pipeline.sh


