Bootstrap: docker
From: ubuntu:18.04


%files
  scripts /opt

%post

  apt-get update
  apt-get install -y zip unzip
    
  # Workaround for filename case collision in linux-libc-dev
  # https://superuser.com/questions/1238903/cant-install-linux-libc-dev-in-ubuntu-on-windows
  apt-get install -y binutils xz-utils
  mkdir pkgtemp
  cd pkgtemp
  apt-get download linux-libc-dev
  ar x linux-libc-dev*deb
  tar xJf data.tar.xz
  tar cJf data.tar.xz ./usr
  ar rcs linux-libc-dev*.deb debian-binary control.tar.xz data.tar.xz
  dpkg -i linux-libc-dev*.deb
  cd ..
  rm -fr pkgtemp

  # SCT installation
  apt-get install -y curl wget gcc git
  REPO=baxpr
  #SCTVER=4.0.0-beta.5-condafix  # has miniconda install bug
  SCTVER=v4.0.0-beta.5-condafix2
  #SCTVER=condafix3  # has sct_image.py int bug
  SCTDIR=/opt/sct
  git clone --branch ${SCTVER} --depth 1 https://github.com/${REPO}/spinalcordtoolbox.git ${SCTDIR}
  cd ${SCTDIR}
  echo $SCTVER > version-installed.txt
  ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct
  
  # Add some things to the SCT python
  ${SCTDIR}/python/envs/venv_sct/bin/pip install pydicom
  #${SCTDIR}/python/envs/venv_sct/bin/pip install 2to3
  
  # AFNI, but we only need the RetroTS bits
  #apt-get install -y wget
  #cd /opt
  #wget https://afni.nimh.nih.gov/pub/dist/tgz/linux_ubuntu_16_64.tgz
  #tar -zxf linux_ubuntu_16_64.tgz linux_ubuntu_16_64/RetroTS.py
  #tar  --wildcards -zxf linux_ubuntu_16_64.tgz linux_ubuntu_16_64/lib_RetroTS/*
  #mv linux_ubuntu_16_64 afni
  #rm linux_ubuntu_16_64.tgz
 
  # Fix up the bit of afni we need for python 3
  # https://docs.python.org/3/library/2to3.html
  #${SCTDIR}/python/envs/venv_sct/bin/2to3 -w /opt/afni/RetroTS.py
  #${SCTDIR}/python/envs/venv_sct/bin/2to3 -w /opt/afni/lib_RetroTS/*
  
  # Get dcm2niix
  #DCM2NIIXVER=v1.0.20190720
  #cd /opt
  #git clone --branch ${DCM2NIIXVER} --depth 1 https://github.com/rordenlab/dcm2niix.git
  #cd dcm2niix
  #mkdir build && cd build
  #cmake ..
  #make
  
  
%environment
  PATH="/opt/scripts:/opt/scripts/external/afni:/opt/sct/bin:${PATH}"


%runscript
  sct_check_dependencies "$@"
