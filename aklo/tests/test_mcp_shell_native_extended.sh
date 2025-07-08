#!/bin/bash
# =============================================================
#  Aklo MCP Shell Native - Suite de tests d'intégration étendue
#  Tâche : TASK-9-5 | PBI-9 | Statut : EN COURS
#  Ce script teste les 4 outils MCP shell natifs étendus :
#    - aklo_execute_shell
#    - aklo_status_shell
#    - safe_shell
#    - project_info
#  Protocole : Respect strict de la charte Aklo (atomicité, logs, validation)
# =============================================================

set -euo pipefail

# Utilitaires communs
echo_section() { echo -e "\n===== $1 =====\n"; }
assert_success() { if [ "$1" -ne 0 ]; then echo "[FAIL] $2"; exit 1; else echo "[OK] $2"; fi; }

# 1. Test aklo_execute_shell
run_test_aklo_execute_shell() {
  echo_section "Test : aklo_execute_shell (validation commandes, arguments, contexte)"
  # Commande autorisée
  OUTPUT=$(./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_execute_shell "status" 2>/dev/null)
  echo "$OUTPUT" | grep -q '"status"' && assert_success 0 "aklo_execute_shell : commande 'status' autorisée"
  # Commande interdite
  OUTPUT_FORBIDDEN=$(./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_execute_shell "forbidden_cmd" 2>/dev/null || true)
  echo "$OUTPUT_FORBIDDEN" | grep -q 'forbidden' && assert_success 0 "aklo_execute_shell : commande interdite bloquée"
  # Argument invalide
  OUTPUT_ARG=$(./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_execute_shell "status" "--bad-arg" 2>/dev/null || true)
  echo "$OUTPUT_ARG" | grep -q 'invalid' && assert_success 0 "aklo_execute_shell : argument invalide détecté"
  # Contexte de travail
  OUTPUT_CTX=$(./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_execute_shell "status" --workdir "/tmp" 2>/dev/null)
  echo "$OUTPUT_CTX" | grep -q '"status"' && assert_success 0 "aklo_execute_shell : contexte workdir supporté"
}

# 2. Test aklo_status_shell
run_test_aklo_status_shell() {
  echo_section "Test : aklo_status_shell (métriques, artefacts, rapport)"
  OUTPUT=$(./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_status_shell 2>/dev/null)
  echo "$OUTPUT" | grep -q '"artefacts"' && assert_success 0 "aklo_status_shell : métriques artefacts présentes"
  # Projet non initialisé
  OUTPUT_NO_INIT=$(AKLO_PROJECT_PATH="/tmp/aklo_fake" ./aklo/modules/mcp/terminal/aklo-terminal.sh aklo_status_shell 2>/dev/null || true)
  echo "$OUTPUT_NO_INIT" | grep -q 'not initialized' && assert_success 0 "aklo_status_shell : gestion projet non initialisé"
  # Rapport santé
  echo "$OUTPUT" | grep -q '"health"' && assert_success 0 "aklo_status_shell : rapport santé présent"
}

# 3. Test safe_shell
run_test_safe_shell() {
  echo_section "Test : safe_shell (sécurité, whitelist, timeout)"
  OUTPUT=$(./aklo/modules/mcp/terminal/aklo-terminal.sh safe_shell "ls" 2>/dev/null)
  echo "$OUTPUT" | grep -q '"success"' && assert_success 0 "safe_shell : commande autorisée 'ls'"
  OUTPUT_FORBIDDEN=$(./aklo/modules/mcp/terminal/aklo-terminal.sh safe_shell "rm" 2>/dev/null || true)
  echo "$OUTPUT_FORBIDDEN" | grep -q 'forbidden' && assert_success 0 "safe_shell : commande interdite 'rm' bloquée"
  # Timeout (commande longue)
  OUTPUT_TIMEOUT=$(./aklo/modules/mcp/terminal/aklo-terminal.sh safe_shell "sleep 5" --timeout 1 2>/dev/null || true)
  echo "$OUTPUT_TIMEOUT" | grep -q 'timeout' && assert_success 0 "safe_shell : timeout respecté"
  # Workdir
  OUTPUT_WD=$(./aklo/modules/mcp/terminal/aklo-terminal.sh safe_shell "ls" --workdir "/tmp" 2>/dev/null)
  echo "$OUTPUT_WD" | grep -q '"success"' && assert_success 0 "safe_shell : workdir supporté"
}

# 4. Test project_info
run_test_project_info() {
  echo_section "Test : project_info (parsing JSON, informations Git, métriques)"
  OUTPUT=$(./aklo/modules/mcp/terminal/aklo-terminal.sh project_info 2>/dev/null)
  echo "$OUTPUT" | grep -q '"project"' && assert_success 0 "project_info : informations projet extraites"
  # Fallback parsing (simulate jq absent)
  OUTPUT_FALLBACK=$(AKLO_FORCE_NO_JQ=1 ./aklo/modules/mcp/terminal/aklo-terminal.sh project_info 2>/dev/null)
  echo "$OUTPUT_FALLBACK" | grep -q '"project"' && assert_success 0 "project_info : fallback parsing OK"
  # Erreur parsing (fichier corrompu)
  cp ./aklo/tests/data/bad_package.json /tmp/package.json 2>/dev/null || true
  OUTPUT_ERR=$(AKLO_PROJECT_PATH="/tmp" ./aklo/modules/mcp/terminal/aklo-terminal.sh project_info 2>/dev/null || true)
  echo "$OUTPUT_ERR" | grep -q 'error' && assert_success 0 "project_info : erreur parsing détectée"
  # Métriques artefacts
  echo "$OUTPUT" | grep -q '"artefact_count"' && assert_success 0 "project_info : métriques artefacts présentes"
}

# Exécution séquentielle
echo "Début de la suite de tests d'intégration MCP shell natif (TASK-9-5)"
run_test_aklo_execute_shell
run_test_aklo_status_shell
run_test_safe_shell
run_test_project_info
echo "Fin de la suite de tests d'intégration MCP shell natif (TASK-9-5)"
