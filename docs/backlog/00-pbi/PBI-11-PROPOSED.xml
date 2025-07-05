# PBI-11 : Créer serveur MCP documentation shell natif étendu

## 📋 Description

Étendre le serveur MCP documentation shell natif pour qu'il offre toutes les fonctionnalités du serveur Node.js, incluant la validation d'artefacts et la recherche avancée.

## 🎯 Objectif Métier

- **Parité fonctionnelle** : Mêmes capacités que le serveur Node.js
- **Performance** : Serveur léger et rapide
- **Universalité** : Fonctionne sur tous les systèmes Unix
- **Maintenance** : Code shell standard, facile à déboguer

## 🔍 Analyse Actuelle

### Serveur Shell Actuel (3 outils)
- `read_protocol_shell` : Lecture protocoles basique
- `list_protocols_shell` : Liste protocoles
- `search_documentation_shell` : Recherche simple

### Serveur Node.js (7 outils)
- `read_protocol` : Lecture protocoles avec sections
- `list_protocols` : Liste avec métadonnées
- `search_documentation` : Recherche avec scope
- `read_artefact` : Lecture artefacts avec métadonnées
- `project_documentation_summary` : Résumé complet
- `validate_artefact` : Validation selon protocoles
- `server_info` : Informations serveur

## 🎯 Fonctionnalités à Ajouter

### 1. Lecture Artefacts (`read_artefact`)
- Parsing des en-têtes d'artefacts
- Extraction métadonnées (status, dates, owner)
- Support tous types (PBI, TASK, DEBUG, etc.)
- Validation format basique

### 2. Validation Artefacts (`validate_artefact`)
- Validation structure selon protocoles
- Vérification champs obligatoires
- Contrôle cohérence (dates, status, etc.)
- Rapport de validation détaillé

### 3. Résumé Documentation (`project_documentation_summary`)
- Scan complet répertoire documentation
- Comptage artefacts par type et status
- Métriques projet (vélocité, qualité)
- Génération rapport structuré

### 4. Recherche Avancée
- Recherche avec scope (protocols/artefacts/all)
- Filtrage par type d'artefact
- Recherche dans métadonnées
- Résultats avec contexte

## 🛠️ Approche Technique

### Parsing Métadonnées Artefacts
```bash
extract_metadata() {
    local file="$1"
    # Extraction en-tête YAML/Markdown
    # Status, dates, owner, type
    # Validation format
}
```

### Validation Protocoles
```bash
validate_pbi() {
    # Vérification structure PBI
    # Champs obligatoires
    # Cohérence business
}

validate_task() {
    # Vérification structure TASK
    # Lien PBI parent
    # Critères acceptation
}
```

### Recherche Multi-Scope
```bash
search_with_scope() {
    local query="$1"
    local scope="$2"  # protocols|artefacts|all
    
    case "$scope" in
        "protocols") search_protocols "$query" ;;
        "artefacts") search_artefacts "$query" ;;
        "all") search_all "$query" ;;
    esac
}
```

### Génération Résumés
```bash
generate_project_summary() {
    # Scan docs/backlog/
    # Comptage par type/status
    # Métriques temporelles
    # Format JSON/Markdown
}
```

## 📊 Critères d'Acceptation

- [ ] 7 outils équivalents au serveur Node.js
- [ ] Parsing métadonnées artefacts fonctionnel
- [ ] Validation complète selon protocoles Aklo
- [ ] Recherche avancée avec scopes
- [ ] Génération résumés projet automatique
- [ ] Performance équivalente ou supérieure
- [ ] Tests complets pour tous les outils
- [ ] Documentation mise à jour

## 🔗 Dépendances

- Accès aux protocoles Aklo (charte/)
- Structure projet Aklo standard
- Optionnel : `jq` pour JSON complexe

## 📈 Impact Attendu

- **Fonctionnalités** : +100% (parité Node.js)
- **Performance** : +30% (pas d'overhead Node.js)
- **Adoption** : +200% (0 dépendances)
- **Maintenance** : +150% (shell standard)

## 🔧 Implémentation Technique

### Structure Serveur Étendu
```bash
#!/bin/sh
# Serveur MCP Documentation Aklo - Version Complète

# 7 outils disponibles
handle_tool_call() {
    case "$tool_name" in
        "read_protocol") handle_read_protocol ;;
        "list_protocols") handle_list_protocols ;;
        "search_documentation") handle_search_documentation ;;
        "read_artefact") handle_read_artefact ;;
        "validate_artefact") handle_validate_artefact ;;
        "project_documentation_summary") handle_project_summary ;;
        "server_info") handle_server_info ;;
    esac
}
```

## 🗓️ Estimation

**Complexité** : Moyenne-Haute (5-6 jours)
**Priorité** : Haute (parité fonctionnelle)

---

**Status** : PROPOSED
**Created** : 2025-01-28
**Owner** : Documentation Team