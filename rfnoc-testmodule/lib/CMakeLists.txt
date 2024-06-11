# Copyright 2011,2012 Free Software Foundation, Inc.
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
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

list(APPEND testmodule_sources
    testblock_impl.cc
    testblock_block_ctrl_impl.cpp
)

set(testmodule_sources "${testmodule_sources}" PARENT_SCOPE)
if(NOT testmodule_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT testmodule_sources)

add_library(gnuradio-testmodule SHARED ${testmodule_sources})
target_link_libraries(gnuradio-testmodule ${Boost_LIBRARIES} ${GNURADIO_ALL_LIBRARIES} ${ETTUS_LIBRARIES})
set_target_properties(gnuradio-testmodule PROPERTIES DEFINE_SYMBOL "gnuradio_testmodule_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-testmodule PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
install(TARGETS gnuradio-testmodule
    LIBRARY DESTINATION lib${LIB_SUFFIX} # .so/.dylib file
    ARCHIVE DESTINATION lib${LIB_SUFFIX} # .lib file
    RUNTIME DESTINATION bin              # .dll file
)

########################################################################
# Build and register unit test
########################################################################
if(CPPUNIT_FOUND)

    include(GrTest)

    include_directories(${CPPUNIT_INCLUDE_DIRS})

    link_directories(${CPPUNIT_LIBRARY_DIRS})

    list(APPEND test_testmodule_sources
        ${CMAKE_CURRENT_SOURCE_DIR}/test_testmodule.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/qa_testmodule.cc
    )

    add_executable(test-testmodule ${test_testmodule_sources})

    target_link_libraries(
        test-testmodule
        ${GNURADIO_RUNTIME_LIBRARIES}
        ${Boost_LIBRARIES}
        ${CPPUNIT_LIBRARIES}
        ${ETTUS_LIBRARIES}
        ${PC_ETTUS_LIBDIR}
        gnuradio-testmodule
    )

    GR_ADD_TEST(test_testmodule test-testmodule)

else(CPPUNIT_FOUND)
    message(WARNING "Disabling unit tests: No CppUnit found.")
endif(CPPUNIT_FOUND)
