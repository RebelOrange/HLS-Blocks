//
// Copyright 2024 Ettus Research, a National Instruments Brand
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
// Module: rfnoc_block_adaptive_filter
//
// Description:
//
//   <Add block description here>
//
// Parameters:
//
//   THIS_PORTID : Control crossbar port to which this block is connected
//   CHDR_W      : AXIS-CHDR data bus width
//   MTU         : Maximum transmission unit (i.e., maximum packet size in
//                 CHDR words is 2**MTU).
//

`default_nettype none


module rfnoc_block_adaptive_filter #(
  parameter [9:0] THIS_PORTID     = 10'd0,
  parameter       CHDR_W          = 64,
  parameter [5:0] MTU             = 10,
  parameter       NUM_PORTS       = 1,
  parameter       FILTER_TYPE     = "NLMS"
)(
  // RFNoC Framework Clocks and Resets
  input  wire                   rfnoc_chdr_clk,
  input  wire                   rfnoc_ctrl_clk,
  input  wire                   ce_clk,
  // RFNoC Backend Interface
  input  wire [511:0]           rfnoc_core_config,
  output wire [511:0]           rfnoc_core_status,
  // AXIS-CHDR Input Ports (from framework)
  input  wire [(0+NUM_PORTS+NUM_PORTS)*CHDR_W-1:0] s_rfnoc_chdr_tdata,
  input  wire [(0+NUM_PORTS+NUM_PORTS)-1:0]        s_rfnoc_chdr_tlast,
  input  wire [(0+NUM_PORTS+NUM_PORTS)-1:0]        s_rfnoc_chdr_tvalid,
  output wire [(0+NUM_PORTS+NUM_PORTS)-1:0]        s_rfnoc_chdr_tready,
  // AXIS-CHDR Output Ports (to framework)
  output wire [(0+NUM_PORTS)*CHDR_W-1:0] m_rfnoc_chdr_tdata,
  output wire [(0+NUM_PORTS)-1:0]        m_rfnoc_chdr_tlast,
  output wire [(0+NUM_PORTS)-1:0]        m_rfnoc_chdr_tvalid,
  input  wire [(0+NUM_PORTS)-1:0]        m_rfnoc_chdr_tready,
  // AXIS-Ctrl Input Port (from framework)
  input  wire [31:0]            s_rfnoc_ctrl_tdata,
  input  wire                   s_rfnoc_ctrl_tlast,
  input  wire                   s_rfnoc_ctrl_tvalid,
  output wire                   s_rfnoc_ctrl_tready,
  // AXIS-Ctrl Output Port (to framework)
  output wire [31:0]            m_rfnoc_ctrl_tdata,
  output wire                   m_rfnoc_ctrl_tlast,
  output wire                   m_rfnoc_ctrl_tvalid,
  input  wire                   m_rfnoc_ctrl_tready
);

  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------

  // Clocks and Resets
  wire               ctrlport_clk;
  wire               ctrlport_rst;
  wire               axis_data_clk;
  wire               axis_data_rst;
  // CtrlPort Master
  wire               m_ctrlport_req_wr;
  wire               m_ctrlport_req_rd;
  wire [19:0]        m_ctrlport_req_addr;
  wire [31:0]        m_ctrlport_req_data;
  reg               m_ctrlport_resp_ack;
  reg [31:0]        m_ctrlport_resp_data;
  // Data Stream to User Logic: main
  wire [NUM_PORTS*32*1-1:0]   m_main_axis_tdata;
  wire [NUM_PORTS*1-1:0]      m_main_axis_tkeep;
  wire [NUM_PORTS-1:0]        m_main_axis_tlast;
  wire [NUM_PORTS-1:0]        m_main_axis_tvalid;
  wire [NUM_PORTS-1:0]        m_main_axis_tready;
  wire [NUM_PORTS*64-1:0]     m_main_axis_ttimestamp;
  wire [NUM_PORTS-1:0]        m_main_axis_thas_time;
  wire [NUM_PORTS*16-1:0]     m_main_axis_tlength;
  wire [NUM_PORTS-1:0]        m_main_axis_teov;
  wire [NUM_PORTS-1:0]        m_main_axis_teob;
  // Data Stream to User Logic: aux
  wire [NUM_PORTS*32*1-1:0]   m_aux_axis_tdata;
  wire [NUM_PORTS*1-1:0]      m_aux_axis_tkeep;
  wire [NUM_PORTS-1:0]        m_aux_axis_tlast;
  wire [NUM_PORTS-1:0]        m_aux_axis_tvalid;
  wire [NUM_PORTS-1:0]        m_aux_axis_tready;
  wire [NUM_PORTS*64-1:0]     m_aux_axis_ttimestamp;
  wire [NUM_PORTS-1:0]        m_aux_axis_thas_time;
  wire [NUM_PORTS*16-1:0]     m_aux_axis_tlength;
  wire [NUM_PORTS-1:0]        m_aux_axis_teov;
  wire [NUM_PORTS-1:0]        m_aux_axis_teob;
  // Data Stream from User Logic: out
  wire [NUM_PORTS*32*1-1:0]   s_out_axis_tdata;
  wire [NUM_PORTS*1-1:0]      s_out_axis_tkeep;
  wire [NUM_PORTS-1:0]        s_out_axis_tlast;
  wire [NUM_PORTS-1:0]        s_out_axis_tvalid;
  wire [NUM_PORTS-1:0]        s_out_axis_tready;
  wire [NUM_PORTS*64-1:0]     s_out_axis_ttimestamp;
  wire [NUM_PORTS-1:0]        s_out_axis_thas_time;
  wire [NUM_PORTS*16-1:0]     s_out_axis_tlength;
  wire [NUM_PORTS-1:0]        s_out_axis_teov;
  wire [NUM_PORTS-1:0]        s_out_axis_teob;

  //---------------------------------------------------------------------------
  // NoC Shell
  //---------------------------------------------------------------------------

  noc_shell_adaptive_filter #(
    .CHDR_W              (CHDR_W),
    .THIS_PORTID         (THIS_PORTID),
    .MTU                 (MTU),
    .NUM_PORTS           (NUM_PORTS)
  ) noc_shell_adaptive_filter_i (
    //---------------------
    // Framework Interface
    //---------------------

    // Clock Inputs
    .rfnoc_chdr_clk      (rfnoc_chdr_clk),
    .rfnoc_ctrl_clk      (rfnoc_ctrl_clk),
    .ce_clk              (ce_clk),
    // Reset Outputs
    .rfnoc_chdr_rst      (),
    .rfnoc_ctrl_rst      (),
    .ce_rst              (),
    // RFNoC Backend Interface
    .rfnoc_core_config   (rfnoc_core_config),
    .rfnoc_core_status   (rfnoc_core_status),
    // CHDR Input Ports  (from framework)
    .s_rfnoc_chdr_tdata  (s_rfnoc_chdr_tdata),
    .s_rfnoc_chdr_tlast  (s_rfnoc_chdr_tlast),
    .s_rfnoc_chdr_tvalid (s_rfnoc_chdr_tvalid),
    .s_rfnoc_chdr_tready (s_rfnoc_chdr_tready),
    // CHDR Output Ports (to framework)
    .m_rfnoc_chdr_tdata  (m_rfnoc_chdr_tdata),
    .m_rfnoc_chdr_tlast  (m_rfnoc_chdr_tlast),
    .m_rfnoc_chdr_tvalid (m_rfnoc_chdr_tvalid),
    .m_rfnoc_chdr_tready (m_rfnoc_chdr_tready),
    // AXIS-Ctrl Input Port (from framework)
    .s_rfnoc_ctrl_tdata  (s_rfnoc_ctrl_tdata),
    .s_rfnoc_ctrl_tlast  (s_rfnoc_ctrl_tlast),
    .s_rfnoc_ctrl_tvalid (s_rfnoc_ctrl_tvalid),
    .s_rfnoc_ctrl_tready (s_rfnoc_ctrl_tready),
    // AXIS-Ctrl Output Port (to framework)
    .m_rfnoc_ctrl_tdata  (m_rfnoc_ctrl_tdata),
    .m_rfnoc_ctrl_tlast  (m_rfnoc_ctrl_tlast),
    .m_rfnoc_ctrl_tvalid (m_rfnoc_ctrl_tvalid),
    .m_rfnoc_ctrl_tready (m_rfnoc_ctrl_tready),

    //---------------------
    // Client Interface
    //---------------------

    // CtrlPort Clock and Reset
    .ctrlport_clk              (ctrlport_clk),
    .ctrlport_rst              (ctrlport_rst),
    // CtrlPort Master
    .m_ctrlport_req_wr         (m_ctrlport_req_wr),
    .m_ctrlport_req_rd         (m_ctrlport_req_rd),
    .m_ctrlport_req_addr       (m_ctrlport_req_addr),
    .m_ctrlport_req_data       (m_ctrlport_req_data),
    .m_ctrlport_resp_ack       (m_ctrlport_resp_ack),
    .m_ctrlport_resp_data      (m_ctrlport_resp_data),

    // AXI-Stream Clock and Reset
    .axis_data_clk (axis_data_clk),
    .axis_data_rst (axis_data_rst),
    // Data Stream to User Logic: main
    .m_main_axis_tdata      (m_main_axis_tdata),
    .m_main_axis_tkeep      (m_main_axis_tkeep),
    .m_main_axis_tlast      (m_main_axis_tlast),
    .m_main_axis_tvalid     (m_main_axis_tvalid),
    .m_main_axis_tready     (m_main_axis_tready),
    .m_main_axis_ttimestamp (m_main_axis_ttimestamp),
    .m_main_axis_thas_time  (m_main_axis_thas_time),
    .m_main_axis_tlength    (m_main_axis_tlength),
    .m_main_axis_teov       (m_main_axis_teov),
    .m_main_axis_teob       (m_main_axis_teob),
    // Data Stream to User Logic: aux
    .m_aux_axis_tdata      (m_aux_axis_tdata),
    .m_aux_axis_tkeep      (m_aux_axis_tkeep),
    .m_aux_axis_tlast      (m_aux_axis_tlast),
    .m_aux_axis_tvalid     (m_aux_axis_tvalid),
    .m_aux_axis_tready     (m_aux_axis_tready),
    .m_aux_axis_ttimestamp (m_aux_axis_ttimestamp),
    .m_aux_axis_thas_time  (m_aux_axis_thas_time),
    .m_aux_axis_tlength    (m_aux_axis_tlength),
    .m_aux_axis_teov       (m_aux_axis_teov),
    .m_aux_axis_teob       (m_aux_axis_teob),
    // Data Stream from User Logic: out
    .s_out_axis_tdata      (s_out_axis_tdata),
    .s_out_axis_tkeep      (s_out_axis_tkeep),
    .s_out_axis_tlast      (s_out_axis_tlast),
    .s_out_axis_tvalid     (s_out_axis_tvalid),
    .s_out_axis_tready     (s_out_axis_tready),
    .s_out_axis_ttimestamp (s_out_axis_ttimestamp),
    .s_out_axis_thas_time  (s_out_axis_thas_time),
    .s_out_axis_tlength    (s_out_axis_tlength),
    .s_out_axis_teov       (s_out_axis_teov),
    .s_out_axis_teob       (s_out_axis_teob)
  );

  //---------------------------------------------------------------------------
  // User Register
  // --------------------------------------------------------------------------
  localparam REG_MU_ADDR    = 16'h00; // Address for example user register
  localparam REG_MU_DEFAULT = 32'h199a0000; //default value 0.1

  reg [31:0] reg_mu = REG_MU_DEFAULT;

  always @(posedge ctrlport_clk) begin
    if (ctrlport_rst) begin
      reg_mu = REG_MU_DEFAULT;
    end else begin
      // Default assignment
      m_ctrlport_resp_ack <= 0;

      // Read user register
      if (m_ctrlport_req_rd) begin // Read request
        case (m_ctrlport_req_addr)
          REG_MU_ADDR: begin
            m_ctrlport_resp_ack  <= 1;
            m_ctrlport_resp_data <= reg_mu;
          end
        endcase
      end

      // Write user register
      if (m_ctrlport_req_wr) begin // Write requst
        case (m_ctrlport_req_addr)
          REG_MU_ADDR: begin
            m_ctrlport_resp_ack <= 1;
            reg_mu            <= m_ctrlport_req_data[31:0];
          end
        endcase
      end
    end
  end


  //---------------------------------------------------------------------------
  // User Logic
  //---------------------------------------------------------------------------

  // sideband handling
  assign s_out_axis_teob = m_main_axis_teob;
  assign s_out_axis_teov = m_main_axis_teov;
  assign s_out_axis_ttimestamp = m_main_axis_ttimestamp;
  assign s_out_axis_thas_time = 0;
  assign s_out_axis_tlength = m_main_axis_tlength;
  
  generate 
    if(FILTER_TYPE=="LMS") begin
      lms_module inst_lms_module(
        .ap_clk      (axis_data_clk),
        .ap_rst_n    (~axis_data_rst),

        .main_in_TDATA  (m_main_axis_tdata),
        .main_in_TVALID (m_main_axis_tvalid),
        .main_in_TREADY (m_main_axis_tready),
        .main_in_TKEEP  (),
        .main_in_TSTRB  (),
        .main_in_TLAST  (m_main_axis_tlast),


        .aux_in_TDATA  (m_aux_axis_tdata),
        .aux_in_TVALID (m_aux_axis_tvalid),
        .aux_in_TREADY (m_aux_axis_tready),
        .aux_in_TKEEP  (),
        .aux_in_TSTRB  (),
        .aux_in_TLAST  (m_aux_axis_tlast),
        

        .output_r_TDATA  (s_out_axis_tdata),
        .output_r_TVALID (s_out_axis_tvalid),
        .output_r_TREADY (s_out_axis_tready),
        .output_r_TKEEP  (),
        .output_r_TSTRB  (),
        .output_r_TLAST  (s_out_axis_tlast),

        .mu           (reg_mu)

      );
    end else if(FILTER_TYPE=="NLMS") begin
      nlms_module inst_nlms_module(
        .ap_clk      (axis_data_clk),
        .ap_rst_n    (~axis_data_rst),

        .main_in_TDATA  (m_main_axis_tdata),
        .main_in_TVALID (m_main_axis_tvalid),
        .main_in_TREADY (m_main_axis_tready),
        .main_in_TKEEP  (),
        .main_in_TSTRB  (),
        .main_in_TLAST  (m_main_axis_tlast),


        .aux_in_TDATA  (m_aux_axis_tdata),
        .aux_in_TVALID (m_aux_axis_tvalid),
        .aux_in_TREADY (m_aux_axis_tready),
        .aux_in_TKEEP  (),
        .aux_in_TSTRB  (),
        .aux_in_TLAST  (m_aux_axis_tlast),
        

        .output_r_TDATA  (s_out_axis_tdata),
        .output_r_TVALID (s_out_axis_tvalid),
        .output_r_TREADY (s_out_axis_tready),
        .output_r_TKEEP  (),
        .output_r_TSTRB  (),
        .output_r_TLAST  (s_out_axis_tlast),

        .mu           (reg_mu)

      );
    end else if (FILTER_TYPE=="FIR") begin

    end
  endgenerate




endmodule // rfnoc_block_adaptive_filter


`default_nettype wire
