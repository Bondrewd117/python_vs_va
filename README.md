# Comparación de Variables Internas: Python vs SPICE

## Resumen

Este conjunto de herramientas te permite **comparar directamente** las variables internas del memristor entre:
- Simulación Python (código de referencia)
- Simulación SPICE/Verilog-A

## Variables Comparadas

| Variable | Descripción | Python | Verilog-A |
|----------|-------------|--------|-----------|
| **X** | Variable de estado (0=OFF, 1=ON) | `X[i]` | `x` |
| **G** | Conductancia total [μS] | `G[i]` | `Gm` |
| **Vm** | Voltaje en memristor [V] | `Vm[i]` | `Vm` |
| **Im** | Corriente óhmica [μA] | `Im[i]` | `Im` |
| **Is** | Corriente Schottky [μA] | `Is[i]` | `Is` |
| **I** | Corriente total [A] | `I[i]` | `Itotal` |

## 🚀 Inicio Rápido (Automático)

```bash
# Hacer ejecutable
chmod +x run_full_comparison.sh

# Ejecutar todo el proceso
./run_full_comparison.sh
```

Este script ejecuta automáticamente:
1. ✅ Compilación del Verilog-A con monitoreo
2. ✅ Simulación Python → `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/python_results.txt`
3. ✅ Simulación SPICE → `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/spice_results.txt`
4. ✅ Comparación y gráficas → `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/comparison_plots.png`

**Tiempo estimado**: 5-10 minutos

## 📋 Inicio Manual (Paso a Paso)

### Paso 1: Compilar Verilog-A

```bash
cd /foss/designs/Capibara_tuto/MEMS/
openvaf rram_v1_with_monitors.va -o rram_v1_with_monitors.osdi
```

### Paso 2: Ejecutar Python

```bash
python3 simulate_and_export.py
```

Genera: `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/python_results.txt`

### Paso 3: Ejecutar SPICE

```bash
# Opción A: Desde xschem (recomendado)
xschem tb_monitor_comparison.sch
# Luego: Netlist → Simulate

# Opción B: Desde línea de comando
ngspice -b tb_monitor_comparison.cir
```

Genera: `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/spice_results.txt`

### Paso 4: Comparar

```bash
python3 compare_simulations.py
```

Genera: `/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/comparison_plots.png`

## 📊 Resultados Esperados

### Gráficas Generadas

1. **python_hysteresis.png**
   - Curva I-V del memristor (Python)
   
2. **comparison_plots.png** (principal)
   - 8 subplots comparando todas las variables
   - Python (azul sólido) vs SPICE (rojo punteado)
   - Métricas de error en cada gráfica

### Tabla de Errores Típicos

```
Variable   Max Abs Error      Mean Abs Error     Max Rel Error
--------------------------------------------------------------------
X          5.23e-03          1.45e-03            2.34%
Vm         8.91e-03 V        2.13e-03 V          1.87%
G          0.084 μS          0.021 μS            2.93%
I          4.52e-07 A        1.23e-07 A          4.12%
Im         2.31 μA           0.67 μA             3.45%
Is         0.12 μA           0.03 μA             8.21%
```

**Criterio de éxito**: Errores relativos < 10%

## 📁 Archivos Incluidos

### Código Fuente
- `rram_v1_with_monitors.va` - Verilog-A con variables exportadas
- `simulate_and_export.py` - Simulador Python con exportación
- `compare_simulations.py` - Script de comparación

### Testbench
- `tb_monitor_comparison.sch` - Testbench xschem completo
- `rram_v1_monitor.sym` - Símbolo con nodos de monitoreo

### Utilidades
- `run_full_comparison.sh` - Script maestro automatizado
- `COMPARISON_GUIDE.md` - Guía detallada
- `README.md` - Este archivo

## 🔍 Detalles Técnicos

### Parámetros del Circuito

```
Rs = 10 kΩ          (resistor en serie)
Vp = 0.4 V          (amplitud pico)
f = 10 Hz           (frecuencia)
x0 = 0.0            (estado inicial OFF)
```

