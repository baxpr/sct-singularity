#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load a Philips scan physlog file, trim to the exact scan time, and split into separate 
# cardiac and respiratory signals. Save to AFNI .1D format. 

import os
import sys
import pandas
import pydicom
import datetime
import nibabel


physlog_file = os.getenv('PHYSLOG')
physlog_Hz = os.getenv('PHYSLOG_HZ')
dicom_file = os.getenv('FMRI_DCM')
fmri_niigz = os.getenv('FMRI_NIIGZ')
print('Physlog file: ' + physlog_file)
print('Physlog sampling rate in Hz: ' + physlog_Hz)
print('DICOM file: ' + dicom_file)
physlog_Hz = float(physlog_Hz)


# Vol acq time
vat = pandas.read_csv('volume_acquisition_time.txt',header=None)
vat = vat[0][0]
print('Volume acquisition time: %f' % vat)

# Number of vols from nii
print('Getting number of vols from %s' % fmri_niigz)
fmri_nii = nibabel.load(fmri_niigz)
nvols = int( fmri_nii.shape[3] )
print('Number of volumes: %d' % nvols)

# Number of vols from dicom
#   NumberOfTemporalPositions from first frame (Philips private field)
#   PerFrameFunctionalGroupsSequence[0].Private_2005_140f[0].NumberOfTemporalPositions
#   Does not include dummy scans
# Does not always return the number of vols!
#ds = pydicom.dcmread(dicom_file)
#PerFrameFunctionalGroupsSequence = ds[0x5200,0x9230]
#nvols = int( PerFrameFunctionalGroupsSequence[0][0x2005,0x140f][0][0x0020,0x0105].value )
#print('Number of volumes: %d' % nvols)



###########################################################################################
# Load the physlog file, trim to match scan length, save card/resp in AFNI .1D format
physlog = pandas.read_csv(physlog_file,delim_whitespace=True,skiprows=6,header=None)
card = physlog.iloc[:,4]
resp = physlog.iloc[:,5]
mark = physlog.iloc[:,9]
lastmark = int(max(mark[mark==20].index))
rowsneeded = int(round(nvols * vat * physlog_Hz))
firstmark = int(lastmark - rowsneeded + 1)
print('Keeping %d physlog points from %d to %d' % (rowsneeded,firstmark,lastmark+1))
card = card[firstmark:lastmark+1]
resp = resp[firstmark:lastmark+1]
card.to_csv('physlog_cardiac.csv',header=False,index=False)
resp.to_csv('physlog_respiratory.csv',header=False,index=False)


