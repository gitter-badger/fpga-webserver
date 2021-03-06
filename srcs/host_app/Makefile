###############################
#                             #
# Makefile for SDAccel 2017.1 #
#                             #
###############################

XOCC=xocc
CC=g++

#Host code
HOST_SRC=./server_main.c ./kernel.c ./lodepng.c ./utility.c
HOST_HDRS=
HOST_CFLAGS=-D FPGA_DEVICE -g -Wall -I${XILINX_SDX}/runtime/include/1_2 -O3 -Wall -D C_KERNEL -D SDX_PLATFORM -D KERNEL=${KERNEL_NAME}
HOST_LFLAGS=-L${XILINX_SDX}/runtime/lib/x86_64 -lxilinxopencl

#Name of host executable
HOST_EXE=host

#Kernel
KERNEL_SRC=
KERNEL_HDRS=
KERNEL_FLAGS=
KERNEL_EXE=$(KERNEL)
KERNEL_NAME=$(KERNEL)

#Custom flag to give to xocc
KERNEL_LDCLFLAGS=--nk $(KERNEL_NAME):1 \
	--xp param:compiler.preserveHlsOutput=1 \
	--max_memory_ports $(KERNEL_NAME) \
	--memory_port_data_width $(KERNEL_NAME):512 \

KERNEL_ADDITIONAL_FLAGS=

#Device to be used
TARGET_DEVICE=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0

#Check if environment is an AWS one or not
ifndef AWS_PLATFORM
$(info setting platform for a non-aws environment)
PLATFORM=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0
else
$(info setting platform for an aws environment)
PLATFORM=${AWS_PLATFORM}
endif

#TARGET for compilation [sw_emu | hw_emu | hw]
TARGET=none
REPORT_FLAG=n
REPORT=
ifeq (${TARGET}, sw_emu)
$(info software emulation)
TARGET=sw_emu
else ifeq (${TARGET}, hw_emu)
$(info hardware emulation)
TARGET=hw_emu
REPORT=--report estimate
else ifeq (${TARGET}, hw)
$(info system build)
TARGET=hw
REPORT=--report system
else
$(info no TARGET selected)
endif

#Translation of Target Device name with underscores
PERIOD:= :
UNDERSCORE:= _
dest_dir=$(TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))

ifndef XILINX_SDX
$(error XILINX_SDX is not set. Please source the SDx settings64.{csh,sh} first)
endif

clean:
	rm -rf .Xil emconfig.json 

clean_sw_emu: clean
	rm -rf sw_emu
clean_hw_emu: clean
	rm -rf hw_emu
clean_hw: clean
	rm -rf hw

cleanall: clean_sw_emu clean_hw_emu clean_hw
	rm -rf _xocc_* xcl_design_wrapper_*

check_TARGET:
ifeq (${TARGET}, none)
	$(error Target can not be set to none)
endif

host:  check_TARGET $(HOST_SRC) $(HOST_HDRS)
	mkdir -p $(dest_dir)
	$(CC) $(HOST_SRC) $(HOST_HDRS) $(HOST_CFLAGS) $(HOST_LFLAGS) -o $(dest_dir)/$(HOST_EXE)

xo:	check_TARGET
	mkdir -p $(dest_dir)
	$(XOCC) --platform $(PLATFORM) --target $(TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(dest_dir)/$(KERNEL_EXE).xo

xclbin:  check_TARGET
	cp $(KERNEL_EXE).xo $(dest_dir)/$(KERNEL_EXE).xo
	$(XOCC) -g --platform $(PLATFORM) --target $(TARGET) --link --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(dest_dir)/$(KERNEL_EXE).xo $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(dest_dir)/$(KERNEL_EXE).xclbin

emulation:  host xclbin
	export XCL_EMULATION_MODE=$(TARGET) && ./$(dest_dir)/$(HOST_EXE) $(dest_dir)/$(KERNEL_EXE).xclbin
	$(info Remeber to export XCL_EMULATION_MODE=$(TARGET) and run emcondigutil for emulation purposes)

build:  host xclbin

run_system:  build
	./$(dest_dir)/$(HOST_EXE) $(dest_dir)/$(KERNEL_EXE)
