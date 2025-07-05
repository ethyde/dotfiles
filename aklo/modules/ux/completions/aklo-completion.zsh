#!/bin/zsh
#==============================================================================
# Auto-complétion Zsh pour Aklo
# Installation: source ce fichier dans ~/.zshrc
#==============================================================================

#compdef aklo

_aklo() {
    local context state line
    typeset -A opt_args

    _arguments -C \
        '1: :_aklo_commands' \
        '*:: :->args' && return 0

    case $state in
        args)
            case $words[1] in
                propose-pbi)
                    _arguments \
                        '--interactive[Mode interactif]' \
                        '--template[Utilise un template]:template:(feature bug epic research)' \
                        '--priority[Définit la priorité]:priority:(high medium low)' \
                        '--help[Affiche l'\''aide]' \
                        '*:title:_message "titre du PBI"'
                    ;;
                plan)
                    _arguments \
                        '--auto[Génération automatique]' \
                        '--template[Template de décomposition]:template:(api frontend backend fullstack bug)' \
                        '--estimate[Mode estimation]' \
                        '--help[Affiche l'\''aide]' \
                        '1:pbi_id:_aklo_pbi_ids'
                    ;;
                start-task)
                    _arguments \
                        '--branch[Nom de branche personnalisé]:branch_name:' \
                        '--help[Affiche l'\''aide]' \
                        '1:task_id:_aklo_task_ids'
                    ;;
                submit-task)
                    _arguments \
                        '--message[Message de commit]:message:' \
                        '--help[Affiche l'\''aide]'
                    ;;
                merge-task)
                    _arguments \
                        '--help[Affiche l'\''aide]' \
                        '1:task_id:_aklo_task_ids'
                    ;;
                release)
                    _arguments \
                        '--help[Affiche l'\''aide]' \
                        '1:type:(major minor patch)'
                    ;;
                hotfix)
                    _arguments \
                        '--help[Affiche l'\''aide]' \
                        '1:action:(publish)' \
                        '*:description:_message "description du hotfix"'
                    ;;
                new)
                    _arguments \
                        '--help[Affiche l'\''aide]' \
                        '1:type:(debug refactor architecture security documentation)' \
                        '*:args:_message "arguments additionnels"'
                    ;;
                status)
                    _arguments \
                        '--brief[Affichage condensé]' \
                        '--detailed[Affichage détaillé]' \
                        '--json[Sortie JSON]' \
                        '--help[Affiche l'\''aide]'
                    ;;
                quickstart)
                    _arguments \
                        '--template[Template de projet]:template:(webapp api library mobile desktop)' \
                        '--skip-tutorial[Ignore le tutoriel]' \
                        '--help[Affiche l'\''aide]'
                    ;;
                validate)
                    _arguments \
                        '--fix[Répare automatiquement]' \
                        '--verbose[Mode verbeux]' \
                        '--help[Affiche l'\''aide]'
                    ;;
                *)
                    _arguments '--help[Affiche l'\''aide]'
                    ;;
            esac
            ;;
    esac
}

# Fonction pour compléter les commandes principales
_aklo_commands() {
    local commands=(
        'init:Lie la Charte Aklo au projet'
        'propose-pbi:Crée un nouveau PBI'
        'plan:Planifie les tâches d'\''un PBI'
        'start-task:Commence une tâche'
        'submit-task:Soumet une tâche pour review'
        'merge-task:Merge une tâche validée'
        'release:Démarre un processus de release'
        'hotfix:Gère les hotfixes'
        'new:Crée un nouvel artefact'
        'status:Affiche l'\''état du projet'
        'quickstart:Mode guidé pour débutants'
        'validate:Valide la configuration'
        'help:Affiche l'\''aide'
    )
    
    _describe 'commands' commands
}

# Fonction pour compléter les IDs de PBI
_aklo_pbi_ids() {
    local pbi_ids=()
    
    if [[ -d "docs/backlog/00-pbi" ]]; then
        for file in docs/backlog/00-pbi/PBI-*.xml(N); do
            if [[ -f "$file" ]]; then
                local id=${file:t}
                id=${id#PBI-}
                id=${id%%-*}
                pbi_ids+=("$id:$(head -1 "$file" 2>/dev/null | sed 's/^# *//' || echo 'PBI')")
            fi
        done
    fi
    
    if (( ${#pbi_ids} > 0 )); then
        _describe 'PBI IDs' pbi_ids
    else
        _message "Aucun PBI trouvé. Créez-en un avec: aklo propose-pbi"
    fi
}

# Fonction pour compléter les IDs de tâches
_aklo_task_ids() {
    local task_ids=()
    
    if [[ -d "docs/backlog/01-tasks" ]]; then
        for file in docs/backlog/01-tasks/TASK-*.xml(N); do
            if [[ -f "$file" ]]; then
                local id=${file:t}
                id=${id#TASK-}
                id=${id%%-*}
                task_ids+=("$id:$(head -1 "$file" 2>/dev/null | sed 's/^# *//' || echo 'Tâche')")
            fi
        done
    fi
    
    if (( ${#task_ids} > 0 )); then
        _describe 'Task IDs' task_ids
    else
        _message "Aucune tâche trouvée. Planifiez un PBI avec: aklo plan <PBI_ID>"
    fi
}

# Enregistrement de la fonction de complétion
_aklo "$@"

# Instructions d'installation pour Zsh
cat << 'EOF'
# Auto-complétion Aklo pour Zsh installée !
# 
# Pour activer dans votre session courante :
#   source aklo-completion.zsh
#
# Pour activer de façon permanente, ajoutez à ~/.zshrc :
#   source /path/to/aklo-completion.zsh
#
# Ou placez ce fichier dans un répertoire de complétion Zsh :
#   mkdir -p ~/.zsh/completions
#   cp aklo-completion.zsh ~/.zsh/completions/_aklo
#   echo 'fpath=(~/.zsh/completions $fpath)' >> ~/.zshrc
#   echo 'autoload -U compinit && compinit' >> ~/.zshrc
#
# Testez avec :
#   aklo <TAB>
#   aklo propose-pbi --<TAB>
#   aklo plan <TAB>
EOF