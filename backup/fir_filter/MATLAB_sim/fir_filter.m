close all;
clear all;
rng(1);

% --- 사용자 설정 ---
nbtap = 20;           % FIR tap 수 (짝수 또는 홀수)
sym_type = 'non-sym';    % 'even': 짝수 대칭, 'odd': 홀수 대칭

% --- FIR 입력 데이터 (복소수) ---
fir_in_real = (-5000:5000)';
fir_in_imag = (5000:-1:-5000)'; % 허수부 데이터 예시
fir_in = complex(fir_in_real, fir_in_imag); % 복소수 입력 데이터 생성

% --- 복소수 FIR 계수 생성 ---
% 고유한 계수(절반 길이)를 생성합니다 (실수부/허수부).
switch sym_type
    case 'even'
        num_unique_coeffs = ceil(nbtap/2);
    case 'odd'
        num_unique_coeffs = ceil(nbtap/2);
    case 'non-sym'
        num_unique_coeffs = nbtap;
end
coeff_base_real = randi([-50, 50], num_unique_coeffs, 1);
coeff_base_imag = randi([-50, 50], num_unique_coeffs, 1);

% sym_type에 따라 전체 대칭 계수를 생성합니다.
switch sym_type
    case 'even' % 짝수 탭 대칭 구조
        if mod(nbtap, 2) ~= 0
            error("sym_type이 'even'일 경우, nbtap은 반드시 짝수여야 합니다.");
        end
        fir_coeffs_real = [coeff_base_real; flipud(coeff_base_real)];
        fir_coeffs_imag = [coeff_base_imag; flipud(coeff_base_imag)];
        
    case 'odd'  % 홀수 탭 대칭 구조
        if mod(nbtap, 2) == 0
            error("sym_type이 'odd'일 경우, nbtap은 반드시 홀수여야 합니다.");
        end
        fir_coeffs_real = [coeff_base_real; flipud(coeff_base_real(1:end-1))];
        fir_coeffs_imag = [coeff_base_imag; flipud(coeff_base_imag(1:end-1))];
        
    case 'non-sym'
        fir_coeffs_real = coeff_base_real;
        fir_coeffs_imag = coeff_base_imag;

    otherwise
        error("sym_type input ERROR!");
end

% 최종 복소수 계수 벡터 생성
fir_coeffs_complex = complex(fir_coeffs_real, fir_coeffs_imag);

% --- FIR 출력 계산 (골든 모델) ---
fir_out = conv(fir_in, fir_coeffs_complex, 'full');

% --- 파일 저장 경로 ---
% 🔽 입력 파일 경로를 실수부와 허수부로 분리
input_file_real   = '/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/input_data_real.txt';
input_file_imag   = '/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/input_data_imag.txt';
output_file_real  = '/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/golden_out_real.txt';
output_file_imag  = '/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/golden_out_imag.txt';
coeffs_file       = '/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB/coeffs_assign.txt';

% --- 입력/출력 파일 저장 ---
% 🔽 입력을 실수부와 허수부 파일로 각각 저장
writematrix(real(fir_in), input_file_real);
writematrix(imag(fir_in), input_file_imag);

% 출력을 실수부와 허수부 파일로 각각 저장
writematrix(real(fir_out), output_file_real);
writematrix(imag(fir_out), output_file_imag);

% --- Verilog assign 문으로 "고유 계수"만 저장 (실수부/허수부) ---
fid = fopen(coeffs_file, 'w');
fprintf(fid, '//--- Real Coefficients ---\n');
for i = 1:length(coeff_base_real)
    fprintf(fid, 'assign coeffs_real[%d] = %d;\n', i-1, coeff_base_real(i));
end

fprintf(fid, '\n//--- Imaginary Coefficients ---\n');
for i = 1:length(coeff_base_imag)
    fprintf(fid, 'assign coeffs_imag[%d] = %d;\n', i-1, coeff_base_imag(i));
end
fclose(fid);

% 🔽 완료 메시지 업데이트
disp('파일 저장 완료:');
disp(['  - Input (Real): ', input_file_real]);
disp(['  - Input (Imag): ', input_file_imag]);
disp(['  - Golden Output (Real): ', output_file_real]);
disp(['  - Golden Output (Imag): ', output_file_imag]);
disp(['  - Coefficients: ', coeffs_file]);