#!/bin/bash
REPO=baxpr
#SCTVER=baxpr/condafix-4.0.2
SCTVER=baxpr/condafix-2472-shutils-move
SCTDIR=/opt/sct
git clone https://github.com/${REPO}/spinalcordtoolbox.git ${SCTDIR}
cd ${SCTDIR}
git checkout ${SCTVER}
ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct
