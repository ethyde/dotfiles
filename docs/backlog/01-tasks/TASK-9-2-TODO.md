# TASK-9-2 : Implémentation outil `project_info` avec parsing JSON natif

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-9](../00-pbi/PBI-9-PROPOSED.md)
**Revue Architecturale Requise:** Oui
**Document d'Architecture (si applicable):** [ARCH-9-1-VALIDATED.md](../02-architecture/ARCH-9-1-VALIDATED.md)
**Assigné à:** `Non assigné`
**Branche Git:** `feature/task-9-2`

---

## 1. Objectif Technique

Implémenter l'outil `project_info` dans le serveur MCP shell natif avec parsing JSON hybride (détection `jq` + fallback natif) pour extraire les informations de projet.

**Fichiers à modifier :**
- `/aklo/modules/mcp/shell-native/aklo-terminal.sh`

**Résultat attendu :**
- Nouvel outil `project_info` disponible dans le serveur MCP shell natif
- Parsing JSON hybride fonctionnel (avec fallback `jq` si disponible)
- Extraction des informations Git (branch, status, remote)
- Lecture de la configuration Aklo (.aklo.conf)
- Métriques projet (comptage PBI, tasks, etc.)

## 2. Contexte et Fichiers Pertinents

### Architecture Validée
[ARCH-9-1-VALIDATED.md](../02-architecture/ARCH-9-1-VALIDATED.md)

### Serveur Node.js de référence
```javascript
// aklo/modules/mcp/terminal/index.js - Lignes 100-112
{
  name: 'project_info',
  description: 'Récupère les informations sur le projet courant (package.json, git, aklo config)',
  inputSchema: {
    type: 'object',
    properties: {
      workdir: {
        type: 'string',
        description: 'Répertoire du projet',
      },
    },
  },
}
```

### Parsing JSON hybride validé
```bash
# Priorité à jq si disponible, sinon fallback manuel optimisé
parse_json_hybrid() {
    local file="$1"
    local key="$2"
    
    if command -v jq >/dev/null 2>&1; then
        jq -r ".$key // \"N/A\"" "$file" 2>/dev/null
    else
        # Fallback pour structures simples
        grep "\"$key\"" "$file" | head -1 | sed 's/.*"'"$key"'": *"\([^"]*\)".*/\1/'
    fi
}
```

### Informations à extraire
```bash
# package.json
- name, version, description

# Git
- current branch, status (clean/dirty), remote URL

# Aklo config (.aklo.conf)
- agent_assistance, auto_journal

# Métriques projet
- Nombre de PBI et tasks par statut
```

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Analyser la structure** du serveur shell natif actuel
2. **Ajouter `project_info`** à la liste des outils dans `tools/list`
3. **Implémenter le parsing JSON hybride** avec détection `jq`
4. **Créer la fonction `handle_project_info`** qui :
   - Parse le paramètre workdir depuis JSON
   - Extrait les infos package.json (name, version, description) via parsing hybride
   - Récupère les informations Git (branch, status, remote)
   - Lit la configuration Aklo (.aklo.conf)
   - Compte les artefacts (PBI, tasks) par statut
   - Retourne un JSON structuré
5. **Ajouter le case `project_info`** dans `tools/call`
6. **Tester le parsing JSON** avec et sans `jq`
7. **Valider la compatibilité** avec le serveur Node.js

## 4. Définition de "Terminé" (Definition of Done)

- [ ] L'outil `project_info` est ajouté à la liste des outils MCP
- [ ] Le parsing JSON hybride fonctionne (avec et sans `jq`)
- [ ] Les informations package.json sont extraites correctement
- [ ] Les informations Git sont récupérées
- [ ] La configuration Aklo (.aklo.conf) est lue
- [ ] Les métriques projet sont calculées
- [ ] La réponse JSON est structurée et conforme au protocole MCP
- [ ] Tests manuels réussis sur différents projets
- [ ] Gestion gracieuse des fichiers manquants
- [ ] Documentation du parsing JSON dans les commentaires