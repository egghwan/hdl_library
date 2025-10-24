# --- 1. 스크립트 인자 확인 ---
# $argc는 -tclargs로 전달된 인자의 개수입니다.
# 2개 인자 (보드 이름, 프로젝트 이름)가 필요합니다.
if {$argc != 2} {
    puts "(!) 사용법: vivado -mode gui -source make_vivado_project.tcl -tclargs <board_name> <project_name>"
    puts "    <board_name> 예시: zcu208, zcu111, versal"
    puts "    <project_name> 예시: my_fir_filter"
    exit 1
}

# 인자를 변수에 할당
set board_name [lindex $argv 0]
set project_name [lindex $argv 1]

puts "--- 입력 파라미터 ---"
puts "  보드 이름: $board_name"
puts "  프로젝트 이름: $project_name"

# --- 2. 보드 이름에 따라 파트 설정 (요청한 로직) ---
puts "--- FPGA 파트 매핑 중 ---"
switch -- $board_name {
    "zcu111" {
        set part_name "xczu28dr-ffvg1517-2-e"
    }
    "zcu208" {
        set part_name "xczu48dr-fsvg1517-2-e"
    }
    "versal" {
        set part_name "xcvc1902-vsva2197-1MP-i-S"
    }
    default {
        puts "❌ 지원되지 않는 보드 이름: $board_name"
        puts "   지원되는 보드: zcu111, zcu208, versal"
        exit 1
    }
}
puts "  매핑된 파트: $part_name"

# --- 3. 경로 및 파일 설정 ---
# 이 Tcl 스크립트가 실행되는 위치를 기준으로 경로 설정
set script_dir [file dirname [info script]]
set src_dir [file normalize "$script_dir/src"]
set tb_dir [file normalize "$script_dir/tb"]

# 프로젝트가 생성될 위치
set project_dir [file normalize "$script_dir/$project_name"]

puts "--- 파일 검색 ---"
# Verilog, SystemVerilog, VHDL, Verilog Headers
set src_files [glob -nocomplain -directory $src_dir *.{v,sv,vhd,vh}]
# TB 파일
set tb_files [glob -nocomplain -directory $tb_dir *.{v,sv,vhd}]

if {[llength $src_files] == 0} {
    puts "(!) 경고: 'src' 디렉토리에서 디자인 소스를 찾을 수 없습니다."
}
if {[llength $tb_files] == 0} {
    puts "(!) 경고: 'tb' 디렉토리에서 시뮬레이션 소스를 찾을 수 없습니다."
}

# --- 4. Vivado 프로젝트 생성 ---
puts "--- 프로젝트 생성 시작: $project_name ---"

# 1. 프로젝트 디렉토리 생성 및 프로젝트 생성 (파트 이름 직접 사용)
file mkdir $project_dir
create_project -force $project_name $project_dir -part $part_name

# 2. 디자인 소스 추가 (src 폴더)
if {[llength $src_files] > 0} {
    puts "  디자인 소스 추가 (src)..."
    add_files -fileset sources_1 -norecurse $src_files
}

# 3. 시뮬레이션 소스 추가 (tb 폴더)
if {[llength $tb_files] > 0} {
    puts "  시뮬레이션 소스 추가 (tb)..."
    add_files -fileset sim_1 -norecurse $tb_files
}

# 4. 컴파일 순서 업데이트
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "--- 프로젝트 생성 완료: $project_dir/$project_name.xpr ---"
close_project
puts "--- Vivado 종료 ---"
