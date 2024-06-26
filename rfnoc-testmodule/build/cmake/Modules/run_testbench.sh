#!/usr/bin/bash

if [[ ! $# -eq 4 ]]; then
	echo "Usage: $0 uhd_fpga_dir test_device makefile_dir test_target"
	echo ""
	echo "Arguments:"
	echo "- uhd_fpga_dir: Path to fpga repository (without usrp3/top)"
	echo "- test_device: Device used for testing (e.g. x300, n3xx, e320)"
	echo "- makefile_dir: Path to the directory with the testbench Makefile"
	echo "- test_target: Test target (xsim, vsim)"
	exit 0
fi

uhd_fpga_dir=$1
uhd_fpga_dir_top=$uhd_fpga_dir/usrp3/top
test_device=$2
test_target=$4
makefile_dir=$3
# Clear $# and pos args so setupenv.sh doesn't freak out
shift
shift
shift
shift

# Need to convert device types to directory names
device_dir=$test_device
if [ $device_dir == "x310" ]; then
	device_dir=x300
fi
if [ $device_dir == "n300" ]; then
	device_dir=n3xx
fi
if [ $device_dir == "n310" ]; then
	device_dir=n3xx
fi
if [ $device_dir == "n320" ]; then
	device_dir=n3xx
fi
if [ $device_dir == "e310" ]; then
	device_dir=e31x
fi

# Now check the paths are valid
if [ ! -r $uhd_fpga_dir_top/Makefile.common ]; then
	echo "ERROR! '${uhd_fpga_dir_top}' is not a valid top-level FPGA directory."
	exit 1
fi
device_dir=$uhd_fpga_dir_top/$device_dir
if [ ! -r $device_dir/setupenv.sh ]; then
	echo "ERROR! '${test_device}' is not a valid USRP device."
	exit 1
fi
echo "Using device directory: $device_dir"
if [ ! -r $makefile_dir/Makefile ]; then
	echo "ERROR! '${makefile_dir}' does not point to an RFNoC block."
	exit 1
fi
# Check the Makefile actually contains a testbench target
if ! grep -q viv_simulator.mak $makefile_dir/Makefile; then
	echo "ERROR! '${makefile_dir}/Makefile' does not contain a test target!."
	exit 1
fi

# Load environment
echo "Loading environment from: '$device_dir/setupenv.sh'"
source $device_dir/setupenv.sh

# And, go
make -C $makefile_dir $test_target UHD_FPGA_DIR=$uhd_fpga_dir || exit 1
