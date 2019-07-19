#!/bin/bash

# build the hkl package from source

# must be absolute paths!
#export PREFIX_DIR=/APSshare/linux/64/hkl-5
export PREFIX_DIR=${HOME}/Apps/hkl-5
export BUILD_DIR=/tmp/hkl_source_build

# build with a very primitive PATH
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin

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
CHMOD=chmod
DIRNAME=dirname
ECHO=echo
EXIT=exit
GIT=git
GREP=grep
ID=id
LS=ls
MAKE=make
MKDIR=mkdir
RM=rm
SCRIPT_NAME=${BASH_SOURCE:-$0}
TAR=tar
TEE=tee
WGET=wget

build() {
    if [ ! -d ${BUILD_DIR} ]; then
        ${ECHO} "${BUILD_DIR} does not exist .. downloading first"
        download
    fi
    
    ${ECHO} "Building in ${BUILD_DIR}, installing into ${PREFIX_DIR}"

    # build gtk-doc
    ${CD} ${BUILD_DIR}/gtk-doc
    ${BASH} autogen.sh 2>&1 | ${TEE} autogen.log
    check_xmlcatalog_found
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    exit_if_no_Makefile
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # build gsl
    ${CD} ${BUILD_DIR}/gsl-2.5
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    exit_if_no_Makefile
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # gobject-introspection
    ${CD} ${BUILD_DIR}/gobject-introspection
    ${BASH} ./autogen.sh 2>&1 | ${TEE} autogen.log
    ./configure --prefix=${PREFIX_DIR} 2>&1 | ${TEE} configure.log
    exit_if_no_Makefile
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    # build hkl
    ${CD} ${BUILD_DIR}/hkl
    ${BASH} ./autogen.sh 2>&1 | ${TEE} autogen.log
    ./configure --prefix=${PREFIX_DIR}  --disable-hkl-doc 2>&1 | ${TEE} configure.log
    check_gobject_introspection
    exit_if_no_Makefile
    ${MAKE} 2>&1 | ${TEE}  make.log
    ${MAKE} install 2>&1 | ${TEE}  install.log

    make_env_setup
    ${ECHO} "Setup your bash environment with this command before running Python code"
    ${ECHO} "   . ${PREFIX_DIR}/hkl_environment.sh "
}

download() {
    ${MKDIR} -p ${BUILD_DIR}

    ${ECHO} "Downloading gtk-doc in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    if [ -e gtk-doc ]; then
        ${ECHO} "ERROR: ${BUILD_DIR}/gtk-doc exists"
        exit 1
    fi
    ${GIT} clone https://gitlab.gnome.org/GNOME/gtk-doc.git

    ${ECHO} "Downloading gsl in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    # TODO: *learn: the directory's name
    if [ -e gsl-2.5 ]; then
        ${ECHO} "ERROR: ${BUILD_DIR}/gsl-2.5 exists"
        exit 1
    fi
    ${WGET} http://gnu.mirrors.pair.com/gsl/gsl-latest.tar.gz
    ${TAR} xzf gsl-latest.tar.gz

    ${ECHO} "Downloading gobject-introspection in ${BUILD_DIR}"
    ${CD} ${BUILD_DIR}
    if [ -e gobject-introspection ]; then
        ${ECHO} "ERROR: ${BUILD_DIR}/gobject-introspection exists"
        exit 1
    fi
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
    if [ -e hkl ]; then
        ${ECHO} "ERROR: ${BUILD_DIR}/hkl exists"
        exit 1
    fi
    ${GIT} clone git://repo.or.cz/hkl.git
    ${CD} hkl
    ${ECHO} "git checkout branch 'next' of gobject-introspection"
    ${GIT} checkout -b next origin/next
    
    ${ECHO} "Directory of ${BUILD_DIR}"
    ${LS} -lAFgh ${BUILD_DIR}
}

reset() {
    ${ECHO} "resetting source directories to distclean state"

    # reset gtk-doc
    ${CD} ${BUILD_DIR}/gtk-doc
    if [ -e ./Makefile ]; then
        ${MAKE} distclean
    fi
    ${RM} -f *.log configure

    # reset gsl
    ${CD} ${BUILD_DIR}/gsl-2.5
    if [ -e ./Makefile ]; then
        ${MAKE} distclean
    fi
    ${RM} -f *.log

    # gobject-introspection
    ${CD} ${BUILD_DIR}/gobject-introspection
    if [ -e ./Makefile ]; then
        ${MAKE} distclean
    fi
    ${RM} -f *.log configure

    # reset hkl
    ${CD} ${BUILD_DIR}/hkl
    if [ -e ./Makefile ]; then
        ${MAKE} distclean
    fi
    ${RM} -f *.log configure
}

