#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load a Philips scan physlog file, trim to the exact scan time, and split into separate 
# cardiac and respiratory signals. Save to AFNI .1D format. 

import sys
import pandas
import pydicom


###########################################################################################
# Get inputs
if len(sys.argv) is not 4:
    print('Usage:')
    print(sys.argv[0] + ' physlog_file physlog_Hz dicom_file')
    exit()

physlog_file = sys.argv[1]
physlog_Hz = sys.argv[2]
dicom_file = sys.argv[3]
print('Physlog file: ' + physlog_file)
print('Physlog sampling rate in Hz: ' + physlog_Hz)
print('DICOM file: ' + dicom_file)
physlog_Hz = float(physlog_Hz)


###########################################################################################
# Get acquisition duration from the DICOM

ds = pydicom.dcmread(dicom_file)

# (5200,9230)       PerFrameFunctionalGroupsSequence
#   (0020,9111)     FrameContentSequence
#     (0018,9074)   FrameAcquisitionDateTime
#     (0020,9157)   DimensionIndexValues
# Acquisition time for each frame (Sequence)
PerFrameFunctionalGroupsSequence = ds[0x5200,0x9230]
FrameAcquisitionDateTime = [x[0x0020,0x9111][0][0x0018,0x9074] for x in PerFrameFunctionalGroupsSequence]
DimensionIndexValues1 = [x[0x0020,0x9111][0][0x0020,0x9157][1] for x in PerFrameFunctionalGroupsSequence]
DimensionIndexValues2 = [x[0x0020,0x9111][0][0x0020,0x9157][2] for x in PerFrameFunctionalGroupsSequence]

min1 = [i for i,x in enumerate(DimensionIndexValues1) if x==min(DimensionIndexValues1)]
min2 = [i for i,x in enumerate(DimensionIndexValues2) if x==min(DimensionIndexValues2)]
max2 = [i for i,x in enumerate(DimensionIndexValues2) if x==max(DimensionIndexValues2)]

mindt = FrameAcquisitionDateTime[ set(min1) & set(min2) ]
maxdt = FrameAcquisitionDateTime[ set(min1) & set(max2) ]

# AcquisitionDuration (WARNING - INCLUDES DUMMY SCANS)
#acqdur = ds[0x0018,0x9073].value

# NumberOfTemporalPositions from first frame (Philips private field)
# PerFrameFunctionalGroupsSequence[0].Private_2005_140f[0].NumberOfTemporalPositions
# WARNING - DOES NOT INCLUDE DUMMY SCANS
#nvols = int( ds[0x5200,0x9230][0][0x2005,0x140f][0][0x0020,0x0105].value )

# Estimate of volume time (sec)
#voltime = acqdur / nvols

# Save voltime in sec to file
print('Saving estimated voltime %f in volume_acquisition_time.txt' % (voltime))
with open('volume_acquisition_time.txt','w') as f:
    f.write( '%f' % (voltime) )


###########################################################################################
# Load the physlog file, trim to match scan length, save card/resp in AFNI .1D format
physlog = pandas.read_csv(physlog_file,delim_whitespace=True,skiprows=6,header=None)
card = physlog.iloc[:,4]
resp = physlog.iloc[:,5]
mark = physlog.iloc[:,9]
lastmark = max(mark[mark==20].index)
rowsneeded = round(acqdur * physlog_Hz)
firstmark = lastmark - rowsneeded + 1
print('Keeping %d physlog points from %d to %d' % (rowsneeded,firstmark,lastmark+1))
card = card[firstmark:lastmark+1]
resp = resp[firstmark:lastmark+1]
card.to_csv('physlog_cardiac.csv',header=False,index=False)
resp.to_csv('physlog_respiratory.csv',header=False,index=False)


