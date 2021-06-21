all: clean comp sim


comp:
	vcs -full64 +v2k \
	-debug_access+all \
	-timescale=1ns/1ns \
	-f ../filelist.f \
	-l com.log

sim:
	./simv -l sim.log

sim_g:
	./simv -gui

clean: 
	rm -rf csrc DVEfiles *.vpd simv simv* ucli.key vc_hdrs.h urg* *.log *.dump