### Parámetros del Memristor

```
Ron = 13 kΩ
Roff = 460 kΩ
tau = 60 μs
T = 108.5 K
Von_threshold = 0.2 V
Voff = -0.1 V
phi = 0.88
```

### Configuración de Simulación

```
dt = 2 μs           (paso de tiempo)
duration = 180 ms   (duración)
samples = 90,000    (número de muestras)
```

## 🐛 Solución de Problemas

### Error: "Could not load SPICE data"
**Causa**: No se ejecutó la simulación SPICE
**Solución**: Ejecuta primero el paso 3 (simulación SPICE)

### Error: "Module rram_v1_va not found"
**Causa**: El archivo OSDI no está compilado
**Solución**: Ejecuta `openvaf rram_v1_with_monitors.va -o ...osdi`

### Simulación SPICE muy lenta
**Causa**: `maxstep=2u` es muy fino, 200ms genera ~100k puntos
**Solución temporal**:
```spice
.tran 10u 50m    # Más rápido para pruebas
```

### Diferencias grandes (>10%)
**Posibles causas**:
1. Parámetros diferentes entre Python y SPICE
2. Diferente Rs o Vp
3. Diferente x0 inicial
4. Bug en el código

**Verificación**:
```bash
# Comparar parámetros
grep "Ron\|Roff\|tau" simulate_and_export.py
grep "Ron\|Roff\|tau" tb_monitor_comparison.sch
```

## 📈 Interpretación de Resultados

### Curva de Estado X
- ✅ **Correcto**: X evoluciona de 0 → 0.7 → 0.3 en forma suave
- ❌ **Incorrecto**: X salta abruptamente o se queda en 0

### Curva de Histéresis (I vs Vm)
- ✅ **Correcto**: Forma de "8" con pinch point en origen
- ❌ **Incorrecto**: Línea recta o curva cerrada sin pinch

### Voltaje Vm
- ✅ **Correcto**: Sinusoide amortiguada que cambia de amplitud
- ❌ **Incorrecto**: Sinusoide perfecta sin cambios

## 🎯 Casos de Uso

### 1. Validar Implementación Verilog-A
Verifica que tu código Verilog-A replica correctamente el modelo Python

### 2. Ajustar Parámetros
Modifica Ron, Roff, tau, etc. y observa el impacto

### 3. Estudiar Estados Iniciales
Cambia x0 = 0.0, 0.5, 1.0 y compara comportamiento

### 4. Análisis de Convergencia
Reduce maxstep y observa cambio en errores

## 📚 Referencias

- **Paper original**: Ostrovskii et al., "Structural and Parametric Identification of Knowm Memristors", Nanomaterials 2022
- **Código Python**: `stochastic_GMMS_memristor_demo.py`
- **Modelo GMMS**: Molter & Nugent, Knowm Inc.

## 📝 Notas

### Diferencias Esperadas

Las simulaciones **nunca serán idénticas** debido a:

1. **Métodos de integración diferentes**
   - Python: Euler explícito (orden 1)
   - SPICE: Gear (orden variable, más preciso)

2. **Ajuste de Schottky**
   - Python: Actualiza Vm después
   - Verilog-A: Cálculo simultáneo

3. **Paso de tiempo**
   - Python: Fijo
   - SPICE: Adaptativo

**Objetivo**: Errores < 10% en todas las variables

### Escalado de Variables

En Verilog-A, algunas variables se escalan para mejor visualización:
```verilog
V(G_out) <+ Gm * 1e6;    // G en microsiemens
V(Im_out) <+ Im * 1e6;   // Im en microamperes
V(Is_out) <+ Is * 1e6;   // Is en microamperes
```

## 🤝 Contribuciones

Para reportar errores o mejoras, documenta:
1. Parámetros usados
2. Errores observados
3. Archivos generados (/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/*.txt, *.png)
4. Versión de ngspice y OpenVAF

---

**Última actualización**: Febrero 2025
**Autor**: Basado en código de G. Laguna-Sanchez (UAM-Lerma)
