# Building hkl from source

## Pre-requisites

	gtk-doc >= 1.9 (all -- required)		http://www.gtk.org/gtk-doc/
	gsl >= 1.12    (lib -- required)		http://www.gnu.org/software/gsl/
	gtkmm >= 2.18  (gui -- optional)		http://www.gtkmm.org
	libg3d	       (gui -- optional)		http://automagically.de/g3dviewer/
	libyaml	       (gui -- optional)		http://pyyaml.org/wiki/LibYAML
	povray	       (doc -- optional)		http://www.povray.org/
	asymptote      (doc -- optional)		http://asymptote.sourceforge.net/
	
	gtkmm-3.24.0 needs gtk+-3.0+ & libsigc++

```
export APSSHARE=/APSshare/linux
export PREFIX_DIR=${APSSHARE}
export SOURCE_DIR=${APSSHARE}/src

# gtk-doc
cd ${SOURCE_DIR}
git clone https://gitlab.gnome.org/GNOME/gtk-doc.git
cd gtk-doc
bash autogen.sh
./configure --prefix=${PREFIX_DIR}
make && make install

# gsl
cd ${SOURCE_DIR}
wget http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
tar xzf gsl-latest.tar.gz
cd gsl-2.5
./configure --prefix=${PREFIX_DIR}
make && make install

export LDFLAGS=-L${PREFIX_DIR}/lib

# gtk+
# install the development package in system

# libsigc++
# install the development package in system

# gtkmm
cd ${SOURCE_DIR}
	#FAIL# wget http://ftp.gnome.org/pub/GNOME/sources/gtkmm/3.24/gtkmm-3.24.0.tar.xz
	#FAIL# tar xJf gtkmm-3.24.0.tar.xz
	#FAIL# cd gtkmm-3.24.0
	#FAIL# ./configure --prefix=${PREFIX_DIR}
	#FAIL# # gtk+-3.22 installed but needs gtk+3.24+
cd ${SOURCE_DIR}
wget http://ftp.gnome.org/pub/GNOME/sources/gtkmm/3.20/gtkmm-3.20.1.tar.xz
tar xJf gtkmm-3.20.1.tar.xz
cd gtkmm-3.20.1
	#FAIL# ./configure --prefix=${PREFIX_DIR}
	#FAIL# #No package 'giomm-2.4' found
	#FAIL# #No package 'pangomm-1.4' found
	#FAIL# #No package 'cairomm-1.0' found
	# install devel packages for cairomm & pangomm
	#FAIL# ./configure --prefix=${PREFIX_DIR}
	#FAIL# #No package 'atkmm-1.6' found
# install devel package for atkmm
./configure --prefix=${PREFIX_DIR}
make && make install

# libg3d: libg3d and g3dviewer -- skip this
	cd ${SOURCE_DIR}
	wget http://automagically.de/files/libg3d-0.0.8.tar.gz
	wget http://automagically.de/files/g3dviewer-0.2.99.4.tar.gz
	tar xzf libg3d-0.0.8.tar.gz
	cd libg3d-0.0.8
	./configure --prefix=${PREFIX_DIR}
	#FAIL# make && make install
	#FAIL# # /bin/sed: can't read /home/mintadmin/Apps/anaconda/envs/py27/lib/libpcre.la: No such file or directory
	# deactivate conda
	# conda install pcre devel package in system
	make distclean
	./configure --prefix=${PREFIX_DIR}
	make && make install
	cd ..
	tar xzf g3dviewer-0.2.99.4.tar.gz
	cd g3dviewer-0.2.99.4
	./configure --prefix=${PREFIX_DIR}
	checking for GTK+ - version >= 2.4.0... Package gtk+-2.0 was not found in the pkg-config search path.
	Perhaps you should add the directory containing `gtk+-2.0.pc'
	to the PKG_CONFIG_PATH environment variable
	No package 'gtk+-2.0' found
	no
	*** Could not run GTK+ test program, checking why...
	*** The test program failed to compile or link. See the file config.log for the
	*** exact error that occured. This usually means GTK+ is incorrectly installed.
	configure: error: GTK+ >= 2.4.0 is required

	needs GTK-2?  We have GTK-3 for gtkmm
	
# hkl
cd ${SOURCE_DIR}
git clone git://repo.or.cz/hkl.git
cd hkl
git checkout -b next origin/next
	# next step needs gobject-introspection package installed
	# Here is how it fails with the package installed
	(py27) mintadmin@mint-vm:.../src/hkl$ bash ./autogen.sh
	autoreconf: Entering directory `.'
	autoreconf: configure.ac: not using Gettext
	autoreconf: running: aclocal --force -I m4
	configure.ac:193: error: AM_COND_IF: no such condition "HAVE_INTROSPECTION"
	/usr/share/aclocal-1.15/cond-if.m4:23: AM_COND_IF is expanded from...
	configure.ac:193: the top level
	autom4te: /usr/bin/m4 failed with exit status: 1
	aclocal: error: echo failed with exit status: 1
	autoreconf: aclocal failed with exit status: 1
bash ./autogen.sh
./configure --prefix=${PREFIX_DIR}  --disable-hkl-doc
make && make install

# test it by running ghkl
cd ${PREFIX_DIR}
./bin/ghkl
# it worked!
```

