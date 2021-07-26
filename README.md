# ARMprocessor

## Description

5-stage Pipelined ARM-reduced Processor Design

## Environment

Verilog-HDL을 기반으로 Quartus 2 Web Edition을 이용해 개발

ARM_System.vmf 프로젝트를 열어서 사용

FPGA 보드에 연결해 전자시계 기능 사용 가능

## Modules

`Instruction_Fetch`

5-stage 중 IF 단계와 PC 업데이트를 담당하는 모듈

`ctrlSig`

주어진 instD와 NZCV값을 토대로 여러 control signal들을 생성하는 모듈

`Instruction_Decode`

5-stage 중 ID 단계를 담당하는 모듈

`Hazard_Unit`

여러 hazard에 대비한 control signal들을 만드는 모듈

`ARMCPU`

+ ExtendMUX : 
Immediate value에 해당 하는 부분을 읽어 signed 혹은 unsigend extension을 해주는 모듈

+ RegisterFile : 
레지스터에 값을 저장하고 반환해주는 모듈

`IDEX_Register`

ID 단계에서 사용된 여러 control signal들과 변수들의 값을 EXE 단계로 넘기는 데에 사용되는 파이프라인 레지스터

`ALU_MUX`

EXE 단계에서 사용되는 ALU32bit 모듈에 들어갈 두 피연산자 SrcA와 SrcB를 결정하는 모듈

`ALU32bit`

EXE 단계에서 사용되는 ALU 연산을 해주는 모듈

`Cond_Unit`

ALU 연산 결과에 따라 NZCV 값을 업데이트 해주는 모듈

`EXMEM_Register`

EXE 단계에서 사용된 여러 control signal들과 변수들의 값을 MEM 단계로 넘기는 데에 사용되는 파이프라인 레지스터

`MEM`

MEM 단계에서 메모리에 쓰거나 메모리로부터 데이터를 읽어오기 위한 arm_cpu 모듈의 output 값을 설정해주는 모듈

`MEMWB`

MEM 단계에서 사용된 여러 control signal들과 변수들의 값을 WB 단계로 넘기는 데에 사용되는 파이프라인 레지스터

`WriteBack`

WB 단계에서 레지스터에 사용할 값을 결정하는 모듈
