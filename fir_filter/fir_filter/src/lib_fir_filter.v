module lib_fir_filter
#(
    parameter TAP_LENGTH = 9,   // Unique Filter Coeffs length
    parameter DIN_BW     = 16,
    parameter DOUT_BW    = 2*DIN_BW,
    parameter SYM_TYPE   = "ODD",                   // "ODD" or "EVEN" or "NONSYM"
    parameter MODE       = "REAL"
)
(
    input                        s_axis_aclk,       // AXI4-Clock
    input                        s_axis_aresetn,    // AXI4-RESETn

    input  signed [DIN_BW-1:0]   s_axis_tdata_real,      // FIR-filter Input data
    input  signed [DIN_BW-1:0]   s_axis_tdata_imag,
    input                        s_axis_tvalid,     // FIR-filter Input valid
    input                        s_axis_tlast,      // FIR-filter Input last

    output                       m_axis_tvalid,     // FIR-filter Output valid
    output                       m_axis_tlast,      // FIR-filter Output last
    output signed [DOUT_BW-1:0] m_axis_tdata_real,       // FIR-filter Output data
    output signed [DOUT_BW-1:0] m_axis_tdata_imag       // FIR-filter Output data
);
    
    //================================================================================
    //== 필터 계수(Filter Coefficients) 초기화
    //================================================================================
    // ⚠️ Note!
    //    1. 해당 로직의 원활한 동작을 위해 FIR Filter의 계수를 Compile 전 반드시 초기화 해줘야 한다.
    //
    // 💡 초기화 예시 1 (TAP_LENGTH = 5, SYM_TYPE ="ODD" 인 경우):
    //
    //          assign coeffs_real[0] = 1;
    //          assign coeffs_real[1] = 2;
    //          assign coeffs_real[2] = 3;
    //          assign coeffs_real[3] = 4;
    //          assign coeffs_real[4] = 5;
    //
    //      필터는 1,2,3,4,5,4,3,2,1 형태의 FIR Filter로 동작
    //
    // 💡 초기화 예시 2 (TAP_LENGTH = 5, SYM_TYPE ="EVEN" 인 경우):
    //
    //          assign coeffs_real[0] = 1;
    //          assign coeffs_real[1] = 2;
    //          assign coeffs_real[2] = 3;
    //          assign coeffs_real[3] = 4;
    //          assign coeffs_real[4] = 5;
    //
    //      필터는 1,2,3,4,5,5,4,3,2,1 형태의 FIR Filter로 동작
    //================================================================================
    // ⚠️ You must modify below code ⚠️ (51 ~ 56 Line)
    //================================================================================
    
    wire signed [DIN_BW-1:0] coeffs_real [0:TAP_LENGTH-1];
    wire signed [DIN_BW-1:0] coeffs_imag [0:TAP_LENGTH-1];

    //genvar i;
    //generate
    //    for (i=0; i<TAP_LENGTH; i=i+1) begin : init_filter_coeffs_reals_real_real
    //        assign coeffs_real[i] = $signed(2*i+1);
    //    end
    //endgenerate
