//--------------------------------------------------------------------------------
// Company: 
// Engineer: 
// 
// Create Date:    10:59:48 07/08/2010 
// Design Name: 
// Module Name:    prbs_top - Behavioral 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//--------------------------------------------------------------------------------

module prbs_top(
   input       INJ_ERR,
   input       CLK,
   output      ERR_DETECT_8,
   output      ERR_DETECT_9
);

  //--------------------------------------------		
  // Set the PRBS parameters
  //--------------------------------------------		
   parameter POLY_LENGHT = 23;
   parameter POLY_TAP = 18;
   parameter INV_PATTERN = 1;

  //--------------------------------------------		
  // Internal variables
  //--------------------------------------------		
   wire [0:0] inj_error_vector = INJ_ERR;
   wire [0:0] prbs_out;
   wire [7:0] err_out_8;
   wire [8:0] err_out_9;

   reg [7:0] prbs_8bits =8'hFF;
   reg [8:0] prbs_9bits = 9'h1FF;
   reg [2:0] sp8_cnt = 3'b000;
   reg [3:0] sp9_cnt = 4'b0000;
   reg chk_en_8 = 1'b0;
   reg chk_en_9 = 1'b0;

//   assign inj_error_vector[0] = INJ_ERR;

  //--------------------------------------------		
  // Instantiate the PRBS generator
  //--------------------------------------------		
  PRBS_ANY #(
    .CHK_MODE(0),
    .INV_PATTERN(INV_PATTERN),
    .POLY_LENGHT(POLY_LENGHT),
    .POLY_TAP(POLY_TAP),
    .NBITS(1))
  I_PRBS_ANY_GEN(
    .RST(1'b 0),
    .CLK(CLK),
    .DATA_IN(inj_error_vector),
    .EN(1'b 1),
    .DATA_OUT(prbs_out));

  //--------------------------------------------		
  // Serial to parallel converters
  //--------------------------------------------		
  always @(posedge CLK) begin
    prbs_8bits <= {prbs_out,prbs_8bits[7:1]};
  end

  always @(posedge CLK) begin
    prbs_9bits <= {prbs_out,prbs_9bits[8:1]};
  end

  //--------------------------------------------		
  // Instantiate the checker with 8 bits input
  //--------------------------------------------
  PRBS_ANY #(
    .CHK_MODE(1),
    .INV_PATTERN(INV_PATTERN),
    .POLY_LENGHT(POLY_LENGHT),
    .POLY_TAP(POLY_TAP),
    .NBITS(8))
  I_PRBS_ANY_CHK8(
      .RST(1'b 0),
    .CLK(CLK),
    .DATA_IN(prbs_8bits),
    .EN(chk_en_8),
    .DATA_OUT(err_out_8));

  //--------------------------------------------		
  // Instantiate the checker with 9 bits input
  //--------------------------------------------
  PRBS_ANY #(
    .CHK_MODE(1),
    .INV_PATTERN(INV_PATTERN),
    .POLY_LENGHT(POLY_LENGHT),
    .POLY_TAP(POLY_TAP),
    .NBITS(9))
  I_PRBS_ANY_CHK9(
      .RST(1'b 0),
    .CLK(CLK),
    .DATA_IN(prbs_9bits),
    .EN(chk_en_9),
    .DATA_OUT(err_out_9));

  //--------------------------------------------		
  // Generate the enable for the 8 bit checker 
  //--------------------------------------------     
  always @(posedge CLK) begin
    sp8_cnt <= sp8_cnt + 1;
    if(sp8_cnt == 7) begin
      chk_en_8 <= 1'b 1;
    end
    else begin
      chk_en_8 <= 1'b 0;
    end
  end

  //--------------------------------------------		
  // Generate the enable for the 9 bit checker 
  //--------------------------------------------     
  always @(posedge CLK) begin
    sp9_cnt <= sp9_cnt + 1;
    if(sp9_cnt == 8) begin
      chk_en_9 <= 1'b 1;
      sp9_cnt <= {4{1'b0}};
    end
    else begin
      chk_en_9 <= 1'b 0;
    end
  end

  //--------------------------------------------		
  // Error detect from the 8 bit checker 
  //--------------------------------------------     
 assign ERR_DETECT_8 = | err_out_8;
 assign ERR_DETECT_9 = | err_out_9;

endmodule
