#!/bin/bash
#
# Prepare inputs for the pipeline and launch it. For later processing we will assume 
# the filenames that are created here.

# Where is sct installed?
export SCTDIR=/opt/sct

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --outdir)
      export OUTDIR="$2"
      shift; shift
      ;;
    --mffe_dir)
      export MFFE_DIR="$2"
      shift; shift
      ;;
    --fmri_niigz)
      export FMRI_NIIGZ="$2"
      shift; shift
      ;;
    --fmri_dcm)
      export FMRI_DCM="$2"
      shift; shift
      ;;
    --physlog_dcm)
      export PHYSLOG_DCM="$2"
      shift; shift
      ;;
    --initcenter)
      export INITCENTER="$2"
      shift; shift
      ;;
    --masksize)
      export MASKSIZE="$2"
      shift; shift
      ;;
    --project)
      export PROJECT="$2"
      shift; shift
      ;;
    --subject)
      export SUBJECT="$2"
      shift; shift
      ;;
    --session)
      export SESSION="$2"
      shift; shift
      ;;
    --scan)
      export SCAN="$2"
      shift; shift
      ;;
    *)
      shift
      ;;
  esac
done

echo PROJECT     = "${PROJECT}"
echo SUBJECT     = "${SUBJECT}"
echo SESSION     = "${SESSION}"
echo SCAN        = "${SCAN}"
echo OUTDIR      = "${OUTDIR}"
echo MFFE_DIR    = "${MFFE_DIR}"
echo FMRI_NIIGZ  = "${FMRI_NIIGZ}"
echo FMRI_DCM    = "${FMRI_DCM}"
echo PHYSLOG_DCM = "${PHYSLOG_DCM}"
echo INITCENTER  = "${INITCENTER}"
echo MASKSIZE    = "${MASKSIZE}"


# Copy most files to working dir OUTDIR
cp "${FMRI_NIIGZ}" "${OUTDIR}"/fmri.nii.gz
cp "${FMRI_DCM}" "${OUTDIR}"/fmri.dcm
#echo "${INITCENTER}" > "${OUTDIR}"/initcenter.txt
#echo "${MASKSIZE}" > "${OUTDIR}"/masksize.txt
unzip "${PHYSLOG_DCM}" -d "${OUTDIR}"

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
fmri_pipeline.sh

	

