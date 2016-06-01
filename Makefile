PREFIX_ARM = arm-none-eabi
COMPILER = gcc

# Microcontroller properties.
PART=LM4F120H5QR
CPU=-mcpu=cortex-m4
FPU=-mfpu=fpv4-sp-d16 -mfloat-abi=softfp

# Program name definition for ARM GNU C compiler.
CC      = ${PREFIX_ARM}-gcc
# Program name definition for Rust compiler
RUSTC   = rustc
RUSTSHA1=$(shell rustc --version -v | sed -n 's|commit-hash: *\(.*\)|\1|p')
# Program name definition for ARM GNU Linker.
LD      = ${PREFIX_ARM}-ld
# Program name definition for ARM GNU Object copy.
CP      = ${PREFIX_ARM}-objcopy
# Program name definition for ARM GNU Object dump.
OD      = ${PREFIX_ARM}-objdump

# Option arguments for C compiler.
CFLAGS=-mthumb ${CPU} ${FPU} -O0 -ffunction-sections -fdata-sections -MD -std=c99 -Wall -pedantic -c -g
# Library stuff passed as flags!
CFLAGS+= -I ${STELLARISWARE_PATH} -DPART_$(PART) -c -DTARGET_IS_BLIZZARD_RA1

RUSTFLAGS = -C opt-level=2 -Z no-landing-pads
RUSTFLAGS+= --target thumbv7m-none-eabi -g --emit obj
RUSTFLAGS+= -L .

PROJECT_NAME = main

LINKER_FILE = freertos_demo.ld

# Flags for LD
LFLAGS  = --gc-sections

# Flags for objcopy
CPFLAGS = -Obinary

# flags for objectdump
ODFLAGS = -S

LIBS := libdriver.a libfreertos_demo.a
OBJS := main.o


all: ${PROJECT_NAME}.axf ${PROJECT_NAME}

libs: libcore.rlib $(LIBS) 

${PROJECT_NAME}.axf: libs $(OBJS)
	@echo
	@echo Linking...
	$(LD) -T $(LINKER_FILE) $(LFLAGS) -o ${PROJECT_NAME}.axf $(OBJS) $(LIBS)

${PROJECT_NAME}: ${PROJECT_NAME}.axf
	@echo
	@echo Copying...
	$(CP) $(CPFLAGS) ${PROJECT_NAME}.axf ${PROJECT_NAME}.bin
	@echo
	@echo Creating list file...
	$(OD) $(ODFLAGS) ${PROJECT_NAME}.axf > ${PROJECT_NAME}.lst

%.o: %.c
	@echo
	@echo Compiling $<...
	$(CC) -c $(CFLAGS) ${<} -o ${@}

%.o: %.rs
	@echo
	@echo Compiling $<...
	$(RUSTC) $(RUSTFLAGS) -o ${@} ${<}

# src/examples/boards/ek-tm4c123gxl/drivers/


libfreertos_demo.a:
	@echo
	@echo Compiling $@...
	@make -C src/examples/boards/ek-tm4c123gxl/freertos_demo
	@cp src/examples/boards/ek-tm4c123gxl/freertos_demo/${COMPILER}/libfreertos_demo.a .

libcore.rlib:
	@echo
	@echo Compiling $@...
	@echo Checking out rust commit: $(RUSTSHA1)
	@cd rust && git checkout $(RUSTSHA1)
	@echo
	@echo Building rust libcore ...
	@$(RUSTC) -C opt-level=2 -Z no-landing-pads --target thumbv7m-none-eabi -g rust/src/libcore/lib.rs

libdriver.a:
	make -C src/driverlib
	cp src/driverlib/${COMPILER}/libdriver.a .


