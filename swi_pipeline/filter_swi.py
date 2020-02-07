#!/opt/sct/python/envs/venv_sct/bin/python
#
# Haacke SWI method
#   https://doi.org/10.1002/1522-2586(200011)12:5%3C661::AID-JMRI2%3E3.0.CO;2-L
#   https://doi.org/10.1002/mrm.20198
#   https://doi.org/10.3174/ajnr.A1400

import nibabel
import numpy
from scipy import signal
import argparse

# Command line args
parser = argparse.ArgumentParser(description='Haacke SWI method')
parser.add_argument('--mag_niigz',required=True)
parser.add_argument('--ph_niigz',required=True)
parser.add_argument('--swi_output_niigz',default='swi.nii.gz')
parser.add_argument('--ph_scale',type=float,default=0.001)
parser.add_argument('--window_alpha',type=float,default=30)
parser.add_argument('--haacke_factor',type=float,default=5)
args = parser.parse_args()

# Load magnitude and phase and combine to complex array
mag_img = nibabel.load(args.mag_niigz)
mag_data = mag_img.get_fdata()
ph_img = nibabel.load(args.ph_niigz)
ph_data = ph_img.get_fdata() * args.ph_scale
im_data = mag_data * numpy.exp(1j*ph_data)

# FFT
fim_data = numpy.fft.fftshift(numpy.fft.fftn(im_data))

# Low-pass window in 1 dimension for each of first two axes
sigma0 = (fim_data.shape[0]-1) / (2*args.window_alpha)
win0 = signal.gaussian(fim_data.shape[0],sigma0)
sigma1 = (fim_data.shape[1]-1) / (2*args.window_alpha)
win1 = signal.gaussian(fim_data.shape[1],sigma1)

# Create 2D window and rescale to max 1
win = numpy.outer(win0,win1)
win = win / numpy.amax(win)

# Element-wise multiplication by window within slice
for k in range(fim_data.shape[2]):
    fim_data[:,:,k] = numpy.multiply(fim_data[:,:,k],win)

# Inverse FFT
lim_data = numpy.fft.ifftn(numpy.fft.ifftshift(fim_data))

# Haacke filter step
filtim_data = numpy.divide(im_data,lim_data)

# Phase mask
filtph_data = numpy.angle(filtim_data)
maskph_data = (numpy.pi+filtph_data) / numpy.pi
maskph_data[filtph_data>0] = 1;
maskph_data = numpy.power(maskph_data,args.haacke_factor)

# Final SWI image
finalim_data = numpy.multiply(maskph_data,numpy.absolute(im_data))

# Write to file
finalim_img = nibabel.Nifti1Image(finalim_data,mag_img.affine)
finalim_img.to_filename(args.swi_output_niigz)
