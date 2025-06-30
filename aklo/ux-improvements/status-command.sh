#!/bin/bash
#==============================================================================
# Amélioration UX : Commande aklo status avancée
# Tableau de bord complet du projet
#==============================================================================

# Fonction principale de status
aklo_status() {
    local mode="${1:-standard}"
    
    case "$mode" in
        "--brief"|"-b")
            show_status_brief
            ;;
        "--detailed"|"-d")
            show_status_detailed
            ;;
        "--json")
            show_status_json
            ;;
        *)
            show_status_standard
            ;;
    esac
}

# Status standard avec tableau de bord visuel
show_status_standard() {
    echo "🤖 Aklo Project Status Dashboard"
    echo "$(printf '%.0s═' {1..50})"
    
    # Configuration du projet
    show_project_config
    
    # État des PBI
    show_pbi_status
    
    # État des tâches
    show_tasks_status
    
    # État Git
    show_git_status
    
    # Résumé
    show_status_summary
}

# Configuration et initialisation
show_project_config() {
    echo ""
    echo "📋 Configuration Projet"
    echo "$(printf '%.0s─' {1..30})"
    
    if [ -f ".aklo.conf" ]; then
        local workdir=$(grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2)
        local project_name=$(basename "$(pwd)")
        
        echo "✅ Projet Aklo initialisé"
        echo "📁 Nom: $project_name"
        echo "📂 Workdir: $workdir"
        echo "🔧 Config: .aklo.conf trouvé"
    else
        echo "❌ Projet non initialisé"
        echo "💡 Exécutez: aklo init"
        return 1
    fi
    
    # Vérifier la charte
    if [ -d "charte" ]; then
        local protocols_count=$(find charte/PROTOCOLES -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        echo "📚 Charte: $protocols_count protocoles liés"
    else
        echo "⚠️  Charte non liée"
    fi
}

# État des Product Backlog Items
show_pbi_status() {
    echo ""
    echo "📋 Product Backlog Items (PBI)"
    echo "$(printf '%.0s─' {1..30})"
    
    if [ ! -d "docs/backlog/00-pbi" ]; then
        echo "📭 Aucun PBI créé"
        echo "💡 Créez votre premier PBI: aklo propose-pbi \"Titre\""
        return
    fi
    
    local total_pbi=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$total_pbi" -eq 0 ]; then
        echo "📭 Aucun PBI créé"
        return
    fi
    
    echo "📊 Total PBI: $total_pbi"
    
    # Compter par statut (analyse basique du contenu)
    local proposed=0
    local planned=0
    local in_progress=0
    local done=0
    
    for pbi_file in docs/backlog/00-pbi/PBI-*.md; do
        if [ -f "$pbi_file" ]; then
            if grep -q "Status.*PROPOSED" "$pbi_file" 2>/dev/null; then
                proposed=$((proposed + 1))
            elif grep -q "Status.*PLANNED" "$pbi_file" 2>/dev/null; then
                planned=$((planned + 1))
            elif grep -q "Status.*IN_PROGRESS" "$pbi_file" 2>/dev/null; then
                in_progress=$((in_progress + 1))
            elif grep -q "Status.*DONE" "$pbi_file" 2>/dev/null; then
                done=$((done + 1))
            else
                proposed=$((proposed + 1))  # Défaut
            fi
        fi
    done
    
    echo "🔵 Proposés: $proposed"
    echo "🟡 Planifiés: $planned" 
    echo "🟠 En cours: $in_progress"
    echo "🟢 Terminés: $done"
    
    # PBI les plus récents
    echo ""
    echo "📝 PBI récents:"
    find docs/backlog/00-pbi -name "PBI-*.md" -type f 2>/dev/null | \
        sort -V | tail -3 | while read -r pbi; do
        local pbi_name=$(basename "$pbi" .md)
        local pbi_title=$(echo "$pbi_name" | sed 's/PBI-[0-9]*-//')
        echo "   • $pbi_title"
    done
}

# État des tâches
show_tasks_status() {
    echo ""
    echo "🔧 Tâches"
    echo "$(printf '%.0s─' {1..30})"
    
    if [ ! -d "docs/backlog/01-tasks" ]; then
        echo "📭 Aucune tâche créée"
        echo "💡 Planifiez un PBI: aklo plan <PBI_ID>"
        return
    fi
    
    local total_tasks=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$total_tasks" -eq 0 ]; then
        echo "📭 Aucune tâche créée"
        return
    fi
    
    echo "📊 Total tâches: $total_tasks"
    
    # Tâches par statut
    local todo=0
    local in_progress=0
    local done=0
    
    for task_file in docs/backlog/01-tasks/TASK-*.md; do
        if [ -f "$task_file" ]; then
            if grep -q "Status.*TODO" "$task_file" 2>/dev/null; then
                todo=$((todo + 1))
            elif grep -q "Status.*IN_PROGRESS" "$task_file" 2>/dev/null; then
                in_progress=$((in_progress + 1))
            elif grep -q "Status.*DONE" "$task_file" 2>/dev/null; then
                done=$((done + 1))
            else
                todo=$((todo + 1))  # Défaut
            fi
        fi
    done
    
    echo "⚪ À faire: $todo"
    echo "🟡 En cours: $in_progress"
    echo "🟢 Terminées: $done"
    
    # Tâche courante (si en cours)
    if [ "$in_progress" -gt 0 ]; then
        echo ""
        echo "🚀 Tâche courante:"
        find docs/backlog/01-tasks -name "TASK-*.md" -type f 2>/dev/null | \
            xargs grep -l "Status.*IN_PROGRESS" 2>/dev/null | head -1 | while read -r task; do
            local task_name=$(basename "$task" .md)
            local task_title=$(echo "$task_name" | sed 's/TASK-[0-9]*-[0-9]*-//')
            echo "   🎯 $task_title"
        done
    fi
}

# État Git
show_git_status() {
    echo ""
    echo "🌿 Git Status"
    echo "$(printf '%.0s─' {1..30})"
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Pas un dépôt Git"
        echo "💡 Initialisez: git init"
        return
    fi
    
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commits_ahead=$(git rev-list --count HEAD ^origin/$current_branch 2>/dev/null || echo "0")
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    
    echo "🌿 Branche: $current_branch"
    echo "📤 Commits en attente: $commits_ahead"
    echo "📝 Fichiers non commités: $uncommitted"
    
    # Branches de feature actives
    local feature_branches=$(git branch | grep -E "(feature|task)" | wc -l | tr -d ' ')
    if [ "$feature_branches" -gt 0 ]; then
        echo "🔀 Branches de feature: $feature_branches"
    fi
    
    # Dernière activité
    local last_commit=$(git log -1 --format="%cr" 2>/dev/null || echo "inconnu")
    echo "🕒 Dernier commit: $last_commit"
}

# Résumé et conseils
show_status_summary() {
    echo ""
    echo "📈 Résumé & Conseils"
    echo "$(printf '%.0s─' {1..30})"
    
    # Calcul de métriques simples
    local total_pbi=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l | tr -d ' ')
    local total_tasks=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$total_pbi" -eq 0 ]; then
        echo "🎯 Prochaine étape: Créer votre premier PBI"
        echo "   aklo propose-pbi \"Nom de votre fonctionnalité\""
    elif [ "$total_tasks" -eq 0 ]; then
        echo "🎯 Prochaine étape: Planifier vos PBI"
        echo "   aklo plan 1"
    else
        echo "🎯 Projet actif avec $total_pbi PBI et $total_tasks tâches"
        
        # Conseils basés sur l'état
        local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$uncommitted" -gt 0 ]; then
            echo "💡 Conseil: Vous avez des changements non commités"
            echo "   git add . && git commit -m \"Description\""
        fi
    fi
    
    echo ""
    echo "🔧 Commandes utiles:"
    echo "   aklo quickstart    # Mode guidé débutant"
    echo "   aklo validate      # Vérifier la configuration"
    echo "   aklo --help        # Aide complète"
}

# Status brief (version condensée)
show_status_brief() {
    local total_pbi=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l | tr -d ' ')
    local total_tasks=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | wc -l | tr -d ' ')
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    echo "🤖 Aklo Status: $total_pbi PBI, $total_tasks tâches, branche $current_branch"
    
    if [ -f ".aklo.conf" ]; then
        echo "✅ Configuré"
    else
        echo "❌ Non configuré - exécutez: aklo init"
    fi
}

# Status JSON (pour intégrations)
show_status_json() {
    local total_pbi=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l | tr -d ' ')
    local total_tasks=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | wc -l | tr -d ' ')
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local is_configured="false"
    
    if [ -f ".aklo.conf" ]; then
        is_configured="true"
    fi
    
    cat << EOF
{
  "aklo": {
    "configured": $is_configured,
    "pbi": {
      "total": $total_pbi
    },
    "tasks": {
      "total": $total_tasks
    },
    "git": {
      "current_branch": "$current_branch"
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
}

# Point d'entrée principal
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    aklo_status "$@"
fi