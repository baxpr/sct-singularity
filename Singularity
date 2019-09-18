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
  ASK_REPORT_QUESTION=false change_default_path=Yes add_to_path=No ./install_sct

  # Add DICOM and NII to the SCT python
  ${SCTDIR}/python/envs/venv_sct/bin/pip install pydicom nilearn
  
  # For X
  apt-get -y install xvfb
  
  # Possible dependencies for wxpython
  # https://github.com/wxWidgets/Phoenix/issues/465#issuecomment-321891912
  # libwebkitgtk-dev libjpeg-dev libtiff-dev libgtk2.0-dev libsdl1.2-dev freeglut3 freeglut3-dev libnotify-dev libgstreamerd-3-dev
  
  # Get fsleyes via pip. wxpython and pathlib2 are required first
  #   https://github.com/wxWidgets/Phoenix/blob/master/README.rst#prerequisites
  #   https://wxpython.org/pages/downloads/
  apt-get install -y dpkg-dev build-essential freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev \
      libgstreamer-plugins-base1.0-dev libgtk-3-dev libjpeg-dev libnotify-dev libpng-dev \
      libsdl1.2-dev libsdl2-dev libsm-dev libtiff-dev libwebkit2gtk-4.0-dev libxtst-dev
  ${SCTDIR}/python/envs/venv_sct/bin/pip install -f \
      https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-18.04 wxPython
  ${SCTDIR}/python/envs/venv_sct/bin/pip install pathlib2 fsleyes

  # Get fsleyes via direct download instead (still won't run without wxpython)
  #cd /opt
  #wget -q https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/dist/FSLeyes-0.30.1-ubuntu1804.tar.gz
  #tar -zxf FSLeyes-0.30.1-ubuntu1804.tar.gz
  #rm FSLeyes-0.30.1-ubuntu1804.tar.gz

  # ImageMagick
  apt-get install -y imagemagick
  

%environment
  PATH="/opt/scripts:/opt/scripts/external/afni:/opt/sct/bin:${PATH}"


%runscript
  sct_check_dependencies "$@"
