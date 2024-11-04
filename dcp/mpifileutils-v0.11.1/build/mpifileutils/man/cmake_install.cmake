# Install script for directory: /lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man

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
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dbcast.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dchmod.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dcmp.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dcp.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/ddup.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dbz2.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dfind.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dreln.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/drm.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dstripe.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dsync.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dtar.1;/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1/dwalk.1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/install/share/man/man1" TYPE FILE FILES
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dbcast.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dchmod.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dcmp.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dcp.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/ddup.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dbz2.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dfind.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dreln.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/drm.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dstripe.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dsync.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dtar.1"
    "/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/man/dwalk.1"
    )
endif()

