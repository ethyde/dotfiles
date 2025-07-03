# PBI-9 : Étendre serveurs MCP shell natifs avec fonctionnalités complètes

## 📋 Description

Étendre les serveurs MCP shell natifs pour qu'ils offrent les mêmes fonctionnalités que les serveurs Node.js, rendant Node.js vraiment optionnel et renforçant l'approche "native-first".

## 🎯 Objectif Métier

- **Universalité** : Fonctionnalités complètes sur 100% des systèmes Unix
- **Simplicité** : 0 dépendances pour toutes les fonctionnalités MCP
- **Performance** : Serveurs légers et rapides
- **Cohérence** : Approche native-first réellement effective

## 🔍 Analyse Actuelle

### Serveurs Shell Natifs (2 outils)
- `aklo_execute_shell` : Commandes aklo basiques
- `aklo_status_shell` : Statut projet simple

### Serveurs Node.js (4 outils)  
- `aklo_execute` : Commandes aklo avec validation avancée
- `aklo_status` : Statut projet détaillé
- `safe_shell` : Exécution shell sécurisée
- `project_info` : Informations projet complètes

## 🎯 Fonctionnalités à Ajouter

### 1. Exécution Shell Sécurisée (`safe_shell`)
- Liste de commandes autorisées
- Validation des arguments
- Timeout configurable
- Gestion d'erreurs robuste

### 2. Informations Projet (`project_info`)
- Lecture package.json (avec parsing JSON natif)
- Informations Git (branch, status, remote)
- Configuration Aklo (.aklo.conf)
- Métriques projet (PBI count, tasks, etc.)

### 3. Validation Avancée Commandes Aklo
- Liste complète des commandes autorisées
- Validation des arguments
- Gestion contexte de travail
- Logs sécurisés

## 🛠️ Approche Technique

### Parsing JSON en Shell Natif
```bash
# Option 1: jq si disponible (fallback si absent)
# Option 2: parsing manuel avec sed/grep/awk
# Option 3: parsing hybride selon complexité
```

### Sécurité Shell
```bash
ALLOWED_COMMANDS=("ls" "cat" "grep" "find" "git" "npm" "node")
validate_command() {
    # Validation whitelist + arguments
}
```

### Gestion Timeout
```bash
execute_with_timeout() {
    timeout "$TIMEOUT" "$@" 2>&1
}
```

## 📊 Critères d'Acceptation

- [ ] Serveurs shell natifs offrent les 4 outils des serveurs Node.js
- [ ] Parsing JSON natif fonctionnel (avec fallback jq)
- [ ] Sécurité équivalente aux serveurs Node.js
- [ ] Performance supérieure aux serveurs Node.js
- [ ] Tests complets pour tous les outils
- [ ] Documentation mise à jour
- [ ] Rétrocompatibilité préservée

## 🔗 Dépendances

- Aucune dépendance externe requise
- Compatible avec tous les systèmes Unix
- Optionnel : `jq` pour parsing JSON avancé

## 📈 Impact Attendu

- **Adoption** : +100% (fonctionne partout)
- **Performance** : +50% (pas de Node.js)
- **Simplicité** : +200% (0 dépendances)
- **Maintenance** : +100% (code shell standard)

## 🗓️ Estimation

**Complexité** : Moyenne (3-4 jours)
**Priorité** : Haute (cohérence architecture native-first)

---

**Status** : PROPOSED
**Created** : 2025-01-28
**Owner** : Architecture Team