Now, tear it all down

```
cd ${PREFIX_DIR}
/bin/rm -rf bin include lib share
cd ${SOURCE_DIR}
/bin/rm -rf gtk/ gtkmm-3.20.1/ gtkmm-3.24.0/
```

Reset the source directories, remove all built products

```
export APSSHARE=/APSshare/linux
export PREFIX_DIR=${APSSHARE}/64
export SOURCE_DIR=${APSSHARE}/src
conda activate py27

# reset gtk-doc
cd ${SOURCE_DIR}/gtk-doc
make distclean

# reset gsl
cd ${SOURCE_DIR}/gsl-2.5
make distclean

# reset hkl
cd ${SOURCE_DIR}/hkl
make distclean
```

Rebuild from source, just the parts we used.

```
export APSSHARE=/APSshare/linux
export PREFIX_DIR=${APSSHARE}/64
export SOURCE_DIR=${APSSHARE}/src
export LDFLAGS=-L${PREFIX_DIR}/lib
#conda activate py27
#_PY_LIB_DIR_=$(dirname $(dirname `which python`))
#export PKG_CONFIG_LIBDIR=${_PY_LIB_DIR_}/lib/pkgconfig
#export PKG_CONFIG_PATH=${PKG_CONFIG_LIBDIR}:/usr/lib/x86_64-linux-gnu/pkgconfig
#export PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR}:/usr/lib/x86_64-linux-gnu/pkgconfig
export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig


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
```

-------------------

The setup for just these parts:

```
export APSSHARE=/APSshare/linux
export PREFIX_DIR=${APSSHARE}/64
export SOURCE_DIR=${APSSHARE}/src

# gtk-doc
cd ${SOURCE_DIR}
git clone https://gitlab.gnome.org/GNOME/gtk-doc.git
cd gtk-doc

# gsl
cd ${SOURCE_DIR}
wget http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
tar xzf gsl-latest.tar.gz
cd gsl-2.5

# gobject-introspection
cd ${SOURCE_DIR}
git clone https://gitlab.gnome.org/GNOME/gobject-introspection.git
cd gobject-introspection

# hkl
cd ${SOURCE_DIR}
git clone git://repo.or.cz/hkl.git
cd hkl
git checkout -b next origin/next
```

today's system package installs (only a few were needed)

