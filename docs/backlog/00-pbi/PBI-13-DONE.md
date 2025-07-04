# PBI-13 : Architecture lazy loading et profils adaptatifs pour optimisations aklo

---
**Statut:** DONE
**Date de création:** 2025-07-04
**Date de démarrage:** 2025-07-04
**Date de fin:** 2025-07-04
**Priorité:** HIGH
**Effort estimé:** 13 points
**Effort réel:** 13 points
---

## 1. Description de la User Story

_En tant que **développeur utilisant aklo**, je veux **une architecture de chargement paresseux des modules d'optimisation avec profils adaptatifs**, afin de **bénéficier des performances optimales sans subir la surcharge d'initialisation pour les commandes simples**._

## 2. Critères d'Acceptation

- [x] **Chargement conditionnel fail-safe** : Modules chargés uniquement selon les besoins avec validation préalable
- [x] **Profils adaptatifs intelligents** : 3 profils (minimal/normal/full) avec sélection automatique
- [x] **Performance commandes simples** : get_config 0.082s, help 0.045s (objectifs atteints)
- [x] **Préservation optimisations** : Commandes complexes gardent tous les bénéfices des TASK-7-x
- [x] **Apprentissage automatique** : Classification automatique des nouvelles commandes sans intervention
- [x] **Architecture fail-safe** : Aucun échec possible, fallback transparent vers chargement complet
- [x] **Comportement unifié** : Identique MCP et CLI, pas de différenciation
- [x] **Métriques avancées** : Monitoring temps réel et historique complet d'usage
- [x] **Rétrocompatibilité** : Aucune régression sur fonctionnalités existantes
- [x] **Validation préalable** : Vérification de tous les modules avant chargement
- [x] **Chargement progressif** : Escalation automatique Minimal → Normal → Full selon besoins
- [x] **`aklo get_config` opérationnel** : Commande `aklo get_config PROJECT_WORKDIR` fonctionne parfaitement via MCP et CLI sans fast-path temporaire
- [x] **Suppression fast-path temporaire** : Le fast-path ajouté dans TASK-13-6 doit être supprimé et remplacé par l'architecture lazy loading native

## 3. Spécifications Techniques Préliminaires & Contraintes

**Architecture proposée :**
```bash
# Profils de chargement adaptatifs
AKLO_PROFILE_MINIMAL="config,basic"           # get_config, status
AKLO_PROFILE_NORMAL="config,basic,cache"      # plan, dev, debug
AKLO_PROFILE_FULL="config,basic,cache,io,perf" # optimize, monitor, benchmark

# Chargement paresseux
load_modules_for_command() {
    local command="$1"
    local profile=$(detect_required_profile "$command")
    load_profile_modules "$profile"
}
```

**Modules concernés :**
- `cache/regex_cache.sh` : Chargement différé pour commandes avec patterns
- `cache/batch_io.sh` : Chargement pour commandes avec I/O multiples
- `cache/id_cache.sh` : Chargement pour commandes créant des artefacts
- `io/io_monitoring.sh` : Chargement pour mode debug/benchmark uniquement
- `performance/performance_tuning.sh` : Chargement pour optimisations avancées

**Contraintes :**
- Préserver toutes les optimisations TASK-7-x existantes
- Maintenir la compatibilité avec les commandes MCP
- Gestion gracieuse des dépendances entre modules
- Fallback robuste en cas d'échec de chargement
- Supprimer le fast-path temporaire ajouté pour `aklo get_config` dans TASK-13-6

**Problème résolu :**
Paradoxe identifié où les optimisations de performance (TASK-7-1 à TASK-7-5) ralentissent le système pour les cas d'usage simples à cause du chargement systématique de tous les modules.

**Note importante :**
Un fast-path temporaire a été ajouté dans `aklo/bin/aklo` lors de TASK-13-6 pour résoudre immédiatement le problème `aklo get_config PROJECT_WORKDIR` via MCP. Ce fast-path doit être supprimé une fois l'architecture lazy loading complètement implémentée dans TASK-13-4.

## 4. Documents d'Architecture Associés

**[ARCH-13-1-VALIDATED.md](../02-architecture/ARCH-13-1-VALIDATED.md)** : Architecture lazy loading et profils adaptatifs fail-safe

## 5. Tasks Associées (Ordre Chronologique)

- [x] TASK-13-8 : Architecture fail-safe et validation préalable (Fondation)
- [x] TASK-13-1 : Détection et classification des commandes avec apprentissage automatique
- [x] TASK-13-2 : Implémentation du système de chargement paresseux fail-safe
- [x] TASK-13-3 : Création des profils adaptatifs de performance
- [x] TASK-13-6 : Système d'apprentissage automatique pour nouvelles commandes
- [x] TASK-13-7 : Système de métriques avancées et monitoring
- [x] TASK-13-4 : Refactoring du script principal avec architecture complète
- [x] TASK-13-5 : Tests de performance et validation des optimisations