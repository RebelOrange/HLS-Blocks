# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.22

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/user/rfdev/hls-blocks/rfnoc-testmodule

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/user/rfdev/hls-blocks/rfnoc-testmodule/build

# Utility rule file for testmodule_swig_swig_doc.

# Include any custom commands dependencies for this target.
include swig/CMakeFiles/testmodule_swig_swig_doc.dir/compiler_depend.make

# Include the progress variables for this target.
include swig/CMakeFiles/testmodule_swig_swig_doc.dir/progress.make

swig/CMakeFiles/testmodule_swig_swig_doc: swig/testmodule_swig_doc.i

swig/testmodule_swig_doc.i: swig/testmodule_swig_doc_swig_docs/xml/index.xml
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/user/rfdev/hls-blocks/rfnoc-testmodule/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating python docstrings for testmodule_swig_doc"
	cd /home/user/rfdev/hls-blocks/rfnoc-testmodule/docs/doxygen && /usr/bin/python3 -B /home/user/rfdev/hls-blocks/rfnoc-testmodule/docs/doxygen/swig_doc.py /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig/testmodule_swig_doc_swig_docs/xml /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig/testmodule_swig_doc.i

swig/testmodule_swig_doc_swig_docs/xml/index.xml: swig/_testmodule_swig_doc_tag
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/user/rfdev/hls-blocks/rfnoc-testmodule/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating doxygen xml for testmodule_swig_doc docs"
	cd /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig && ./_testmodule_swig_doc_tag
	cd /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig && /usr/bin/doxygen /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig/testmodule_swig_doc_swig_docs/Doxyfile

testmodule_swig_swig_doc: swig/CMakeFiles/testmodule_swig_swig_doc
testmodule_swig_swig_doc: swig/testmodule_swig_doc.i
testmodule_swig_swig_doc: swig/testmodule_swig_doc_swig_docs/xml/index.xml
testmodule_swig_swig_doc: swig/CMakeFiles/testmodule_swig_swig_doc.dir/build.make
.PHONY : testmodule_swig_swig_doc

# Rule to build all files generated by this target.
swig/CMakeFiles/testmodule_swig_swig_doc.dir/build: testmodule_swig_swig_doc
.PHONY : swig/CMakeFiles/testmodule_swig_swig_doc.dir/build

swig/CMakeFiles/testmodule_swig_swig_doc.dir/clean:
	cd /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig && $(CMAKE_COMMAND) -P CMakeFiles/testmodule_swig_swig_doc.dir/cmake_clean.cmake
.PHONY : swig/CMakeFiles/testmodule_swig_swig_doc.dir/clean

swig/CMakeFiles/testmodule_swig_swig_doc.dir/depend:
	cd /home/user/rfdev/hls-blocks/rfnoc-testmodule/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/user/rfdev/hls-blocks/rfnoc-testmodule /home/user/rfdev/hls-blocks/rfnoc-testmodule/swig /home/user/rfdev/hls-blocks/rfnoc-testmodule/build /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig /home/user/rfdev/hls-blocks/rfnoc-testmodule/build/swig/CMakeFiles/testmodule_swig_swig_doc.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : swig/CMakeFiles/testmodule_swig_swig_doc.dir/depend

