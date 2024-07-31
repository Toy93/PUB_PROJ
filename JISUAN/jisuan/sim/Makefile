TOP_NAME = jisuan
export LOCAL_HOME := ${VERIFY_ROOT}/UT/${TOP_NAME}/src
CMP_OPT =
RUN_OPT = 
SIMULATOR = vcs
tc=base_test
seed=1000
dump_fsdb=1
cov=0
init=0

CMP_OPT=+v2k -full64 -sverilog +nospecify +notimingcheck +partcomp -j8 -fgp -debug_all -CFLAGS -DVCS -cm tgl \
	-timescale=1ns/1ps \
	$(UVM_HOME)/src/uvm_pkg.sv \
	$(UVM_HOME)/src/uvm_macros.svh \
	$(UVM_HOME)/src/dpi/uvm_dpi.cc \
	-f ${LOCAL_HOME}/filelist/filelist.f \
	-P $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/novas.tab $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/pli.a \
	-l comp.log \
	-top testbench 

RUN_OPT=./simv -l sim.log +UVM_TESTNAME=${tc} +seed=${seed}

ifeq (${SIMULATOR},vcs)
else ifeq (${SIMULATOR},irun)
endif

ifeq (${cov},1)
	ifeq (${SIMULATOR},vcs)
		CMP_OPT+=-cm line+branch+cond+fsm+tgl\
				 -cm_dir ./cov/${tc}.vdb

		RUN_OPT+=-cm line+branch+cond+fsm+tgl\
				 -cm_dir ./cov/${tc}/${tc}.vdb\
				 -cm_name ${seed}_${tc}\
				 -cm_test ./cov/${tc}/${seed}_${tc}
	else ifeq (${SIMULATOR},irun)
		CMP_OPT+=-cm line+branch+cond+fsm+tgl -debug_all
	endif
endif

ifeq (${dump_fsdb},1)
	RUN_OPT+=+DUMP_FSDB
endif


all:
	make clean
	make comp
	make run
comp:
	${SIMULATOR} ${CMP_OPT}

run:
	${RUN_OPT}
verdi:
	verdi \
	-sv \
	-f ${LOCAL_HOME}/filelist/filelist.f \
	-ssf tb.fsdb \
	-top testbench \
	-nologo \
	&

check:
imc_merge_cov:
imc:

urg:
	urg -dir ./cov/${tc}.vdb\
		-dir ./cov/${tc}/${tc}.vdb\
		-dbname simv_merge.vdb\
		-noreport
dve:
	dve -mode64 -cov -dir simv_merge.vdb &

.PHONY:all cmp verdi clean
clean:
	ls |grep -v Makefile|xargs rm -rf
