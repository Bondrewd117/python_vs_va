# RESUMEN DE CAMBIOS - Rutas Actualizadas

## ✅ Cambios Realizados

Todas las referencias a `/tmp` han sido cambiadas a:
```
/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp
```

## 📁 Archivos Modificados

### 1. Scripts Python
- ✅ **simulate_and_export.py**
  - Línea de exportación de datos
  - Línea de guardado de gráfica
  
- ✅ **compare_simulations.py**
  - Variable OUTPUT_DIR definida al inicio
  - Funciones load_python_data() y load_spice_data()
  - Mensajes de error y éxito
  - Guardado de comparison_plots.png

### 2. Testbench xschem
- ✅ **tb_monitor_comparison.sch**
  - Comando wrdata en bloque .control

### 3. Script Bash
- ✅ **run_full_comparison.sh**
  - Variable OUTPUT_DIR añadida
  - Creación automática del directorio
  - Todas las verificaciones de archivos
  - Mensajes de resumen final

### 4. Documentación
- ✅ **README.md**
  - Todas las referencias a rutas de archivos
  
- ✅ **COMPARISON_GUIDE.md**
  - Todas las referencias a rutas de archivos

## 📂 Estructura de Directorios

```
/home/salieri/eda/designs/Capibara_tuto/MEMS/
├── rram_v1_with_monitors.va
├── rram_v1_with_monitors.osdi
├── rram_v1_monitor.sym
├── tb_monitor_comparison.sch
├── simulate_and_export.py
├── compare_simulations.py
├── run_full_comparison.sh
├── README.md
├── COMPARISON_GUIDE.md
└── tmp/  ← NUEVO DIRECTORIO
    ├── python_results.txt       (generado por simulación)
    ├── spice_results.txt        (generado por simulación)
    ├── python_hysteresis.png    (generado por simulación)
    ├── comparison_plots.png     (generado por comparación)
    └── spice_sim.log            (log de SPICE)
```

## 🔄 Archivos de Salida

Todos los archivos generados ahora se guardan en:
```
/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/
```

| Archivo | Descripción |
|---------|-------------|
| `python_results.txt` | Datos de simulación Python (tiempo, voltajes, corrientes, estado) |
| `spice_results.txt` | Datos de simulación SPICE (mismo formato) |
| `python_hysteresis.png` | Gráfica de histéresis I-V de Python |
| `comparison_plots.png` | 8 gráficas comparando todas las variables |
| `spice_sim.log` | Log de la simulación SPICE (para debugging) |

## 🚀 Uso Actualizado

### Método Rápido (Automático)

```bash
cd /home/salieri/eda/designs/Capibara_tuto/MEMS/
./run_full_comparison.sh
```

El script:
1. ✅ Crea el directorio `tmp/` si no existe
2. ✅ Compila el Verilog-A
3. ✅ Ejecuta simulación Python → guarda en `tmp/`
4. ✅ Ejecuta simulación SPICE → guarda en `tmp/`
5. ✅ Compara y genera gráficas → guarda en `tmp/`

### Archivos Resultantes

Al terminar, encontrarás:
```bash
ls -lh /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/

python_results.txt       ~6.5 MB
spice_results.txt        ~variable MB
python_hysteresis.png    ~50 KB
comparison_plots.png     ~200 KB
spice_sim.log            ~variable KB
```

## ✨ Ventajas del Nuevo Directorio

1. **Organización**: Todos los resultados en un lugar dedicado
2. **Persistencia**: Los archivos no se borran con reinicio del sistema
3. **Accesibilidad**: Fácil de encontrar y respaldar
4. **Permisos**: No requiere permisos de root
5. **Desarrollo**: Mantiene separados datos de código

## 🔍 Verificación

Para verificar que todo funciona correctamente:

```bash
# 1. Verificar que el directorio existe
ls -ld /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/

# 2. Ejecutar solo Python
cd /home/salieri/eda/designs/Capibara_tuto/MEMS/
python3 simulate_and_export.py

# 3. Verificar que se creó el archivo
ls -lh tmp/python_results.txt

# 4. Ver las primeras líneas
head tmp/python_results.txt
```

## 📝 Notas Importantes

⚠️ **Antes de ejecutar por primera vez:**

```bash
# Asegúrate de que el directorio tiene los permisos correctos
chmod 755 /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/
```

⚠️ **Si usas otros scripts o notebooks:**

Actualiza cualquier referencia a `/tmp/` en tus propios scripts a:
```python
OUTPUT_DIR = "/home/salieri/eda/designs/Capibara_tuto/MEMS/tmp"
```

## 🐛 Troubleshooting

### Error: "Permission denied" al escribir en tmp/

```bash
# Solución: Dar permisos de escritura
chmod 755 /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp/
```

### Error: "Directory not found"

```bash
# Solución: Crear el directorio manualmente
mkdir -p /home/salieri/eda/designs/Capibara_tuto/MEMS/tmp
```

### Los archivos no aparecen

```bash
# Verificar que los scripts tienen la ruta correcta
grep "OUTPUT_DIR" simulate_and_export.py
grep "OUTPUT_DIR" compare_simulations.py
```

## ✅ Checklist Final

- [x] Directorio `tmp/` creado
- [x] Scripts Python actualizados
- [x] Script bash actualizado
- [x] Testbench xschem actualizado
- [x] Documentación actualizada
- [x] Permisos configurados
- [x] Scripts son ejecutables

## 🎯 Siguiente Paso

Ejecuta la comparación completa:
```bash
cd /home/salieri/eda/designs/Capibara_tuto/MEMS/
./run_full_comparison.sh
```

---

**Última actualización**: Febrero 2025
