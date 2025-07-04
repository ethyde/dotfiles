# PBI-13 : Architecture lazy loading et profils adaptatifs pour optimisations aklo

---
**Statut:** IN_PROGRESS
**Date de création:** 2025-07-04
**Date de démarrage:** 2025-07-04
**Priorité:** HIGH
**Effort estimé:** 13 points
---

## 1. Description de la User Story

_En tant que **développeur utilisant aklo**, je veux **une architecture de chargement paresseux des modules d'optimisation avec profils adaptatifs**, afin de **bénéficier des performances optimales sans subir la surcharge d'initialisation pour les commandes simples**._

## 2. Critères d'Acceptation

- [ ] **Chargement conditionnel fail-safe** : Modules chargés uniquement selon les besoins avec validation préalable
- [ ] **Profils adaptatifs intelligents** : 4 profils (minimal/normal/full/auto) avec sélection automatique
- [ ] **Performance commandes simples** : get_config, status < 0.050s (vs 0.080s actuel)
- [ ] **Préservation optimisations** : Commandes complexes gardent tous les bénéfices des TASK-7-x
- [ ] **Apprentissage automatique** : Classification automatique des nouvelles commandes sans intervention
- [ ] **Architecture fail-safe** : Aucun échec possible, fallback transparent vers chargement complet
- [ ] **Comportement unifié** : Identique MCP et CLI, pas de différenciation
- [ ] **Métriques avancées** : Monitoring temps réel et historique complet d'usage
- [ ] **Rétrocompatibilité** : Aucune régression sur fonctionnalités existantes
- [ ] **Validation préalable** : Vérification de tous les modules avant chargement
- [ ] **Chargement progressif** : Escalation automatique Minimal → Normal → Full selon besoins
- [ ] **`aklo get_config` opérationnel** : Commande `aklo get_config PROJECT_WORKDIR` fonctionne parfaitement via MCP et CLI sans fast-path temporaire
- [ ] **Suppression fast-path temporaire** : Le fast-path ajouté dans TASK-13-6 doit être supprimé et remplacé par l'architecture lazy loading native

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

- [ ] TASK-13-8 : Architecture fail-safe et validation préalable (Fondation)
- [ ] TASK-13-1 : Détection et classification des commandes avec apprentissage automatique
- [ ] TASK-13-2 : Implémentation du système de chargement paresseux fail-safe
- [ ] TASK-13-3 : Création des profils adaptatifs de performance
- [ ] TASK-13-6 : Système d'apprentissage automatique pour nouvelles commandes
- [ ] TASK-13-7 : Système de métriques avancées et monitoring
- [ ] TASK-13-4 : Refactoring du script principal avec architecture complète
- [ ] TASK-13-5 : Tests de performance et validation des optimisations