info() {
    ${ECHO} "ARG1:            ${ARG1}"
    ${ECHO} "BASENAME:        ${BASENAME}"
    # ${ECHO} "BASH:            ${BASH}"
    ${ECHO} "BUILD_DIR:       ${BUILD_DIR}"
    ${ECHO} "DIRNAME:         ${DIRNAME}"
    # ${ECHO} "ECHO:            ${ECHO}"
    ${ECHO} "GI_DIR_OS:       ${GI_DIR_OS}"
    # ${ECHO} "GIT:             ${GIT}"
    ${ECHO} "GI_TYPELIB_PATH: ${GI_TYPELIB_PATH}"
    ${ECHO} "ID:              ${ID}"
    ${ECHO} "IS_MINT:         ${IS_MINT}"
    ${ECHO} "IS_RHEL7:        ${IS_RHEL7}"
    ${ECHO} "LDFLAGS:         ${LDFLAGS}"
    ${ECHO} "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
    # ${ECHO} "MAKE:            ${MAKE}"
    # ${ECHO} "MKDIR:           ${MKDIR}"
    ${ECHO} "OS:              ${OS}"
    ${ECHO} "PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}"
    ${ECHO} "PREFIX_DIR:      ${PREFIX_DIR}"
    ${ECHO} "SCRIPT_NAME:     ${SCRIPT_NAME}"
    # ${ECHO} "TAR:             ${TAR}"
    # ${ECHO} "WGET:            ${WGET}"
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

exit_if_no_Makefile() {
    if [ ! -e ./Makefile ]; then
        ${ECHO} "No Makefile in `pwd`"
        exit 1
    fi
}

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
        _result=`${GREP} "${match}" ${BUILD_DIR}/hkl/configure.log`
        echo "match = |$match|"
        echo "check = |$_result|"
    fi

    if [[ ${_result} == *"... no" ]]; then
        ${ECHO} "ERROR: gobject-introspection package not found during configure step"
        ${ECHO} "  '${_result}'"
        ${ECHO} "  For more details, examine these files:"
        ${ECHO} "    - ${BUILD_DIR}/hkl/configure.log"
        ${ECHO} "    - ${BUILD_DIR}/hkl/config.log"
        ${ECHO} "  Are there conflicting 'gobject-introspection-1.0.pc' file on your system?"
        ${ECHO} "  In each, check the 'Version:' line"
        ${ECHO} "  (Hint: try removing Anaconda Python from PATH)"
        ${EXIT} 1
    fi
}

check_xmlcatalog_found() {
    # report and exit if problem
    if [ -e ${BUILD_DIR}/gtk-doc/autogen.log ]; then
        match="checking for xmlcatalog"
        _result=`${GREP} "${match}" ${BUILD_DIR}/gtk-doc/autogen.log`
        echo "match = |$match|"
        echo "check = |$_result|"
    fi

    if [[ ${_result} == *"... no" ]]; then
        ${ECHO} "ERROR: xmlcatalog not found during autogen.sh step"
        ${ECHO} "  '${_result}'"
        ${ECHO} "  For more details, examine this file:"
        ${ECHO} "    - ${BUILD_DIR}/gtk-doc/autogen.log"
        ${ECHO} "  Debian: Is the libxml2-utils package installed on your system?"
        ${ECHO} "  RHEL: Is the libxml2 package installed on your system?"
        ${EXIT} 1
    fi
}

# TODO: replace with better
append_or_define_path() {
    _path=$1
    entry=$2
    contains ${_path} ${entry}
    if [ ${contains_result} != 0 ]; then
        # already defined, keep list
        append_or_define_path_result=${_path}
    elif [ "${entry}" == "${_path}" ] ; then
        # same thing
        append_or_define_path_result=${_path}
    elif [ "" == "${_path}" ] ; then
        # empty _path, create list
        append_or_define_path_result=${entry}
    elif [ "" == "${entry}" ] ; then
        # empty entry, keep list
        append_or_define_path_result=${_path}
    else
        # append to list
        append_or_define_path_result=${_path}:${entry}
    fi
    # echo "append_or_define_path_result: $append_or_define_path_result"
}

contains() {
    # return 0 if path $source does not contain $item
    source=$1
    item=$2
    contains_result=0
    if [[ ${source} == "${item}:"* ]]; then
        # at the start
        contains_result=1
    elif [[ ${source} == *":${item}" ]]; then
        # at the end
        contains_result=3
    elif [[ ${source} == *":${item}:"* ]]; then
        # in the middle
        contains_result=2
    fi
    # echo "contains: ${item} -- ${contains_result}"
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

    contains /bin:/usr/local/bin:/tmp /boot
    contains /bin:/usr/local/bin:/tmp /bin
    contains /bin:/usr/local/bin:/tmp /usr/local/bin
    contains /bin:/usr/local/bin:/tmp /tmp
    
    append_or_define_path /start
    append_or_define_path /start /start
    append_or_define_path /start:/middle:/end /start
    append_or_define_path /start:/middle:/end /middle
    append_or_define_path /start:/middle:/end /end
    append_or_define_path /start:/middle:/end /end/more
    append_or_define_path /start:/middle:/end /end/more

    # make_env_setup

}

make_env_setup() {
    _f=${PREFIX_DIR}/hkl_environment.sh
    ${ECHO} "Creating environment setup in ${_f}"
    
    ${ECHO} "#!/bin/bash" > ${_f}
    ${ECHO} "" >> ${_f}
    ${ECHO} "# source this file to setup environment for hkl:" >> ${_f}
    ${ECHO} "#    . ${_f}" >> ${_f}
    ${ECHO} "" >> ${_f}
    ${ECHO} "export PATH=\$PATH:${PREFIX_DIR}/bin" >> ${_f}
    ${ECHO} "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${_f}
    ${ECHO} "export GI_TYPELIB_PATH=${GI_TYPELIB_PATH}" >> ${_f}
    
    ${CHMOD} +x ${_f}
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
