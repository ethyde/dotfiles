# Conventions de Configuration Aklo

## Vue d'ensemble

Ce document définit les conventions de nommage et de formatage pour les fichiers de configuration Aklo, en particulier `.aklo.conf`. Ces conventions garantissent la cohérence et la maintenabilité du code.

## Conventions de Nommage des Variables

### Variables Globales : UPPERCASE

Les variables définies au niveau global (racine du fichier) utilisent la convention **UPPERCASE** avec des underscores pour séparer les mots.

```bash
# ✅ CORRECT
PROJECT_WORKDIR=/Users/user/project
CACHE_ENABLED=true
VALIDATE_LINTER=true
AUTO_JOURNAL=false
LINTER_COMMAND="echo 'Linter configuré'"

# ❌ INCORRECT
project_workdir=/Users/user/project
cacheEnabled=true
```

**Rationale :** Les variables globales sont souvent exportées vers l'environnement shell et suivent la convention POSIX standard.

### Variables de Section : lowercase

Les variables définies dans des sections `[section_name]` utilisent la convention **lowercase** avec des underscores pour séparer les mots.

```bash
# ✅ CORRECT
[cache]
enabled=true
cache_dir=/tmp/aklo_cache
max_size_mb=100
ttl_days=7

[performance_profiles]
default_profile=NORMAL
auto_detection=true
override_enabled=true

[profile.minimal]
modules="core/basic_functions"
target_time="0.050"
description="Commandes de configuration rapides"

# ❌ INCORRECT
[cache]
ENABLED=true
CacheDir=/tmp/aklo_cache
MaxSizeMb=100
```

**Rationale :** Les variables de section sont des configurations locales qui ne sont pas exportées globalement et suivent une convention plus lisible.

## Conventions de Formatage

### Guillemets pour les Valeurs Textuelles

Toutes les valeurs contenant des espaces, des caractères spéciaux ou des chaînes de caractères doivent être entourées de guillemets doubles.

```bash
# ✅ CORRECT
description="Commandes de configuration rapides"
modules="core/basic_functions cache/regex_cache"
LINTER_COMMAND="echo 'Test réussi'"

# ❌ INCORRECT (risque d'injection et d'erreurs de parsing)
description=Commandes de configuration rapides
modules=core/basic_functions cache/regex_cache
```

### Noms de Sections

Les noms de sections utilisent la convention **lowercase** avec des points pour la hiérarchie.

```bash
# ✅ CORRECT
[cache]
[performance_profiles]
[profile.minimal]
[profile.normal]
[profile.full]

# ❌ INCORRECT
[Cache]
[PERFORMANCE_PROFILES]
[Profile.Minimal]
```

## Structure Type d'un Fichier .aklo.conf

```bash
# Configuration Aklo pour le projet [nom_projet]
# Générée automatiquement lors de la vérification de conformité

# Variables globales (UPPERCASE)
PROJECT_WORKDIR=/path/to/project
CACHE_ENABLED=true
VALIDATE_LINTER=true
LINTER_COMMAND="echo 'Linter configuré'"

# Section de configuration (lowercase)
[cache]
enabled=true
cache_dir="/tmp/aklo_cache"
max_size_mb=100

[performance_profiles]
default_profile="NORMAL"
auto_detection=true

[profile.minimal]
modules="core/basic_functions"
target_time="0.050"
description="Commandes de configuration rapides"
```

## Validation et Tests

### Règles de Validation

1. **Variables globales** : Doivent être en UPPERCASE
2. **Variables de section** : Doivent être en lowercase
3. **Valeurs textuelles** : Doivent être entre guillemets doubles
4. **Noms de sections** : Doivent être en lowercase avec points pour hiérarchie

### Tests de Non-Régression

Les tests suivants doivent être exécutés pour valider le respect des conventions :

```bash
# Test des variables globales
grep -E "^[A-Z_]+=.*$" .aklo.conf

# Test des variables de section
grep -E "^\[.*\]$" -A 10 .aklo.conf | grep -E "^[a-z_]+=.*$"

# Test des guillemets pour valeurs textuelles
grep -E "=\".*\"$" .aklo.conf
```

## Historique des Modifications

### Version 1.0 (2025-01-28)
- **Commit :** `7f5b711` - fix(config): Harmonisation des conventions de nommage des variables
- **Changements :** Standardisation initiale des conventions
- **Impact :** Variables de profils de performance harmonisées

## Outils de Validation

### Script de Validation (Futur)

Un script de validation automatique pourrait être créé pour vérifier le respect de ces conventions :

```bash
#!/bin/bash
# validate-config.sh
# Valide le respect des conventions dans .aklo.conf
```

### Intégration CI/CD

Ces validations devraient être intégrées dans les pipelines de CI/CD pour prévenir les régressions.

## Exemples d'Erreurs Communes

### ❌ Mélange de Conventions

```bash
# INCORRECT - Mélange de conventions
PROJECT_WORKDIR=/path/to/project  # Global UPPERCASE ✅
cache_enabled=true                # Global lowercase ❌

[cache]
ENABLED=true                      # Section UPPERCASE ❌
cache_dir=/tmp/cache              # Section lowercase ✅
```

### ❌ Valeurs Sans Guillemets

```bash
# INCORRECT - Risque d'injection
description=Commandes de configuration rapides  # ❌
modules=core/basic_functions cache/regex_cache  # ❌

# CORRECT
description="Commandes de configuration rapides"  # ✅
modules="core/basic_functions cache/regex_cache"  # ✅
```

## Contact et Maintenance

Pour toute question sur ces conventions ou pour proposer des modifications, référez-vous au protocole META-IMPROVEMENT de la Charte IA Aklo.

---

**Note :** Ce document fait partie intégrante de la documentation technique Aklo et doit être maintenu à jour lors de toute modification des conventions.