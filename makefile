# === Configuración por plataforma ===
VENV ?= .venv
KERNEL_NAME ?= python-course
KERNEL_DISPLAY ?= Python (python-course)

# Detección de Sistema Operativo
ifeq ($(OS),Windows_NT)
    VENV_PY = $(VENV)/Scripts/python.exe
else
    VENV_PY = $(VENV)/bin/python
endif

PY  := $(VENV_PY)
PIP := $(VENV_PY) -m pip

SHELL := /bin/bash

# === Ayuda ===
.PHONY: help
help: ## Muestra esta ayuda con la descripción de los comandos
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: activate-hint
activate-hint: ## Muestra el comando para activar el venv en tu terminal
	@echo "Activa manualmente el entorno en tu terminal:"
	@echo "  macOS/Linux (bash/zsh):  source .venv/bin/activate"
	@echo "  Windows PowerShell:      .\\.venv\\Scripts\\Activate.ps1"
	@echo "  Windows CMD:             .\\.venv\\Scripts\\activate.bat"

.PHONY: deactivate-hint
deactivate-hint: ## Muestra cómo desactivar (salir) del entorno virtual en tu terminal actual
	@echo "Para DESACTIVAR el entorno virtual actual, ejecuta en tu terminal:"
	@echo "  macOS/Linux (bash/zsh):  deactivate"
	@echo "  Windows PowerShell:      deactivate"
	@echo "  Windows CMD:             .\\.venv\\Scripts\\deactivate.bat"

# === Entorno e instalación ===
.PHONY: venv
venv: ## Crea el entorno virtual (.venv) si no existe
	@test -d "$(VENV)" || python -m venv "$(VENV)"
	@echo "Entorno virtual listo en $(VENV)"
	@echo "Python del venv: $(VENV_PY)"

.PHONY: install
install: venv ## Instala/actualiza dependencias dentro del venv
	$(PIP) install --upgrade pip
	@test -f requirements.txt || (echo "No existe requirements.txt"; exit 1)
	$(PIP) install -r requirements.txt
	@$(PY) -c "import sys; print('Usando:', sys.executable)"

.PHONY: kernel
kernel: venv ## Registra el kernel de Jupyter para este proyecto (desde el venv)
	$(PY) -m ipykernel install --user --name "$(KERNEL_NAME)" --display-name "$(KERNEL_DISPLAY)"

.PHONY: init
init: install kernel ## Inicializa el proyecto: instala dependencias y registra kernel

# === Calidad de código ===
.PHONY: format
format: ## Formatea el código con isort y Black (en el venv)
	$(PY) -m isort .
	$(PY) -m black .

.PHONY: lint
lint: ## Ejecuta flake8 para revisión estática (en el venv)
	$(PY) -m flake8 .

.PHONY: test
test: ## Ejecuta la suite de pruebas con pytest (en el venv)
	$(PY) -m pytest

.PHONY: check
check: ## Ejecuta formato, linter y pruebas
	$(MAKE) format
	$(MAKE) lint
	$(MAKE) test

# === Notebooks / Jupyter ===
.PHONY: lab
lab: ## Abre JupyterLab con el venv
	$(PY) -m jupyter lab

# === Utilidades ===
.PHONY: freeze
freeze: ## Congela dependencias en requirements.lock.txt
	$(PIP) freeze > requirements.lock.txt
	@echo "Escrito requirements.lock.txt"

.PHONY: clean
clean: ## Limpia artefactos, checkpoints y el entorno virtual
	@find . -name "__pycache__" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".ipynb_checkpoints" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@rm -rf .pytest_cache .mypy_cache build dist *.egg-info 2>/dev/null || true
	@rm -rf .venv 2>/dev/null || true
	@echo "Limpieza completada"

# === Diagnóstico (útil) ===
.PHONY: which
which: ## Imprime el Python y pip en uso (del venv)
	@$(PY) -c "import sys; print('PYTHON =', sys.executable)"
	@$(PY) -m pip --version
