# TASK-9-1 : Implémentation outil `safe_shell` en shell natif

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-9](../00-pbi/PBI-9-IN_PROGRESS.md)
**Revue Architecturale Requise:** Oui
**Document d'Architecture (si applicable):** [ARCH-9-1-VALIDATED.md](../02-architecture/ARCH-9-1-VALIDATED.md)
**Assigné à:** `Non assigné`
**Branche Git:** `feature/task-9-1`

---

## 1. Objectif Technique

Implémenter l'outil `safe_shell` dans le serveur MCP shell natif (`aklo-terminal.sh`) pour permettre l'exécution sécurisée de commandes shell avec validation via un fichier `commands.whitelist` configurable, gestion des timeouts et logs sécurisés.

**Fichiers à modifier :**
- `/aklo/modules/mcp/shell-native/aklo-terminal.sh`
- `/aklo/config/commands.whitelist` (à créer)

**Résultat attendu :**
- Nouvel outil `safe_shell` disponible dans le serveur MCP shell natif
- Validation des commandes selon une whitelist configurable et externe
- Gestion des timeouts et erreurs robuste
- Sécurité équivalente au serveur Node.js

## 2. Contexte et Fichiers Pertinents

### Architecture Validée
[ARCH-9-1-VALIDATED.md](../02-architecture/ARCH-9-1-VALIDATED.md)

### Serveur Node.js de référence
```javascript
// aklo/modules/mcp/terminal/index.js - Lignes 67-85
{
  name: 'safe_shell',
  description: 'Exécute une commande shell sécurisée avec restrictions Aklo',
  inputSchema: {
    type: 'object',
    properties: {
      command: {
        type: 'string',
        description: 'Commande shell à exécuter',
      },
      workdir: {
        type: 'string',
        description: 'Répertoire de travail',
      },
      timeout: {
        type: 'number',
        description: 'Timeout en millisecondes (défaut: 30000)',
        default: 30000,
      },
    },
    required: ['command'],
  },
}
```

### Approche sécurité validée
```bash
# Whitelist des commandes autorisées dans aklo/config/commands.whitelist
# Fichier texte simple, une commande par ligne
# ls
# cat
# grep

validate_command_from_file() {
    local cmd="$1"
    local base_cmd=$(echo "$cmd" | awk '{print $1}')
    
    if grep -Fxq "$base_cmd" "aklo/config/commands.whitelist"; then
        return 0
    fi
    return 1
}

execute_with_timeout() {
    local timeout_val="$1"
    local workdir="$2"
    local command="$3"
    
    cd "$workdir" 2>/dev/null || return 1
    timeout "$timeout_val" sh -c "$command" 2>&1
}
```

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Analyser la structure actuelle** du serveur shell natif `aklo-terminal.sh`
2. **Ajouter `safe_shell`** à la liste des outils dans la réponse `tools/list`
3. **Implémenter la fonction `handle_safe_shell`** avec :
   - Parsing des paramètres JSON (command, workdir, timeout)
   - Lecture de la whitelist depuis `aklo/config/commands.whitelist`
   - Validation de la commande selon la whitelist
   - Exécution avec timeout dans le répertoire spécifié
   - Gestion des erreurs et retour JSON approprié
4. **Ajouter le case `safe_shell`** dans la fonction `tools/call`
5. **Tester la sécurité** avec des commandes interdites
6. **Valider la compatibilité** avec le serveur Node.js

## 4. Définition de "Terminé" (Definition of Done)

- [ ] L'outil `safe_shell` est ajouté à la liste des outils MCP
- [ ] La fonction `handle_safe_shell` est implémentée avec validation sécurisée depuis un fichier externe
- [ ] Les commandes non présentes dans la whitelist sont rejetées
- [ ] Le timeout fonctionne correctement (défaut 30s)
- [ ] L'exécution dans un répertoire spécifique fonctionne
- [ ] Les réponses JSON sont conformes au protocole MCP
- [ ] Tests manuels réussis avec commandes autorisées et interdites
- [ ] Documentation mise à jour dans les commentaires du code