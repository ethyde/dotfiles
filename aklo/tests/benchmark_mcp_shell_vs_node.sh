#!/usr/bin/env bash
# =============================================================
#  Aklo MCP Shell Native vs Node.js - Script de benchmark
#  Tâche : TASK-9-5 | PBI-9 | Statut : EN COURS
#  Ce script compare les performances des serveurs MCP shell natifs et Node.js :
#    - Temps de démarrage
#    - Temps de réponse par outil
#    - Utilisation mémoire
#    - Parité fonctionnelle
#  Protocole : Respect strict de la charte Aklo (atomicité, logs, validation)
# =============================================================

set -euo pipefail

# Utilitaires communs
echo_section() { echo -e "\n===== $1 =====\n"; }
measure_time() { /usr/bin/time -f "%e" "$@" 2>&1 | tail -n 1; }
measure_mem() { /usr/bin/time -f "%M" "$@" 2>&1 | tail -n 1; }

# Chemins à adapter selon l'environnement
SHELL_SERVER="./aklo/modules/mcp/terminal/aklo-terminal.sh"
NODE_SERVER="node ./aklo/modules/mcp/terminal/index.js"

# 1. Benchmark temps de démarrage
benchmark_startup_time() {
  echo_section "Benchmark : Temps de démarrage (shell vs Node.js)"
  TIME_SHELL=$(measure_time $SHELL_SERVER aklo_status_shell)
  TIME_NODE=$(measure_time $NODE_SERVER aklo_status)
  echo "Shell MCP startup: $TIME_SHELL s"
  echo "Node.js MCP startup: $TIME_NODE s"
}

# 2. Benchmark temps de réponse
benchmark_response_time() {
  echo_section "Benchmark : Temps de réponse par outil (shell vs Node.js)"
  TIME_SHELL=$(measure_time $SHELL_SERVER safe_shell "ls")
  TIME_NODE=$(measure_time $NODE_SERVER safe_shell "ls")
  echo "Shell safe_shell: $TIME_SHELL s"
  echo "Node.js safe_shell: $TIME_NODE s"
}

# 3. Benchmark utilisation mémoire
benchmark_memory_usage() {
  echo_section "Benchmark : Utilisation mémoire (shell vs Node.js)"
  MEM_SHELL=$(measure_mem $SHELL_SERVER aklo_status_shell)
  MEM_NODE=$(measure_mem $NODE_SERVER aklo_status)
  echo "Shell MCP RSS: $MEM_SHELL KB"
  echo "Node.js MCP RSS: $MEM_NODE KB"
}

# 4. Validation parité fonctionnelle
validate_functional_parity() {
  echo_section "Validation : Parité fonctionnelle (shell vs Node.js)"
  OUT_SHELL=$($SHELL_SERVER aklo_status_shell)
  OUT_NODE=$($NODE_SERVER aklo_status)
  diff <(echo "$OUT_SHELL") <(echo "$OUT_NODE") && echo "[OK] Parité fonctionnelle atteinte" || echo "[WARN] Différences détectées"
}

# Exécution séquentielle
echo "Début du benchmark MCP shell natif vs Node.js (TASK-9-5)"
benchmark_startup_time
benchmark_response_time
benchmark_memory_usage
validate_functional_parity
echo "Fin du benchmark MCP shell natif vs Node.js (TASK-9-5)"
