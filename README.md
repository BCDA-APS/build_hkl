# build_hkl

This repository provides a tool (['build.sh`]())
to download, build, install, and test the
[*hkl*](https://people.debian.org/~picca/hkl/hkl.html) package 
(source code: https://repo.or.cz/hkl.git).

In this file, edit BUILD_DIR to specify where the source code
will be stored and built.  Edit PREFIX_DIR to specify where 
build products (executable, libraries, configuration files, ...)
will be stored.  By default, 

	PREFIX_DIR=${HOME}/Apps/hkl-5
	BUILD_DIR=/tmp/hkl_source_build

To start the download, build, and installation
steps with this command:

    ./build.sh build

See also [work](https://github.com/NSLS-II/hklpy) to integrate 
*hkl* into [*bluesky*](https://blueskyproject.io/) and 
[ophyd](https://github.com/bluesky/ophyd)
