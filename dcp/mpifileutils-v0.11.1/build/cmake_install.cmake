# Install script for directory: /lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/opt/cray/pe/cce/17.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_errors.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_bz2.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_flist.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_flist_internal.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_io.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_param_path.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_path.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_pred.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_progress.h"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/common/mfu_util.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0"
         RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib64" TYPE SHARED_LIBRARY FILES "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/libmfu.so.4.0.0")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0"
         OLD_RPATH "/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
         NEW_RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/opt/cray/pe/cce/17.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so.4.0.0")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so"
         RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib64" TYPE SHARED_LIBRARY FILES "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/libmfu.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so"
         OLD_RPATH "/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
         NEW_RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/opt/cray/pe/cce/17.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib64/libmfu.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib64" TYPE STATIC_LIBRARY FILES "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/libmfu.a")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lwgrp" TYPE FILE FILES
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/lwgrp/README"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/lwgrp/LICENSE.TXT"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/dtcmp" TYPE FILE FILES
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/dtcmp/README.md"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/dtcmp/LICENSE.TXT"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/libcircle" TYPE FILE FILES "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/libcircle/COPYING")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/mpifileutils" TYPE FILE FILES
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/LICENSE"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/NOTICE"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/test/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/man/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
