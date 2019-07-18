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
GIT=git
ID=id
LS=ls
MAKE=make
MKDIR=mkdir
PS=ps
READLINK=readlink
SCRIPT_NAME=${BASH_SOURCE:-$0}
TAR=tar
WGET=wget

build() {
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

	${ECHO} "Downloading hkl in ${BUILD_DIR}"
	${CD} ${BUILD_DIR}
	${GIT} clone git://repo.or.cz/hkl.git
	${CD} hkl
	${GIT} checkout -b next origin/next
	
	${ECHO} "Directory of ${BUILD_DIR}"
	${LS} -lAFgh ${BUILD_DIR}
}

# TODO: replace with better
contains() {
	_source=$1
	_item=$2
	contains_result=0
	IFS=':'
	for _s in $_source; do
		if [ "$_item" == "$_s" ] ; then
			contains_result=${contains_result} + 1
		fi
	done
	unset IFS
	unset _source
	unset _item
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

# FIXME: stops appending after two items, replace with better
strip_item_from_path() {
	_item=$1
	IFS=':'
	_new_path=
	for _s in $PATH; do
		#echo "examining: $_s"
		if [[ "$_s" != *"$_item"* ]] ; then
			append_or_define_path ${_new_path} ${_s}
			_new_path=${append_or_define_path_result}
		fi
		# echo "---------------"
	done
	unset IFS
	#echo "_new_path : $_new_path"
}

download() {
    ${ECHO} "${ARG1}"
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

setup() {
	IS_MINT=`grep "^NAME=" /etc/os-release | grep "Linux Mint"`
	IS_RHEL=`grep "^NAME=" /etc/os-release | grep "Red Hat Enterprise Linux"`
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

tests() {
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

	strip_item_from_path anaconda/

}

usage() {
    ${ECHO} "Usage: $(${BASENAME} ${SCRIPT_NAME}) {build|download|info|reset|tests}"
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

    tests)
    setup
    tests
    ;;

    reset)
    setup
    reset
    ;;

    *)
    usage
    ;;
esac
