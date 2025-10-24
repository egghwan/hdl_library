module lib_regmap
#(
    parameter USE_CDC = 0, // 1 = "Use CDC", 0 = "Don't Use CDC"
    parameter AXI_AW = 12,
    parameter AXI_DW = 32
)
(
    // AXI Interface (AXI Clock Domain)
    input               S_AXI_ACLK,
    input               S_AXI_ARESETN,
    // ... (기존 AXI 포트들) ...
    input [AXI_AW-1:0]  S_AXI_AWADDR,
    input               S_AXI_AWVALID,
    output              S_AXI_AWREADY,
    input [AXI_DW-1:0]  S_AXI_WDATA,
    input               S_AXI_WVALID,
    output              S_AXI_WREADY,
    input               S_AXI_BREADY,
    output [1:0]        S_AXI_BRESP,
    output              S_AXI_BVALID,
    input [AXI_AW-1:0]  S_AXI_ARADDR,
    input               S_AXI_ARVALID,
    output              S_AXI_ARREADY,
    input               S_AXI_RREADY,
    output [AXI_DW-1:0] S_AXI_RDATA,
    output [1:0]        S_AXI_RRESP,
    output              S_AXI_RVALID,

    // NEW: Ports for PL Clock Domain (if USE_CDC == 1)
    input               PL_CLK,
    input               PL_ARESETN,

    // My Module (PL Clock Domain)
    input [AXI_DW-1:0] in1,          // PL -> PS (PL_CLK Domain)
    input [AXI_DW-1:0] in2,          // PL -> PS (PL_CLK Domain)
    output reg out1,    // PS -> PL (PL_CLK Domain)
    output reg out2,    // PS -> PL (PL_CLK Domain)
    output reg [31:0] out3           // PS -> PL (PL_CLK Domain)
);

// AXI Clock/Reset
wire clk = S_AXI_ACLK;
wire rst_n = S_AXI_ARESETN;


import address_map::*;

// AXI -> Local Bus (AXI Clock Domain)
reg signed [AXI_DW-1:0] pl_to_ps_data; // AXI Domain
wire       [AXI_AW-1:0] pl_to_ps_addr; // AXI Domain
wire                    pl_to_ps_ren;  // AXI Domain
wire       [AXI_DW-1:0] ps_to_pl_data; // AXI Domain
wire       [AXI_AW-1:0] ps_to_pl_addr; // AXI Domain
wire                    ps_to_pl_wen;  // AXI Domain

lib_axi2local
#(
    .AXI_AW(AXI_AW),
    .AXI_DW(AXI_DW)
)
u_lib_axi2local
(
    .S_AXI_ACLK     (S_AXI_ACLK),
    .S_AXI_ARESETN  (S_AXI_ARESETN),
    // ... (AXI 신호 연결) ...
    .S_AXI_AWADDR   (S_AXI_AWADDR),
    .S_AXI_AWVALID  (S_AXI_AWVALID),
    .S_AXI_AWREADY  (S_AXI_AWREADY),
    .S_AXI_WDATA    (S_AXI_WDATA),
    .S_AXI_WVALID  (S_AXI_WVALID),
    .S_AXI_WREADY   (S_AXI_WREADY),
    .S_AXI_BREADY   (S_AXI_BREADY),
    .S_AXI_BRESP    (S_AXI_BRESP),
    .S_AXI_BVALID   (S_AXI_BVALID),
    .S_AXI_ARADDR   (S_AXI_ARADDR),
    .S_AXI_ARVALID  (S_AXI_ARVALID),
    .S_AXI_ARREADY  (S_AXI_ARREADY),
    .S_AXI_RREADY   (S_AXI_RREADY),
    .S_AXI_RDATA    (S_AXI_RDATA),
    .S_AXI_RRESP    (S_AXI_RRESP),
    .S_AXI_RVALID   (S_AXI_RVALID),

    .pl_to_ps_data  (pl_to_ps_data), // AXI Domain
    .pl_to_ps_addr  (pl_to_ps_addr), // AXI Domain
    .pl_to_ps_ren   (pl_to_ps_ren),  // AXI Domain
    .ps_to_pl_data  (ps_to_pl_data), // AXI Domain
    .ps_to_pl_addr  (ps_to_pl_addr), // AXI Domain
    .ps_to_pl_wen   (ps_to_pl_wen)   // AXI Domain
);

