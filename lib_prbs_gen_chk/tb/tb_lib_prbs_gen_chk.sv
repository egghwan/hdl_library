`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:30:50 09/03/2010
// Design Name:   prbs_top
// Module Name:   C:/designs/app_notes/prbs_xapp_verilog/prbs_top_tb.v
// Project Name:  prbs_xapp_verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: prbs_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module prbs_top_tb;

parameter CLK_PERIOD = 10;

	// Inputs
	reg INJ_ERR;
	reg CLK;

	// Outputs
	wire ERR_DETECT_8;
	wire ERR_DETECT_9;

// ========================================================================== //
//	Instantiate the Unit Under Test (UUT)                                      //
// ========================================================================== //
	prbs_top uut (
		.INJ_ERR(INJ_ERR), 
		.CLK(CLK), 
		.ERR_DETECT_8(ERR_DETECT_8), 
		.ERR_DETECT_9(ERR_DETECT_9)
	);
   
// ========================================================================== //
// Clock Generation                                                          //
// ========================================================================== //
   initial
      CLK = 1'b0;
   always
      #(CLK_PERIOD/2) CLK = ~CLK;
  
// ========================================================================== //
// Inject Error Generation                                                    //
// ========================================================================== //
   initial begin
      INJ_ERR = 1'b0;		
      #(CLK_PERIOD*50);
      INJ_ERR = 1'b1;
      #CLK_PERIOD;
      INJ_ERR = 1'b0;      
   end   

endmodule

