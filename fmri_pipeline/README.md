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
    _moco                 Motion corrected fMRI
    _moco_mean            Mean of motion corrected fMRI volumes
    
    _mffe                 Unprocessed mFFE
    
    _maskNN               Registration mask, NN mm in size
    
    _cord                 Segmented spinal cord ("seg")
    _cord_labeled         Vertebral label ROIs found on the t2sag
    _cord_labeled_discs   Disc point labels found on the t2sag
    _cord_labeled_body    Body center points from _cord_labeled
    _centerline           Cord centerline
    
    _gm                   Segmented gray matter found on the mFFE
    _wm                   Segmented white matter found on the mFFE
    _csf                  Atlas CSF compartment from the PAM50 template
    
    _notspine             "Not spine" region used to obtain confound signals
    
    _gmcut                Gray matter cut into four horns
    _gmcutlabel           Gray matter cut into four horns and marked by level
    
    _synt2                Synthetic T2 built from the gray and white segmentations
    
    _R_*_inslice          Connectivity maps for within-slice seeds (R)
    _Z_*_inslice          Connectivity maps for within-slice seeds (Z)
    
    _template_            Indicates data from template image, not subject image

Other outputs:

    qcreport.pdf                  QC report and view of results
    mffe_csa.csv                  Cross-sectional areas
    R_inslice.csv                 ROI-to-ROI connectivity within slice (R)
    Z_inslice.csv                 ROI-to-ROI connectivity within slice (Z)
    
    fmri_gmcut.csv                Label info for ROI images of same base filename
    fmri_gmcutlabel.csv
    
    physlog_cardiac.csv           Cardiac signal from physlog
    physlog_respiratory.csv       Respiratory signal from physlog
    ricor.slibase.1D              Physlog signals as output from RetroTS
    ricor.csv                     Computed respiratory regressors
    
    fmri_moco_params.tsv          Estimated fMRI motion parameters
    fmri_moco_params_X.nii.gz
    fmri_moco_params_Y.nii.gz
    
    volume_acquisition_time.txt   Volume acq time used for filtering (sec)

