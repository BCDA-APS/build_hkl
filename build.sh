#!/bin/bash

# build the hkl package from source

# must be absolute paths!
#export PREFIX_DIR=/APSshare/linux/64/hkl
export PREFIX_DIR=${HOME}/hkl
export BUILD_DIR=/tmp/hkl_source_build

####################################################################
# build these packages in BUILD_DIR
# install them in PREFIX_DIR
#
# gtk-doc
# gsl
# gobject-introspection
# hkl

####################################################################

# Commands needed by this script
ARG1=$1
BASENAME=basename
BASH=bash
CD=cd
DIRNAME=dirname
ECHO=echo
EXIT=exit
GIT=git
GREP=grep
ID=id
LS=ls
MAKE=make
MKDIR=mkdir
PS=ps
READLINK=readlink
SCRIPT_NAME=${BASH_SOURCE:-$0}
TAR=tar
TEE=tee
WGET=wget

build() {
    ${ECHO} "Building in ${BUILD_DIR}, installing into ${PREFIX_DIR}"

    # build gtk-doc
    ${CD} ${BUILD_DIR}/gtk-doc
    ${BASH} autogen.sh 2>&1 | ${TEE} autogen.log
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # build gsl
    ${CD} ${BUILD_DIR}/gsl-2.5
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # gobject-introspection
    ${CD} ${BUILD_DIR}/gobject-introspection
    ${BASH} ./autogen.sh 2>&1 | ${TEE} autogen.log
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # build hkl
    ${CD} ${BUILD_DIR}/hkl
    ${BASH} ./autogen.sh 2>&1 | ${TEE} autogen.log
    ./configure --prefix=${PREFIX_DIR}  --disable-hkl-doc 2>&1 | ${TEE} configure.log
    check_gobject_introspection
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log
}

download() {
    ${MKDIR} -p ${BUILD_DIR}

    ${ECHO} "Downloading gtk-doc in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    ${GIT} clone https://gitlab.gnome.org/GNOME/gtk-doc.git

    ${ECHO} "Downloading gsl in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    ${WGET} http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
    ${TAR} xzf gsl-latest.tar.gz

    ${ECHO} "Downloading gobject-introspection in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    ${GIT} clone https://gitlab.gnome.org/GNOME/gobject-introspection.git
    ${CD} gobject-introspection
    # autogen.sh was removed after this tag
    # Mint: we have glib-2.0 2.56.4
    # 1.60.0 needs glib-2.0 >= 2.58.0
    # 1.59.4 needs glib-2.0 >= 2.58.0
    # 1.57.2 needs glib-2.0 >= 2.57.2
    # 1.56.1 needs glib-2.0 >= 2.56.1
    # 1.56.0 needs glib-2.0 >= 2.56.0
    ${ECHO} "git checkout tag 1.56.1 of gobject-introspection"
    ${GIT} checkout 1.56.1

    ${ECHO} "Downloading hkl in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    ${GIT} clone git://repo.or.cz/hkl.git
    ${CD} hkl
    ${ECHO} "git checkout branch 'next' of gobject-introspection"
    ${GIT} checkout -b next origin/next
    
    ${ECHO} "Directory of ${BUILD_DIR}"
    ${LS} -lAFgh ${BUILD_DIR}
}

info() {
    ${ECHO} "ARG1:            ${ARG1}"
    ${ECHO} "BASENAME:        ${BASENAME}"
    ${ECHO} "BASH:            ${BASH}"
    ${ECHO} "BUILD_DIR:       ${BUILD_DIR}"
    ${ECHO} "DIRNAME:         ${DIRNAME}"
    ${ECHO} "ECHO:            ${ECHO}"
    ${ECHO} "GI_DIR_OS:       ${GI_DIR_OS}"
    ${ECHO} "GIT:             ${GIT}"
    ${ECHO} "GI_TYPELIB_PATH: ${GI_TYPELIB_PATH}"
    ${ECHO} "ID:              ${ID}"
    ${ECHO} "IS_MINT:         ${IS_MINT}"
    ${ECHO} "IS_RHEL7:        ${IS_RHEL7}"
    ${ECHO} "LDFLAGS:         ${LDFLAGS}"
    ${ECHO} "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
    ${ECHO} "MAKE:            ${MAKE}"
    ${ECHO} "MKDIR:           ${MKDIR}"
    ${ECHO} "OS:              ${OS}"
    ${ECHO} "PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}"
    ${ECHO} "PREFIX_DIR:      ${PREFIX_DIR}"
    ${ECHO} "PS:              ${PS}"
    ${ECHO} "READLINK:        ${READLINK}"
    ${ECHO} "SCRIPT_NAME:     ${SCRIPT_NAME}"
    ${ECHO} "TAR:             ${TAR}"
    ${ECHO} "WGET:            ${WGET}"
}

