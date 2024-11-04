# Install script for directory: /lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/mpifileutils/src

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

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dbcast/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dbz2/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dchmod/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dcmp/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dcp/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dcp1/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/ddup/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dfilemaker1/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dfind/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dreln/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/drm/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dstripe/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dsync/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dtar/cmake_install.cmake")
  include("/lustre/orion/proj-shared/stf008/hvac/sylee/dcp/mpifileutils-v0.11.1/build/mpifileutils/src/dwalk/cmake_install.cmake")

endif()

