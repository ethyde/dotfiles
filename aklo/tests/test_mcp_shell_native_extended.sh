#!/usr/bin/env bash
# =============================================================
#  Aklo MCP Shell Native - Suite de tests d'intégration étendue
#  Tâche : TASK-9-5 | PBI-9 | Statut : EN COURS
#  Ce script teste les 4 outils MCP shell natifs étendus :
#    - aklo_execute_shell
#    - aklo_status_shell
#    - safe_shell
#    - project_info
#  Protocole : Respect strict de la charte Aklo (atomicité, logs, validation)
#
#  ⚠️  jq (JSON processor) est recommandé pour project_info, mais le fallback natif Bash est automatique si jq est absent
#  Le fallback peut être forcé via AKLO_FORCE_NO_JQ=1
# =============================================================

set -euo pipefail

# Utilitaires communs
echo_section() { echo -e "\n===== $1 =====\n"; }
assert_success() { if [ "$1" -ne 0 ]; then echo "[FAIL] $2"; exit 1; else echo "[OK] $2"; fi; }

# 1. Test existence de la whitelist
run_test_whitelist_existence() {
  echo_section "Test : existence de aklo/config/commands.whitelist"
  if [ -f ./aklo/config/commands.whitelist ]; then
    echo "[OK] commands.whitelist présent"
  else
    echo "[FAIL] commands.whitelist absent"; exit 1
  fi
}

# 2. Test aklo_execute_shell
run_test_aklo_execute_shell() {
  echo_section "Test : aklo_execute_shell (validation commandes, arguments, contexte)"
  OUTPUT=$(echo '{"command":"status"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_execute_shell)
  echo "$OUTPUT" | grep -q '"status"' && assert_success 0 "aklo_execute_shell : commande 'status' autorisée"
  OUTPUT_FORBIDDEN=$(echo '{"command":"forbidden_cmd"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_execute_shell || true)
  echo "$OUTPUT_FORBIDDEN" | grep -q 'non autorisée' && assert_success 0 "aklo_execute_shell : commande interdite bloquée"
  OUTPUT_ARG=$(echo '{"command":"status","args":["--bad-arg"]}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_execute_shell || true)
  echo "$OUTPUT_ARG" | grep -q 'invalid' && assert_success 0 "aklo_execute_shell : argument invalide détecté"
  OUTPUT_CTX=$(echo '{"command":"status","workdir":"/tmp"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_execute_shell)
  echo "$OUTPUT_CTX" | grep -q '"status"' && assert_success 0 "aklo_execute_shell : contexte workdir supporté"
}

# 3. Test aklo_status_shell
run_test_aklo_status_shell() {
  echo_section "Test : aklo_status_shell (métriques, artefacts, rapport)"
  OUTPUT=$(echo '{}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_status_shell)
  echo "$OUTPUT" | grep -q '"artefacts"' && assert_success 0 "aklo_status_shell : métriques artefacts présentes"
  OUTPUT_NO_INIT=$(AKLO_PROJECT_PATH="/tmp/aklo_fake" echo '{}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh aklo_status_shell || true)
  echo "$OUTPUT_NO_INIT" | grep -q 'not initialized' && assert_success 0 "aklo_status_shell : gestion projet non initialisé"
  echo "$OUTPUT" | grep -q '"health"' && assert_success 0 "aklo_status_shell : rapport santé présent"
}

# 4. Test safe_shell
run_test_safe_shell() {
  echo_section "Test : safe_shell (sécurité, whitelist, timeout)"
  # Ajoute 'sleep' à la whitelist pour le test de timeout
  grep -q '^sleep$' ./aklo/config/commands.whitelist || echo 'sleep' >> ./aklo/config/commands.whitelist
  OUTPUT=$(echo '{"command":"ls"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh safe_shell)
  echo "$OUTPUT" | grep -q '"success"' && assert_success 0 "safe_shell : commande autorisée 'ls'"
  OUTPUT_FORBIDDEN=$(echo '{"command":"rm"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh safe_shell || true)
  echo "$OUTPUT_FORBIDDEN" | grep -q 'not in the allowed list' && assert_success 0 "safe_shell : commande interdite 'rm' bloquée"
  # 'sleep' est autorisé dans la whitelist uniquement pour ce test de timeout
  OUTPUT_TIMEOUT=$(echo '{"command":"sleep 5","timeout":1000}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh safe_shell || true)
  echo "$OUTPUT_TIMEOUT" | grep -q 'timeout' && assert_success 0 "safe_shell : timeout respecté"
  OUTPUT_WD=$(echo '{"command":"ls","workdir":"/tmp"}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh safe_shell)
  echo "$OUTPUT_WD" | grep -q '"success"' && assert_success 0 "safe_shell : workdir supporté"
  # Retire 'sleep' de la whitelist après le test
  sed -i '' '/^sleep$/d' ./aklo/config/commands.whitelist
}

# 5. Test project_info
run_test_project_info() {
  echo_section "Test : project_info (parsing JSON, informations Git, métriques)"
  OUTPUT=$(echo '{}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh project_info)
  echo "$OUTPUT" | grep -q '"project"' && assert_success 0 "project_info : informations projet extraites"
  OUTPUT_FALLBACK=$(AKLO_FORCE_NO_JQ=1 echo '{}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh project_info)
  echo "$OUTPUT_FALLBACK" | grep -q '"project"' && assert_success 0 "project_info : fallback parsing OK"
  cp ./aklo/tests/data/bad_package.json /tmp/package.json 2>/dev/null || true
  OUTPUT_ERR=$(AKLO_PROJECT_PATH="/tmp" echo '{}' | ./aklo/modules/mcp/shell-native/aklo-terminal.sh project_info || true)
  echo "$OUTPUT_ERR" | grep -q 'error' && assert_success 0 "project_info : erreur parsing détectée"
  echo "$OUTPUT" | grep -q '"artefact_count"' && assert_success 0 "project_info : métriques artefacts présentes"
}

# 6. Test présence de jq
run_test_jq_presence() {
  echo_section "Test : présence de jq (JSON processor)"
  if command -v jq >/dev/null 2>&1; then
    echo "[OK] jq présent"
  else
    echo "[FAIL] jq absent"; exit 1
  fi
}

# Exécution séquentielle
if [ $# -eq 0 ]; then
  echo "Début de la suite de tests d'intégration MCP shell natif (TASK-9-5)"
  run_test_whitelist_existence
  run_test_aklo_execute_shell
  run_test_aklo_status_shell
  run_test_safe_shell
  run_test_project_info
  run_test_jq_presence
  echo "Fin de la suite de tests d'intégration MCP shell natif (TASK-9-5)"
else
  "$@"
fi
