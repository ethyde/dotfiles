#!/bin/bash
#==============================================================================
# Auto-complétion Bash pour Aklo
# Installation: source ce fichier dans ~/.bashrc ou ~/.bash_profile
#==============================================================================

_aklo_completion() {
    local cur prev words cword
    _init_completion || return

    # Commandes principales d'Aklo
    local commands="init propose-pbi plan start-task submit-task merge-task release hotfix new status quickstart validate help"
    
    # Sous-commandes pour certaines commandes
    local release_types="major minor patch"
    local hotfix_subcommands="publish"
    local new_types="debug refactor architecture security documentation"
    local status_options="--brief --detailed --json"
    local quickstart_options="--template --skip-tutorial"
    
    # Si on est en train de compléter la première commande
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi
    
    # Complétion contextuelle selon la commande
    case "${words[1]}" in
        "propose-pbi")
            case "$prev" in
                "--template")
                    COMPREPLY=($(compgen -W "feature bug epic research" -- "$cur"))
                    ;;
                "--priority")
                    COMPREPLY=($(compgen -W "high medium low" -- "$cur"))
                    ;;
                *)
                    COMPREPLY=($(compgen -W "--interactive --template --priority --help" -- "$cur"))
                    ;;
            esac
            ;;
        "plan")
            if [[ $cword -eq 2 ]]; then
                # Compléter avec les IDs de PBI disponibles
                local pbi_ids=""
                if [[ -d "docs/backlog/00-pbi" ]]; then
                    pbi_ids=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | \
                        sed 's/.*PBI-\([0-9]*\)-.*/\1/' | sort -n | tr '\n' ' ')
                fi
                COMPREPLY=($(compgen -W "$pbi_ids" -- "$cur"))
            else
                case "$prev" in
                    "--template")
                        COMPREPLY=($(compgen -W "api frontend backend fullstack bug" -- "$cur"))
                        ;;
                    *)
                        COMPREPLY=($(compgen -W "--auto --template --estimate --help" -- "$cur"))
                        ;;
                esac
            fi
            ;;
        "start-task")
            if [[ $cword -eq 2 ]]; then
                # Compléter avec les IDs de tâches disponibles
                local task_ids=""
                if [[ -d "docs/backlog/01-tasks" ]]; then
                    task_ids=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | \
                        sed 's/.*TASK-\([0-9]*\)-.*/\1/' | sort -n | tr '\n' ' ')
                fi
                COMPREPLY=($(compgen -W "$task_ids" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--branch --help" -- "$cur"))
            fi
            ;;
        "merge-task")
            if [[ $cword -eq 2 ]]; then
                # Compléter avec les IDs de tâches disponibles
                local task_ids=""
                if [[ -d "docs/backlog/01-tasks" ]]; then
                    task_ids=$(find docs/backlog/01-tasks -name "TASK-*.md" 2>/dev/null | \
                        sed 's/.*TASK-\([0-9]*\)-.*/\1/' | sort -n | tr '\n' ' ')
                fi
                COMPREPLY=($(compgen -W "$task_ids" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--help" -- "$cur"))
            fi
            ;;
        "release")
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$release_types" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--help" -- "$cur"))
            fi
            ;;
        "hotfix")
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$hotfix_subcommands" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--help" -- "$cur"))
            fi
            ;;
        "new")
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$new_types" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--help" -- "$cur"))
            fi
            ;;
        "status")
            COMPREPLY=($(compgen -W "$status_options --help" -- "$cur"))
            ;;
        "quickstart")
            case "$prev" in
                "--template")
                    COMPREPLY=($(compgen -W "webapp api library mobile desktop" -- "$cur"))
                    ;;
                *)
                    COMPREPLY=($(compgen -W "$quickstart_options --help" -- "$cur"))
                    ;;
            esac
            ;;
        "validate")
            COMPREPLY=($(compgen -W "--fix --verbose --help" -- "$cur"))
            ;;
        *)
            # Pour toutes les autres commandes, proposer --help
            COMPREPLY=($(compgen -W "--help" -- "$cur"))
            ;;
    esac
}

# Enregistrer la fonction de complétion pour la commande 'aklo'
complete -F _aklo_completion aklo

# Instructions d'installation
cat << 'EOF'
# Auto-complétion Aklo installée !
# 
# Pour activer dans votre session courante :
#   source aklo-completion.bash
#
# Pour activer de façon permanente, ajoutez à ~/.bashrc :
#   source /path/to/aklo-completion.bash
#
# Testez avec :
#   aklo <TAB><TAB>
#   aklo propose-pbi --<TAB><TAB>
#   aklo plan <TAB><TAB>
EOF