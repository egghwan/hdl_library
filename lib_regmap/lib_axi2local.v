module lib_axi2local
#(
    parameter AXI_AW = 12,
    parameter AXI_DW = 32
)
(
    //-------- AXI Interface ----------//
    input               S_AXI_ACLK,       //AXI Clock
    input               S_AXI_ARESETN,    //AXI Negative Reset

    // Write Address     (PS write address to PL)
    input [AXI_AW-1:0]  S_AXI_AWADDR,
    input               S_AXI_AWVALID,
    output              S_AXI_AWREADY,

    // Write Data        (PS write data to PL)
    input [AXI_DW-1:0]  S_AXI_WDATA,
    input               S_AXI_WVALID,
    output              S_AXI_WREADY,

    // Write Response   
    input               S_AXI_BREADY,
    output [1:0]        S_AXI_BRESP,
    output              S_AXI_BVALID,

    // Read Address      (PS Read address from PL)
    input [AXI_AW-1:0]  S_AXI_ARADDR,
    input               S_AXI_ARVALID,
    output              S_AXI_ARREADY,

    // Read Data         (PS Read data from PL)
    input               S_AXI_RREADY,
    output [AXI_DW-1:0] S_AXI_RDATA,
    output [1:0]        S_AXI_RRESP,
    output              S_AXI_RVALID,
    //---------------------------------//

    //--------- Local Interface -------//
    input   [AXI_DW-1:0] pl_to_ps_data, // --> S_AXI_RDATA
    output  [AXI_AW-1:0] pl_to_ps_addr, // <-- S_AXI_ARADDR
    output               pl_to_ps_ren,   // read enable

    output  [AXI_DW-1:0] ps_to_pl_data, // <-- S_AXI_WDATA
    output  [AXI_AW-1:0] ps_to_pl_addr, // <-- S_AXI_WADDR
    output               ps_to_pl_wen   // write enable
);

// AXI4-LITE wires
reg [AXI_AW-1 : 0] 	r_axi_awaddr;
reg  	            r_axi_awready;
reg  	            r_axi_wready;
reg [1 : 0] 	    r_axi_bresp;
reg  	            r_axi_bvalid   = 1'b0;
reg [AXI_AW-1 : 0] 	r_axi_araddr;
reg  	            r_axi_arready;
reg [AXI_DW-1 : 0] 	r_axi_rdata;
reg [1 : 0] 	    r_axi_rresp;
reg  	            r_axi_rvalid;

assign S_AXI_AWREADY  = r_axi_awready;
assign S_AXI_WREADY	  = r_axi_wready;
assign S_AXI_BRESP	  = r_axi_bresp;
assign S_AXI_BVALID	  = r_axi_bvalid;
assign S_AXI_ARREADY  = r_axi_arready;
assign S_AXI_RDATA	  = r_axi_rdata;
assign S_AXI_RRESP	  = r_axi_rresp;
assign S_AXI_RVALID	  = r_axi_rvalid;

reg r_aw_en;

// r_axi_awready //
always @(posedge S_AXI_ACLK ) begin
    if (!S_AXI_ARESETN) begin
        r_axi_awready <= 1'b0;
        r_aw_en       <= 1'b1;
    end
    else begin
        if (~r_axi_awready && S_AXI_AWVALID && S_AXI_WVALID && r_aw_en) begin
            r_axi_awready <= 1'b1;
            r_aw_en       <= 1'b0;
        end
        else if (S_AXI_BREADY && r_axi_bvalid) begin
            r_axi_awready <= 1'b0;
            r_aw_en       <= 1'b1;
        end
        else begin
            r_axi_awready <= 1'b0;
        end
    end
end

// r_axi_awaddr //
always @(posedge S_AXI_ACLK ) begin
    if (!S_AXI_ARESETN) begin
        r_axi_awaddr <= 0;
    end
    else begin
        if(~r_axi_awready && S_AXI_AWVALID && S_AXI_WVALID && r_aw_en) begin
            r_axi_awaddr <= S_AXI_AWADDR;
        end
    end
end

// r_axi_wready //
always @(posedge S_AXI_ACLK ) begin
    if (!S_AXI_ARESETN) begin
        r_axi_wready <= 1'b0;
    end
    else begin
        if (~r_axi_awready && S_AXI_AWVALID && S_AXI_WVALID && r_aw_en) begin
            r_axi_wready <= 1'b1;
        end
        else begin
            r_axi_wready <= 1'b0;
        end
    end
end


always @( posedge S_AXI_ACLK )begin
    if ( S_AXI_ARESETN == 1'b0 ) begin
        r_axi_bvalid  <= 0;
        r_axi_bresp   <= 2'b0;
    end 
    else begin    
        if (r_axi_awready && S_AXI_AWVALID && ~r_axi_bvalid && r_axi_wready && S_AXI_WVALID) begin
            r_axi_bvalid <= 1'b1;
            r_axi_bresp  <= 2'b0; // 'OKAY' response 
        end
        else begin
            if (S_AXI_BREADY && r_axi_bvalid) begin
                r_axi_bvalid <= 1'b0; 
            end  
        end
    end
end   

// PL Write //
assign ps_to_pl_addr = r_axi_awaddr;
assign ps_to_pl_data = S_AXI_WDATA;
assign ps_to_pl_wen = r_axi_wready && S_AXI_WVALID && r_axi_awready && S_AXI_AWVALID;

assign S_AXI_AWREADY = r_axi_awready;
assign S_AXI_WREADY  = r_axi_wready;
assign S_AXI_BRESP   = r_axi_bresp;
assign S_AXI_BVALID  = r_axi_bvalid;


// Read address && response //
always @( posedge S_AXI_ACLK ) begin
	if ( S_AXI_ARESETN == 1'b0 ) begin
		r_axi_arready <= 1'b0;
		r_axi_araddr  <= 32'b0;
	end
	else begin
		if (~r_axi_arready && S_AXI_ARVALID) begin
			r_axi_arready <= 1'b1;
			r_axi_araddr  <= S_AXI_ARADDR;
		end
		else begin
			r_axi_arready <= 1'b0;
		end
	end
end

always @( posedge S_AXI_ACLK ) begin
	if ( S_AXI_ARESETN == 1'b0 ) begin
		r_axi_rvalid <= 0;
		r_axi_rresp  <= 0;
	end
	else begin
		if (r_axi_arready && S_AXI_ARVALID && ~r_axi_rvalid) begin
			r_axi_rvalid <= 1'b1;
			r_axi_rresp  <= 2'b0;
		end
		else if (r_axi_rvalid && S_AXI_RREADY) begin
			r_axi_rvalid <= 1'b0;
		end
	end
end

assign pl_to_ps_ren = r_axi_arready & S_AXI_ARVALID & ~r_axi_rvalid;
assign pl_to_ps_addr = r_axi_araddr;

assign S_AXI_ARREADY = r_axi_arready;
assign S_AXI_RDATA   = pl_to_ps_data;
assign S_AXI_RRESP   = r_axi_rresp;
assign S_AXI_RVALID  = r_axi_rvalid;


endmodule