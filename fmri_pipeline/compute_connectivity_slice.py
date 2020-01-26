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
regbp_file = 'fmri_regbp.nii.gz'
level_file = 'fmri_cord_labeled.nii.gz'
gm_file = 'fmri_gmcut.nii.gz'
gm_csv = 'fmri_gmcut.csv'

# Make slice-label ROIs from the GM file so we can easily do slice-wise masking
img = nibabel.load(gm_file)
nslices = img.shape[2]
slice_img = list()
for s in range(nslices):
    slice_regbp = numpy.zeros(img.get_data().shape)
    slice_regbp[:,:,s] = 1
    slice_img.append( nibabel.Nifti1Image(slice_regbp,img.affine,img.header) )

# Get the ROI label info
roi_info = pandas.read_csv(gm_csv)

# Compute connectivity within each slice, applying bandpass filter
print("Connectivity computation")
for s in range(nslices):
    
    # ROI signals. Labels are the same every time because they come from
    # the full gm_file. The slice_img varies but is only an extra mask.
    # Signals must be standardized for the connectivity calc below
    roi_regbp,roi_labels = img_to_signals_labels(regbp_file,gm_file,slice_img[s])
    roi_regbp = nilearn.signal.clean(roi_regbp,detrend=True, standardize=True)
    roi_horns = roi_info["horn"][roi_info["label"]==roi_labels]

    roi_moco,roi_moco_labels = img_to_signals_labels(moco_file,gm_file,slice_img[s])
    if not roi_moco_labels==roi_labels:
        raise Exception('Label mismatch')
    
    # Plot before and after filtering for 1 ROI
    fig,axs = pyplot.subplots(2,1)
    axs[0].plot(range(roi_moco.shape[0]),roi_moco[:,0])
    axs[0].set_yticklabels([])
    axs[0].set_title('%s signal, slice %d' % (roi_horns[0],s))
    axs[1].plot(range(roi_regbp.shape[0]),roi_regbp[:,0])
    axs[1].set_yticklabels([])
    axs[1].set_title('After regression+bandpass')
    axs[1].set_xlabel('Volume')
    fig.tight_layout()
    fig.savefig('roisignal_%s_slice%d.png' % (roi_horns[0],s))

    # Get filtered fmri data for this slice
    slice_masker = NiftiMasker(slice_img[s])
    slice_regbp = slice_masker.fit_transform(regbp_file)
    slice_regbp = nilearn.signal.clean(slice_regbp,detrend=True, standardize=True)
    #print('Slice data size %d,%d' % slice_regbp.shape)

    # Connectivity matrix computation. Relies on the detrend and standardize 
    # steps so we are working with mean 0, SD 1 data.
    # Otherwise we will get some nonsense instead of an actual correlation coef.
    # Normalizing factor is N, not N-1, because nilearn.signal._standardize scales
    # using numpy.std with default dof 0.
    r_roi_mat = numpy.dot(roi_regbp.T, roi_regbp) / (roi_regbp.shape[0])

    # Flatten the conn matrices to the unique values
    k1,k2 = numpy.triu_indices(roi_regbp.shape[1],k=1)
    r_roi_vec = r_roi_mat[k1,k2]
    z_roi_vec = numpy.arctanh(r_roi_vec) * numpy.sqrt(roi_regbp.shape[0]-3)
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
    r_slice_regbp = numpy.dot(slice_regbp.T, roi_regbp) / roi_regbp.shape[0]
    z_slice_regbp = numpy.arctanh(r_slice_regbp) * numpy.sqrt(roi_regbp.shape[0]-3)
    #print( 'R %d,%d ranges %f,%f' % (r_slice_regbp.shape[0],r_slice_regbp.shape[1],
    #                                 r_slice_regbp.min(),r_slice_regbp.max()) )
    r_slice_img = slice_masker.inverse_transform(r_slice_regbp.T)
    z_slice_img = slice_masker.inverse_transform(z_slice_regbp.T)

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
