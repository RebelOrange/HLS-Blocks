# Copyright 2011,2012,2014 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.8)
project(gr-testmodule CXX C)
enable_testing()

# Install to PyBOMBS target prefix if defined
if(DEFINED ENV{PYBOMBS_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{PYBOMBS_PREFIX})
    message(STATUS "PyBOMBS installed GNU Radio. Setting CMAKE_INSTALL_PREFIX to $ENV{PYBOMBS_PREFIX}")
endif()

# Select the release build type by default to get optimization flags
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Release")
   message(STATUS "Build type not specified: defaulting to release.")
endif(NOT CMAKE_BUILD_TYPE)
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "")

# Make sure our local CMake Modules path comes first
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/Modules)

# Set the version information here
set(VERSION_MAJOR 3)
set(VERSION_API   8)
set(VERSION_ABI   0)
set(VERSION_PATCH 0)

cmake_policy(SET CMP0011 NEW)

# Enable generation of compile_commands.json for code completion engines
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

########################################################################
# Compiler specific setup
########################################################################
if((CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR
    CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    AND NOT WIN32)
    #http://gcc.gnu.org/wiki/Visibility
    add_definitions(-fvisibility=hidden)
endif()

SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_C_STANDARD 11)

########################################################################
# Install directories
########################################################################
find_package(Gnuradio "3.8" REQUIRED)
include(GrVersion)

include(GrPlatform) #define LIB_SUFFIX

if(NOT CMAKE_MODULES_DIR)
    set(CMAKE_MODULES_DIR lib${LIB_SUFFIX}/cmake)
endif(NOT CMAKE_MODULES_DIR)

set(GR_INCLUDE_DIR      include/testmodule)
set(GR_CMAKE_DIR        ${CMAKE_MODULES_DIR}/testmodule)
set(GR_PKG_DATA_DIR     ${GR_DATA_DIR}/${CMAKE_PROJECT_NAME})
set(GR_PKG_DOC_DIR      ${GR_DOC_DIR}/${CMAKE_PROJECT_NAME})
set(GR_PKG_CONF_DIR     ${GR_CONF_DIR}/${CMAKE_PROJECT_NAME}/conf.d)
set(GR_PKG_LIBEXEC_DIR  ${GR_LIBEXEC_DIR}/${CMAKE_PROJECT_NAME})

set(RFNOC_DATA_DIR     share                          CACHE PATH "Base location for data")
set(RFNOC_PKG_DATA_DIR ${RFNOC_DATA_DIR}/rfnoc/       CACHE PATH "Path to install RFNoC package data")
set(PROJECT_DATA_DIR   ${RFNOC_PKG_DATA_DIR}          CACHE PATH "Path for this project's package data")

########################################################################
# On Apple only, set install name and use rpath correctly, if not already set
########################################################################
if(APPLE)
    if(NOT CMAKE_INSTALL_NAME_DIR)
        set(CMAKE_INSTALL_NAME_DIR
            ${CMAKE_INSTALL_PREFIX}/${GR_LIBRARY_DIR} CACHE
            PATH "Library Install Name Destination Directory" FORCE)
    endif(NOT CMAKE_INSTALL_NAME_DIR)
    if(NOT CMAKE_INSTALL_RPATH)
        set(CMAKE_INSTALL_RPATH
            ${CMAKE_INSTALL_PREFIX}/${GR_LIBRARY_DIR} CACHE
            PATH "Library Install RPath" FORCE)
    endif(NOT CMAKE_INSTALL_RPATH)
    if(NOT CMAKE_BUILD_WITH_INSTALL_RPATH)
        set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE
            BOOL "Do Build Using Library Install RPath" FORCE)
    endif(NOT CMAKE_BUILD_WITH_INSTALL_RPATH)
endif(APPLE)

###########################################################################
# Find UHD
###########################################################################
find_package(UHD "4.0" REQUIRED)
if(UHD_FOUND)
    message(STATUS "Found UHD:")
    include_directories(${UHD_INCLUDE_DIRS})
    message(STATUS " * INCLUDES = ${UHD_INCLUDE_DIRS}")
    link_directories(${UHD_LIBRARIES})
    message(STATUS " * LIBS = ${UHD_LIBRARIES}")
    find_program(_rfnoc_image_builder_exe
        "rfnoc_image_builder"
    )
    if (_rfnoc_image_builder_exe)
        message(STATUS
            " * rfnoc_image_builder = ${_rfnoc_image_builder_exe}")
    endif()
else()
    message(FATAL_ERROR "UHD >= 4.0 not found.")
endif()

set(UHD_FPGA_DIR "" CACHE PATH "Path to FPGA source directory")
if(NOT UHD_FPGA_DIR)
    message(FATAL_ERROR
        "Could not find FPGA directory."
        "Please provide it using -DUHD_FPGA_DIR!")
endif(NOT UHD_FPGA_DIR)
if(UHD_FPGA_DIR AND NOT EXISTS ${UHD_FPGA_DIR}/usrp3/top/Makefile.common)
    message(
        FATAL_ERROR
        "Invalid FPGA source directory: ${UHD_FPGA_DIR}. "
        "Please provide it using -DUHD_FPGA_DIR!")
endif()
message(STATUS " * FPGA source directory: ${UHD_FPGA_DIR}")

set(UHD_FPGA_DEFAULT_DEVICE "e310"
    CACHE STRING "Default device for testbench execution")

