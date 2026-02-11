v {xschem version=3.4.7 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
B 2 670 -1230 1470 -830 {flags=graph
y1=-0.00015
y2=0.00015
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=-0.5
x2=0.5
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"Hysteresis Im vs Vm; i(v2) -\\""
color=4
dataset=-1
unitx=1
logx=0
logy=0
linewidth_mult=3
digital=0
sweep=v(Vm_mon)}
B 2 -140 -810 660 -410 {flags=graph
y1=-0.00015
y2=0.00015
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.2
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
sweep=time
color=4
node="\\"Current Im [A]; i(v2) -\\""}
B 2 -150 -1230 650 -830 {flags=graph
y1=0
y2=1.1
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.2
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
color=6
node="\\"State Variable X; v(X_mon)\\""
linewidth_mult=2}
B 2 670 -810 1470 -410 {flags=graph
y1=0
y2=500000
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.2
divx=5
subdivx=1
dataset=-1
unitx=1
logx=0
logy=0
color=5
node="\\"Resistance Rm [Ohms]; v(Vm_mon) i(v2) / abs()\\""
linewidth_mult=2}
B 2 1510 -1230 2310 -830 {flags=graph
y1=0
y2=3
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.2
divx=5
subdivx=1
dataset=-1
unitx=1
logx=0
logy=0
color="4 5"
node="\\"Conductance G [uS]; v(G_mon)\\"
\\"1/R [uS]; v(Vm_mon) i(v2) / 1000000 /\\""
linewidth_mult=2}
B 2 1510 -810 2310 -410 {flags=graph
y1=-150
y2=150
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.2
divx=5
subdivx=1
dataset=-1
unitx=1
logx=0
logy=0
color="4 5 6"
node="\\"Im [uA]; v(Im_mon)\\"
\\"Is [uA]; v(Is_mon)\\"
\\"Itotal [uA]; i(v2) 1000000 *\\""
linewidth_mult=2}
N 130 -170 130 -110 {
lab=V_input}
N 130 -170 240 -170 {
lab=V_input}
N 130 70 490 70 {
lab=0}
N 130 -50 130 70 {
lab=0}
N 490 70 490 90 {
lab=0}
N 240 -170 240 -130 {
lab=V_input}
N 240 -70 240 -50 {
lab=Vm_mon}
N 240 -50 490 -50 {
lab=Vm_mon}
N 490 -50 490 -20 {
lab=Vm_mon}
N 490 60 490 70 {lab=0}
C {devices/gnd.sym} 490 90 0 0 {name=l2 lab=0}
C {devices/launcher.sym} 540 -190 0 0 {name=h1
descr="Load I-V" 
tclcommand="
set rawfile [file tail [file rootname [xschem get schname]]]
xschem raw_read $netlist_dir/$\{rawfile\}.raw
unset rawfile
"}
C {devices/code_shown.sym} 2350 -750 0 0 {name=NGSPICE
only_toplevel=true
value="
*================================================================
* Simulation setup - matches Python parameters
*================================================================
.options num_threads=8
.options method=gear
.options maxstep=2u
.options reltol=1e-4
.options abstol=1e-12

* Transient analysis
.tran 2u 200m

.control
	save all
	run
	write tb_monitor_comparison.raw
	
	* Export data for Python comparison
	set wr_singlescale
	set wr_vecnames
	option numdgt=15
	wrdata /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/spice_results.txt time v(V_input) v(Vm_mon) v(X_mon) v(G_mon) v(Im_mon) v(Is_mon) i(v2)
.endc
" }
C {devices/lab_wire.sym} 180 -170 0 0 {name=l3 sig_type=std_logic lab=V_input}
C {devices/code_shown.sym} 2350 -350 0 0 {name=MODELS2
only_toplevel=true
format="tcleval( @value )"
value="
*================================================================
* RRAM Model with Internal Variable Monitoring
*================================================================

.control
pre_osdi /foss/designs/Capibara_tuto/MEMS/rram_v1_with_monitors.osdi
.endc

*----------------------------------------------------------------
* Subcircuit with monitoring outputs
*----------------------------------------------------------------
.subckt rram_v1 TE BE X_OUT G_OUT VM_OUT IS_OUT IM_OUT
N1 TE BE X_OUT G_OUT VM_OUT IS_OUT IM_OUT rram_v1_model
.ends rram_v1

*----------------------------------------------------------------
* Model parameters (match Python exactly)
*----------------------------------------------------------------
.model rram_v1_model rram_v1_va 
+ x0=0.0
+ Ron=13e3
+ Roff=460e3
+ tau=6e-5
+ T=108.5
+ Von_threshold=0.2
+ Voff=-0.1
+ phi=0.88
+ Af=1e-7
+ Ar=1e-7
+ Bf=8
+ Br=8
"
spice_ignore=false}
C {devices/vsource.sym} 130 -80 0 1 {name=V2 value="SINE(0 0.4 10)"
spice_ignore=false}
C {rram_v1_monitor.sym} 490 20 2 0 {name=R1
model=rram_v1
spiceprefix=X
}
C {devices/lab_wire.sym} 490 -50 1 0 {name=l1 sig_type=std_logic lab=Vm_mon}
C {devices/res.sym} 240 -100 0 0 {name=Rs
value=10k
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} 450 50 2 0 {name=l5 sig_type=std_logic lab=X_mon}
C {devices/lab_wire.sym} 450 35 2 0 {name=l6 sig_type=std_logic lab=G_mon}
C {devices/lab_wire.sym} 450 20 2 0 {name=l7 sig_type=std_logic lab=Vm_mon}
C {devices/lab_wire.sym} 450 5 2 0 {name=l8 sig_type=std_logic lab=Is_mon}
C {devices/lab_wire.sym} 450 -10 2 0 {name=l9 sig_type=std_logic lab=Im_mon}
C {devices/title.sym} 140 200 0 0 {name=l10 author="Comparison: Python vs SPICE Internal Variables"}
