#!/usr/bin/env python3
"""
Compare internal variables between Python and SPICE simulations
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d

# Define output directory
OUTPUT_DIR = "/foss/designs/Capibara_tuto/MEMS/tmp"

def load_python_data(filename=None):
    """Load Python simulation results"""
    if filename is None:
        filename = f"{OUTPUT_DIR}/python_results.txt"
    print(f"Loading Python data from {filename}...")
    data = np.loadtxt(filename,skiprows=1)
    
    result = {
        'time': data[:, 0],
        'V_input': data[:, 1],
        'Vm': data[:, 2],
        'X': data[:, 3],
        'G_uS': data[:, 4],
        'Im_uA': data[:, 5],
        'Is_uA': data[:, 6],
        'I': data[:, 7]
    }
    
    print(f"  Loaded {len(result['time'])} samples")
    print(f"  Time range: {result['time'][0]*1e3:.3f} to {result['time'][-1]*1e3:.3f} ms")
    return result

def load_spice_data(filename=None):
    """Load SPICE simulation results"""
    if filename is None:
        filename = f"{OUTPUT_DIR}/spice_results.txt"
    print(f"\nLoading SPICE data from {filename}...")
    
    try:
        data = np.loadtxt(filename, skiprows=1)
    except:
        print("ERROR: Could not load SPICE data.")
        print("Make sure to run the SPICE simulation first!")
        return None
    
    result = {
        'time': data[:, 0],
        'V_input': data[:, 1],
        'Vm': data[:, 2],
        'X': data[:, 3],
        'G_uS': data[:, 4],
        'Im_uA': data[:, 5],
        'Is_uA': data[:, 6],
        'I': data[:, 7]
    }
    
    print(f"  Loaded {len(result['time'])} samples")
    print(f"  Time range: {result['time'][0]*1e3:.3f} to {result['time'][-1]*1e3:.3f} ms")
    return result

def interpolate_to_common_time(py_data, spice_data):
    """Interpolate both datasets to common time points"""
    # Use Python time points as reference (usually denser)
    t_common = py_data['time']
    
    # Interpolate SPICE data to Python time points
    spice_interp = {}
    for key in ['V_input', 'Vm', 'X', 'G_uS', 'Im_uA', 'Is_uA', 'I']:
        f = interp1d(spice_data['time'], spice_data[key], 
                     kind='linear', fill_value='extrapolate')
        spice_interp[key] = f(t_common)
    
    return t_common, py_data, spice_interp

def calculate_errors(py_data, spice_interp, var_name):
    """Calculate error metrics between Python and SPICE"""
    py = py_data[var_name]
    sp = spice_interp[var_name]
    
    # Remove any NaN or Inf values
    mask = np.isfinite(py) & np.isfinite(sp)
    py = py[mask]
    sp = sp[mask]
    
    if len(py) == 0:
        return None
    
    # Calculate errors
    abs_error = np.abs(py - sp)
    rel_error = np.abs((py - sp) / (np.abs(py) + 1e-12)) * 100
    
    return {
        'max_abs': np.max(abs_error),
        'mean_abs': np.mean(abs_error),
        'rms': np.sqrt(np.mean(abs_error**2)),
        'max_rel': np.max(rel_error),
        'mean_rel': np.mean(rel_error)
    }

def plot_comparison(t_common, py_data, spice_interp):
    """Create comprehensive comparison plots"""
    fig, axes = plt.subplots(4, 2, figsize=(16, 12))
    fig.suptitle('Python vs SPICE Simulation Comparison', fontsize=16, fontweight='bold')
    
    variables = [
        ('X', 'State Variable X', ''),
        ('Vm', 'Voltage Vm', 'V'),
        ('G_uS', 'Conductance G', 'μS'),
        ('I', 'Total Current I', 'A'),
        ('Im_uA', 'Ohmic Current Im', 'μA'),
        ('Is_uA', 'Schottky Current Is', 'μA'),
        ('V_input', 'Input Voltage V', 'V')
    ]
    
    for idx, (var, title, unit) in enumerate(variables):
        row = idx // 2
        col = idx % 2
        ax = axes[row, col]
        
        # Plot both signals
        ax.plot(t_common * 1000, py_data[var], 'b-', label='Python', linewidth=2, alpha=0.7)
        ax.plot(t_common * 1000, spice_interp[var], 'r--', label='SPICE', linewidth=1.5, alpha=0.7)
        
        ax.set_xlabel('Time [ms]')
        ax.set_ylabel(f'{title} [{unit}]' if unit else title)
        ax.set_title(title)
        ax.legend()
        ax.grid(True, alpha=0.3)
        
        # Calculate and display error
        errors = calculate_errors(py_data, spice_interp, var)
        if errors:
            error_text = f"RMS error: {errors['rms']:.2e}\nMax rel: {errors['max_rel']:.2f}%"
            ax.text(0.02, 0.98, error_text, transform=ax.transAxes,
                   verticalalignment='top', bbox=dict(boxstyle='round', 
                   facecolor='wheat', alpha=0.5), fontsize=8)
    
    # Hysteresis comparison in last subplot
    ax = axes[3, 1]
    ax.plot(py_data['Vm'], py_data['I']*1e6, 'b-', label='Python', linewidth=2, alpha=0.7)
    ax.plot(spice_interp['Vm'], spice_interp['I']*1e6, 'r--', label='SPICE', linewidth=1.5, alpha=0.7)
    ax.set_xlabel('Vm [V]')
    ax.set_ylabel('I [μA]')
    ax.set_title('Hysteresis: I vs Vm')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/comparison_plots.png', dpi=150, bbox_inches='tight')
    print(f"\nComparison plots saved to: {OUTPUT_DIR}/comparison_plots.png")
    
    return fig

def print_error_summary(py_data, spice_interp):
    """Print summary of errors for all variables"""
    print("\n" + "="*70)
    print("ERROR SUMMARY")
    print("="*70)
    
    variables = ['X', 'Vm', 'G_uS', 'I', 'Im_uA', 'Is_uA']
    
    print(f"{'Variable':<10} {'Max Abs Error':<18} {'Mean Abs Error':<18} {'Max Rel Error':<15}")
    print("-"*70)
    
    for var in variables:
        errors = calculate_errors(py_data, spice_interp, var)
        if errors:
            print(f"{var:<10} {errors['max_abs']:<18.6e} {errors['mean_abs']:<18.6e} {errors['max_rel']:<14.2f}%")
    
    print("="*70)

def main():
    print("="*70)
    print("PYTHON vs SPICE MEMRISTOR SIMULATION COMPARISON")
    print("="*70)
    
    # Load data
    py_data = load_python_data()
    spice_data = load_spice_data()
    
    if spice_data is None:
        print("\nERROR: Cannot proceed without SPICE data.")
        print("Steps to generate SPICE data:")
        print("1. Open tb_monitor_comparison.sch in xschem")
        print("2. Run simulation (Netlist -> Simulate)")
        print(f"3. Data will be saved to {OUTPUT_DIR}/spice_results.txt")
        return
    
    # Interpolate to common time base
    print("\nInterpolating to common time base...")
    t_common, py_data, spice_interp = interpolate_to_common_time(py_data, spice_data)
    
    # Calculate and print errors
    print_error_summary(py_data, spice_interp)
    
    # Create comparison plots
    print("\nGenerating comparison plots...")
    fig = plot_comparison(t_common, py_data, spice_interp)
    
    # Show plots
    plt.show()
    
    print("\n" + "="*70)
    print("COMPARISON COMPLETE")
    print("="*70)
    print("\nFiles generated:")
    print(f"  - {OUTPUT_DIR}/python_results.txt      (Python simulation data)")
    print(f"  - {OUTPUT_DIR}/spice_results.txt       (SPICE simulation data)")
    print(f"  - {OUTPUT_DIR}/python_hysteresis.png   (Python hysteresis plot)")
    print(f"  - {OUTPUT_DIR}/comparison_plots.png    (Comparison plots)")

if __name__ == '__main__':
    main()
