Bootstrap: docker
From: ubuntu:18.04


%files
  scripts /opt


%post

  apt-get update
  apt-get install -y zip unzip
    
  #apt-get install -y linux-libc-dev
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
  SCTVER=baxpr/condafix
  SCTDIR=/opt/sct
  git clone --branch ${SCTVER} --depth 1 https://github.com/${REPO}/spinalcordtoolbox.git ${SCTDIR}
  cd ${SCTDIR}
  echo $SCTVER > version-installed.txt
  ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct
  
  # Add some things to the SCT python
  ${SCTDIR}/python/envs/venv_sct/bin/pip install pydicom nilearn

  
%environment
  PATH="/opt/scripts:/opt/scripts/external/afni:/opt/sct/bin:${PATH}"


%runscript
  sct_check_dependencies "$@"