//-------------------------------------------------
// CDC Logic Generation
//-------------------------------------------------
generate
    if (USE_CDC == 0) begin : gen_no_cdc
        // --- 방법 1: CDC 없음 (모든 로직이 S_AXI_ACLK로 동작) ---

        // PS write to PL (AXI Domain)
        always @(posedge clk) begin
            if(!rst_n) begin
                out1 <= 0;
                out2 <= 0;
                out3 <= 0;
            end
            else if(ps_to_pl_wen) begin
                case(ps_to_pl_addr)
                    BEACON_RST  : out1 <= ps_to_pl_data[0];
                    BEACON_START : out2 <= ps_to_pl_data[0];
                    BEACON_ATTEN : out3 <= ps_to_pl_data;
                    default: begin
                        out1 <= out1;
                        out2 <= out2;
                        out3 <= out3;
                    end
                endcase
            end
        end

        // PS read from PL (AXI Domain)
        always @(posedge clk) begin
            if(!rst_n) begin
                pl_to_ps_data <= 0;
            end
            else if(pl_to_ps_ren) begin
                case(pl_to_ps_addr)
                    BEACON_PWR_DOWN   : pl_to_ps_data <= in1;
                    BEACON_PWR_UP     : pl_to_ps_data <= in2;
                    default: begin
                        pl_to_ps_data <= 32'b0;
                    end
                endcase
            end
        end

    end
    else begin : gen_use_cdc
        // --- 방법 2: CDC 사용 (AXI 도메인과 PL 도메인 분리) ---
        wire pl_clk   = PL_CLK;
        wire pl_rst_n = PL_ARESETN;
        // 1. PS write to PL (AXI_CLK -> PL_CLK)
        // 'ps_to_pl_wen' 펄스 신호를 PL_CLK로 동기화
        wire ps_to_pl_wen_synced;
        
        cdc_sync_pulse u_cdc_write_strobe (
            .SRC_CLK    (S_AXI_ACLK),
            .SRC_RST_N  (S_AXI_ARESETN),
            .SRC_PULSE  (ps_to_pl_wen),
            
            .DST_CLK    (PL_CLK),
            .DST_RST_N  (PL_ARESETN),
            .DST_PULSE  (ps_to_pl_wen_synced)
        );

        // PL 로직은 PL_CLK로 동작
        // `out` 레지스터들은 `pl_rst_n` (PL_ARESETN)을 사용해야 함
        always @(posedge pl_clk) begin
            if (!pl_rst_n) begin
                out1 <= 0;
                out2 <= 0;
                out3 <= 0;
            end
            // 동기화된 펄스를 감지
            else if (ps_to_pl_wen_synced) begin 
                // AXI 도메인에서 넘어온 데이터/주소를 샘플링
                // (데이터/주소는 동기화 불필요 - 펄스 동기화 방식의 특징)
                case (ps_to_pl_addr) 
                    BEACON_RST   : out1 <= ps_to_pl_data[0];
                    BEACON_START : out2 <= ps_to_pl_data[0];
                    BEACON_ATTEN : out3 <= ps_to_pl_data;
                    default: begin
                        out1 <= out1;
                        out2 <= out2;
                        out3 <= out3;
                    end
                endcase
            end
        end

        // 2. PS read from PL (PL_CLK -> AXI_CLK)
        // 'in1', 'in2' 데이터를 AXI_CLK 도메인으로 동기화
        wire [AXI_DW-1:0] in1_synced;
        wire [AXI_DW-1:0] in2_synced;

        cdc_sync_data #( .WIDTH(AXI_DW) ) u_cdc_in1 (
            .SRC_CLK    (pl_clk),    // PL_CLK
            .SRC_RST_N  (pl_rst_n),  // PL_ARESETN
            .SRC_DATA   (in1),
            
            .DST_CLK    (clk),       // S_AXI_ACLK
            .DST_RST_N  (rst_n),     // S_AXI_ARESETN
            .DST_DATA   (in1_synced)
        );

        cdc_sync_data #( .WIDTH(AXI_DW) ) u_cdc_in2 (
            .SRC_CLK    (pl_clk),
            .SRC_RST_N  (pl_rst_n),
            .SRC_DATA   (in2),
            
            .DST_CLK    (clk),
            .DST_RST_N  (rst_n),
            .DST_DATA   (in2_synced)
        );

        // AXI 로직(읽기)은 S_AXI_ACLK로 동작
        always @(posedge clk) begin
            if (!rst_n) begin
                pl_to_ps_data <= 0;
            end
            else if (pl_to_ps_ren) begin
                // 동기화된 데이터를 읽음
                case (pl_to_ps_addr) 
                    BEACON_PWR_DOWN : pl_to_ps_data <= in1_synced;
                    BEACON_PWR_UP   : pl_to_ps_data <= in2_synced;
                    default         : pl_to_ps_data <= 32'b0;
                endcase
            end
        end

    end
