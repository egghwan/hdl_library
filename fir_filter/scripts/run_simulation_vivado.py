import os
import subprocess
import platform
import sys
import glob
# import psutil  # --- 추가된 부분 ---

# pandas와 matplotlib는 현재 사용하지 않으므로 주석 처리
# import pandas as pd
# import matplotlib.pyplot as plt

# ============================================================
# 사용자 설정 (기존과 동일)
# ============================================================
PROJECT_DIR = "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter"
PROJECT_NAME = "fir_filter"
TCL_SCRIPT_NAME = "run_sim.tcl"
CLEANUP_DIR = "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/scripts"
SIM_DATA_DIR = "/home/kkh/Desktop/kkh/works/fpga_proj/fir_filter/MATLAB"
SIM_DATA_FILE = os.path.join(SIM_DATA_DIR, "sim_data.csv")
VIVADO_PATH = "vivado"

# ============================================================

# --- 수정된 함수 ---
# --- 강력하게 수정된 함수 ---
def is_vivado_project_open(project_dir, project_name):
    """
    프로젝트 Lock 파일 또는 실행 중인 프로세스를 확인하여 Vivado 프로젝트가 열려있는지 확인합니다.
    (1차: Lock 파일 확인, 2차: 프로세스 Command-line 및 작업 디렉토리 확인)
    """
    project_file_name = f'{project_name}.xpr'
    
    # 1. Lock 파일 확인 (가장 빠르고 안정적인 방법)
    lock_file_path = os.path.join(project_dir, '.Xil', f'{project_file_name}.lock')
    if os.path.exists(lock_file_path):
        print("✅ 확인 (1/2): Lock 파일이 존재합니다. 프로젝트가 열려있습니다.")
        return True

    # 2. 실행 중인 프로세스 확인 (Lock 파일이 없을 경우의 예비책)
    try:
        for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'cwd']):
            # Vivado 프로세스가 아니면 건너뛰기
            if 'vivado' not in proc.info['name'].lower():
                continue

            # 검사 2-1: Command-line 인자에 프로젝트 파일 이름이 있는지 확인
            if proc.info['cmdline'] and any(project_file_name in s for s in proc.info['cmdline']):
                print(f"✅ 확인 (2/2): 실행 인자에서 프로젝트({project_file_name})를 찾았습니다 (PID: {proc.info['pid']}).")
                return True

            # 검사 2-2: 프로세스의 현재 작업 디렉토리(CWD)가 프로젝트 디렉토리와 일치하는지 확인
            # (GUI에서 직접 프로젝트를 열었을 때를 위한 검사)
            if proc.info['cwd']:
                try:
                    if os.path.samefile(proc.info['cwd'], project_dir):
                        print(f"✅ 확인 (2/2): 프로세스의 작업 디렉토리가 프로젝트 폴더와 일치합니다 (PID: {proc.info['pid']}).")
                        return True
                except FileNotFoundError:
                    # CWD 경로가 유효하지 않은 경우 무시
                    pass

    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        # 일부 프로세스 정보 접근에 실패해도 무시하고 계속 진행
        pass

    print("ℹ️ 정보: 열려있는 프로젝트를 찾지 못했습니다. 새로 시작합니다.")
    return False
