//
// Copyright 2024 Ettus Research, a National Instruments Brand
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
// Module: rfnoc_block_adaptive_filter_tb
//
// Description: Testbench for the adaptive_filter RFNoC block.
//

`default_nettype none


module rfnoc_block_adaptive_filter_tb;

  `include "test_exec.svh"

  import PkgTestExec::*;
  import PkgChdrUtils::*;
  import PkgRfnocBlockCtrlBfm::*;
  import PkgRfnocItemUtils::*;
  import MatLabDatHandler::*;
  import rfnoc_helpers::*;

  //---------------------------------------------------------------------------
  // Testbench Configuration
  //---------------------------------------------------------------------------

  localparam [31:0] NOC_ID          = 32'h630D30DA;
  localparam [ 9:0] THIS_PORTID     = 10'h123;
  localparam int    CHDR_W          = 64;    // CHDR size in bits
  localparam int    MTU             = 10;    // Log2 of max transmission unit in CHDR words
  localparam int    NUM_PORTS       = 1;
  localparam int    NUM_PORTS_I     = 0+NUM_PORTS+NUM_PORTS;
  localparam int    NUM_PORTS_O     = 0+NUM_PORTS;
  localparam int    ITEM_W          = 32;    // Sample size in bits
  localparam int    SPP             = 64;    // Samples per packet
  localparam int    PKT_SIZE_BYTES  = SPP * (ITEM_W/8);
  localparam int    STALL_PROB      = 25;    // Default BFM stall probability
  localparam real   CHDR_CLK_PER    = 5.0;   // 200 MHz
  localparam real   CTRL_CLK_PER    = 8.0;   // 125 MHz
  localparam real   CE_CLK_PER      = 4.0;   // 250 MHz

  //---------------------------------------------------------------------------
  // Clocks and Resets
  //---------------------------------------------------------------------------

  bit rfnoc_chdr_clk;
  bit rfnoc_ctrl_clk;
  bit ce_clk;

  sim_clock_gen #(CHDR_CLK_PER) rfnoc_chdr_clk_gen (.clk(rfnoc_chdr_clk), .rst());
  sim_clock_gen #(CTRL_CLK_PER) rfnoc_ctrl_clk_gen (.clk(rfnoc_ctrl_clk), .rst());
  sim_clock_gen #(CE_CLK_PER) ce_clk_gen (.clk(ce_clk), .rst());

  //---------------------------------------------------------------------------
  // Bus Functional Models
  //---------------------------------------------------------------------------

  // Backend Interface
  RfnocBackendIf backend (rfnoc_chdr_clk, rfnoc_ctrl_clk);

  // AXIS-Ctrl Interface
  AxiStreamIf #(32) m_ctrl (rfnoc_ctrl_clk, 1'b0);
  AxiStreamIf #(32) s_ctrl (rfnoc_ctrl_clk, 1'b0);

  // AXIS-CHDR Interfaces
  AxiStreamIf #(CHDR_W) m_chdr [NUM_PORTS_I] (rfnoc_chdr_clk, 1'b0);
  AxiStreamIf #(CHDR_W) s_chdr [NUM_PORTS_O] (rfnoc_chdr_clk, 1'b0);

  // Block Controller BFM
  RfnocBlockCtrlBfm #(CHDR_W, ITEM_W) blk_ctrl = new(backend, m_ctrl, s_ctrl);

  // CHDR word and item/sample data types
  typedef ChdrData #(CHDR_W, ITEM_W)::chdr_word_t chdr_word_t;
  typedef ChdrData #(CHDR_W, ITEM_W)::item_t      item_t;

  // Connect block controller to BFMs
  for (genvar i = 0; i < NUM_PORTS_I; i++) begin : gen_bfm_input_connections
    initial begin
      blk_ctrl.connect_master_data_port(i, m_chdr[i], PKT_SIZE_BYTES);
      blk_ctrl.set_master_stall_prob(i, STALL_PROB);
    end
  end
  for (genvar i = 0; i < NUM_PORTS_O; i++) begin : gen_bfm_output_connections
    initial begin
      blk_ctrl.connect_slave_data_port(i, s_chdr[i]);
      blk_ctrl.set_slave_stall_prob(i, STALL_PROB);
    end
  end

  //---------------------------------------------------------------------------
  // Device Under Test (DUT)
  //---------------------------------------------------------------------------

  // DUT Slave (Input) Port Signals
  logic [CHDR_W*NUM_PORTS_I-1:0] s_rfnoc_chdr_tdata;
  logic [       NUM_PORTS_I-1:0] s_rfnoc_chdr_tlast;
  logic [       NUM_PORTS_I-1:0] s_rfnoc_chdr_tvalid;
  logic [       NUM_PORTS_I-1:0] s_rfnoc_chdr_tready;

  // DUT Master (Output) Port Signals
  logic [CHDR_W*NUM_PORTS_O-1:0] m_rfnoc_chdr_tdata;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tlast;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tvalid;
  logic [       NUM_PORTS_O-1:0] m_rfnoc_chdr_tready;

  // Map the array of BFMs to a flat vector for the DUT connections
  for (genvar i = 0; i < NUM_PORTS_I; i++) begin : gen_dut_input_connections
    // Connect BFM master to DUT slave port
    assign s_rfnoc_chdr_tdata[CHDR_W*i+:CHDR_W] = m_chdr[i].tdata;
    assign s_rfnoc_chdr_tlast[i]                = m_chdr[i].tlast;
    assign s_rfnoc_chdr_tvalid[i]               = m_chdr[i].tvalid;
    assign m_chdr[i].tready                     = s_rfnoc_chdr_tready[i];
  end
  for (genvar i = 0; i < NUM_PORTS_O; i++) begin : gen_dut_output_connections
    // Connect BFM slave to DUT master port
    assign s_chdr[i].tdata        = m_rfnoc_chdr_tdata[CHDR_W*i+:CHDR_W];
    assign s_chdr[i].tlast        = m_rfnoc_chdr_tlast[i];
    assign s_chdr[i].tvalid       = m_rfnoc_chdr_tvalid[i];
    assign m_rfnoc_chdr_tready[i] = s_chdr[i].tready;
  end

  rfnoc_block_adaptive_filter #(
    .THIS_PORTID         (THIS_PORTID),
    .CHDR_W              (CHDR_W),
    .MTU                 (MTU),
    .NUM_PORTS           (NUM_PORTS)
  ) dut (
    .rfnoc_chdr_clk      (rfnoc_chdr_clk),
    .rfnoc_ctrl_clk      (rfnoc_ctrl_clk),
    .ce_clk              (ce_clk),
    .rfnoc_core_config   (backend.cfg),
    .rfnoc_core_status   (backend.sts),
    .s_rfnoc_chdr_tdata  (s_rfnoc_chdr_tdata),
    .s_rfnoc_chdr_tlast  (s_rfnoc_chdr_tlast),
    .s_rfnoc_chdr_tvalid (s_rfnoc_chdr_tvalid),
    .s_rfnoc_chdr_tready (s_rfnoc_chdr_tready),
    .m_rfnoc_chdr_tdata  (m_rfnoc_chdr_tdata),
    .m_rfnoc_chdr_tlast  (m_rfnoc_chdr_tlast),
    .m_rfnoc_chdr_tvalid (m_rfnoc_chdr_tvalid),
    .m_rfnoc_chdr_tready (m_rfnoc_chdr_tready),
    .s_rfnoc_ctrl_tdata  (m_ctrl.tdata),
    .s_rfnoc_ctrl_tlast  (m_ctrl.tlast),
    .s_rfnoc_ctrl_tvalid (m_ctrl.tvalid),
    .s_rfnoc_ctrl_tready (m_ctrl.tready),
    .m_rfnoc_ctrl_tdata  (s_ctrl.tdata),
    .m_rfnoc_ctrl_tlast  (s_ctrl.tlast),
    .m_rfnoc_ctrl_tvalid (s_ctrl.tvalid),
    .m_rfnoc_ctrl_tready (s_ctrl.tready)
  );

  //---------------------------------------------------------------------------
  // Helper Functions
  //---------------------------------------------------------------------------
    typedef struct {
        item_t  samples[$];
        chdr_word_t mdata[$];
        packet_info_t pkt_info;
    } test_packet_t;

  task automatic matlab_test(
    string mainPath,
    string auxPath,
    string outputPath = "results.dat",
    string dataFolder = "~/rfdev/data/",
    reg[32:0] learning_rate = 32'h199a0000,
    int num_packets = 1,
    int prob = 0,
    IN_PORT_MAIN = 0,
    IN_PORT_AUX = 1,
    OUT_PORT_OUT = 0
  );
    mailbox #(test_packet_t) packets_mb_main = new();
    mailbox #(test_packet_t) packets_mb_aux = new();
    
    IQPair iqPairMain, iqPairAux, iqPairOut;
    int fdMain, fdAux, fdResults;
    string mainString, auxString, resultsString;
    mainString = {dataFolder, mainPath};
    auxString = {dataFolder, auxPath};
    resultsString = {dataFolder, outputPath};

    //Set BFM TREADY behavior
    blk_ctrl.set_master_stall_prob(IN_PORT_MAIN, prob);
    blk_ctrl.set_master_stall_prob(IN_PORT_AUX, prob);
    blk_ctrl.set_master_stall_prob(OUT_PORT_OUT, prob);
    //blk_ctrl.reg_write(learning_rate,16'h00);

    // open files for reading and writing
    fdMain = OpenFile(mainString, "r");
    fdAux = OpenFile(auxString, "r");
    fdResults = OpenFile(resultsString, "w");

    fork
      repeat (num_packets) begin : send_process
        test_packet_t packet_main, packet_aux;
        int packet_length = SPP;
        packet_main.samples = {};
        packet_aux.samples = {};

        for (int i=0; i < packet_length; i++) begin : load_iq_samps
          iqPairMain = ReadIQSamples(fdMain);
          iqPairAux = ReadIQSamples(fdAux);
          packet_main.samples.push_back({iqPairMain.I, iqPairMain.Q});
          packet_aux.samples.push_back({iqPairAux.I, iqPairAux.Q});
        end

        // Generate Random Metadata
        packet_main.mdata = {};
        packet_aux.mdata = {};
        for (int i = 0; i < $urandom_range(0,31); i++) begin
          packet_main.mdata.push_back(Rand #(CHDR_W)::rand_logic());
          packet_aux.mdata.push_back(Rand #(CHDR_W)::rand_logic());
        end

        // Generate random header info
        packet_main.pkt_info = Rand #($bits(packet_main.pkt_info))::rand_logic();
        packet_aux.pkt_info = Rand #($bits(packet_aux.pkt_info))::rand_logic();

        // enquee packet for each port
        blk_ctrl.send_items(IN_PORT_MAIN, packet_main.samples, packet_main.mdata, packet_main.pkt_info);
        blk_ctrl.send_items(IN_PORT_AUX, packet_aux.samples, packet_aux.mdata, packet_aux.pkt_info);
      
      end
      
      repeat (num_packets) begin : recv_process
        test_packet_t packet_out;

        blk_ctrl.recv_items_adv(OUT_PORT_OUT, packet_out.samples, packet_out.mdata, packet_out.pkt_info);
        for (int i = 0; i < SPP; i++) begin : recv_iq_samps
          iqPairOut.I = packet_out.samples[i][31:16];
          iqPairOut.Q = packet_out.samples[i][15:0];
          WriteIQSamples(fdResults, iqPairOut);
        end


      end
    join
    
    CloseFile(fdMain);
    CloseFile(fdAux);
    CloseFile(fdResults);


  endtask : matlab_test

  //---------------------------------------------------------------------------
  // Main Test Process
  //---------------------------------------------------------------------------

    string mainFile = "main_samples.dat";
    string auxFile =  "aux_samples.dat";
    string outputFile = "sim_results.dat";
    string folder = "/home/user/rfdev/mnt/data/input/noise_cancel/";
  initial begin : tb_main

    // Initialize the test exec object for this testbench
    test.start_tb("rfnoc_block_adaptive_filter_tb");

    // Start the BFMs running
    blk_ctrl.run();

    //--------------------------------
    // Reset
    //--------------------------------

    test.start_test("Flush block then reset it", 10us);
    blk_ctrl.flush_and_reset();
    test.end_test();

    //--------------------------------
    // Verify Block Info
    //--------------------------------

    test.start_test("Verify Block Info", 2us);
    `ASSERT_ERROR(blk_ctrl.get_noc_id() == NOC_ID, "Incorrect NOC_ID Value");
    `ASSERT_ERROR(blk_ctrl.get_num_data_i() == NUM_PORTS_I, "Incorrect NUM_DATA_I Value");
    `ASSERT_ERROR(blk_ctrl.get_num_data_o() == NUM_PORTS_O, "Incorrect NUM_DATA_O Value");
    `ASSERT_ERROR(blk_ctrl.get_mtu() == MTU, "Incorrect MTU Value");
    test.end_test();

    //--------------------------------
    // Test Sequences
    //--------------------------------
    // <Add your test code here>
    /*
    test.start_test("<Name your first test>", 1000us);
    matlab_test(mainFile, auxFile, outputFile, folder, 16'h00000009, 15);
    test.end_test();
    */

    test.start_test("<Name your first test>", 1000us);
    matlab_test(mainFile, auxFile, outputFile, folder, 32'h199a0000, 15);
    test.end_test();

    //--------------------------------
    // Finish Up
    //--------------------------------
    test.end_tb();
  end : tb_main

endmodule : rfnoc_block_adaptive_filter_tb


`default_nettype wire
