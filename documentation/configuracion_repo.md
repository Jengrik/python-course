# Guía de Ejecución del Curso — `python-course`

Este documento explica **paso a paso** cómo preparar y ejecutar el entorno del curso en dos modalidades:

1) **Sin usar el Makefile** (comandos “manuales”).
2) **Usando el Makefile** (automatiza la mayoría de tareas).

Incluye instrucciones para **macOS/Linux** y **Windows PowerShell**. Si usas VSCode, verás notas específicas para seleccionar el **kernel** correcto en los notebooks.

---

## 0) Requisitos previos

- **Python 3.11+** (recomendado 3.12.x).
- **pip** actualizado.
- **VSCode** (opcional pero recomendado) con extensiones: *Python*, *Jupyter*, *Pylance*, *Black Formatter*, *isort*.
- Clonar o crear el repositorio `python-course` en tu máquina.

> **Importante:** Trabaja siempre con **entornos virtuales (venv)** para aislar dependencias y evitar mezclar con el Python global del sistema.

---

## 1) Estructura mínima del repositorio

```
python-course/
├─ sessions/
│  ├─ 01-fundamentos/
│  │  ├─ notebooks/01_intro.ipynb
│  │  ├─ data/
│  │  └─ src/
├─ .vscode/
│  ├─ settings.json
│  └─ extensions.json
├─ requirements.txt
├─ pyproject.toml
├─ Makefile
└─ (se creará) .venv/
```

---

## 2) Opción A — **Sin usar el Makefile** (modo manual)

### 2.1 Crear el entorno virtual

**macOS / Linux**
```bash
cd python-course
python3 -m venv .venv
```

**Windows PowerShell**
```powershell
cd python-course
py -3 -m venv .venv
```

> Esto crea la carpeta `.venv/` con un intérprete de Python **aislado** para el proyecto.

---

### 2.2 Activar el entorno virtual

**macOS / Linux (bash/zsh)**
```bash
source .venv/bin/activate
```

**Windows PowerShell**
```powershell
.\.venv\Scripts\Activate.ps1
```

> Verás tu prompt con un prefijo como `(.venv)` indicando que el entorno está **activo**.

---

### 2.3 Actualizar pip e instalar dependencias

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

> Las librerías se instalarán **dentro de `.venv`**, no en el sistema.

---

### 2.4 Registrar el **kernel** de Jupyter para este proyecto

```bash
python -m ipykernel install --user --name python-course --display-name "Python (python-course)"
```

- `--name`: identificador interno del kernel.
- `--display-name`: cómo lo verás en Jupyter/VSCode.

---

### 2.5 Abrir JupyterLab **o** VSCode

**JupyterLab local**
```bash
jupyter lab
```
Abre el navegador → navega a `sessions/01-fundamentos/notebooks/01_intro.ipynb`.

**VSCode**
- Abre la carpeta `python-course`.
- Abre `sessions/01-fundamentos/notebooks/01_intro.ipynb`.
- En la esquina superior derecha del notebook, selecciona el kernel **Python (python-course)**.

---

### 2.6 Verificación rápida del entorno

En una celda de notebook o en la terminal con el venv activo:

```python
import sys, platform
import numpy as np, pandas as pd

print(sys.executable)  # Debe apuntar a .../.venv/bin/python (macOS/Linux) o ...\.venv\Scripts\python.exe (Windows)
print(platform.python_version())
print("NumPy:", np.__version__, "Pandas:", pd.__version__)
```

---

### 2.7 Desactivar el entorno virtual

- **macOS/Linux (bash/zsh)**: `deactivate`
- **Windows PowerShell**: `deactivate`
- **Windows CMD**: `.\.venv\Scripts\deactivate.bat`

> *Desactivar* vuelve tu shell a su estado normal (usa el Python global del sistema).

---

## 3) Opción B — **Usando el Makefile** (modo automatizado)

El Makefile incluye targets que usan internamente el Python del **venv**. No necesitas “activar” el venv para que funcionen.