# --- 수정된 함수 ---
def generate_tcl_script(tcl_path, is_already_open, project_path=None):
    """상황에 맞는 Tcl 스크립트를 생성합니다."""
    print(f"📄 Tcl 스크립트 생성 중... -> {tcl_path}")

    if is_already_open:
        # 이미 열려있을 경우: 시뮬레이션 실행 및 종료만 수행 (백그라운드 실행)
        tcl_commands = f"""
puts "INFO: 이미 열려있는 GUI에서 시뮬레이션을 실행합니다."
launch_simulation
run all
puts "INFO: 시뮬레이션 완료. Tcl 스크립트를 종료합니다."
exit
"""
    else:
        # 새로 실행할 경우: 프로젝트 열기, 시뮬레이션 실행 후 대기
        tcl_commands = f"""
puts "INFO: 프로젝트 열기 -> {project_path}"
open_project {project_path}
puts "INFO: Behavioral Simulation 시작..."
launch_simulation
puts "INFO: 시뮬레이션 실행 (run all)..."
run all
puts "INFO: 시뮬레이션 완료. GUI 창을 닫으면 다음 단계가 진행됩니다."
"""
    try:
        with open(tcl_path, 'w') as f:
            f.write(tcl_commands)
        print("✅ Tcl 스크립트 생성 완료.")
    except IOError as e:
        print(f"❌ 에러: Tcl 스크립트 파일 생성에 실패했습니다. {e}")
        sys.exit(1)

# --- 수정된 함수 ---
def run_vivado_simulation(tcl_path, is_already_open):
    """생성된 Tcl 스크립트를 사용하여 Vivado를 실행합니다."""
    vivado_executable = VIVADO_PATH
    if platform.system() == "Windows" and not vivado_executable.endswith(".bat"):
        vivado_executable += ".bat"

    if is_already_open:
        print("\n🚀 이미 실행 중인 Vivado에 시뮬레이션 명령 전달...")
        # 백그라운드 Tcl 모드로 실행하여 기존 GUI에 영향
        command = [vivado_executable, "-mode", "tcl", "-source", tcl_path]
    else:
        print("\n🚀 Vivado 시뮬레이션 (GUI 모드) 실행...")
        # GUI 모드로 새로 실행
        command = [vivado_executable, "-mode", "gui", "-source", tcl_path]
    
    print(f"👉 실행할 명령어: {' '.join(command)}")

    try:
        # subprocess.run을 사용하여 프로세스가 끝날 때까지 대기
        result = subprocess.run(command, check=True, text=True, capture_output=True)
        # print("\n--- Vivado 출력 로그 ---")
        # print(result.stdout)
        # if result.stderr:
        #     print("\n--- Vivado 에러 로그 ---")
        #     print(result.stderr)
        print("\n✅ Vivado 스크립트 실행 완료.")
            
    except FileNotFoundError:
        print(f"❌ 에러: Vivado 실행 파일을 찾을 수 없습니다. '{VIVADO_PATH}'")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print("❌ 에러: Vivado 실행 중 오류가 발생했습니다.")
        print(e.stdout)
        print(e.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ 에러: 스크립트 실행 중 예외가 발생했습니다. {e}")
        sys.exit(1)

# cleanup_vivado_files 함수는 기존과 동일
def cleanup_vivado_files(directory):
    if not os.path.isdir(directory): return
    try:
        original_dir = os.getcwd()
        os.chdir(directory)
        files_to_remove = glob.glob("vivado*")
        for f in files_to_remove:
            try:
                os.remove(f)
            except OSError:
                pass
    finally:
        os.chdir(original_dir)

# plot_simulation_results 함수는 현재 사용하지 않음

# --- 수정된 main 함수 ---
# --- 수정된 main 함수 ---
def main():
    """메인 실행 함수"""
    project_file_path = os.path.join(PROJECT_DIR, f"{PROJECT_NAME}.xpr")
    tcl_script_path = os.path.join(PROJECT_DIR, TCL_SCRIPT_NAME)

    if not os.path.exists(project_file_path):
        print(f"❌ 치명적 에러: Vivado 프로젝트 파일을 찾을 수 없습니다! 경로: {project_file_path}")
        sys.exit(1)

    # --- 수정된 부분 ---
    # 이제 함수에 프로젝트 경로와 프로젝트 이름을 각각 전달합니다.
    
    # (이하 코드는 기존과 동일)
    #generate_tcl_script(tcl_script_path, project_is_open, project_file_path)
    
    run_vivado_simulation(tcl_script_path)
    
if __name__ == "__main__":
    main()
