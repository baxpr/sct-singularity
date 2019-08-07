#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load fmri space masks and create dorsal and ventral ROIs

import nibabel

gm_file = 'fmri_moco_GM.nii.gz'
label_file = 'fmri_moco_LABEL.nii.gz'

# Load images
gm = nibabel.load(gm_file)
label = nibabel.load(label_file)

# Verify that geometry matches
if not (label.get_qform() == gm.get_qform()).all():
    raise Exception('GM/LABEL mismatch in qform')
if not (label.get_sform() == gm.get_sform()).all():
    raise Exception('GM/LABEL mismatch in sform')
if not (label.affine == gm.affine).all():
    raise Exception('GM/LABEL mismatch in affine')
if not label.header.get_data_shape() == gm.header.get_data_shape():
    raise Exception('GM/LABEL mismatch in data shape')    

# Mask labels by gray matter and write to file
gm_data = gm.get_data()
label_data = label.get_data()
gm_inds = gm_data>0
gm_data[gm_inds] = label_data[gm_inds]
gmmasked = nibabel.Nifti1Image(gm_data,gm.affine,gm.header)
nibabel.save(gmmasked,'fmri_moco_GMmasked.nii.gz')


