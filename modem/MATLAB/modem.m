%% --- 1. 시뮬레이션 파라미터 설정 ---
clear; clc; close all;

tx_dac_bits = 12; % zcu208은 14비트이나, 의도적으로 2비트 덜 씀
tx_sampling_rate = 245.76e6;  % (Hz) 245.76 MHz

% 신호 길이
tx_signal_duration = 0.0001;  % (s) 0.001초

% QAM 설정 (16-QAM으로 가정)
tx_modulation_order = 4;
tx_bits_per_symbol = log2(tx_modulation_order);  % 16-QAM = 4 bits/symbol

% Pulse Shaping (RRC) 설정
tx_samples_per_symbol = 8;  % 심볼 당 샘플 수 (Oversampling Ratio)
tx_rrc_rolloff = 0.25;      % Roll-off factor (alpha)
tx_rrc_span_symbols = 10;   % RRC 필터가 몇 개의 심볼 길이에 해당하는지

%% --- 2. 심볼 및 비트 수 계산 ---

% 심볼 속도 (Baud Rate)
tx_symbol_rate = tx_sampling_rate / tx_samples_per_symbol;

% 총 생성할 샘플 및 심볼 수
tx_total_samples = floor(tx_sampling_rate * tx_signal_duration);
tx_total_symbols = floor(tx_symbol_rate * tx_signal_duration);

% 총 필요한 비트 수 (qammod를 위해 짝수 비트 수 맞춤)
tx_total_bits = tx_total_symbols * tx_bits_per_symbol;

fprintf('--- TX 파라미터 ---\n');
fprintf('DAC 비트: %d-bit\n', tx_dac_bits);
fprintf('샘플링 속도: %.2f MHz\n', tx_sampling_rate / 1e6);
fprintf('심볼 속도: %.2f Msps\n', tx_symbol_rate / 1e6);
fprintf('신호 길이: %.1f ms\n', tx_signal_duration * 1000);
fprintf('총 샘플 수: %d\n', tx_total_samples);
fprintf('총 심볼 수: %d\n', tx_total_symbols);
fprintf('변조 방식: %d-QAM\n', tx_modulation_order);
fprintf('RRC 롤오프: %.2f\n', tx_rrc_rolloff);
fprintf('심볼 당 샘플 수: %d\n', tx_samples_per_symbol);
fprintf('--------------------\n');

%% --- 3. 16-QAM 변조 (Modulation) ---

% 0.001초 분량의 랜덤 비트 생성
% randi([min, max], M, N) -> 0 또는 1, tx_total_bits x 1 크기
tx_bits = randi([0 1], tx_total_bits, 1);

% QAM 심볼 생성 (Communications Toolbox 필요)

tx_symbols = qammod(tx_bits, tx_modulation_order, 'gray', ... 
                        'InputType', 'bit', ...
                        'UnitAveragePower', true);

fi_tx_symbols = round(tx_symbols * 2^11);
fi_MATLAB_tx_symbols = fi(tx_symbols,1,12,11);

%% --- 4. RRC 펄스 성형 (Pulse Shaping - FIR Filter) ---
tx_rrc_taps = rcosdesign(tx_rrc_rolloff, ...
                         tx_rrc_span_symbols, ...
                         tx_samples_per_symbol, ...
                         'sqrt'); % 'sqrt' for Root-Raised Cosine

fi_tx_rrc_taps = round(tx_rrc_taps * 2^(tx_dac_bits-1));
fi_MATLAB_tx_rrc_taps = fi(tx_rrc_taps,1,12,11);


% 심볼 업샘플링 (SPS만큼 0을 삽입)
fi_tx_upsampled_symbols = upsample(fi_tx_symbols, tx_samples_per_symbol);

% RRC Filtering
fi_tx_rrc = conv(fi_tx_upsampled_symbols, fi_tx_rrc_taps);


%% --- 7. RTL 검증 파일 생성 (수정된 로직) ---
fprintf('\n--- RTL 검증 파일 생성 시작 ---\n');

% --- 1. 입력 데이터 (Input Data) ---
% 'fi_MATLAB_tx_symbols' (fi 객체)를 업샘플링하여
% 'fi_tx_upsampled_symbols' (fi 객체)를 생성합니다.
fi_tx_upsampled_symbols = upsample(fi_MATLAB_tx_symbols, tx_samples_per_symbol);

% fi 객체에서 정수 값(RTL로 들어갈 값)을 추출
input_int_real = int(real(fi_tx_upsampled_symbols));
input_int_imag = int(imag(fi_tx_upsampled_symbols));

% 파일 쓰기 (input_data_real.txt)
fileID = fopen('input_data_real.txt', 'w');
fprintf(fileID, '%d\n', input_int_real);
fclose(fileID);

% 파일 쓰기 (input_data_imag.txt)
fileID = fopen('input_data_imag.txt', 'w');
fprintf(fileID, '%d\n', input_int_imag);
fclose(fileID);

fprintf('파일 생성 완료: input_data_real.txt, input_data_imag.txt\n');

% --- 2. 필터 계수 (Filter Coefficients) ---
% 'fi_MATLAB_tx_rrc_taps' (fi 객체)에서 정수 값을 추출
coeffs_int = int(fi_MATLAB_tx_rrc_taps);

fileID = fopen('coeffs_assign.txt', 'w');
fprintf(fileID, '//--- Real Coefficients ---\n');
for i = 0:length(coeffs_int)-1
    % MATLAB 인덱스(i+1)를 Verilog 인덱스(i)에 맞춤
    fprintf(fileID, 'assign coeffs_real[%d] = %d;\n', i, coeffs_int(i+1));
end

fprintf(fileID, '\n//--- Imaginary Coefficients (RRC filter is real) ---\n');
for i = 0:length(coeffs_int)-1
    fprintf(fileID, 'assign coeffs_imag[%d] = 0;\n', i);
end
fclose(fileID);

fprintf('파일 생성 완료: coeffs_assign.txt\n');

% 결과 fi 객체에서 정수 값 추출
output_int_real = real(fi_tx_rrc);
output_int_imag = imag(fi_tx_rrc);
% 파일 쓰기 (golden_out_real.txt)
fileID = fopen('golden_out_real.txt', 'w');
fprintf(fileID, '%d\n', output_int_real);
fclose(fileID);

% 파일 쓰기 (golden_out_imag.txt)
fileID = fopen('golden_out_imag.txt', 'w');
fprintf(fileID, '%d\n', output_int_imag);
fclose(fileID);

fprintf('파일 생성 완료: golden_out_real.txt, golden_out_imag.txt\n');
fprintf('--- 모든 파일 생성 완료 ---\n');