########################################################################
# Find rfnoc-testmodule build dependencies
########################################################################
find_package(ettus REQUIRED)
if(NOT ettus_FOUND)
    message(FATAL_ERROR "gnuradio-ettus not found.")
endif(NOT ettus_FOUND)

find_package(PythonLibs)
if(NOT PYTHONLIBS_FOUND)
    message(FATAL_ERROR "Python Libs not found.")
endif(NOT PYTHONLIBS_FOUND)

include_directories(
    ${CMAKE_SOURCE_DIR}/lib
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_BINARY_DIR}/lib
    ${CMAKE_BINARY_DIR}/include
)

########################################################################
# Find bash (for executing make and sourcing the Vivado env)
########################################################################
find_package(UnixCommands)
if(BASH)
    message(STATUS "Found bash interpreter: ${BASH}")
    configure_file(
        ${CMAKE_SOURCE_DIR}/cmake/Modules/run_testbench.sh.in
        ${CMAKE_BINARY_DIR}/cmake/Modules/run_testbench.sh
        @ONLY
    )
else()
    message(FATAL_ERROR
        "Bash interpreter not found: Cannot generate FPGA targets.")
endif()

########################################################################
# Testbench targets and FPGA helpers
########################################################################
add_custom_target(testbenches)
macro(RFNOC_ADD_TB_DIR)
    if(UHD_FPGA_DIR)
        get_filename_component(_tb_dir "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
        set(_target_name "${_tb_dir}_tb")
        message(STATUS "Adding testbench target: ${_target_name}")
        # Use e310 so the simulation uses a free webpack license compatiable device
        add_custom_target(${_target_name}
            COMMAND ${CMAKE_SOURCE_DIR}/build/cmake/Modules/run_testbench.sh ${UHD_FPGA_DIR} e310 ${CMAKE_CURRENT_SOURCE_DIR} xsim
        )
        add_dependencies(testbenches ${_target_name})
    endif()
endmacro()

# Helper macro to register an RFNoC block directory.
# Such a directory must always have a Makefiles.srcs containing all the
# required HDL files for synthesis, and optionally a Makefile file for running
# the testbench.
# The NOTESTBENCH argument can be used to skip the testbench target generation.
macro(RFNOC_REGISTER_BLOCK_DIR)
    cmake_parse_arguments(_rfnoc_block "NOTESTBENCH" "" "" ${ARGN})
    get_filename_component(_blk_name "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
    message(STATUS "Registering RFNoC block: ${_blk_name}")
    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/Makefile.srcs _makefile_srcs)
    list(APPEND _block_src_files "Makefile.srcs")
    string(REGEX MATCHALL "[a-z_]+\\.(vhdl|vhd|vh|svh|sv|v)" _src_files ${_makefile_srcs})
    foreach(_src_file ${_src_files})
        string(STRIP "${_src_file}" _src_file})
        list(APPEND _block_src_files "${_src_file}")
    endforeach()
    install(FILES ${_block_src_files}
        DESTINATION ${PROJECT_DATA_DIR}/fpga/${_blk_name}
        COMPONENT fpga)
    RFNOC_ADD_TB_DIR()
endmacro()

macro(RFNOC_REGISTER_IMAGE_CORE)
    cmake_parse_arguments(_rfnoc_image_core "" "SRC" "" ${ARGN})
    get_filename_component(_target_name ${_rfnoc_image_core_SRC} NAME_WE)
    if(NOT _target_name MATCHES "image_core")
        message(FATAL_ERROR
            "Invalid image core source file name: ${_rfnoc_image_core_SRC} (must end in `image_core`)")
    endif()
    if (_rfnoc_image_builder_exe)
        message(STATUS "Adding image core target: ${_target_name}")
        add_custom_target(${_target_name}
            COMMAND ${_rfnoc_image_builder_exe} -F ${UHD_FPGA_DIR} -y ${CMAKE_CURRENT_SOURCE_DIR}/${_rfnoc_image_core_SRC} -I ${CMAKE_SOURCE_DIR}/rfnoc
        )
    endif()
endmacro()

macro(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        SET(dirlist ${dirlist} ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
endmacro()

########################################################################
# Find gnuradio build dependencies
########################################################################
find_package(Doxygen)

########################################################################
# Setup doxygen option
########################################################################
if(DOXYGEN_FOUND)
    option(ENABLE_DOXYGEN "Build docs using Doxygen" ON)
else(DOXYGEN_FOUND)
    option(ENABLE_DOXYGEN "Build docs using Doxygen" OFF)
endif(DOXYGEN_FOUND)

########################################################################
# Create uninstall target
########################################################################
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
@ONLY)

add_custom_target(uninstall
    ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )


########################################################################
# Add subdirectories
########################################################################
add_subdirectory(include/testmodule)
add_subdirectory(lib)
add_subdirectory(apps)
add_subdirectory(docs)
add_subdirectory(swig)
add_subdirectory(python)
add_subdirectory(grc)
add_subdirectory(rfnoc)
add_subdirectory(rfnoc/blocks)
add_subdirectory(rfnoc/fpga)
add_subdirectory(rfnoc/icores)

########################################################################
# Install cmake search helper for this library
########################################################################

install(FILES cmake/Modules/testmoduleConfig.cmake
    DESTINATION ${CMAKE_MODULES_DIR}/testmodule
)
