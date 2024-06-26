//
// Copyright 2024 <+YOU OR YOUR COMPANY+>.
// 
// This is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
// 
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 51 Franklin Street,
// Boston, MA 02110-1301, USA.
//

//
// Module: rfnoc_block_testblock
//
// Description:
//
//   This is a skeleton file for a RFNoC block. It passes incoming samples
//   to the output without any modification. A read/write user register is
//   instantiated, but left unused.
//
// Parameters:
//
//   THIS_PORTID : Control crossbar port to which this block is connected
//   CHDR_W      : AXIS-CHDR data bus width
//   MTU         : Maximum transmission unit (i.e., maximum packet size in
//                 CHDR words is 2**MTU).
//

`default_nettype none


module rfnoc_block_testblock #(
  parameter [9:0] THIS_PORTID     = 10'd0,
  parameter       CHDR_W          = 64,
  parameter [5:0] MTU             = 10,
  parameter       NUM_PORTS       = 1
)(
  // RFNoC Framework Clocks and Resets
  input  wire                   rfnoc_chdr_clk,
  input  wire                   rfnoc_ctrl_clk,
  input  wire                   ce_clk,
  // RFNoC Backend Interface
  input  wire [511:0]           rfnoc_core_config,
  output wire [511:0]           rfnoc_core_status,
  // AXIS-CHDR Input Ports (from framework)
  input  wire [(0+NUM_PORTS)*CHDR_W-1:0] s_rfnoc_chdr_tdata,
  input  wire [(0+NUM_PORTS)-1:0]        s_rfnoc_chdr_tlast,
  input  wire [(0+NUM_PORTS)-1:0]        s_rfnoc_chdr_tvalid,
  output wire [(0+NUM_PORTS)-1:0]        s_rfnoc_chdr_tready,
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
  reg                m_ctrlport_resp_ack;
  reg  [31:0]        m_ctrlport_resp_data;
  // Payload Stream to User Logic: in
  wire [NUM_PORTS*32*1-1:0]   m_in_payload_tdata;
  wire [NUM_PORTS*1-1:0]      m_in_payload_tkeep;
  wire [NUM_PORTS-1:0]        m_in_payload_tlast;
  wire [NUM_PORTS-1:0]        m_in_payload_tvalid;
  wire [NUM_PORTS-1:0]        m_in_payload_tready;
  // Context Stream to User Logic: in
  wire [NUM_PORTS*CHDR_W-1:0] m_in_context_tdata;
  wire [NUM_PORTS*4-1:0]      m_in_context_tuser;
  wire [NUM_PORTS-1:0]        m_in_context_tlast;
  wire [NUM_PORTS-1:0]        m_in_context_tvalid;
  wire [NUM_PORTS-1:0]        m_in_context_tready;
  // Payload Stream to User Logic: out
  wire [NUM_PORTS*32*1-1:0]   s_out_payload_tdata;
  wire [NUM_PORTS*1-1:0]      s_out_payload_tkeep;
  wire [NUM_PORTS-1:0]        s_out_payload_tlast;
  wire [NUM_PORTS-1:0]        s_out_payload_tvalid;
  wire [NUM_PORTS-1:0]        s_out_payload_tready;
  // Context Stream to User Logic: out
  wire [NUM_PORTS*CHDR_W-1:0] s_out_context_tdata;
  wire [NUM_PORTS*4-1:0]      s_out_context_tuser;
  wire [NUM_PORTS-1:0]        s_out_context_tlast;
  wire [NUM_PORTS-1:0]        s_out_context_tvalid;
  wire [NUM_PORTS-1:0]        s_out_context_tready;

  //---------------------------------------------------------------------------
  // NoC Shell
  //---------------------------------------------------------------------------

  noc_shell_testblock #(
    .CHDR_W      (CHDR_W),
    .THIS_PORTID (THIS_PORTID),
    .MTU         (MTU),
    .NUM_PORTS   (NUM_PORTS)
  ) noc_shell_testblock_i (
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
    .ctrlport_clk         (ctrlport_clk),
    .ctrlport_rst         (ctrlport_rst),
    // CtrlPort Master
    .m_ctrlport_req_wr    (m_ctrlport_req_wr),
    .m_ctrlport_req_rd    (m_ctrlport_req_rd),
    .m_ctrlport_req_addr  (m_ctrlport_req_addr),
    .m_ctrlport_req_data  (m_ctrlport_req_data),
    .m_ctrlport_resp_ack  (m_ctrlport_resp_ack),
    .m_ctrlport_resp_data (m_ctrlport_resp_data),

    // AXI-Stream Payload Context Clock and Reset
    .axis_data_clk        (axis_data_clk),
    .axis_data_rst        (axis_data_rst),
    // Payload Stream to User Logic: in
    .m_in_payload_tdata   (m_in_payload_tdata),
    .m_in_payload_tkeep   (m_in_payload_tkeep),
    .m_in_payload_tlast   (m_in_payload_tlast),
    .m_in_payload_tvalid  (m_in_payload_tvalid),
    .m_in_payload_tready  (m_in_payload_tready),
    // Context Stream to User Logic: in
    .m_in_context_tdata   (m_in_context_tdata),
    .m_in_context_tuser   (m_in_context_tuser),
    .m_in_context_tlast   (m_in_context_tlast),
    .m_in_context_tvalid  (m_in_context_tvalid),
    .m_in_context_tready  (m_in_context_tready),
    // Payload Stream from User Logic: out
    .s_out_payload_tdata  (s_out_payload_tdata),
    .s_out_payload_tkeep  (s_out_payload_tkeep),
    .s_out_payload_tlast  (s_out_payload_tlast),
    .s_out_payload_tvalid (s_out_payload_tvalid),
    .s_out_payload_tready (s_out_payload_tready),
    // Context Stream from User Logic: out
    .s_out_context_tdata  (s_out_context_tdata),
    .s_out_context_tuser  (s_out_context_tuser),
    .s_out_context_tlast  (s_out_context_tlast),
    .s_out_context_tvalid (s_out_context_tvalid),
    .s_out_context_tready (s_out_context_tready)
  );

  //---------------------------------------------------------------------------
  // User Registers
  //---------------------------------------------------------------------------
  //
  // There's only one register now, but we'll structure the register code to
  // make it easier to add more registers later.
  // Register use the ctrlport_clk clock.
  //
  //---------------------------------------------------------------------------

  // Note: Register addresses increment by 4
  localparam REG_USER_ADDR    = 0; // Address for example user register
  localparam REG_USER_DEFAULT = 0; // Default value for user register

  reg [31:0] reg_user = REG_USER_DEFAULT;

  always @(posedge ctrlport_clk) begin
    if (ctrlport_rst) begin
      reg_user = REG_USER_DEFAULT;
    end else begin
      // Default assignment
      m_ctrlport_resp_ack <= 0;

      // Read user register
      if (m_ctrlport_req_rd) begin // Read request
        case (m_ctrlport_req_addr)
          REG_USER_ADDR: begin
            m_ctrlport_resp_ack  <= 1;
            m_ctrlport_resp_data <= reg_user;
          end
        endcase
      end

      // Write user register
      if (m_ctrlport_req_wr) begin // Write requst
        case (m_ctrlport_req_addr)
          REG_USER_ADDR: begin
            m_ctrlport_resp_ack <= 1;
            reg_user            <= m_ctrlport_req_data[31:0];
          end
        endcase
      end
    end
  end

  //---------------------------------------------------------------------------
  // User Logic
  //---------------------------------------------------------------------------
  //
  // User logic uses the axis_data_clk clock. While the registers above use the
  // ctrlport_clk clock, in the block YAML configuration file both the control
  // and data interfaces are specified to use the rfnoc_chdr clock. Therefore,
  // we do not need to cross clock domains when using user registers with
  // user logic.
  //
  //---------------------------------------------------------------------------

  // Sample data, pass through unchanged
  assign s_out_payload_tdata  = m_in_payload_tdata;
  assign s_out_payload_tlast  = m_in_payload_tlast;
  assign s_out_payload_tvalid = m_in_payload_tvalid;
  assign m_in_payload_tready  = s_out_payload_tready;

  // Context data, we are not doing anything with the context
  // (the CHDR header info) so we can simply pass through unchanged
  assign s_out_context_tdata  = m_in_context_tdata;
  assign s_out_context_tuser  = m_in_context_tuser;
  assign s_out_context_tlast  = m_in_context_tlast;
  assign s_out_context_tvalid = m_in_context_tvalid;
  assign m_in_context_tready  = s_out_context_tready;

  // Only 1-sample per clock, so tkeep should always be asserted
  assign s_out_payload_tkeep = {NUM_PORTS{1'b1}};

endmodule // rfnoc_block_testblock

`default_nettype wire

