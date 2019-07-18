#!/bin/bash

# build the hkl package from source

####################################################################
# build these packages in SOURCE_DIR
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

# Mint or el7:
# (base) mintadmin@mint-vm:/APSshare/linux$ grep "^NAME=" /etc/os-release 
# NAME="Linux Mint"
# jemian@wow ~ $ grep "^NAME=" /etc/os-release
# NAME="Red Hat Enterprise Linux Workstation"

# if []; then
#     export APSSHARE=/APSshare/linux
#     export PREFIX_DIR=${APSSHARE}/64
#     export SOURCE_DIR=${APSSHARE}/src
# elif []; then
# else
# fi

####################################################################
# configure as needed below

export LDFLAGS=-L${PREFIX_DIR}/lib
export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig

# GI_TYPELIB_PATH is needed by Python clients to find the typelib file(s)
GI_TYPELIB_PATH=${PREFIX_DIR}/lib/girepository-1.0
#???# GI_TYPELIB_PATH=${GI_TYPELIB_PATH}:/usr/lib/girepository-1.0
export GI_TYPELIB_PATH

####################################################################
# download the source code

# gtk-doc
cd ${SOURCE_DIR}
git clone https://gitlab.gnome.org/GNOME/gtk-doc.git

# gsl
cd ${SOURCE_DIR}
wget http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
tar xzf gsl-latest.tar.gz

# gobject-introspection
cd ${SOURCE_DIR}
git clone https://gitlab.gnome.org/GNOME/gobject-introspection.git

# hkl
cd ${SOURCE_DIR}
git clone git://repo.or.cz/hkl.git
cd hkl
git checkout -b next origin/next

####################################################################
# build the packages

# build gtk-doc
cd ${SOURCE_DIR}/gtk-doc
bash autogen.sh 2>&1 | tee autogen.log
./configure --prefix=${PREFIX_DIR} 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

# build gsl
cd ${SOURCE_DIR}/gsl-2.5
./configure --prefix=${PREFIX_DIR} 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

# gobject-introspection
cd ${SOURCE_DIR}/gobject-introspection
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
cd ${SOURCE_DIR}/hkl
bash ./autogen.sh 2>&1 | tee autogen.log
./configure --prefix=${PREFIX_DIR}  --disable-hkl-doc 2>&1 | tee configure.log
make  2>&1 | tee  make.log
make install 2>&1 | tee  install.log

####################################################################
# reset the packages back to as-downloaded

# reset gtk-doc
cd ${SOURCE_DIR}/gtk-doc
make distclean

# reset gsl
cd ${SOURCE_DIR}/gsl-2.5
make distclean

# gobject-introspection
cd ${SOURCE_DIR}/gobject-introspection
make distclean

# reset hkl
cd ${SOURCE_DIR}/hkl
make distclean