reset() {
    ${ECHO} "resetting source directories to distclean state"

    # reset gtk-doc
    ${CD} ${BUILD_DIR}/gtk-doc
    ${MAKE} distclean

    # reset gsl
    ${CD} ${BUILD_DIR}/gsl-2.5
    ${MAKE} distclean

    # gobject-introspection
    ${CD} ${BUILD_DIR}/gobject-introspection
    ${MAKE} distclean

    # reset hkl
    ${CD} ${BUILD_DIR}/hkl
    ${MAKE} distclean
}

setup() {
    IS_MINT=`${GREP} "^NAME=" /etc/os-release | ${GREP} "Linux Mint"`
    IS_RHEL=`${GREP} "^NAME=" /etc/os-release | ${GREP} "Red Hat Enterprise Linux"`
    if [ "" != "${IS_MINT}" ] ; then
        export OS=Mint
        export GI_DIR_OS=/usr/lib/x86_64-linux-gnu/girepository-1.0
    elif [ "" != "${IS_RHEL}" ] ; then
        export OS=Mint
        export GI_DIR_OS=/usr/lib/girepository-1.0
    else
        export OS=
    fi
    
    # only if ${PREFIX_DIR}/bin not already in path
    _part=${PREFIX_DIR}/bin
    append_or_define_path ${PATH} ${_part}
    export PATH=${append_or_define_path_result}
    # echo $PATH
    
    if [ -z "$IOC_STARTUP_DIR" ] ; then
        export LD_LIBRARY_PATH=${PREFIX_DIR}/lib
    else
        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX_DIR}/lib
    fi
    export LDFLAGS=-L${PREFIX_DIR}/lib
    
    # for gobject-introspection
    # PKG_CONFIG_PATH needed to find .pc file(s)
    export PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig

    # GI_TYPELIB_PATH needed by Python clients to find .typelib file(s)
    export GI_TYPELIB_PATH=${PREFIX_DIR}/lib/girepository-1.0:${GI_DIR_OS}
}

####################################################################

check_gobject_introspection() {
	# report and exit if problem

	# Problem occurs when we try to find gobject-introspection
	# The system provides one version, Anaconda another
	# Detect this *after* the configure step during the build.
	# if problem: configure.log contains this message: 
	#    checking for gobject-introspection... no
	# if no problem: configure.log contains this message: 
	#    checking for gobject-introspection... yes
	
	if [ -e ${BUILD_DIR}/hkl/configure.log ]; then
	    match="checking for gobject-introspection"
	    check_gobject_introspection_check=`${GREP} "${match}" ${BUILD_DIR}/hkl/configure.log`
	    echo "match = |$match|"
	    echo "check = |$check_gobject_introspection_check|"
	fi

	if [[ ${check_gobject_introspection_check} == *"... no" ]]; then
		${ECHO} "ERROR: gobject-introspection package not found during configure step"
		${ECHO} "  '${check_gobject_introspection_check}'"
		${ECHO} "  For more details, examine these files:"
		${ECHO} "    - ${BUILD_DIR}/hkl/configure.log"
		${ECHO} "    - ${BUILD_DIR}/hkl/config.log"
		${ECHO} "  Are there conflicting 'gobject-introspection-1.0.pc' file on your systems?"
		${ECHO} "  In each, check the 'Version:' line"
		${ECHO} "  (Hint: try removing Anaconda Python from PATH)"
		${EXIT} 1
	fi
}

# TODO: replace with better
append_or_define_path() {
    target=$1
    entry=$2
    if [ "" == "${target}" ] ; then
        append_or_define_path_result=${entry}
    elif [ "" == "${entry}" ] ; then
        append_or_define_path_result=${target}
    else
        append_or_define_path_result=${target}:${entry}
    fi
    # echo "append_or_define_path_result: $append_or_define_path_result"
}

developer() {
    #${ECHO} "${ARG1}"
    #if [ "" == "${IOC_PID}" ] ; then
    #  echo "IOC_PID matches empty string"
    #fi
    #if [ -z "$IOC_STARTUP_DIR" ] ; then
    #  echo "-z was True : IOC_STARTUP_DIR='$IOC_STARTUP_DIR'"
    #fi
    #if [ -d "/usr/lib/x86_64-linux-gnu/" ] ; then
    #  echo "/usr/lib/x86_64-linux-gnu/: yes"
    #fi
    #if [ -d "/no/such/path/" ] ; then
    #  echo "/no/such/path/: yes"
    #fi

    check_gobject_introspection

}

usage() {
    ${ECHO} "Usage: $(${BASENAME} ${SCRIPT_NAME}) {build|download|info|reset}"
}

####################################################################

case ${ARG1} in
    build)
    setup
    build
    ;;

    download)
    setup
    download
    ;;

    info)
    setup
    info
    ;;

    dev | devel | developer)
    setup
    developer
    ;;

    reset)
    setup
    reset
    ;;

    *)
    usage
    ;;
esac
