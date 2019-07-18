#!/bin/bash

# build the hkl package from source

####################################################################
# build these packages in BUILD_DIR
# install them in PREFIX_DIR
#
# gtk-doc
# gsl
# gobject-introspection
# hkl

echo "This script is under development.  Do NOT run it yet!"
exit 1

####################################################################
# customize for development system

# "mint-vm" or "wow.aps.anl.gov" or "otz.aps.anl.gov"
NODE_NAME=`uname -n`

# TODO: ensure Anaconda python is not on the build path

# TODO: determine Mint or RHEL7:
# (base) mintadmin@mint-vm:/APSshare/linux$ grep "^NAME=" /etc/os-release 
# NAME="Linux Mint"
# jemian@wow ~ $ grep "^NAME=" /etc/os-release
# NAME="Red Hat Enterprise Linux Workstation"

# if [ Mint ]; then
#     export APSSHARE=/APSshare/linux
#     export PREFIX_DIR=${APSSHARE}/64
#     export BUILD_DIR=${APSSHARE}/src
#     export GI_DIR_OS=/usr/lib/x86_64-linux-gnu/girepository-1.0
#     conda deactivate
# elif [ APS RHEL7 ]; then
#     export SANDBOX=~/sandbox/build_hkl
#     export PREFIX_DIR=${SANDBOX}/64
#     export BUILD_DIR=${SANDBOX}/src
#     export GI_DIR_OS=/usr/lib/girepository-1.0
#     export PATH=/home/oxygen/JEMIAN/bin:/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/lib64/ccache:/usr/local/epics/base/bin/linux-x86_64:/usr/local/epics/base/lib/linux-x86_64:/usr/local/epics/opi/bin/linux-x86_64:/APSshare/epics/extensions-base/3.14.12.3-ext1/bin/linux-x86_64:/APSshare/epics/extensions/bin/linux-x86_64
# else
# fi

####################################################################
# configure as needed below

export PATH=${PATH}:${PREFIX_DIR}/bin
# TODO: assumes already defined, check first
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX_DIR}/lib
export LDFLAGS=-L${PREFIX_DIR}/lib

# gobject-inspection environment variables

# PKG_CONFIG_PATH needed to find .pc file(s)
export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig

# GI_TYPELIB_PATH needed by Python clients to find .typelib file(s)
export GI_TYPELIB_PATH=${PREFIX_DIR}/lib/girepository-1.0:${GI_DIR_OS}

####################################################################
# download the source code

# TODO: $BUILD_DIR must be an absolute path for this to work
mkdir -p ${BUILD_DIR}

# gtk-doc
cd ${BUILD_DIR}
git clone https://gitlab.gnome.org/GNOME/gtk-doc.git

# gsl
cd ${BUILD_DIR}
wget http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
tar xzf gsl-latest.tar.gz

# gobject-introspection
cd ${BUILD_DIR}
git clone https://gitlab.gnome.org/GNOME/gobject-introspection.git

# hkl
cd ${BUILD_DIR}
git clone git://repo.or.cz/hkl.git
cd hkl
git checkout -b next origin/next

####################################################################
# build the packages

# build gtk-doc
cd ${BUILD_DIR}/gtk-doc
bash autogen.sh 2>&1 | tee autogen.log
./configure --prefix=${PREFIX_DIR} 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

# build gsl
cd ${BUILD_DIR}/gsl-2.5
./configure --prefix=${PREFIX_DIR} 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

# gobject-introspection
cd ${BUILD_DIR}/gobject-introspection
# autogen.sh was removed after this tag
# Mint: we have glib-2.0 2.56.4
# 1.60.0 needs glib-2.0 >= 2.58.0
# 1.59.4 needs glib-2.0 >= 2.58.0
# 1.57.2 needs glib-2.0 >= 2.57.2
# 1.56.1 needs glib-2.0 >= 2.56.1
# 1.56.0 needs glib-2.0 >= 2.56.0
git checkout 1.56.1
bash ./autogen.sh 2>&1 | tee autogen.log
./configure --prefix=${PREFIX_DIR} 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

# build hkl
cd ${BUILD_DIR}/hkl
bash ./autogen.sh 2>&1 | tee autogen.log
./configure --prefix=${PREFIX_DIR}  --disable-hkl-doc 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

####################################################################
# reset the packages back to as-downloaded

# reset gtk-doc
cd ${BUILD_DIR}/gtk-doc
make distclean

# reset gsl
cd ${BUILD_DIR}/gsl-2.5
make distclean

# gobject-introspection
cd ${BUILD_DIR}/gobject-introspection
make distclean

# reset hkl
cd ${BUILD_DIR}/hkl
make distclean
