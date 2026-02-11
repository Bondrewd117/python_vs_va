#!/bin/bash
#================================================================
# Master script to run complete Python vs SPICE comparison
#================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
WORK_DIR="/foss/designs/Capibara_tuto/MEMS"
SCRIPT_DIR="$(pwd)"
OUTPUT_DIR="/foss/designs/Capibara_tuto/MEMS/tmp"

# Create output directory if it doesn't exist
#mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  PYTHON vs SPICE MEMRISTOR COMPARISON - AUTOMATED WORKFLOW${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

#----------------------------------------------------------------
# Step 1: Setup and compile Verilog-A
#----------------------------------------------------------------
echo -e "${YELLOW}[Step 1/4] Compiling Verilog-A with monitoring...${NC}"

if [ ! -d "$WORK_DIR" ]; then
    echo -e "${RED}ERROR: Work directory not found: $WORK_DIR${NC}"
    exit 1
fi

cd "$WORK_DIR"

# Copy files
echo "  Copying rram_v1_with_monitors.va..."
cp "$SCRIPT_DIR/rram_v1_with_monitors.va" ./ 2>/dev/null || echo "  (already exists)"

echo "  Copying rram_v1_monitor.sym..."
cp "$SCRIPT_DIR/rram_v1_monitor.sym" ./ 2>/dev/null || echo "  (already exists)"

# Compile
echo "  Compiling to OSDI..."
if openvaf rram_v1_with_monitors.va -o rram_v1_with_monitors.osdi; then
    echo -e "  ${GREEN}✓ Compilation successful${NC}"
else
    echo -e "  ${RED}✗ Compilation failed${NC}"
    exit 1
fi

#----------------------------------------------------------------
# Step 2: Run Python simulation
#----------------------------------------------------------------
echo ""
echo -e "${YELLOW}[Step 2/4] Running Python simulation...${NC}"

cd "$SCRIPT_DIR"

if [ ! -f "simulate_and_export.py" ]; then
    echo -e "${RED}ERROR: simulate_and_export.py not found${NC}"
    exit 1
fi

#chmod +x simulate_and_export.py

if python3 simulate_and_export.py; then
    echo -e "  ${GREEN}✓ Python simulation complete${NC}"
    
    if [ -f "$OUTPUT_DIR/python_results.txt" ]; then
        PYLINES=$(wc -l < "$OUTPUT_DIR/python_results.txt")
        echo -e "  ${GREEN}✓ Data exported: $PYLINES lines${NC}"
    fi
else
    echo -e "  ${RED}✗ Python simulation failed${NC}"
    exit 1
fi

#----------------------------------------------------------------
# Step 3: Run SPICE simulation
#----------------------------------------------------------------
echo ""
echo -e "${YELLOW}[Step 3/4] Running SPICE simulation...${NC}"
echo -e "  ${BLUE}NOTE: This may take several minutes...${NC}"

# Check if testbench exists
if [ ! -f "tb_monitor_comparison.sch" ]; then
    echo -e "${RED}ERROR: tb_monitor_comparison.sch not found${NC}"
    exit 1
fi

# Generate netlist and run simulation
echo "  Generating netlist..."
cd "$WORK_DIR"

# Create a temporary SPICE file to run
cat > run_spice.cir << EOF
*================================================================
* Automated SPICE simulation for comparison
*================================================================

.control
pre_osdi $WORK_DIR/rram_v1_with_monitors.osdi
.endc

.options num_threads=8
.options method=gear
.options maxstep=2u
.options reltol=1e-4
.options abstol=1e-12

.subckt rram_v1 TE BE X_OUT G_OUT VM_OUT IS_OUT IM_OUT
N1 TE BE X_OUT G_OUT VM_OUT IS_OUT IM_OUT rram_v1_model
.ends

.model rram_v1_model rram_v1_va 
+ x0=0.0 Ron=13e3 Roff=460e3 tau=6e-5 T=108.5
+ Von_threshold=0.2 Voff=-0.1 phi=0.88
+ Af=1e-7 Ar=1e-7 Bf=8 Br=8

* Circuit
Vin V_input 0 SIN(0 0.4 10)
Rs V_input TE 10k
Xmem TE 0 X_mon G_mon Vm_mon Is_mon Im_mon rram_v1

.tran 2u 200m

.control
    save all
    run
    set wr_singlescale
    set wr_vecnames
    option numdgt=15
    wrdata $OUTPUT_DIR/spice_results.txt time v(V_input) v(Vm_mon) v(X_mon) v(G_mon) v(Im_mon) v(Is_mon) i(Vin)
    quit
.endc

.end
EOF

echo "  Running ngspice simulation..."
if ngspice -b run_spice.cir -o $OUTPUT_DIR/spice_sim.log > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ SPICE simulation complete${NC}"
    
    if [ -f "$OUTPUT_DIR/spice_results.txt" ]; then
        SPLINES=$(wc -l < "$OUTPUT_DIR/spice_results.txt")
        echo -e "  ${GREEN}✓ Data exported: $SPLINES lines${NC}"
    else
        echo -e "  ${RED}✗ No data file generated${NC}"
        echo "  Check $OUTPUT_DIR/spice_sim.log for errors"
        exit 1
    fi
else
    echo -e "  ${RED}✗ SPICE simulation failed${NC}"
    echo "  Check $OUTPUT_DIR/spice_sim.log for details"
    exit 1
fi

#----------------------------------------------------------------
# Step 4: Compare results
#----------------------------------------------------------------
echo ""
echo -e "${YELLOW}[Step 4/4] Comparing results...${NC}"

cd "$SCRIPT_DIR"

if [ ! -f "compare_simulations.py" ]; then
    echo -e "${RED}ERROR: compare_simulations.py not found${NC}"
    exit 1
fi

chmod +x compare_simulations.py

if python3 compare_simulations.py; then
    echo -e "  ${GREEN}✓ Comparison complete${NC}"
else
    echo -e "  ${RED}✗ Comparison failed${NC}"
    exit 1
fi

#----------------------------------------------------------------
# Summary
#----------------------------------------------------------------
echo ""
echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}  ✓ ALL STEPS COMPLETED SUCCESSFULLY${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""
echo "Generated files:"
echo "  • $OUTPUT_DIR/python_results.txt      - Python simulation data"
echo "  • $OUTPUT_DIR/spice_results.txt       - SPICE simulation data"
echo "  • $OUTPUT_DIR/python_hysteresis.png   - Python hysteresis plot"
echo "  • $OUTPUT_DIR/comparison_plots.png    - Complete comparison plots"
echo ""
echo -e "${GREEN}Open $OUTPUT_DIR/comparison_plots.png to view results!${NC}"
echo ""

# Offer to open the plot
if command -v xdg-open &> /dev/null; then
    read -p "Open comparison plots? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open $OUTPUT_DIR/comparison_plots.png &
    fi
fi
