#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.1_AR76780 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Thu Dec 12 23:44:53 PST 2024
# SW Build 3247384 on Thu Jun 10 19:36:07 MDT 2021
#
# IP Build 3246043 on Fri Jun 11 00:30:35 MDT 2021
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim rfnoc_block_adaptive_filter_tb_behav -key {Behavioral:sim_1:Functional:rfnoc_block_adaptive_filter_tb} -tclbatch rfnoc_block_adaptive_filter_tb.tcl -log simulate.log"
xsim rfnoc_block_adaptive_filter_tb_behav -key {Behavioral:sim_1:Functional:rfnoc_block_adaptive_filter_tb} -tclbatch rfnoc_block_adaptive_filter_tb.tcl -log simulate.log

