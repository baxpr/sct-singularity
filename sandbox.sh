singularity shell --writeable --bind `pwd`:/wkdir sandbox

exit 0


# Install sct in ubuntu 18.04 singularity container:

apt-get update && apt-get install -y curl wget gcc git

SCTVER=4.0.0-beta.5
WKDIR=/wkdir
SCTDIR=/wkdir/sct-${SCTVER}

git clone --branch ${SCTVER} --depth 1 https://github.com/neuropoly/spinalcordtoolbox.git ${SCTDIR}

cd ${SCTDIR}

ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct  # -b -d

export PATH="${SCTDIR}/bin:${PATH}"

