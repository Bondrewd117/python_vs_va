v {xschem version=3.4.7 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
B 2 670 -1230 1470 -830 {flags=graph
y1=-3.7e-06
y2=3.7e-06
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=-0.66314875
x2=0.66314875
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="\\"Hysteresis Im vs Vm;0 i(v2) -\\""
color=4
dataset=-1
unitx=1
logx=0
logy=0
linewidth_mult=3
digital=0
sweep=v(TE)}
B 2 -140 -810 660 -410 {flags=graph
y1=-3.7e-06
y2=3.7e-06
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.18
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
sweep=time
color="7 4"
node="\\"Current Im; i(v2) -\\"
\\"Voltage Vm; v(Vm) 0.001 *\\""}
B 2 -150 -1230 650 -830 {flags=graph
y1=-6.2416667
y2=-4.8416667
ypos1=0
ypos2=2
divy=5
subdivy=4
unity=1
x1=0
x2=0.18
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
dataset=-1
unitx=1
logx=0
logy=0
color="6 5"
node="\\"Input V; v(V_input)\\"
\\"Vm across memristor; v(Vm)\\""
linewidth_mult=2}
B 2 670 -810 1470 -410 {flags=graph
y1=0
y2=480000
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=0.18
divx=5
subdivx=1
dataset=-1
unitx=1
logx=0
logy=0
color=4
node="\\"Resistance Rm; v(TE) i(v2) / abs()\\""}
N 130 -170 130 -110 {
lab=V_input}
N 130 -170 240 -170 {
lab=V_input}
N 130 70 490 70 {
lab=0}
N 130 -50 130 70 {
lab=0}
N 490 30 490 70 {
lab=0}
N 240 -170 240 -130 {
lab=V_input}
N 240 -70 240 -50 {
lab=TE}
N 240 -50 490 -50 {
lab=TE}
N 490 -50 490 -30 {
lab=TE}
C {devices/gnd.sym} 130 70 0 0 {name=l2 lab=0}
C {devices/launcher.sym} 540 -190 0 0 {name=h1
descr="Load I-V" 
tclcommand="
set rawfile [file tail [file rootname [xschem get schname]]]
xschem raw_read $netlist_dir/$\{rawfile\}.raw
unset rawfile
"}
C {devices/lab_wire.sym} 180 -170 0 0 {name=l3 sig_type=std_logic lab=V_input}
C {devices/vsource.sym} 130 -80 0 1 {name=V2 value="SINE(0 0.7 10)"
spice_ignore=false}
C {rram_v1.sym} 490 0 0 0 {name=R1
model=rram_v1
spiceprefix=X
}
C {devices/res.sym} 240 -100 0 0 {name=Rs
value=10k
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} 300 -50 0 0 {name=l4 sig_type=std_logic lab=TE}
C {devices/code_shown.sym} -100 180 0 0 {name=NGSPICE
only_toplevel=true
value="
.options num_threads=8 reltol=1e-4 abstol=1e-12
.tran 100u 200m
.control
	save all
	run
	write tb_liss_rram_v1.raw
.endc

" }
C {devices/code_shown.sym} 752.5 -332.5 0 0 {name=MODELS2
only_toplevel=true
format="tcleval( @value )"
value="
*MADE BY JORGE ALEJANDRO JUAREZ LORA IPN

.subckt rram_v1 TE BE
N1 TE BE rram_v1_model
.ends rram_v1

.model rram_v1_model rram_v1_va


.control
pre_osdi /foss/designs/Capibara_tuto/MEMS/rram_v1.osdi
.endc
"
spice_ignore=false}
