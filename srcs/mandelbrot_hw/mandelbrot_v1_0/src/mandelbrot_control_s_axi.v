// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1ns/1ps
module mandelbrot_control_s_axi #(
  parameter integer C_ADDR_WIDTH = 12,
  parameter integer C_DATA_WIDTH = 32
)
(
  // AXI4-Lite slave signals
  input  wire                      aclk       ,
  input  wire                      areset     ,
  input  wire                      aclk_en    ,
  input  wire                      awvalid    ,
  output wire                      awready    ,
  input  wire [C_ADDR_WIDTH-1:0]   awaddr     ,
  input  wire                      wvalid     ,
  output wire                      wready     ,
  input  wire [C_DATA_WIDTH-1:0]   wdata      ,
  input  wire [C_DATA_WIDTH/8-1:0] wstrb      ,
  input  wire                      arvalid    ,
  output wire                      arready    ,
  input  wire [C_ADDR_WIDTH-1:0]   araddr     ,
  output wire                      rvalid     ,
  input  wire                      rready     ,
  output wire [C_DATA_WIDTH-1:0]   rdata      ,
  output wire [2-1:0]              rresp      ,
  output wire                      bvalid     ,
  input  wire                      bready     ,
  output wire [2-1:0]              bresp      ,
  output wire                      ap_start   ,
  input  wire                      ap_idle    ,
  input  wire                      ap_done    ,
  // User defined arguments
  output wire [32-1:0]             ctrl_length,
  output wire [64-1:0]             a          
);

//------------------------Address Info-------------------
// 0x000 : Control signals
//         bit 0  - ap_start (Read/Write/COH)
//         bit 1  - ap_done (Read/COR)
//         bit 2  - ap_idle (Read)
//         others - reserved
// 0x010 : Data signal of ctrl_length
//         bit 31~0 - ctrl_length[31:0] (Read/Write)
// 0x014 : reserved
// 0x018 : Data signal of a
//         bit 31~0 - a[31:0] (Read/Write)
// 0x01c : Data signal of a
//         bit 31~0 - a[63:32] (Read/Write)
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam [C_ADDR_WIDTH-1:0]       LP_ADDR_AP_CTRL                = 12'h000;
localparam [C_ADDR_WIDTH-1:0]       LP_ADDR_CTRL_LENGTH_0          = 12'h010;
localparam [C_ADDR_WIDTH-1:0]       LP_ADDR_a_0                    = 12'h018;
localparam [C_ADDR_WIDTH-1:0]       LP_ADDR_a_1                    = 12'h01c;
localparam integer                  LP_SM_WIDTH                    = 2;
localparam [LP_SM_WIDTH-1:0]        SM_WRIDLE                      = 2'd0;
localparam [LP_SM_WIDTH-1:0]        SM_WRDATA                      = 2'd1;
localparam [LP_SM_WIDTH-1:0]        SM_WRRESP                      = 2'd2;
localparam [LP_SM_WIDTH-1:0]        SM_RDIDLE                      = 2'd0;
localparam [LP_SM_WIDTH-1:0]        SM_RDDATA                      = 2'd1;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
reg  [LP_SM_WIDTH-1:0]              wstate                         = SM_WRIDLE;
reg  [LP_SM_WIDTH-1:0]              wnext                         ;
reg  [C_ADDR_WIDTH-1:0]             waddr                         ;
wire [C_DATA_WIDTH-1:0]             wmask                         ;
wire                                aw_hs                         ;
wire                                w_hs                          ;
reg  [LP_SM_WIDTH-1:0]              rstate                         = SM_RDIDLE;
reg  [LP_SM_WIDTH-1:0]              rnext                         ;
reg  [C_DATA_WIDTH-1:0]             rdata_r                       ;
wire                                ar_hs                         ;
wire [C_ADDR_WIDTH-1:0]             raddr                         ;
// internal registers
wire                                int_ap_idle                   ;
reg                                 int_ap_done                    = 1'b0;
reg                                 int_ap_start                   = 1'b0;

reg  [32-1:0]                       int_ctrl_length                = 32'd0;
reg  [64-1:0]                       int_a                          = 64'd0;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

//------------------------AXI write fsm------------------
assign awready = (~areset) & (wstate == SM_WRIDLE);
assign wready  = (wstate == SM_WRDATA);
assign bresp   = 2'b00;  // OKAY
assign bvalid  = (wstate == SM_WRRESP);
assign wmask   = { {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}} };
assign aw_hs   = awvalid & awready;
assign w_hs    = wvalid & wready;

