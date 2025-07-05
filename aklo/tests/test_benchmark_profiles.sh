#!/bin/bash

#==============================================================================
# Benchmark des Profils - TASK-13-5
#
# Auteur: AI_Agent
# Version: 1.0
# Benchmark détaillé des profils de l'architecture intelligente
#==============================================================================

# Configuration des tests
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
AKLO_SCRIPT="${PROJECT_ROOT}/aklo/bin/aklo"

# Chargement du framework de test
source "${SCRIPT_DIR}/test_framework.sh"

# Variables de configuration
BENCHMARK_RESULTS="/tmp/aklo_benchmark_results.csv"
ITERATIONS=10

# Initialisation du fichier de résultats
setup_benchmark() {
    echo "command,profile,iteration,duration_ms,modules_loaded,startup_time" > "$BENCHMARK_RESULTS"
}

# Fonction de benchmark détaillé
benchmark_command() {
    local command="$1"
    local expected_profile="$2"
    
    echo "=== Benchmark: $command (Profil $expected_profile) ==="
    
    for i in $(seq 1 $ITERATIONS); do
        local start_time=$(date +%s.%N)  # Secondes avec décimales
        
        # Exécution avec capture des métriques
        local output
        if [[ "$expected_profile" == "MINIMAL" ]]; then
            output=$(AKLO_DEBUG=true "${AKLO_SCRIPT}" "$command" 2>&1)
        else
            output=$("${AKLO_SCRIPT}" "$command" 2>&1)
        fi
        
        local end_time=$(date +%s.%N)
        local duration_sec=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
        local duration=$(echo "$duration_sec * 1000" | bc -l 2>/dev/null || echo "100")  # Conversion en ms
        
        # Extraction des métriques
        local modules_count=0
        local startup_time="0"
        
        if echo "$output" | grep -q "Modules chargés:"; then
            modules_count=$(echo "$output" | grep "Modules chargés:" | sed 's/.*Modules chargés: \([0-9]*\).*/\1/')
        fi
        
        if echo "$output" | grep -q "Initialisation terminée en"; then
            startup_time=$(echo "$output" | grep "Initialisation terminée en" | sed 's/.*terminée en \([0-9.]*\)s.*/\1/')
        fi
        
        # Enregistrement des résultats
        echo "$command,$expected_profile,$i,$duration,$modules_count,$startup_time" >> "$BENCHMARK_RESULTS"
        
        echo "  Itération $i: ${duration}ms (modules: $modules_count, startup: ${startup_time}s)"
    done
    
    # Calcul des statistiques
    local avg_duration=$(awk -F',' -v cmd="$command" '$1==cmd {sum+=$4; count++} END {printf "%.1f", sum/count}' "$BENCHMARK_RESULTS")
    local min_duration=$(awk -F',' -v cmd="$command" '$1==cmd {if(min=="" || $4<min) min=$4} END {print min}' "$BENCHMARK_RESULTS")
    local max_duration=$(awk -F',' -v cmd="$command" '$1==cmd {if(max=="" || $4>max) max=$4} END {print max}' "$BENCHMARK_RESULTS")
    
    echo "📊 Statistiques $command:"
    echo "   Moyenne: ${avg_duration}ms"
    echo "   Min: ${min_duration}ms"
    echo "   Max: ${max_duration}ms"
    echo "✓ Benchmark $command terminé"
}

#==============================================================================
# Test 1: Benchmark profil MINIMAL
#==============================================================================
test_benchmark_minimal() {
    echo "=== Benchmark Profil MINIMAL ==="
    
    benchmark_command "get_config" "MINIMAL"
    benchmark_command "help" "MINIMAL"
    
    echo "✓ Benchmark profil MINIMAL terminé"
}

#==============================================================================
# Test 2: Benchmark profil NORMAL
#==============================================================================
test_benchmark_normal() {
    echo "=== Benchmark Profil NORMAL ==="
    
    benchmark_command "plan" "NORMAL"
    
    echo "✓ Benchmark profil NORMAL terminé"
}

#==============================================================================
# Test 3: Benchmark profil FULL
#==============================================================================
test_benchmark_full() {
    echo "=== Benchmark Profil FULL ==="
    
    benchmark_command "optimize" "FULL"
    
    echo "✓ Benchmark profil FULL terminé"
}

#==============================================================================
# Test 4: Analyse des résultats
#==============================================================================
test_analyze_results() {
    echo "=== Analyse des Résultats ==="
    
    if [[ -f "$BENCHMARK_RESULTS" ]]; then
        echo "📊 Résumé par profil:"
        
        # Analyse par profil
        for profile in "MINIMAL" "NORMAL" "FULL"; do
            local avg=$(awk -F',' -v prof="$profile" '$2==prof {sum+=$4; count++} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}' "$BENCHMARK_RESULTS")
            local count=$(awk -F',' -v prof="$profile" '$2==prof {count++} END {print count+0}' "$BENCHMARK_RESULTS")
            echo "   $profile: ${avg}ms (${count} mesures)"
        done
        
        echo ""
        echo "📈 Analyse détaillée disponible dans: $BENCHMARK_RESULTS"
        
        # Génération d'un rapport simple
        echo "# Rapport de Benchmark - Architecture Intelligente" > "/tmp/aklo_benchmark_report.md"
        echo "" >> "/tmp/aklo_benchmark_report.md"
        echo "## Résultats par Profil" >> "/tmp/aklo_benchmark_report.md"
        echo "" >> "/tmp/aklo_benchmark_report.md"
        
        for profile in "MINIMAL" "NORMAL" "FULL"; do
            local avg=$(awk -F',' -v prof="$profile" '$2==prof {sum+=$4; count++} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}' "$BENCHMARK_RESULTS")
            local min=$(awk -F',' -v prof="$profile" '$2==prof {if(min=="" || $4<min) min=$4} END {print min+0}' "$BENCHMARK_RESULTS")
            local max=$(awk -F',' -v prof="$profile" '$2==prof {if(max=="" || $4>max) max=$4} END {print max+0}' "$BENCHMARK_RESULTS")
            
            echo "### Profil $profile" >> "/tmp/aklo_benchmark_report.md"
            echo "- Temps moyen: ${avg}ms" >> "/tmp/aklo_benchmark_report.md"
            echo "- Temps minimum: ${min}ms" >> "/tmp/aklo_benchmark_report.md"
            echo "- Temps maximum: ${max}ms" >> "/tmp/aklo_benchmark_report.md"
            echo "" >> "/tmp/aklo_benchmark_report.md"
        done
        
        echo "✓ Rapport généré: /tmp/aklo_benchmark_report.md"
    else
        fail "Fichier de résultats non trouvé"
    fi
    
    echo "✓ Analyse des résultats terminée"
}

#==============================================================================
# Exécution des benchmarks
#==============================================================================
main() {
    echo "🚀 Démarrage des benchmarks des profils - TASK-13-5"
    
    setup_benchmark
    
    # Vérification que le script existe
    assert_file_exists "$AKLO_SCRIPT" "Script principal aklo doit exister"
    
    # Exécution des benchmarks
    test_benchmark_minimal
    test_benchmark_normal  
    test_benchmark_full
    test_analyze_results
    
    echo "✅ Tous les benchmarks des profils sont terminés !"
    echo "📊 Résultats: $BENCHMARK_RESULTS"
    echo "📈 Rapport: /tmp/aklo_benchmark_report.md"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi