# Adding MatLabDatHandler.sv
'''verilog
    import MatLabDatHander::*
'''

MatLabDatHandler is added to the project by 'install-matlab-rfnoc.sh':
'''sh
#!/bin/bash -i
MATLABDIR=~/rfdev/matlab-rfnoc/

echo '#
//# added by matlab-rfnoc, see github.com/rebelorange/matlab-rfnoc.git
//#
MATLAB_RFNOC_SRCS_V := $(shell find '$MATLABDIR' -name "*.v*")
SIM_DESIGN_SRCS +=$(MATLAB_RFNOC_SRCS_V)
//# endadd' >> $UHD_FPGA_DIR/usrp3/lib/sim/Makefile.srcs

# Opening File Descriptors