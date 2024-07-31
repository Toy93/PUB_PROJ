export PROJ_DIR  =  SHA256
TOP_NAME  = testbench
filelist  = 
SIMULATOR = vcs
tc        = base_test
seed      = 1000
dump_fsdb = 1
ccov      = 1
init      = 0
verbosity = 1
debug     = off
sim_way   = uvm
max_quit  = 10
SYNTHTBDIR=synth_tb

CMP_OPT=+v2k -full64 -sverilog +nospecify +notimingcheck +partcomp -j8 -fgp -debug_all -CFLAGS -DVCS -cm tgl \
	-timescale=1ns/1ps \
	-f ${filelist} \
	-P $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/novas.tab $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/pli.a \
	-l comp.log \
	-top ${TOP_NAME}

RUN_OPT=./simv -l run.log +UVM_TESTNAME=${tc} +seed=${seed} -deraceclockdata +UVM_MAX_QUIT_COUNT=$(max_quit)

ifeq (${SIMULATOR},vcs)
else ifeq (${SIMULATOR},irun)
endif

ifeq (${ccov},1)
	ifeq (${SIMULATOR},vcs)
		CMP_OPT+=-cm line+branch+cond+fsm+tgl\
				 -cm_dir ./ccov/${tc}.vdb

		RUN_OPT+=-cm line+branch+cond+fsm+tgl\
				 -cm_dir ./ccov/${tc}/${tc}.vdb\
				 -cm_name ${seed}_${tc}\
				 -cm_test ./ccov/${tc}/${seed}_${tc}
	else ifeq (${SIMULATOR},irun)
		CMP_OPT+=-cm line+branch+cond+fsm+tgl -debug_all
	endif
endif

ifeq (${debug}, on)
	CMP_OPT+=+define+DEBUG
endif

ifeq (${sim_way}, uvm)
	CMP_OPT+=+incdir+${UVM_HOME}/src\
			${UVM_HOME}/dpi/uvm_dpi.cc

	filelist=${DESIGN_ROOT}/${PROJ_DIR}/sim/src/filelist/filelist.f
else 
	filelist=${DESIGN_ROOT}/${PROJ_DIR}/rtl/filelist.f
endif

ifeq (${verbosity},0)
	RUN_OPT+=+UVM_VERBOSITY=UVM_NONE
else ifeq (${verbosity},1)
	RUN_OPT+=+UVM_VERBOSITY=UVM_LOW
else ifeq (${verbosity},2)
	RUN_OPT+=+UVM_VERBOSITY=UVM_MEDIUM
else ifeq (${verbosity},3)
	RUN_OPT+=+UVM_VERBOSITY=UVM_UVM_HIGH
else ifeq (${verbosity},4)
	RUN_OPT+=+UVM_VERBOSITY=UVM_FULL
else
	RUN_OPT+=+UVM_VERBOSITY=UVM_DEBUG
endif

ifeq (${dump_fsdb},1)
	CMP_OPT+=+define+DUMP_FSDB
	RUN_OPT+=+DUMP_FSDB
endif

all:
	#make clean
	make precomp
	make comp
	make run

precomp:
	cd ${SIM_HOME};\
	mkdir ${PROJ_DIR};\
	cd ${PROJ_DIR};\
	ln -sf ${filelist} .

comp:
	cd ${SIM_HOME}/${PROJ_DIR};\
	${SIMULATOR} ${CMP_OPT}

comp_vhdl:
	cd ${SIM_HOME}/${PROJ_DIR};\
	vhdlcom -vhdl08 -f ${filelist}

comp_vlog:
	cd ${SIM_HOME}/${PROJ_DIR};\
	${SIMULATOR} +v2k -full64 -sverilog +nospecify +notimingcheck +partcomp -j8 -fgp -debug_all -CFLAGS -DVCS -cm tgl /home/ICer/work/PROJ_HOME/HW/Design/CPU29/rtl/testbench.sv
run:
	cd ${SIM_HOME}/${PROJ_DIR};\
	${RUN_OPT}

check:
	check.pl ${SIM_HOME}/${PROJ_DIR}/run.log

spyglass:
	cd ${SIM_HOME}/${PROJ_DIR};\
	spyglass &

spy:
	cd ${SIM_HOME}/${PROJ_DIR};\
	spyglass -verilog \
	-enable_pass_exit_codes \
	-enableSV \
	-report moresimple \
	-wdir spyglass \
	+define+SYNTHESIS \
	+define+EMU_TB \
	+incdir+${SYNTHTBDIR} \
	-batch \
	-top top \
	-waiver synth_tb.swl \
	-templatedir /home/nvtools/engr/2014/12/31_04_57_36/nvtools/spyglass/nvidia-policies/SpyGlass-5.2.1.2 \
	-template Lint  \
	-f filelist.f &

clog:
	gvim ${SIM_HOME}/${PROJ_DIR}/comp.log

rlog:
	gvim ${SIM_HOME}/${PROJ_DIR}/run.log

verdi:
	cd ${SIM_HOME}/${PROJ_DIR};\
	verdi \
	-sv \
	-f ${filelist} \
	-ssf tb.fsdb \
	-top ${TOP_NAME} \
	-nologo \
	&

imc_merge_cov:
imc:

urg:
	cd ${SIM_HOME}/${PROJ_DIR};\
	urg -dir ./ccov/${tc}.vdb\
		-dir ./ccov/${tc}/${tc}.vdb\
		-dbname simv_merge.vdb\
		-noreport
dve:
	cd ${SIM_HOME}/${PROJ_DIR};\
	dve -mode64 -ccov -dir simv_merge.vdb &

.PHONY:all cmp verdi clean
clean:
	rm -rf ${SIM_HOME}/${PROJ_DIR};\

clean_sim_home:
	rm -rf ${SIM_HOME}/*
