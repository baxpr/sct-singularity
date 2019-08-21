#!/bin/bash
#
# Prepare inputs for the pipeline

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --outdir)
      OUTDIR="$2"
      shift; shift
      ;;
    --mffe_dir)
      MFFE_DIR="$2"
      shift; shift
      ;;
    --fmri_niigz)
      FMRI_NIIGZ="$2"
      shift; shift
      ;;
    --fmri_dcm)
      FMRI_DCM="$2"
      shift; shift
      ;;
    --physlog_dcm)
      PHYSLOG_DCM="$2"
      shift; shift
      ;;
    --initcenter)
      INITCENTER="$2"
      shift; shift
      ;;
    --masksize)
      MASKSIZE="$2"
      shift; shift
      ;;
    --project)
      PROJECT="$2"
      shift; shift
      ;;
    --subject)
      SUBJECT="$2"
      shift; shift
      ;;
    --session)
      SESSION="$2"
      shift; shift
      ;;
    --scan)
      SCAN="$2"
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
cp "${PHYSLOG_DCM}" "${OUTDIR}"/physlog.dcm
cat "${INITCENTER}" > "${OUTDIR}"/initcenter.txt
cat "${MASKSIZE}" > "${OUTDIR}"/masksize.txt

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


	

