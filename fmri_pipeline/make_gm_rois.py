#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load fmri space masks and create dorsal and ventral ROIs

import sys
import nibabel
import numpy
import scipy.ndimage

gm_file = sys.argv[1]
label_file = sys.argv[2]

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

# Verify that orientation is RPI (as SCT calls it) or LAS (as nibabel calls it)
ort = nibabel.aff2axcodes(gm.affine)
if not ort == ('L', 'A', 'S'):
    raise Exception('GM image orientation is not nibabel LAS')

# Split GM into horns, slice by slice at center of mass
gm_data = gm.get_data()
gm_data[gm_data>0] = 1
dims = gm.header.get_data_shape()
if not (dims[2]<dims[0] and dims[2]<dims[1]):
    raise Exception('Third dimension is not slice dimension?')
nslices = dims[2]
horn_data = numpy.zeros(dims)

for s in range(nslices):
    
    slicedata = numpy.copy(gm_data[:,:,s])
    quadrants = numpy.zeros(dims[0:2])

    com = [int(round(x)) for x in scipy.ndimage.center_of_mass(slicedata)]

    # Label quadrants. For correct data orientation, these are
    #    1 - left ventral
    #    2 - right ventral
    #    3 - left dorsal
    #    4 - right dorsal
    quadrants[com[0]+1:,com[1]+1:] = 1
    quadrants[:com[0],com[1]+1:] = 2
    quadrants[com[0]+1:,:com[1]] = 3
    quadrants[:com[0],:com[1]] = 4

    # Set centerline values to zero
    slicedata[com[0]:com[0]+1,:] = 0
    slicedata[:,com[1]:com[1]+1] = 0

    # Label the four horns
    horn_data[:,:,s] = numpy.multiply(slicedata,quadrants)

# Save labeled horns to file with CSV index
leveldict = {
    1: "Lventral",
    2: "Rventral",
    3: "Ldorsal",
    4: "Rdorsal"
}
horn = nibabel.Nifti1Image(horn_data,gm.affine,gm.header)
nibabel.save(horn,'fmri_gmcut.nii.gz')
with open('fmri_gmcut.csv','w') as f:
    f.write("horn,label\n")
    f.write(leveldict.get(1) + ",1\n")
    f.write(leveldict.get(2) + ",2\n")
    f.write(leveldict.get(3) + ",3\n")
    f.write(leveldict.get(4) + ",4\n")

# Mask labels by gray matter and write to file
label_data = label.get_data()
gm_inds = gm_data>0
gm_data[gm_inds] = label_data[gm_inds]
gmmasked = nibabel.Nifti1Image(gm_data,gm.affine,gm.header)
nibabel.save(gmmasked,'fmri_gmlabeled.nii.gz')

# Label by level and horn:
#    301 - C3, left ventral
#    302 - C3, right ventral
#    etc
label_data = numpy.multiply(label_data,horn_data>0)
horn_data = numpy.multiply(horn_data,label_data>0)
hornlevel_data = 100*label_data + horn_data
hornlevel = nibabel.Nifti1Image(hornlevel_data,gm.affine,gm.header)
nibabel.save(hornlevel,'fmri_gmcutlabel.nii.gz')

hvals=numpy.round(numpy.unique(hornlevel_data))
hvals = hvals[hvals!=0]
with open('fmri_gmcutlabel.csv','w') as f:
    f.write("horn_level,horn,level,label\n")
    for hval in hvals:
        thishorn = str(int(hval))[-1]
        thislevel = str(int(hval))[0:-2]
        thishornlevel = "%s_%s" % (leveldict.get(int(thishorn)),thislevel)
        f.write("%s,%s,%s,%d\n" % (thishornlevel,leveldict.get(int(thishorn)),thislevel,hval))

    
    