```
2019-07-16 09:49:08 install libpangox-1.0-0:amd64 <none> 0.0.2-5
2019-07-16 09:49:08 install libgsf-1-common:all <none> 1.14.41-2
2019-07-16 09:49:08 install libgsf-1-114:amd64 <none> 1.14.41-2
2019-07-16 09:49:09 install libg3d0:amd64 <none> 0.0.8-24
2019-07-16 09:49:09 install libg3d-plugins:amd64 <none> 0.0.8-24
2019-07-16 09:49:09 install libgtkglext1:amd64 <none> 1.2.0-8
2019-07-16 09:49:09 install g3dviewer:amd64 <none> 0.2.99.5~svn130-5
2019-07-16 09:49:09 install libg3d-dev:amd64 <none> 0.0.8-24
2019-07-16 09:49:09 install libg3d-plugin-gdkpixbuf:amd64 <none> 0.0.8-24
2019-07-16 09:50:15 install tex-common:all <none> 6.09
2019-07-16 09:50:15 install freeglut3:amd64 <none> 2.8.1-3
2019-07-16 09:50:15 install libgslcblas0:amd64 <none> 2.4+dfsg-6
2019-07-16 09:50:15 install libgsl23:amd64 <none> 2.4+dfsg-6
2019-07-16 09:50:15 install libosmesa6:amd64 <none> 19.0.2-1ubuntu1.1~18.04.1
2019-07-16 09:50:16 install imagemagick-6.q16:amd64 <none> 8:6.9.7.4+dfsg-16ubuntu6.7
2019-07-16 09:50:16 install imagemagick:amd64 <none> 8:6.9.7.4+dfsg-16ubuntu6.7
2019-07-16 09:50:16 install tk8.6-blt2.5:amd64 <none> 2.5.3+dfsg-4
2019-07-16 09:50:16 install blt:amd64 <none> 2.5.3+dfsg-4
2019-07-16 09:50:16 install python3-tk:amd64 <none> 3.6.8-1~18.04
2019-07-16 09:50:16 install python3-pil.imagetk:amd64 <none> 5.1.0-1
2019-07-16 09:50:16 install libptexenc1:amd64 <none> 2017.20170613.44572-8ubuntu0.1
2019-07-16 09:50:16 install libsynctex1:amd64 <none> 2017.20170613.44572-8ubuntu0.1
2019-07-16 09:50:17 install libtexlua52:amd64 <none> 2017.20170613.44572-8ubuntu0.1
2019-07-16 09:50:17 install libtexluajit2:amd64 <none> 2017.20170613.44572-8ubuntu0.1
2019-07-16 09:50:17 install libpotrace0:amd64 <none> 1.14-2
2019-07-16 09:50:17 install libzzip-0-13:amd64 <none> 0.13.62-3.1ubuntu0.18.04.1
2019-07-16 09:50:17 install texlive-binaries:amd64 <none> 2017.20170613.44572-8ubuntu0.1
2019-07-16 09:50:18 install fonts-lmodern:all <none> 2.004.5-3
2019-07-16 09:50:18 install texlive-base:all <none> 2017.20180305-1
2019-07-16 09:50:20 install texlive-latex-base:all <none> 2017.20180305-1
2019-07-16 09:50:21 install texlive-latex-recommended:all <none> 2017.20180305-1
2019-07-16 09:50:23 install texlive-pictures:all <none> 2017.20180305-1
2019-07-16 09:50:24 install texlive-plain-generic:all <none> 2017.20180305-2
2019-07-16 09:50:27 install texlive-pstricks:all <none> 2017.20180305-2
2019-07-16 09:50:28 install asymptote:amd64 <none> 2.41-4
2019-07-16 09:51:37 install povray:amd64 <none> 1:3.7.0.4-2
2019-07-16 09:51:37 install povray-includes:all <none> 1:3.7.0.4-2
2019-07-16 09:55:08 install libgsl-dev:amd64 <none> 2.4+dfsg-6
2019-07-16 10:05:55 install libbullet2.87:amd64 <none> 2.87+dfsg-2
2019-07-16 10:05:55 install libhkl5:amd64 <none> 5.0.0.2449-1
2019-07-16 10:05:55 install ghkl:amd64 <none> 5.0.0.2449-1
2019-07-16 10:06:07 install gir1.2-hkl-5.0:amd64 <none> 5.0.0.2449-1
2019-07-16 16:10:52 install libdbus-1-dev:amd64 <none> 1.12.2-1ubuntu1.1
2019-07-16 16:10:52 install libxi-dev:amd64 <none> 2:1.7.9-1
2019-07-16 16:10:53 install x11proto-record-dev:all <none> 2018.4-4
2019-07-16 16:10:53 install libxtst-dev:amd64 <none> 2:1.2.3-1
2019-07-16 16:10:53 install libatspi2.0-dev:amd64 <none> 2.28.0-1
2019-07-16 16:10:53 install libatk-bridge2.0-dev:amd64 <none> 2.26.2-1
2019-07-16 16:10:53 install libatk1.0-dev:amd64 <none> 2.28.1-1
2019-07-16 16:10:53 install libcairo-script-interpreter2:amd64 <none> 1.15.10-2ubuntu0.1
2019-07-16 16:10:53 install libpixman-1-dev:amd64 <none> 0.34.0-2
2019-07-16 16:10:54 install libxcb-shm0-dev:amd64 <none> 1.13-2~ubuntu18.04
2019-07-16 16:10:54 install libcairo2-dev:amd64 <none> 1.15.10-2ubuntu0.1
2019-07-16 16:10:54 install libepoxy-dev:amd64 <none> 1.4.3-1
2019-07-16 16:10:54 install libgdk-pixbuf2.0-dev:amd64 <none> 2.36.11-2
2019-07-16 16:10:54 install libpango1.0-dev:amd64 <none> 1.40.14-1ubuntu0.1
2019-07-16 16:10:54 install x11proto-xinerama-dev:all <none> 2018.4-4
2019-07-16 16:10:55 install libxinerama-dev:amd64 <none> 2:1.1.3-1
2019-07-16 16:10:55 install x11proto-randr-dev:all <none> 2018.4-4
2019-07-16 16:10:55 install libxrandr-dev:amd64 <none> 2:1.5.1-1
2019-07-16 16:10:55 install libxcursor-dev:amd64 <none> 1:1.1.15-1
2019-07-16 16:10:55 install wayland-protocols:all <none> 1.13-1
2019-07-16 16:10:55 install libxkbcommon-dev:amd64 <none> 0.8.0-1ubuntu0.1
2019-07-16 16:10:55 install libgtk-3-dev:amd64 <none> 3.22.30-1ubuntu3
2019-07-16 17:26:49 install gobject-introspection:amd64 <none> 1.56.1-1
```
