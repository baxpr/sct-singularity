## Output files

Output images are named as `<geometry>_<contents>.nii.gz`.

Geometries are

    fmri_     Native geometry of the fMRI
    mffe_     Native geometry of the mFFE
    t2sag_    Native geometry of the T2 sagittal.
    ipmffe_   Iso-voxel padded geometry based on the native mFFE. This is used to accurately 
                  resample the vertebral locations between geometries.
    warp_     Warp field between two geometries


Contents are

    _fmri                 Unprocessed fMRI
    _fmri0                First volume of unprocessed fMRI
    _fmri_moco            Motion corrected fMRI
    _fmri_moco_mean       Mean of motion corrected fMRI volumes
    
    _mffe                 Unprocessed mFFE
    
    _maskNN               Registration mask, NN mm in size
    
    _cord                 Segmented spinal cord ("seg")
    _cord_labeled         Vertebral label ROIs found on the t2sag
    _cord_labeled_discs   Disc point labels found on the t2sag
    _cord_labeled_body    Body center points from _cord_labeled
    _centerline           Cord centerline
    
    _gm                   Segmented gray matter found on the mFFE
    _wm                   Segmented white matter found on the mFFE
    _csf                  Segmented CSF from the PAM50 template    
    
    _synt2                Synthetic T2 built from the gray and white segmentations
    
    _template_            Indicates data from template image, not subject image

