Bootstrap: docker
From: ubuntu:18.04


%files


%post

  apt-get update
    
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

  # AFNI, but we only need the 3dretroicor binary
  apt-get install -y wget
  cd /opt
  mkdir afni
  wget https://afni.nimh.nih.gov/pub/dist/tgz/linux_ubuntu_16_64.tgz
  tar -zxf linux_ubuntu_16_64.tgz linux_ubuntu_16_64/3dretroicor
  mv linux_ubuntu_16_64/3dretroicor .
  rm linux_ubuntu_16_64.tgz
  rmdir linux_ubuntu_16_64

  # SCT installation
  apt-get install -y curl wget gcc git
  REPO=baxpr
  SCTVER=4.0.0-beta.5-condafix
  SCTDIR=/opt/sct
  echo $SCTVER > /opt/sct/version-installed.txt
  git clone --branch ${SCTVER} --depth 1 https://github.com/${REPO}/spinalcordtoolbox.git ${SCTDIR}
  cd ${SCTDIR}
  ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct
    
  
%environment
  PATH="/opt/sct/bin:/opt/afni:${PATH}"


%runscript
  sct_check_dependencies "$@"
