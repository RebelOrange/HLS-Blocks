#!/bin/bash -i
mkdir ~/rfdev/hls-builds/{module name}

cp run_hls.tcl ~/rfdev/hls-builds/{module name}
cp test.cpp ~/rfdev/hls-builds/{module name}
cp test.h ~/rfdev/hls-builds/{module name}
cp test_tb.cpp ~/rfdev/hls-builds/{module name}

cd ~/hls-builds/{module name}

vitis -f run_hls.tcl
cd -

mkdir verilog
rm -rf verilog/*
cp -r ~/rfdev/hls-builds/{module name}/{project name}/solution1/syn/verilog/* verilog/
