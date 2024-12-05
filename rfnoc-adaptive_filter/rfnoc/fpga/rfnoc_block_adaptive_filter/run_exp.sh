#! /bin/bash
# learning rate 
l_rates=("32'h4ccccccd" "32'h07ae147b" "32'h00c49ba6")
experiments=("1" "2" "3" "4")
for l_rate in "${l_rates[@]}"; do
    for exp in "${experiments[@]}"; do
        sed -i "174 c\ localparam nlms_mu = $l_rate;" rfnoc_block_adaptive_filter_tb.sv 
        sed -i "163 c\ localparam folder = \"/home/user/rfdev/mnt/data/experiments/records/SNR/exp$exp/\";" rfnoc_block_adaptive_filter_tb.sv
        make xsim
    done
done

l_rates=("32'h4ccccccd" "32'h07ae147b" "32'h00c49ba6")
experiments=("1" "2" "3" "4" "5" "6")
for l_rate in "${l_rates[@]}"; do
    for exp in "${experiments[@]}"; do
        sed -i "174 c\ localparam nlms_mu = $l_rate;" rfnoc_block_adaptive_filter_tb.sv 
        sed -i "163 c\ localparam folder = \"/home/user/rfdev/mnt/data/experiments/records/BW/exp$exp/\";" rfnoc_block_adaptive_filter_tb.sv
        make xsim
    done
done

l_rates=("32'h4ccccccd" "32'h07ae147b" "32'h00c49ba6")
experiments=("1" "2" "3" "4")
for l_rate in "${l_rates[@]}"; do
    for exp in "${experiments[@]}"; do
        sed -i "174 c\ localparam nlms_mu = $l_rate;" rfnoc_block_adaptive_filter_tb.sv 
        sed -i "163 c\ localparam folder = \"/home/user/rfdev/mnt/data/experiments/records/path_length/exp$exp/\";" rfnoc_block_adaptive_filter_tb.sv
        make xsim
    done
done
