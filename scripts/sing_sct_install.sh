#!/bin/bash
REPO=baxpr
#SCTVER=baxpr/condafix-4.0.2
SCTVER=condafix-91beb0b-shutil-deepseg
SCTDIR=/opt/sct
git clone https://github.com/${REPO}/spinalcordtoolbox.git ${SCTDIR}
cd ${SCTDIR}
git checkout ${SCTVER}
ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct

# Add DICOM and NII to the SCT python
${SCTDIR}/python/envs/venv_sct/bin/pip install pydicom nilearn

# Get fsleyes via pip. wxpython and pathlib2 are required first
${SCTDIR}/python/envs/venv_sct/bin/pip install -f \
    https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-18.04 wxPython
${SCTDIR}/python/envs/venv_sct/bin/pip install pathlib2 fsleyes


# Note: baxpr/condafix-4.0.2 works fine outside of build