> **Nota sobre Windows:** para usar `make` cómodamente, ejecuta los comandos en **Git Bash** o **WSL**. Si prefieres PowerShell/CMD, puedes seguir la **Opción A** (manual).

### 3.1 Inicializar todo (crear venv + instalar deps + registrar kernel)

```bash
make init
```
- Crea `.venv/` si no existe.
- Instala dependencias de `requirements.txt` **dentro del venv**.
- Registra el kernel **Python (python-course)**.

### 3.2 Abrir JupyterLab

```bash
make lab
```

### 3.3 Comprobar el intérprete y pip en uso

```bash
make which
```
Salida esperada (ejemplo macOS/Linux):
```
PYTHON = /ruta/a/python-course/.venv/bin/python
pip X.Y from .../.venv/lib/python...
```

### 3.4 Formateo, lint y pruebas

```bash
make format   # isort + black
make lint     # flake8
make test     # pytest
make check    # las tres anteriores en secuencia
```

### 3.5 Congelar dependencias (snapshot reproducible)

```bash
make freeze
# genera requirements.lock.txt con versiones exactas
```

### 3.6 Ayuda para activar/desactivar en tu terminal

```bash
make activate-hint
make deactivate-hint
```

> Recuerda: `make` no puede activar o desactivar tu **terminal padre**; estos targets imprimen las instrucciones exactas para que lo hagas tú.

### 3.7 Limpieza (incluye borrar `.venv`)

```bash
make clean
```
- Borra `__pycache__`, `.ipynb_checkpoints`, caches de test y **el venv**.
- Tras `clean`, vuelve a ejecutar `make init` para recrear el entorno.

---

## 4) Notas para VSCode (recomendado)

- Revisa `.vscode/settings.json` y `.vscode/extensions.json` (incluyen recomendaciones de extensiones y formateo con Black).
- Abre un notebook (`.ipynb`) y selecciona el kernel **Python (python-course)**. Si no aparece:
  1. Asegúrate de haber corrido `make init` o la sección manual de **ipykernel**.
  2. Reinicia VSCode si hiciste cambios recientes de kernels.
- Terminal integrado: si `python.terminal.activateEnvironment` está activado, VSCode activará automáticamente el venv al abrir un terminal nuevo.

---

## 5) Errores comunes y soluciones

- **Paquetes instalados globalmente por error**
  Verifica qué Python estás usando:
  ```bash
  python -c "import sys; print(sys.executable)"
  ```
  Si no apunta a `.venv`, activa el venv o usa el Makefile (que ya fuerza el venv).

- **El kernel no aparece en Jupyter/VSCode**
  Vuelve a registrar:
  ```bash
  python -m ipykernel install --user --name python-course --display-name "Python (python-course)"
  ```
  Lista y limpia kernels antiguos si es necesario:
  ```bash
  jupyter kernelspec list
  jupyter kernelspec remove <nombre-viejo>
  ```

- **Windows: `python` no se reconoce**
  Usa `py -3` en lugar de `python` para crear el venv manualmente.

- **Después de `make clean`**
  Se borra `.venv`. Ejecuta `make init` para recrearlo antes de usar `make lab`, `make format`, etc.

---

## 6) Comandos de referencia rápida

**Manual (sin Makefile)**
```bash
# Crear venv
python3 -m venv .venv           # macOS/Linux
py -3 -m venv .venv             # Windows

# Activar
source .venv/bin/activate       # macOS/Linux
.\.venv\Scripts\Activate.ps1    # Windows

# Instalar deps
python -m pip install --upgrade pip
pip install -r requirements.txt

# Registrar kernel
python -m ipykernel install --user --name python-course --display-name "Python (python-course)"

# Ejecutar JupyterLab
jupyter lab

# Desactivar
deactivate
```

**Con Makefile**
```bash
make init      # venv + deps + kernel
make lab       # abre JupyterLab
make which     # muestra intérprete/pip del venv
make format    # black + isort
make lint      # flake8
make test      # pytest
make check     # calidad completa
make freeze    # genera requirements.lock.txt
make clean     # limpia (incluye borrar .venv)
make activate-hint
make deactivate-hint
```