//--- Real Coefficients ---
//--- Real Coefficients ---
assign coeffs_real[0] = -5;
assign coeffs_real[1] = -8;
assign coeffs_real[2] = -8;
assign coeffs_real[3] = -6;
assign coeffs_real[4] = -2;
assign coeffs_real[5] = 3;
assign coeffs_real[6] = 9;
assign coeffs_real[7] = 14;
assign coeffs_real[8] = 15;
assign coeffs_real[9] = 13;
assign coeffs_real[10] = 7;
assign coeffs_real[11] = -2;
assign coeffs_real[12] = -13;
assign coeffs_real[13] = -24;
assign coeffs_real[14] = -31;
assign coeffs_real[15] = -33;
assign coeffs_real[16] = -27;
assign coeffs_real[17] = -14;
assign coeffs_real[18] = 4;
assign coeffs_real[19] = 26;
assign coeffs_real[20] = 47;
assign coeffs_real[21] = 63;
assign coeffs_real[22] = 68;
assign coeffs_real[23] = 60;
assign coeffs_real[24] = 38;
assign coeffs_real[25] = 4;
assign coeffs_real[26] = -40;
assign coeffs_real[27] = -85;
assign coeffs_real[28] = -123;
assign coeffs_real[29] = -146;
assign coeffs_real[30] = -144;
assign coeffs_real[31] = -112;
assign coeffs_real[32] = -47;
assign coeffs_real[33] = 50;
assign coeffs_real[34] = 172;
assign coeffs_real[35] = 310;
assign coeffs_real[36] = 450;
assign coeffs_real[37] = 579;
assign coeffs_real[38] = 683;
assign coeffs_real[39] = 750;
assign coeffs_real[40] = 774;
assign coeffs_real[41] = 750;
assign coeffs_real[42] = 683;
assign coeffs_real[43] = 579;
assign coeffs_real[44] = 450;
assign coeffs_real[45] = 310;
assign coeffs_real[46] = 172;
assign coeffs_real[47] = 50;
assign coeffs_real[48] = -47;
assign coeffs_real[49] = -112;
assign coeffs_real[50] = -144;
assign coeffs_real[51] = -146;
assign coeffs_real[52] = -123;
assign coeffs_real[53] = -85;
assign coeffs_real[54] = -40;
assign coeffs_real[55] = 4;
assign coeffs_real[56] = 38;
assign coeffs_real[57] = 60;
assign coeffs_real[58] = 68;
assign coeffs_real[59] = 63;
assign coeffs_real[60] = 47;
assign coeffs_real[61] = 26;
assign coeffs_real[62] = 4;
assign coeffs_real[63] = -14;
assign coeffs_real[64] = -27;
assign coeffs_real[65] = -33;
assign coeffs_real[66] = -31;
assign coeffs_real[67] = -24;
assign coeffs_real[68] = -13;
assign coeffs_real[69] = -2;
assign coeffs_real[70] = 7;
assign coeffs_real[71] = 13;
assign coeffs_real[72] = 15;
assign coeffs_real[73] = 14;
assign coeffs_real[74] = 9;
assign coeffs_real[75] = 3;
assign coeffs_real[76] = -2;
assign coeffs_real[77] = -6;
assign coeffs_real[78] = -8;
assign coeffs_real[79] = -8;
assign coeffs_real[80] = -5;

