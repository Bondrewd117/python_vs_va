# Guía de Comparación Python vs SPICE - Variables Internas del Memristor

## Archivos Generados

### 1. Código Verilog-A con Monitoreo
- **rram_v1_with_monitors.va** - Versión del memristor que exporta variables internas
  - Nodos adicionales: X_OUT, G_OUT, VM_OUT, IS_OUT, IM_OUT
  - Estos nodos exponen las variables internas como voltajes

### 2. Símbolo xschem
- **rram_v1_monitor.sym** - Símbolo actualizado con 5 pines adicionales de salida

### 3. Testbench xschem
- **tb_monitor_comparison.sch** - Testbench completo que conecta todos los monitores
  - Exporta automáticamente datos a `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/spice_results.txt`

### 4. Scripts Python
- **simulate_and_export.py** - Ejecuta simulación Python y exporta datos
- **compare_simulations.py** - Compara y grafica ambas simulaciones

## Procedimiento Completo

### Paso 1: Compilar el Verilog-A con Monitoreo

```bash
cd /foss/designs/Capibara_tuto/MEMS/

# Copiar el nuevo archivo Verilog-A
cp rram_v1_with_monitors.va ./

# Compilar a OSDI
openvaf rram_v1_with_monitors.va -o rram_v1_with_monitors.osdi
```

### Paso 2: Copiar el Símbolo

```bash
# Copiar el nuevo símbolo
cp rram_v1_monitor.sym /foss/designs/Capibara_tuto/MEMS/
```

### Paso 3: Ejecutar Simulación Python

```bash
# Hacer ejecutable
chmod +x simulate_and_export.py

# Ejecutar
python3 simulate_and_export.py
```

**Salida esperada:**
- `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/python_results.txt` - Datos de la simulación
- `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/python_hysteresis.png` - Gráfica de histéresis

### Paso 4: Ejecutar Simulación SPICE

```bash
# Abrir xschem
xschem tb_monitor_comparison.sch &

# En xschem:
# 1. Netlist -> Simulate
# 2. Esperar a que termine la simulación
# 3. Los datos se guardan automáticamente en /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/spice_results.txt
```

**Nota**: La simulación SPICE puede tardar varios minutos debido al pequeño paso de tiempo (2μs).

### Paso 5: Comparar Resultados

```bash
# Hacer ejecutable
chmod +x compare_simulations.py

# Ejecutar comparación
python3 compare_simulations.py
```

**Salida esperada:**
- Tabla de errores en consola
- `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/comparison_plots.png` - Gráficas comparativas
- Ventana interactiva con todas las gráficas

## Variables Comparadas

| Variable | Descripción | Unidades |
|----------|-------------|----------|
| **X** | Variable de estado | 0-1 |
| **G** | Conductancia total | μS |
| **Vm** | Voltaje en memristor | V |
| **Im** | Corriente óhmica | μA |
| **Is** | Corriente Schottky | μA |
| **I** | Corriente total | A |
| **V_input** | Voltaje de entrada | V |

## Interpretación de Errores

### Errores Típicos Esperados

```
Variable   Max Abs Error      Mean Abs Error     Max Rel Error
--------------------------------------------------------------------
X          < 0.01             < 0.001            < 5%
Vm         < 0.01 V           < 0.001 V          < 2%
G          < 0.1 μS           < 0.01 μS          < 3%
I          < 1e-6 A           < 1e-7 A           < 5%
```

### Causas de Diferencias

1. **Método de integración diferente**
   - Python: Euler explícito simple
   - SPICE: Gear (más preciso para sistemas stiff)

2. **Paso de tiempo**
   - Python: Fijo en 2μs
   - SPICE: Adaptativo con máximo 2μs

3. **Orden de operaciones**
   - Python: Actualiza Vm después de Schottky
   - Verilog-A: Calcula todo simultáneamente

4. **Precisión numérica**
   - Python: Float64 (15 dígitos)
   - SPICE: Depende de tolerancias (reltol=1e-4)

## Gráficas Generadas

### 1. Python Hysteresis (`python_hysteresis.png`)
- Curva I-V del memristor
- Solo simulación Python

### 2. Comparison Plots (`comparison_plots.png`)
- 8 subplots comparando todas las variables
- Python (línea azul sólida) vs SPICE (línea roja punteada)
- Incluye error RMS en cada gráfica

## Troubleshooting

### Error: "Could not load SPICE data"
**Solución**: Ejecuta primero la simulación SPICE en xschem

### Error: "Module rram_v1_va not found"
**Solución**: Verifica que el archivo .osdi esté compilado correctamente

### Error: "File not found: /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/python_results.txt"
**Solución**: Ejecuta primero `simulate_and_export.py`

### Simulación SPICE muy lenta
**Causas**:
- maxstep=2u es muy pequeño
- 200ms de simulación = 100,000 puntos

**Solución temporal** (para pruebas rápidas):
```spice
.tran 10u 50m     # Paso más grande, tiempo más corto
```

## Verificación de Resultados Correctos

Las simulaciones están alineadas correctamente si:

1. ✅ **X (estado)**: Evoluciona de 0 a ~0.7 y regresa
2. ✅ **Vm**: Sigue forma sinusoidal amortiguada
3. ✅ **I vs Vm**: Muestra curva en forma de "8" (pinch point en origen)
4. ✅ **Errores relativos**: < 10% para todas las variables
5. ✅ **Tendencias**: Ambas curvas siguen el mismo patrón

## Parámetros del Modelo

Ambas simulaciones usan:

```
Ron = 13 kΩ
Roff = 460 kΩ  
tau = 60 μs
T = 108.5 K
Von_threshold = 0.2 V
Voff = -0.1 V
phi = 0.88
Rs = 10 kΩ
Vp = 0.4 V
f = 10 Hz
x0 = 0.0 (OFF state)
```

## Archivos de Salida

```
/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/
├── python_results.txt        # Datos Python (tiempo, V, Vm, X, G, Im, Is, I)
├── spice_results.txt         # Datos SPICE (mismo formato)
├── python_hysteresis.png     # Histéresis Python
└── comparison_plots.png      # Comparación completa (8 plots)
```

## Siguientes Pasos

1. **Ajustar parámetros**: Modifica Rs, Vp, tau, etc. y recompara
2. **Estado inicial**: Cambia x0 a 0.5 o 1.0 y observa diferencias
3. **Variación estocástica**: Habilita variables aleatorias en Python
4. **Análisis de frecuencia**: Cambia frecuencia de 10Hz a otros valores

## Referencias

- Código Python original: `stochastic_GMMS_memristor_demo.py`
- Paper: Ostrovskii et al., "Structural and Parametric Identification of Knowm Memristors", Nanomaterials 2022
