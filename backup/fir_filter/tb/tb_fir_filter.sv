`include "lib_testbench.svh"

module tb_fir_filter();

    `LIB_CLK_GEN(clk, 100_000_000);
    `LIB_RST_GEN(rst_n, clk, 5);
    `LIB_DUT_TEST_VECTOR_FILE_READ("/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/input_data_real.txt", input_data_real);
    `LIB_DUT_TEST_VECTOR_FILE_READ("/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/input_data_imag.txt", input_data_imag);
    //`LIB_DUT_DRIVE_AXI4_STREAM(s_axis_tvalid, s_axis_tlast, s_axis_tdata, 16, clk, rst_n, input_data);
    //`LIB_DUT_DRIVE_AXI4_STREAM_VERIFY(s_axis_tvalid_real, s_axis_tlast_real, s_axis_tdata_real, 16, clk, rst_n, input_data_real);
    //`LIB_DUT_DRIVE_AXI4_STREAM_COMPLEX(s_axis_tvalid, s_axis_tlast, s_axis_tdata_real, s_axis_tdata_imag, 16, clk, rst_n, input_data_real, input_data_imag);
    `LIB_DUT_DRIVE_AXI4_STREAM_COMPLEX_VERIFY(s_axis_tvalid, s_axis_tlast, s_axis_tdata_real, s_axis_tdata_imag, 16, clk, rst_n, input_data_real, input_data_imag);
    wire m_axis_tvalid;
    wire m_axis_tlast;
    wire [2*16-1:0] m_axis_tdata_real;
    wire [2*16-1:0] m_axis_tdata_imag;

    // My IP
    fir_filter
    #(
        .TAP_LENGTH(28),    // Unique Filter Coeffs length
        .DIN_BW(),
        .DOUT_BW(),
        .SYM_TYPE("ODD"),
        .MODE("COMPLEX")       // REAL or COMPLEX
    )
    u_fir_filter
    (
        .s_axis_aclk    (clk),
        .s_axis_aresetn (rst_n),
        .s_axis_tdata_real (s_axis_tdata_real),
        .s_axis_tdata_imag (s_axis_tdata_imag),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast (s_axis_tlast),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tdata_real (m_axis_tdata_real),
        .m_axis_tdata_imag (m_axis_tdata_imag),
        .m_axis_tlast (m_axis_tlast)
    );

    //`LIB_COMPARE_WITH_GOLDEN_REAL(clk, rst_n, m_axis_tvalid, m_axis_tdata_imag, m_axis_tlast, "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/golden_out_imag.txt");
    `LIB_COMPARE_WITH_GOLDEN_COMPLEX(clk, rst_n, m_axis_tvalid, m_axis_tdata_real, m_axis_tdata_imag, m_axis_tlast, "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/golden_out_real.txt", "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/golden_out_imag.txt");

// --- 신호 모니터링 및 파일 저장 로직 (이 부분을 tb_fir_filter.sv에 추가) ---
initial begin
    int data_file;
    data_file = $fopen("/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/sim_data.csv", "w");
    
    // 파일 헤더 작성 (CSV 형식)
    $fdisplay(data_file, "Output");

    wait (rst_n === 1'b1); // 리셋 대기

    forever @(posedge clk) begin
        // 출력 데이터가 유효할 때만 입력과 출력을 함께 기록
        if (m_axis_tvalid) begin
            $fdisplay(data_file, "%d", m_axis_tdata_real);
        end
    end
end
endmodule