//--- Imaginary Coefficients (RRC filter is real) ---
assign coeffs_imag[0] = 0;
assign coeffs_imag[1] = 0;
assign coeffs_imag[2] = 0;
assign coeffs_imag[3] = 0;
assign coeffs_imag[4] = 0;
assign coeffs_imag[5] = 0;
assign coeffs_imag[6] = 0;
assign coeffs_imag[7] = 0;
assign coeffs_imag[8] = 0;
assign coeffs_imag[9] = 0;
assign coeffs_imag[10] = 0;
assign coeffs_imag[11] = 0;
assign coeffs_imag[12] = 0;
assign coeffs_imag[13] = 0;
assign coeffs_imag[14] = 0;
assign coeffs_imag[15] = 0;
assign coeffs_imag[16] = 0;
assign coeffs_imag[17] = 0;
assign coeffs_imag[18] = 0;
assign coeffs_imag[19] = 0;
assign coeffs_imag[20] = 0;
assign coeffs_imag[21] = 0;
assign coeffs_imag[22] = 0;
assign coeffs_imag[23] = 0;
assign coeffs_imag[24] = 0;
assign coeffs_imag[25] = 0;
assign coeffs_imag[26] = 0;
assign coeffs_imag[27] = 0;
assign coeffs_imag[28] = 0;
assign coeffs_imag[29] = 0;
assign coeffs_imag[30] = 0;
assign coeffs_imag[31] = 0;
assign coeffs_imag[32] = 0;
assign coeffs_imag[33] = 0;
assign coeffs_imag[34] = 0;
assign coeffs_imag[35] = 0;
assign coeffs_imag[36] = 0;
assign coeffs_imag[37] = 0;
assign coeffs_imag[38] = 0;
assign coeffs_imag[39] = 0;
assign coeffs_imag[40] = 0;
assign coeffs_imag[41] = 0;
assign coeffs_imag[42] = 0;
assign coeffs_imag[43] = 0;
assign coeffs_imag[44] = 0;
assign coeffs_imag[45] = 0;
assign coeffs_imag[46] = 0;
assign coeffs_imag[47] = 0;
assign coeffs_imag[48] = 0;
assign coeffs_imag[49] = 0;
assign coeffs_imag[50] = 0;
assign coeffs_imag[51] = 0;
assign coeffs_imag[52] = 0;
assign coeffs_imag[53] = 0;
assign coeffs_imag[54] = 0;
assign coeffs_imag[55] = 0;
assign coeffs_imag[56] = 0;
assign coeffs_imag[57] = 0;
assign coeffs_imag[58] = 0;
assign coeffs_imag[59] = 0;
assign coeffs_imag[60] = 0;
assign coeffs_imag[61] = 0;
assign coeffs_imag[62] = 0;
assign coeffs_imag[63] = 0;
assign coeffs_imag[64] = 0;
assign coeffs_imag[65] = 0;
assign coeffs_imag[66] = 0;
assign coeffs_imag[67] = 0;
assign coeffs_imag[68] = 0;
assign coeffs_imag[69] = 0;
assign coeffs_imag[70] = 0;
assign coeffs_imag[71] = 0;
assign coeffs_imag[72] = 0;
assign coeffs_imag[73] = 0;
assign coeffs_imag[74] = 0;
assign coeffs_imag[75] = 0;
assign coeffs_imag[76] = 0;
assign coeffs_imag[77] = 0;
assign coeffs_imag[78] = 0;
assign coeffs_imag[79] = 0;
assign coeffs_imag[80] = 0;
    //======================== 필터 계수 초기화 끝 =======================================

    // Wire Signal
    wire signed [DIN_BW-1:0]   w_systolic_delay_real   [0:TAP_LENGTH-1];
    wire signed [DOUT_BW-1:0]  w_systolic_casc_real    [0:TAP_LENGTH-1];
    wire signed [DIN_BW-1:0]   w_systolic_delay_imag   [0:TAP_LENGTH-1];
    wire signed [DOUT_BW-1:0]  w_systolic_casc_imag    [0:TAP_LENGTH-1];

    // shifter 출력
    wire signed [DIN_BW-1:0]   w_dout_shifter_real;
    wire signed [DIN_BW-1:0]   w_dout_shifter_imag;
    wire                       w_active;
    wire                       w_flush_ongoing;

    wire signed [DIN_BW-1:0]   effective_din_real   = s_axis_tvalid ? s_axis_tdata_real : {DIN_BW{1'b0}}; // Feed input to the systolic array only when s_axis_tvalid is 1
    wire signed [DIN_BW-1:0]   effective_din_imag   = s_axis_tvalid ? s_axis_tdata_imag : {DIN_BW{1'b0}}; // Feed input to the systolic array only when s_axis_tvalid is 1

    wire                       effective_din_real_v = s_axis_tvalid || w_flush_ongoing;

    // SRL Based Shift Register
    fir_shifter
    #(
        .DIN_BW(DIN_BW),
        .TAP_LENGTH(TAP_LENGTH),
        .SYM_TYPE(SYM_TYPE)
    )
    u_fir_shifter
    (
        .clk            (s_axis_aclk),
        .rst            (!s_axis_aresetn),

        .din_v          (s_axis_tvalid),      // Fir Filter Input Data valid
        .din_last       (s_axis_tlast),       // Fir Filter Input Data last
        .din_real       (s_axis_tdata_real),       // Fir Filter Input Data
        .din_imag       (s_axis_tdata_imag),

        .dout_real      (w_dout_shifter_real),     // Fir Shifter Output
        .dout_imag      (w_dout_shifter_imag),
        .active         (w_active),           // Fir Filter Processing Active Signal
        .flush_ongoing  (w_flush_ongoing)     // Flushing Signal
    );

    genvar k;
    generate
        if(SYM_TYPE == "EVEN") begin
            for (k=0; k<TAP_LENGTH; k=k+1) begin : gen_systolic_array_even
                if (k==0) begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element_first
                    (
                        .clk             (s_axis_aclk        ),
                        .rst             (!s_axis_aresetn    ),

                        .din_active      (w_active           ),     //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real (coeffs_real[k]          ),     // Feed input to the systolic array only when s_axis_tvalid is 1
                        .din_coeffs_imag (coeffs_imag[k]),
                        .din_real        (effective_din_real      ),
                        .din_imag        (effective_din_imag      ),
                        .din_shifter_real(w_dout_shifter_real     ),
                        .din_shifter_imag(w_dout_shifter_imag     ),
                        .din_casc_real   ({DOUT_BW{1'b0}}         ),
                        .din_casc_imag   ({DOUT_BW{1'b0}}         ),

                        .dout_delay_real (w_systolic_delay_real[k]),
                        .dout_delay_imag (w_systolic_delay_imag[k]),
                        .dout_casc_real  (w_systolic_casc_real[k] ),
                        .dout_casc_imag  (w_systolic_casc_imag[k] )
                    );
                end 
                else begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element
                    (
                        .clk             (s_axis_aclk            ),
                        .rst             (!s_axis_aresetn        ),

                        .din_active      (w_active               ),  //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real (coeffs_real[k]              ),
                        .din_coeffs_imag (coeffs_imag[k]),
                        .din_real        (w_systolic_delay_real[k-1]  ),
                        .din_imag        (w_systolic_delay_imag[k-1]),
                        .din_shifter_real(w_dout_shifter_real         ),
                        .din_shifter_imag(w_dout_shifter_imag),
                        .din_casc_real   (w_systolic_casc_real[k-1]   ),
                        .din_casc_imag   (w_systolic_casc_imag[k-1]   ),

                        .dout_delay_real (w_systolic_delay_real[k]    ),
                        .dout_delay_imag (w_systolic_delay_imag[k]    ),
                        .dout_casc_real  (w_systolic_casc_real[k]     ),
                        .dout_casc_imag  (w_systolic_casc_imag[k]     )
                    );
                end
            end
        end
        else if(SYM_TYPE == "ODD") begin
            for (k=0; k<TAP_LENGTH; k=k+1) begin : gen_systolic_array_odd
                if (k==0) begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element_first
                    (
                        .clk                (s_axis_aclk            ),
                        .rst                (!s_axis_aresetn        ),
                    
                        .din_active         (w_active               ),  //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real    (coeffs_real[k]              ),
                        .din_coeffs_imag    (coeffs_imag[k]),
                        .din_real           (effective_din_real          ),
                        .din_imag           (effective_din_imag),
                        .din_shifter_real   (w_dout_shifter_real         ),
                        .din_shifter_imag   (w_dout_shifter_imag),
                        .din_casc_real      ({DOUT_BW{1'b0}}        ),
                        .din_casc_imag      ({DOUT_BW{1'b0}}        ),

                        .dout_delay_real    (w_systolic_delay_real[k]    ),
                        .dout_delay_imag    (w_systolic_delay_imag[k]    ),
                        .dout_casc_real     (w_systolic_casc_real[k]     ),
                        .dout_casc_imag     (w_systolic_casc_imag[k]     )
                    );
                end 
                else if(k==TAP_LENGTH-1)begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element_last
                    (
                        .clk                (s_axis_aclk            ),
                        .rst                (!s_axis_aresetn        ),
                    
                        .din_active         (w_active                    ),  //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real    (coeffs_real[k]              ),
                        .din_coeffs_imag    (coeffs_imag[k]              ),
                        .din_real           (w_systolic_delay_real[k-1]  ),
                        .din_imag           (w_systolic_delay_imag[k-1]  ),
                        .din_shifter_real   (0                      ),
                        .din_shifter_imag   (0),
                        .din_casc_real      (w_systolic_casc_real[k-1]   ),
                        .din_casc_imag      (w_systolic_casc_imag[k-1]   ),

                        .dout_delay_real    (w_systolic_delay_real[k]    ),
                        .dout_delay_imag    (w_systolic_delay_imag[k]    ),
                        .dout_casc_real     (w_systolic_casc_real[k]     ),
                        .dout_casc_imag     (w_systolic_casc_imag[k]     )
                    );
                end
                else begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element
                    (
                        .clk            (s_axis_aclk            ),
                        .rst            (!s_axis_aresetn        ),

                        .din_active     (w_active               ),  //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real     (coeffs_real[k]              ),
                        .din_coeffs_imag     (coeffs_imag[k]              ),
                        .din_real            (w_systolic_delay_real[k-1]  ),
                        .din_imag            (w_systolic_delay_imag[k-1]  ),
                        .din_shifter_real    (w_dout_shifter_real         ),
                        .din_shifter_imag    (w_dout_shifter_imag         ),
                        .din_casc_real       (w_systolic_casc_real[k-1]   ),
                        .din_casc_imag       (w_systolic_casc_imag[k-1]   ),

                        .dout_delay_real     (w_systolic_delay_real[k]    ),
                        .dout_delay_imag     (w_systolic_delay_imag[k]    ),
                        .dout_casc_real      (w_systolic_casc_real[k]     ),
                        .dout_casc_imag      (w_systolic_casc_imag[k]     )
                    );
                end
            end
        end
        else begin  //when "NONSYM"
            for (k=0; k<TAP_LENGTH; k=k+1) begin : gen_systolic_array_nonsym
                if (k==0) begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element_first
                    (
                        .clk             (s_axis_aclk        ),
                        .rst             (!s_axis_aresetn    ),

                        .din_active      (w_active           ),     //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real (coeffs_real[k]          ),     // Feed input to the systolic array only when s_axis_tvalid is 1
                        .din_coeffs_imag (coeffs_imag[k]),
                        .din_real        (effective_din_real      ),
                        .din_imag        (effective_din_imag      ),
                        .din_shifter_real({DIN_BW{1'b0}}             ),
                        .din_shifter_imag({DIN_BW{1'b0}}             ),
                        .din_casc_real   ({DOUT_BW{1'b0}}         ),
                        .din_casc_imag   ({DOUT_BW{1'b0}}         ),

                        .dout_delay_real (w_systolic_delay_real[k]),
                        .dout_delay_imag (w_systolic_delay_imag[k]),
                        .dout_casc_real  (w_systolic_casc_real[k] ),
                        .dout_casc_imag  (w_systolic_casc_imag[k] )
                    );
                end 
                else begin
                    fir_systolic_element #(DIN_BW) u_fir_systolic_element
                    (
                        .clk             (s_axis_aclk            ),
                        .rst             (!s_axis_aresetn        ),

                        .din_active      (w_active               ),  //⚠️ fir filter input (s_axis_tdata_real) is not valid, systolic element doesn't operate
                        .din_coeffs_real (coeffs_real[k]              ),
                        .din_coeffs_imag (coeffs_imag[k]),
                        .din_real        (w_systolic_delay_real[k-1]  ),
                        .din_imag        (w_systolic_delay_imag[k-1]),
                        .din_shifter_real({DIN_BW{1'b0}}         ),
                        .din_shifter_imag({DIN_BW{1'b0}}),
                        .din_casc_real   (w_systolic_casc_real[k-1]   ),
                        .din_casc_imag   (w_systolic_casc_imag[k-1]   ),
                        .dout_delay_real (w_systolic_delay_real[k]    ),
                        .dout_delay_imag (w_systolic_delay_imag[k]    ),
                        .dout_casc_real  (w_systolic_casc_real[k]     ),
                        .dout_casc_imag  (w_systolic_casc_imag[k]     ) 
                    );
                end
            end
        end
    endgenerate

    // Make m_axis_tvalid && m_axis_tlast //
    localparam FILTER_DELAY = TAP_LENGTH + 4;
    reg [FILTER_DELAY-1:0] r_output_v_pipe;

    always @(posedge s_axis_aclk) begin : gen_m_axis_tvalid
        if (!s_axis_aresetn) begin
            r_output_v_pipe <= 0;
        end
        else if (w_active) begin
            r_output_v_pipe <= {r_output_v_pipe[FILTER_DELAY-2:0], effective_din_real_v};
        end
        else begin
            r_output_v_pipe[FILTER_DELAY-1] <= 0;
        end
    end

    reg r_flush_ongoing_1d;

    always @(posedge s_axis_aclk) begin : gen_m_axis_tlast
        if(!s_axis_aresetn) begin
            r_flush_ongoing_1d <= 1'b0;
        end
        else begin
            r_flush_ongoing_1d <= w_flush_ongoing;
        end
    end
    
    assign m_axis_tvalid = r_output_v_pipe[FILTER_DELAY-1];
    assign m_axis_tdata_real  = w_systolic_casc_real[TAP_LENGTH-1];
    assign m_axis_tdata_imag  = w_systolic_casc_imag[TAP_LENGTH-1];
    assign m_axis_tlast = r_flush_ongoing_1d && !w_flush_ongoing;

endmodule

//(* dont_touch = "yes" *)
module fir_shifter // @suppress "File contains multiple design units"
#(
    parameter DIN_BW = 16,
    parameter TAP_LENGTH = 9,
    parameter SYM_TYPE = "ODD"
)
(
    input  clk,
    input  rst,
    input  din_v,
    input  din_last,
    input  signed [DIN_BW-1:0] din_real,
    input  signed [DIN_BW-1:0] din_imag,
    output signed [DIN_BW-1:0] dout_real,
    output signed [DIN_BW-1:0] dout_imag,
    output active,
    output flush_ongoing
);
    localparam is_odd = (SYM_TYPE == "ODD") ? 1 : 0;
    localparam FLUSH_CNT = (SYM_TYPE == "ODD") ? 3*TAP_LENGTH+1-is_odd : (SYM_TYPE == "EVEN") ? 3*TAP_LENGTH+1 : (2*TAP_LENGTH + 1);

    (* srl_style = "srl_register" *) reg signed [DIN_BW-1:0] r_srl_real [0:2*TAP_LENGTH-1];
    (* srl_style = "srl_register" *) reg signed [DIN_BW-1:0] r_srl_imag [0:2*TAP_LENGTH-1];

    integer k;

    reg r_flush_ongoing;
    reg [$clog2(4*TAP_LENGTH+1)-1:0] r_flush_cnt;

    always @(posedge clk) begin : check_flushing_state
        if (rst) begin
            r_flush_ongoing <= 1'b0;
        end else if (din_last) begin
            r_flush_ongoing <= 1'b1;
        end else if (r_flush_cnt == FLUSH_CNT) begin
            r_flush_ongoing <= 1'b0;
        end
    end

    always @(posedge clk) begin : flushing_cnt
        if (rst) begin
            r_flush_cnt <= 0;
        end else if (r_flush_ongoing) begin
            r_flush_cnt <= r_flush_cnt + 1'b1;
        end else begin
            r_flush_cnt <= 0;
        end
    end

    assign active = din_v || r_flush_ongoing;
    assign flush_ongoing = r_flush_ongoing;

    always @(posedge clk) begin : shift_register
        if (rst) begin
            for (k=0; k<2*TAP_LENGTH; k=k+1) r_srl_real[k] <= 0;
            for (k=0; k<2*TAP_LENGTH; k=k+1) r_srl_imag[k] <= 0;
        end 
        else if (active) begin
            for (k=0; k<2*TAP_LENGTH-1; k=k+1) begin
                r_srl_real[k+1] <= r_srl_real[k];
                r_srl_imag[k+1] <= r_srl_imag[k];
            end
            if (din_v) begin
                 r_srl_real[0] <= din_real;
                 r_srl_imag[0] <= din_imag;
            end
            else if (r_flush_ongoing) begin
                r_srl_real[0] <= 0;
                r_srl_imag[0] <= 0;
            end
        end
    end

    assign dout_real = r_srl_real[2*TAP_LENGTH-1-is_odd];
    assign dout_imag = r_srl_imag[2*TAP_LENGTH-1-is_odd];

endmodule
// ------------------------------------------------------------
module fir_systolic_element  // @suppress "File contains multiple design units"
#(
    parameter DIN_BW = 16
)
(
    input                        clk,
    input                        rst,

    input                        din_active,
    input  signed [DIN_BW-1:0]   din_coeffs_real,
    input  signed [DIN_BW-1:0]   din_coeffs_imag,
    input  signed [DIN_BW-1:0]   din_real,
    input  signed [DIN_BW-1:0]   din_imag,
    input  signed [DIN_BW-1:0]   din_shifter_real,
    input  signed [DIN_BW-1:0]   din_shifter_imag,
    input  signed [2*DIN_BW-1:0] din_casc_real,
    input  signed [2*DIN_BW-1:0] din_casc_imag,

    output signed [DIN_BW-1:0]   dout_delay_real,
    output signed [DIN_BW-1:0]   dout_delay_imag,
    output signed [2*DIN_BW-1:0] dout_casc_real,
    output signed [2*DIN_BW-1:0] dout_casc_imag
);

    reg signed [DIN_BW-1:0]   r_din_1d_real, r_din_2d_real;
    reg signed [DIN_BW-1:0]   r_din_1d_imag, r_din_2d_imag;
    reg signed [DIN_BW-1:0]   r_din_1d_real_shifter;
    reg signed [DIN_BW-1:0]   r_din_1d_imag_shifter;
    reg signed [DIN_BW:0]     r_preadd_out_real;
    reg signed [DIN_BW:0]     r_preadd_out_imag;
    reg signed [2*DIN_BW-1:0] r_mult_out_real;
    reg signed [2*DIN_BW-1:0] r_mult_out_imag;
    reg signed [2*DIN_BW-1:0] r_afteradd_out_real;
    reg signed [2*DIN_BW-1:0] r_afteradd_out_imag;
    reg signed [DIN_BW-1:0]   r_coeffs_real;
    reg signed [DIN_BW-1:0]   r_coeffs_imag;

    always @(posedge clk) begin
        if (rst) begin
            r_coeffs_real         <= 0;
            r_coeffs_imag         <= 0;
            r_din_1d_real         <= 0;
            r_din_1d_imag         <= 0;
            r_din_2d_real         <= 0;
            r_din_2d_imag         <= 0;
            r_din_1d_real_shifter <= 0;
            r_din_1d_imag_shifter <= 0;
            r_preadd_out_real     <= 0;
            r_preadd_out_imag     <= 0;
            r_mult_out_real       <= 0;
            r_mult_out_imag       <= 0;
            r_afteradd_out_real   <= 0;
            r_afteradd_out_imag   <= 0;
        end else if (din_active) begin
            r_coeffs_real          <= din_coeffs_real;      
            r_coeffs_imag          <= din_coeffs_imag;      
            r_din_1d_real         <= din_real;
            r_din_1d_imag         <= din_imag;
            r_din_2d_real         <= r_din_1d_real;
            r_din_2d_imag         <= r_din_1d_imag;
            r_din_1d_real_shifter <= din_shifter_real;
            r_din_1d_imag_shifter <= din_shifter_imag;
            r_preadd_out_real     <= r_din_2d_real + r_din_1d_real_shifter;
            r_preadd_out_imag     <= r_din_2d_imag + r_din_1d_imag_shifter;
            r_mult_out_real       <= (r_preadd_out_real * r_coeffs_real) - (r_preadd_out_imag * r_coeffs_imag); // TODO : Complex Multiplier can reduced number of multiplier if preadd
            r_mult_out_imag       <= (r_preadd_out_real * r_coeffs_imag) + (r_preadd_out_imag * r_coeffs_real); // TODO : Complex Multiplier can reduced number of multiplier if preadd
            r_afteradd_out_real   <= r_mult_out_real + din_casc_real;
            r_afteradd_out_imag   <= r_mult_out_imag + din_casc_imag;
        end
    end

    assign dout_delay_real = r_din_2d_real;
    assign dout_delay_imag = r_din_2d_imag;
    assign dout_casc_real  = r_afteradd_out_real;
    assign dout_casc_imag  = r_afteradd_out_imag;

endmodule
