package address_map;

    localparam AXI_AW = 12;
    localparam AXI_DW = 32;
    // ps to pl
    localparam BEACON_RST    = 12'h000;
    localparam BEACON_START  = 12'h004;
    localparam BEACON_ATTEN  = 12'h008;

    // pl to ps
    localparam BEACON_PWR_DOWN = 12'h014;
    localparam BEACON_PWR_UP = 12'h018;

endpackage