// wstate
always @(posedge aclk) begin
  if (areset)
    wstate <= SM_WRIDLE;
  else if (aclk_en)
    wstate <= wnext;
end

// wnext
always @(*) begin
  case (wstate)
    SM_WRIDLE:
      if (awvalid)
        wnext = SM_WRDATA;
      else
        wnext = SM_WRIDLE;
    SM_WRDATA:
      if (wvalid)
        wnext = SM_WRRESP;
      else
        wnext = SM_WRDATA;
    SM_WRRESP:
      if (bready)
        wnext = SM_WRIDLE;
      else
        wnext = SM_WRRESP;
    default:
      wnext = SM_WRIDLE;
  endcase
end

// waddr
always @(posedge aclk) begin
  if (aclk_en) begin
    if (aw_hs)
      waddr <= awaddr;
  end
end

//------------------------AXI read fsm-------------------
assign arready = (~areset) && (rstate == SM_RDIDLE);
assign rdata   = rdata_r;
assign rresp   = 2'b00;  // OKAY
assign rvalid  = (rstate == SM_RDDATA);
assign ar_hs   = arvalid & arready;
assign raddr   = araddr;

// rstate
always @(posedge aclk) begin
  if (areset)
    rstate <= SM_RDIDLE;
  else if (aclk_en)
    rstate <= rnext;
end

// rnext
always @(*) begin
  case (rstate)
    SM_RDIDLE:
      if (arvalid)
        rnext = SM_RDDATA;
      else
        rnext = SM_RDIDLE;
    SM_RDDATA:
      if (rready & rvalid)
        rnext = SM_RDIDLE;
      else
        rnext = SM_RDDATA;
    default:
      rnext = SM_RDIDLE;
  endcase
end

// rdata_r
always @(posedge aclk) begin
  if (aclk_en) begin
    if (ar_hs) begin
      rdata_r <= 1'b0;
      case (raddr)
        LP_ADDR_AP_CTRL: begin
          rdata_r[0] <= int_ap_start;
          rdata_r[1] <= int_ap_done;
          rdata_r[2] <= int_ap_idle;
        end
        LP_ADDR_CTRL_LENGTH_0: begin
          rdata_r <= int_ctrl_length[0+:32];
        end
        LP_ADDR_a_0: begin
          rdata_r <= int_a[0+:32];
        end
        LP_ADDR_a_1: begin
          rdata_r <= int_a[32+:32];
        end

        default: begin
          rdata_r <= {C_DATA_WIDTH{1'b0}};
        end
      endcase
    end
  end
end

//------------------------Register logic-----------------
assign ap_start     = int_ap_start;
assign int_ap_idle  = ap_idle;
assign ctrl_length = int_ctrl_length;
assign a = int_a;

// int_ap_start
always @(posedge aclk) begin
  if (areset)
    int_ap_start <= 1'b0;
  else if (aclk_en) begin
    if (w_hs && waddr == LP_ADDR_AP_CTRL && wstrb[0] && wdata[0])
      int_ap_start <= 1'b1;
    else if (ap_done)
      int_ap_start <= 1'b0;
  end
end

// int_ap_done
always @(posedge aclk) begin
  if (areset)
    int_ap_done <= 1'b0;
  else if (aclk_en) begin
    if (ap_done)
      int_ap_done <= 1'b1;
    else if (ar_hs && raddr == LP_ADDR_AP_CTRL)
      int_ap_done <= 1'b0; // clear on read
  end
end

// int_ctrl_length[32-1:0]
always @(posedge aclk) begin
  if (areset)
    int_ctrl_length[0+:32] <= 32'd0;   else if (aclk_en) begin
    if (w_hs && waddr == LP_ADDR_CTRL_LENGTH_0)
      int_ctrl_length[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (int_ctrl_length[0+:32] & ~wmask[0+:32]);
  end
end

// int_a[32-1:0]
always @(posedge aclk) begin
  if (areset)
    int_a[0+:32] <= 32'd0;   else if (aclk_en) begin
    if (w_hs && waddr == LP_ADDR_a_0)
      int_a[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (int_a[0+:32] & ~wmask[0+:32]);
  end
end

// int_a[32-1:0]
always @(posedge aclk) begin
  if (areset)
    int_a[32+:32] <= 32'd0;
  else if (aclk_en) begin
    if (w_hs && waddr == LP_ADDR_a_1)
      int_a[32+:32] <= (wdata[0+:32] & wmask[0+:32]) | (int_a[32+:32] & ~wmask[0+:32]);
  end
end


endmodule

`default_nettype wire

