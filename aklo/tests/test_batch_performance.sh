#!/bin/bash

# Tests de performance pour les optimisations I/O par batch
# TASK-7-2: Mesure de l'amélioration des performances

# Source des fonctions
script_dir="$(dirname "$0")"
source "${script_dir}/../bin/aklo_batch_io.sh"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration des tests
TEST_DIR="/tmp/aklo_perf_test"
NUM_FILES=50

# Setup des fichiers de test
setup_performance_test() {
    echo "🔧 Configuration des tests de performance..."
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    
    # Créer de nombreux fichiers pour tester les performances
    for i in $(seq 1 $NUM_FILES); do
        echo "Content of file $i - $(date)" > "$TEST_DIR/file_$i.txt"
    done
    
    echo "✓ $NUM_FILES fichiers créés dans $TEST_DIR"
}

# Nettoyage
cleanup_performance_test() {
    rm -rf "$TEST_DIR"
}

# Test de performance: Lecture individuelle vs batch
test_read_performance() {
    echo -e "${BLUE}=== Test de performance: Lecture de fichiers ===${NC}"
    
    local files=()
    for i in $(seq 1 $NUM_FILES); do
        files+=("$TEST_DIR/file_$i.txt")
    done
    
    # Reset des métriques
    reset_io_metrics
    
    echo "📊 Test 1: Lecture individuelle (méthode classique)"
    local start_time=$(date +%s%N)
    local individual_result=""
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            individual_result="$individual_result$(cat "$file" 2>/dev/null) "
        fi
    done
    local end_time=$(date +%s%N)
    local individual_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local individual_syscalls=$NUM_FILES  # Un syscall par fichier
    
    echo "  ⏱️  Durée: ${individual_duration}ms"
    echo "  🔧 Syscalls: $individual_syscalls"
    
    # Reset des métriques pour le test batch
    reset_io_metrics
    
    echo "📊 Test 2: Lecture batch (méthode optimisée)"
    start_time=$(date +%s%N)
    local batch_result=$(batch_read_files "${files[@]}")
    end_time=$(date +%s%N)
    local batch_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local batch_syscalls=$(get_io_metrics | grep -o '[0-9]*' | head -1)
    
    echo "  ⏱️  Durée: ${batch_duration}ms"
    echo "  🔧 Syscalls: $batch_syscalls"
    
    # Calcul de l'amélioration
    if [ $individual_duration -gt 0 ] && [ $batch_duration -gt 0 ]; then
        local time_improvement=$(( (individual_duration - batch_duration) * 100 / individual_duration ))
        local syscall_reduction=$(( (individual_syscalls - batch_syscalls) * 100 / individual_syscalls ))
        
        echo -e "${GREEN}📈 Amélioration temps: ${time_improvement}%${NC}"
        echo -e "${GREEN}📉 Réduction syscalls: ${syscall_reduction}%${NC}"
        
        if [ $syscall_reduction -ge 40 ]; then
            echo -e "${GREEN}✓ Objectif de réduction de 40-60% des syscalls atteint${NC}"
        else
            echo -e "${YELLOW}⚠ Objectif de réduction de 40-60% des syscalls non atteint${NC}"
        fi
    fi
    
    echo
}

# Test de performance: Vérification d'existence individuelle vs batch
test_existence_performance() {
    echo -e "${BLUE}=== Test de performance: Vérification d'existence ===${NC}"
    
    local files=()
    for i in $(seq 1 $NUM_FILES); do
        files+=("$TEST_DIR/file_$i.txt")
    done
    
    echo "📊 Test 1: Vérification individuelle (méthode classique)"
    local start_time=$(date +%s%N)
    local individual_count=0
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            individual_count=$((individual_count + 1))
        fi
    done
    local end_time=$(date +%s%N)
    local individual_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local individual_syscalls=$NUM_FILES  # Un syscall par fichier
    
    echo "  ⏱️  Durée: ${individual_duration}ms"
    echo "  🔧 Syscalls: $individual_syscalls"
    echo "  📁 Fichiers trouvés: $individual_count"
    
    # Reset des métriques pour le test batch
    reset_io_metrics
    
    echo "📊 Test 2: Vérification batch (méthode optimisée)"
    start_time=$(date +%s%N)
    local batch_result=$(batch_check_existence "${files[@]}")
    local batch_count=$(echo "$batch_result" | grep -o "exists" | wc -l)
    end_time=$(date +%s%N)
    local batch_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local batch_syscalls=$(get_io_metrics | grep -o '[0-9]*' | head -1)
    
    echo "  ⏱️  Durée: ${batch_duration}ms"
    echo "  🔧 Syscalls: $batch_syscalls"
    echo "  📁 Fichiers trouvés: $batch_count"
    
    # Calcul de l'amélioration
    if [ $individual_duration -gt 0 ] && [ $batch_duration -gt 0 ]; then
        local time_improvement=$(( (individual_duration - batch_duration) * 100 / individual_duration ))
        local syscall_reduction=$(( (individual_syscalls - batch_syscalls) * 100 / individual_syscalls ))
        
        echo -e "${GREEN}📈 Amélioration temps: ${time_improvement}%${NC}"
        echo -e "${GREEN}📉 Réduction syscalls: ${syscall_reduction}%${NC}"
    fi
    
    echo
}

# Test du cache de scan de répertoires
test_scan_cache_performance() {
    echo -e "${BLUE}=== Test de performance: Cache de scan de répertoires ===${NC}"
    
    echo "📊 Test 1: Premier scan (sans cache)"
    reset_io_metrics
    local start_time=$(date +%s%N)
    local first_scan=$(batch_scan_directory "$TEST_DIR" "*.txt")
    local end_time=$(date +%s%N)
    local first_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local first_syscalls=$(get_io_metrics | grep -o '[0-9]*' | head -1)
    
    echo "  ⏱️  Durée: ${first_duration}ms"
    echo "  🔧 Syscalls: $first_syscalls"
    echo "  📁 Fichiers trouvés: $(echo "$first_scan" | wc -w)"
    
    echo "📊 Test 2: Second scan (avec cache)"
    reset_io_metrics
    start_time=$(date +%s%N)
    local second_scan=$(batch_scan_directory "$TEST_DIR" "*.txt")
    end_time=$(date +%s%N)
    local second_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    local second_syscalls=$(get_io_metrics | grep -o '[0-9]*' | head -1)
    
    echo "  ⏱️  Durée: ${second_duration}ms"
    echo "  🔧 Syscalls: $second_syscalls"
    echo "  📁 Fichiers trouvés: $(echo "$second_scan" | wc -w)"
    
    if [ $first_duration -gt 0 ] && [ $second_duration -gt 0 ]; then
        local cache_improvement=$(( (first_duration - second_duration) * 100 / first_duration ))
        echo -e "${GREEN}📈 Amélioration cache: ${cache_improvement}%${NC}"
    fi
    
    echo
}

# Exécution des tests
main() {
    echo -e "${BLUE}🚀 Tests de performance - Optimisations I/O par batch${NC}"
    echo "Nombre de fichiers de test: $NUM_FILES"
    echo
    
    setup_performance_test
    
    test_read_performance
    test_existence_performance
    test_scan_cache_performance
    
    cleanup_performance_test
    
    echo -e "${GREEN}✅ Tests de performance terminés${NC}"
}

# Lancer les tests si le script est exécuté directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi