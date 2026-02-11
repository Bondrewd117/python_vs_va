#!/usr/bin/env python3
#******************************************************************
# Stochastic simulator for Knowm memristor based on the GMMS model
# Modified to export internal variables for comparison with SPICE
#******************************************************************

import sys
import matplotlib.pyplot as plt
import numpy as np

if __name__ == '__main__':
    print("Simulating Knowm memristor and exporting data...")

    # Physical constants
    q = 1.6e-19  # Elementary charge
    k = 1.3e-23  # Boltzmann's constant

    # Constants for the GMMS model
    A_f = 1e-7
    A_r = 1e-7
    B_f = 8
    B_r = 8
    phi = 0.88

    # Simulation parameters
    Ron = 13000     # ON state resistance
    Roff = 460000   # OFF state resistance
    Tao = 0.00006   # Memristor time constant (60us)
    SamplesByTao = 30  # Implicit sampling resolution
    T = 108.5       # Temperature in Kelvin
    Rs = 10000      # Resistor in series with the memristor
    Vp = 0.4        # Input peak voltage
    Reseted = True  # Initial state of the memristor

    # Threshold voltages (non-stochastic)
    Voff = -0.1
    Von_threshold = 0.2

    # Working variables for simulation
    dt = Tao / SamplesByTao  # Sampling period (2us)
    dt2Tao = dt / Tao
    epsilon = q / (k * T)
    
    t = np.arange(0.0, 0.18, dt)  # Time vector
    size = len(t)
    V = Vp * np.sin(2 * np.pi * 10 * t)  # 10Hz sinusoidal signal

    # Vectors for all variables
    X = np.zeros(size)   # State variable
    G = np.zeros(size)   # Conductance
    I = np.zeros(size)   # Total current
    Vm = np.zeros(size)  # Voltage across memristor
    Im = np.zeros(size)  # Ohmic current
    Is = np.zeros(size)  # Schottky current
    Von = np.zeros(size) # Dynamic Von threshold
    R = np.zeros(size)   # Resistance

    # Initial condition
    if Reseted:
        X[0] = 0.0
        G[0] = 1.0 / Roff
    else:
        X[0] = 1.0
        G[0] = 1.0 / Ron

    print(f"Simulation parameters:")
    print(f"  dt = {dt*1e6:.2f} us")
    print(f"  Samples = {size}")
    print(f"  Duration = {t[-1]*1000:.1f} ms")
    print(f"  Rs = {Rs/1000:.1f} kOhm")
    print(f"  Vp = {Vp} V")
    print(f"  x0 = {X[0]}")

    # Main simulation loop
    for i in range(1, size):
        # Voltage divider
        if G[i-1] != 0.0:
            Rm = 1.0 / G[i-1]
        else:
            Rm = sys.float_info.max
        
        # Store resistance
        R[i] = Rm
        
        # Calculate currents and voltages BEFORE Schottky adjustment
        I[i] = V[i] / (Rm + Rs)
        Vm[i] = V[i] * Rm / (Rm + Rs)
        
        # Store ohmic current BEFORE Schottky
        Im[i] = G[i-1] * Vm[i]

        # Update state variable (MMS model)
        sqrtX = np.sqrt(X[i-1])
        Von[i] = Von_threshold + (0.1 * np.cos(4 * np.pi * sqrtX / (1.7 - X[i-1]))) / (1 + 10 * sqrtX)
        
        Poff_on = 1.0 / (1.0 + np.exp(-epsilon * (Vm[i] - Von[i])))
        Pon_off = 1.0 - (1.0 / (1.0 + np.exp(-epsilon * (Vm[i] - Voff))))
        
        X[i] = dt2Tao * (Poff_on * (1 - X[i-1]) - Pon_off * X[i-1]) + X[i-1]
        G[i] = (X[i] / Ron) + ((1 - X[i]) / Roff)

        # Schottky diode effect adjustment (GMMS model)
        Is[i] = A_f * np.exp(B_f * Vm[i]) - A_r * np.exp(B_r * Vm[i])
        I[i] = phi * I[i] + (1.0 - phi) * Is[i]
        Vm[i] = V[i] - Rs * I[i]  # Adjust Vm after Schottky
        
        # Adjust conductance
        if abs(Vm[i]) > 1e-9:
            G[i] += Is[i] / Vm[i]

    # Export data to file
    output_dir = "/foss/designs/Capibara_tuto/MEMS/tmp"
    print(f"\nExporting data to {output_dir}/python_results.txt...")
    
    # Create data array matching SPICE format
    # Columns: time, V_input, Vm, X, G(uS), Im(uA), Is(uA), I(A)
    data = np.column_stack((
        t,                # time
        V,                # V_input
        Vm,               # Vm (after Schottky adjustment)
        X,                # X (state variable)
        G * 1e6,          # G in microsiemens
        Im * 1e6,         # Im in microamps
        Is * 1e6,         # Is in microamps
        I                 # I in amps
    ))
    
    # Save with header
    header = "time V_input Vm X G_uS Im_uA Is_uA I"
    np.savetxt(f'{output_dir}/python_results.txt', data, 
               header=header, comments='',
               fmt='%.15e')
    
    print(f"Data exported: {size} samples")
    print(f"File: {output_dir}/python_results.txt")
    
    # Print some statistics
    print(f"\nStatistics:")
    print(f"  X:  min={X.min():.4f}, max={X.max():.4f}, final={X[-1]:.4f}")
    print(f"  Vm: min={Vm.min():.4f}V, max={Vm.max():.4f}V")
    print(f"  I:  min={I.min()*1e6:.2f}uA, max={I.max()*1e6:.2f}uA")
    print(f"  R:  min={R.min()/1000:.1f}kOhm, max={R.max()/1000:.1f}kOhm")

    # Plot hysteresis
    plt.figure(figsize=(10, 6))
    plt.plot(Vm, I*1e6, 'b-', linewidth=2)
    plt.xlabel('Vm [Volts]')
    plt.ylabel('Im [μA]')
    plt.title('Hysteresis: Python Simulation')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/python_hysteresis.png', dpi=150)
    print(f"\nPlot saved: {output_dir}/python_hysteresis.png")
    
    plt.show()

    print("\nDone! Ready for comparison with SPICE results.")
