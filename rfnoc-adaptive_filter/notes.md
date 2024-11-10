# Initial Setup
## Generating a Block

1. run `rfnocmodtool newmod` in bash, name module the "topic" of the fpga image (ex: adaptive filter)
2. In the new module directory, run `rfnocmodtool add` and add any individual blocks

## Changing to Simple IQ Interface

1. Change directory to `rfnoc/blocks/` and open the desired yaml file in a text editor.
2. Change the following sections:
 "fpga_iface" from "axis_pyld_ctxt" to "axis_data"
 "context_fifo_depth" to "info_fifo_depth

 ### Run create verilog
 ```sh
python3 $RFDEVPREFIX/uhd/host/utils/rfnoc_blocktool/rfnoc_create_verilog.py -c $RFDEVPREFIX/blocks/rfnoc-adaptive_filter/rfnoc/blocks/lms.yml -d $RFDEVPREFIX/blocks/rfnoc-adaptive_filter/rfnoc/fpga/rfnoc_block_lms/

 ```
