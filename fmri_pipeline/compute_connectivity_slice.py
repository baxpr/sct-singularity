#!/opt/sct/python/envs/venv_sct/bin/python
#
# Functional connectivity maps

import numpy
import nibabel
import nilearn
import pandas
import matplotlib.pyplot as pyplot
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker
from nilearn.masking import intersect_masks,unmask
from nilearn.regions import img_to_signals_labels

moco_file = 'fmri_moco.nii.gz'
filt_file = 'fmri_filt.nii.gz'
level_file = 'fmri_cord_labeled.nii.gz'
gm_file = 'fmri_gmcut.nii.gz'
gm_csv = 'fmri_gmcut.csv'
vat_file = 'volume_acquisition_time.txt'


# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read().strip())
    print('Found vol time of %f sec' % t_r)


# Make slice-label ROIs from the GM file so we can easily do slice-wise masking
img = nibabel.load(gm_file)
nslices = img.shape[2]
slice_img = list()
for s in range(nslices):
    slice_filt_bp = numpy.zeros(img.get_data().shape)
    slice_filt_bp[:,:,s] = 1
    slice_img.append( nibabel.Nifti1Image(slice_filt_bp,img.affine,img.header) )

# Get the ROI label info
roi_info = pandas.read_csv(gm_csv)

# Compute connectivity within each slice, applying bandpass filter
print("Connectivity computation")
for s in range(nslices):
    
    # ROI signals. Labels are the same every time because they come from
    # the full gm_file. The slice_img varies but is only an extra mask
    roi_filt,roi_labels = img_to_signals_labels(filt_file,gm_file,slice_img[s])
    roi_horns = roi_info["horn"][roi_info["label"]==roi_labels]
    roi_filt_bp = nilearn.signal.clean(roi_filt,standardize=True,detrend=True,
                                    high_pass=0.01,low_pass=0.10,t_r=t_r)

    roi_moco,roi_moco_labels = img_to_signals_labels(moco_file,gm_file,slice_img[s])
    if not roi_moco_labels==roi_labels:
        raise Exception('Label mismatch')
    
    # Plot before and after filtering for 1 ROI
    fig,axs = pyplot.subplots(3,1)
    axs[0].plot(range(roi_moco.shape[0]),roi_moco[:,0])
    axs[0].set_yticklabels([])
    axs[0].set_title('%s signal, slice %d' % (roi_horns[0],s))
    axs[1].plot(range(roi_filt.shape[0]),roi_filt[:,0])
    axs[1].set_yticklabels([])
    axs[1].set_title('After confound regression')
    axs[2].plot(range(roi_filt_bp.shape[0]),roi_filt_bp[:,0])
    axs[2].set_yticklabels([])
    axs[2].set_title('After bandpass filter')
    axs[2].set_xlabel('Volume')
    fig.tight_layout()
    fig.savefig('roisignal_%s_slice%d.png' % (roi_horns[0],s))

    # Get filtered fmri data for this slice
    slice_masker = NiftiMasker(slice_img[s],standardize=True,detrend=True,
                    high_pass=0.01,low_pass=0.10,t_r=t_r)
    slice_filt_bp = slice_masker.fit_transform(filt_file)
    #print('Slice data size %d,%d' % slice_filt_bp.shape)

    # Connectivity matrix computation
    r_roi_mat = numpy.dot(roi_filt_bp.T, roi_filt_bp) / roi_filt_bp.shape[0]
    #z_roi_mat = numpy.arctanh(r_roi_mat) * numpy.sqrt(roi_filt_bp.shape[0]-3)

    # Flatten the conn matrices to the unique values
    k1,k2 = numpy.triu_indices(roi_filt_bp.shape[1],k=1)
    r_roi_vec = r_roi_mat[k1,k2]
    z_roi_vec = numpy.arctanh(r_roi_vec) * numpy.sqrt(roi_filt_bp.shape[0]-3)
    roi_labelvec = ["{}_{}".format(a,b) for a,b in zip(roi_horns[k1],roi_horns[k2])]
    
    # Get level labels. Hack - list the same image twice because img_to_signals_labels
    # requires 4D input for some reason. Trim the duplicate off afterwards
    level_data,level_labels = img_to_signals_labels([level_file,level_file],gm_file,
        slice_img[s],strategy="median")
    level_data = level_data[0,:]
    if not level_labels==roi_labels:
        raise Exception("Label mismatch")
    level = numpy.round(numpy.median(level_data))

    # Build data frame of slicewise results
    # DataFrame.append handles varying/mismatched colnames correctly
    colnames = ["metric","slice","level"] + roi_labelvec
    rowdataR = ["R","%d" % s,"%d" % level] + ["%0.3f" % x for x in r_roi_vec]
    rowdataZ = ["Z","%d" % s,"%d" % level] + ["%0.3f" % x for x in z_roi_vec]
    thisR = pandas.DataFrame([rowdataR],columns=colnames)
    thisZ = pandas.DataFrame([rowdataZ],columns=colnames)
    print(thisR)
    if s==0:
        roiR = thisR
        roiZ = thisZ
    else:
        roiR = roiR.append(thisR)
        roiZ = roiZ.append(thisZ)
    
    # Connectivity map computation
    # Relies on standardization to mean 0, sd 1 above
    r_slice_filt_bp = numpy.dot(slice_filt_bp.T, roi_filt_bp) / roi_filt_bp.shape[0]
    z_slice_filt_bp = numpy.arctanh(r_slice_filt_bp) * numpy.sqrt(roi_filt_bp.shape[0]-3)
    #print( 'R %d,%d ranges %f,%f' % (r_slice_filt_bp.shape[0],r_slice_filt_bp.shape[1],
    #                                 r_slice_filt_bp.min(),r_slice_filt_bp.max()) )
    r_slice_img = slice_masker.inverse_transform(r_slice_filt_bp.T)
    z_slice_img = slice_masker.inverse_transform(z_slice_filt_bp.T)

    # Put R back into image space slice by slice. Initialized to zero
    # and slices don't overlap, so we can just add one at a time
    if s==0:
        r_img = r_slice_img  # Initialize
        z_img = z_slice_img
    else:
        r_img = nilearn.image.math_img("a+b",a=r_img,b=r_slice_img)
        z_img = nilearn.image.math_img("a+b",a=z_img,b=z_slice_img)


# Save complete R,Z images to file
for k,horn in enumerate(roi_horns):
    nilearn.image.index_img(r_img,k).to_filename('fmri_R_%s_inslice.nii.gz' % horn)
    nilearn.image.index_img(z_img,k).to_filename('fmri_Z_%s_inslice.nii.gz' % horn)

roiR.to_csv('R_inslice.csv',index=False)
roiZ.to_csv('Z_inslice.csv',index=False)
