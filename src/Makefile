all: clean comp sim

OUTPUT=tb_counter

comp:
	vcs -full64 +v2k \
	-debug_access+all \
	-timescale=1ns/1ns \
	-f ../filelist.f \
	-l com.log -q

sim:
	./simv -l sim.log -q

sim_g:
	./simv -gui

clean: 
	rm -rf csrc DVEfiles *.vpd simv simv* ucli.key vc_hdrs.h urg* *.log *.dump


