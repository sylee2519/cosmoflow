# Install script for directory: /lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src/dstripe

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
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe"
         RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dstripe/dstripe")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe"
         OLD_RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib:"
         NEW_RPATH "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib64:/opt/cray/pe/mpich/8.1.28/ofi/cray/17.0/lib:/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/opt/cray/pe/cce/17.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/dstripe")
    endif()
  endif()
endif()