endgenerate

endmodule

//
// 2-FF Register Synchronizer (for Data)
//
module cdc_sync_data
#(
    parameter WIDTH = 1
)
(
    input                   SRC_CLK,
    input                   SRC_RST_N,
    input [WIDTH-1:0]       SRC_DATA,   // 소스 클럭 도메인 데이터
 
    input                   DST_CLK,
    input                   DST_RST_N,  // 목적지 클럭 도메인 리셋
    output reg [WIDTH-1:0]  DST_DATA    // 목적지 클럭 도메인 데이터
);
 
    // 툴이 이 레지스터를 CDC 경로로 인식하도록 속성(attribute)을 지정
    (* ASYNC_REG = "TRUE" *) 
    reg [WIDTH-1:0] data_ff1;
 
    // 2단 동기화기 (목적지 클럭으로 동작)
    always @(posedge DST_CLK or negedge DST_RST_N) begin
        if (!DST_RST_N) begin
            data_ff1 <= 'b0;
            DST_DATA <= 'b0;
        end
        else begin
            data_ff1 <= SRC_DATA; // 1단 FF: 비동기 데이터 캡처 (Metastability 발생 가능)
            DST_DATA <= data_ff1; // 2단 FF: 안정화된 데이터 출력
        end
    end
    
endmodule

//
// 1-Cycle Pulse Synchronizer
//
module cdc_sync_pulse
(
    input   SRC_CLK,
    input   SRC_RST_N,
    input   SRC_PULSE, // 소스 클럭 도메인 1-cycle 펄스
    
    input   DST_CLK,
    input   DST_RST_N,
    output  DST_PULSE  // 목적지 클럭 도메인 1-cycle 펄스
);

    // 1. 펄스 신호를 목적지 도메인으로 2-FF 동기화
    (* ASYNC_REG = "TRUE" *)
    reg sreg1, sreg2;

    always @(posedge DST_CLK or negedge DST_RST_N) begin
        if (!DST_RST_N) begin
            sreg1 <= 1'b0;
            sreg2 <= 1'b0;
        end
        else begin
            sreg1 <= SRC_PULSE;
            sreg2 <= sreg1;
        end
    end

    // 2. 목적지 도메인에서 Rising Edge를 감지하여 펄스 생성
    reg sreg2_dly;
    
    always @(posedge DST_CLK or negedge DST_RST_N) begin
        if (!DST_RST_N) begin
            sreg2_dly <= 1'b0;
        end
        else begin
            sreg2_dly <= sreg2;
        end
    end

    // sreg2가 0->1로 변하는 시점에 1-cycle 펄스 출력
    assign DST_PULSE = (sreg2 == 1'b1) && (sreg2_dly == 1'b0);

endmodule