# VHDL Assignment-2

디지털논리회로설계 · 2022042251 · Donghan Kim

강의자료 `VHDL_1.pdf` 22페이지의 문제 1~5를 구현했습니다.

## 제출 파일

| 문제 | VHDL 소스 | Logisim 프로젝트 |
|---|---|---|
| 1. 4-input AND / OR | [logic_test.vhd](src/logic_test.vhd) | [logi_test.circ](circuits/logi_test.circ) |
| 2. 8-to-1 MUX | [mux8_1.vhd](src/mux8_1.vhd) | [mux8_1.circ](circuits/mux8_1.circ) |
| 3. 7-Segment 문자 a,b,c,d,f,g | [seg7_letters.vhd](src/seg7_letters.vhd) | [segment.circ](circuits/segment.circ) |
| 4. 25-person Voting Machine | [vote25.vhd](src/vote25.vhd) | [vote.circ](circuits/vote.circ) |
| 5. 13-bit Voting Count + Display | [vote13_display.vhd](src/vote13_display.vhd) | [vote13_display.circ](circuits/vote13_display.circ) |

- [PDF 보고서](report.pdf): 회로 설명, 전체 VHDL 코드, Logisim 실험 캡처, 검증 결과
- [실험 캡처](screenshots/)
- [컴파일 로그](validation/compile.log), [시뮬레이션 로그](validation/simulation.log)
- [자동 검증 테스트벤치](validation/tb_assignment2.vhd)

## 실행 환경과 동작

Logisim-evolution 5.0.0, Questa Altera Starter FPGA Edition 2025.2, VHDL-2002를 사용했습니다.
Logisim에서 각 `.circ`를 열고 Questa 경로를 설정한 뒤 `Simulate > VHDL Simulation Enabled`를 켭니다.
프로젝트의 `main` 회로에서 입력 핀을 변경하여 결과를 확인할 수 있습니다.
각 프로젝트에는 이전 실습에서 사용한 VHDL 엔티티가 함께 포함될 수 있습니다.

7-Segment 출력 비트 순서는 `a b c d e f g dp`이며, `1`일 때 켜집니다.
문제 4는 찬성표가 **13개 이상**일 때 `result=1`입니다.
문제 5는 `en=0`일 때 모든 세그먼트를 끄고, `en=1`일 때 찬성 수를 표시합니다.
13비트 입력에서 찬성 수는 최대 13이므로 E(14)와 F(15)는 발생하지 않습니다.

## 자동 검증 결과

2026-10-29 Questa에서 소스 5개와 테스트벤치를 컴파일했으며 오류 0개, 경고 0개였습니다.
시뮬레이션 **19,106개 테스트가 모두 통과**했습니다.

- AND/OR: 전체 16개 입력 조합
- MUX: 256개 데이터 패턴 × 8개 선택값 = 2,048개
- 문자 표시: 6개 문자 및 2개 공백 선택값 = 8개
- 25인 투표기: 찬성 수 0~25 × 25개 순환 위치 = 650개
- 13인 투표 수 표시: 전체 8,192개 입력 × enable 2개 상태 = 16,384개

25인 투표기는 2^25개 전체 패턴을 전수 검사한 것이 아니라, 모든 찬성 수와 순환 위치를 검사했습니다.
테스트벤치는 VHDL 출력 값을 검사하며, Logisim의 실제 표시 및 연결은 실험 캡처와 별도로 확인했습니다.

## Questa에서 검증 재실행

Questa 실행 파일이 PATH에 있는 상태에서 저장소 루트에서 실행합니다.
다른 Questa/Logisim 시뮬레이션이 같은 단일 세션 라이선스를 사용 중이면 먼저 해당 시뮬레이션을 중지합니다.

```text
vlib work
vcom -2002 -work work src/logic_test.vhd src/mux8_1.vhd src/seg7_letters.vhd src/vote25.vhd src/vote13_display.vhd validation/tb_assignment2.vhd
vsim -c -onfinish stop work.tb_assignment2 -do validation/run.do
```

정상 종료 시 `ALL TESTS PASSED: 19106 cases`가 표시됩니다.
