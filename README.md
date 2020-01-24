## Output files

Output images are named as `<geometry>_<contents>.nii.gz`. Geometries are

    fmri     Native geometry of the fMRI
    
    mffe     Native geometry of the mFFE
    
    t2sag    Native geometry of the T2 sagittal.
    
    ipmffe   Iso-voxel padded geometry based on the native mFFE. This is used to accurately 
             resample the vertebral locations between geometries.
