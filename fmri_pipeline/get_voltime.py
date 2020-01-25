#!/opt/sct/python/envs/venv_sct/bin/python
#
# Several different ways we can get the volume acquisition time

import pydicom
import datetime
import os
import nibabel

# Parameters from calling environment
fmri_dcm = os.getenv('FMRI_DCM')
fmri_niigz = os.getenv('FMRI_NIIGZ')
vat_spec = os.getenv('FMRI_VOLTIMESEC')


def get_vat_from_nifti(fmri_niigz):

    print('Getting volume acquisition time from %s' % fmri_niigz)
    nii = nibabel.load(fmri_niigz)
    if nii.header.get_xyzt_units()[1] is not 'sec':
        raise Exception('Units are not sec in %s' % fmri_niigz)
    vat = nii.header.get_zooms()[3]
    return vat


def get_vat_from_dicom(fmri_dcm):

    print('Getting volume acquisition time from %s' % fmri_dcm)
    ds = pydicom.dcmread(fmri_dcm)

    # (5200,9230)       PerFrameFunctionalGroupsSequence
    #   (0020,9111)     FrameContentSequence
    #     (0018,9074)   FrameAcquisitionDateTime
    #     (0020,9157)   DimensionIndexValues (0=irrelevant,1=slice,2=volume)

    # Acquisition time and dim index for each frame
    PerFrameFunctionalGroupsSequence = ds[0x5200,0x9230]
    FrameAcquisitionDateTime = [x[0x0020,0x9111][0][0x0018,0x9074] 
        for x in PerFrameFunctionalGroupsSequence]
    DimensionIndexValues1 = [x[0x0020,0x9111][0][0x0020,0x9157][1] 
        for x in PerFrameFunctionalGroupsSequence]
    DimensionIndexValues2 = [x[0x0020,0x9111][0][0x0020,0x9157][2] 
        for x in PerFrameFunctionalGroupsSequence]

    # Boolean - is this element the min or max index of the entire bunch?
    min1 = [x==min(DimensionIndexValues1) for x in DimensionIndexValues1]
    min2 = [x==min(DimensionIndexValues2) for x in DimensionIndexValues2]
    max2 = [x==max(DimensionIndexValues2) for x in DimensionIndexValues2]

    # Index value of min slice + min volume, and min slice + max volume
    # (The first and last volumes of the time series)
    minloc = [i for i,xy in enumerate(zip(min1,min2)) if xy[0] and xy[1]][0]
    maxloc = [i for i,xy in enumerate(zip(min1,max2)) if xy[0] and xy[1]][0]

    # Datetime for first and last volumes, converted to datetime
    mindtstr = FrameAcquisitionDateTime[ minloc ]
    maxdtstr = FrameAcquisitionDateTime[ maxloc ]
    mindt = datetime.datetime.strptime(mindtstr.value,'%Y%m%d%H%M%S.%f')
    maxdt = datetime.datetime.strptime(maxdtstr.value,'%Y%m%d%H%M%S.%f')

    # Compute volume acquisition time. Note, totaltime is from beginning of first vol to
    # beginning of last vol
    totaltime = (maxdt-mindt).total_seconds()
    vat = totaltime / (max(DimensionIndexValues2) - min(DimensionIndexValues2))

    return vat


if vat_spec == 'fromDICOM':
    vat = get_vat_from_dicom(fmri_dcm)
elif vat_spec == 'fromNIFTI': 
    vat = get_vat_from_nifti(fmri_niigz)
else:
    vat = float(vat_spec)

# Save voltime in sec to file
print('Saving estimated voltime %f sec in volume_acquisition_time.txt' % vat)
with open('volume_acquisition_time.txt','w') as f:
    f.write( '%f' % (vat) )

