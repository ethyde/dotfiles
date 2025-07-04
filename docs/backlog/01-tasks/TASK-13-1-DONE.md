# TASK-13-1 : Détection et classification des commandes par profil de performance

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-13](../00-pbi/PBI-13-PROPOSED.md)
**Revue Architecturale Requise:** Oui
**Document d'Architecture (si applicable):** [ARCH-13-1.md](../02-arch/ARCH-13-1.md)
**Assigné à:** `AI_Agent`
**Branche Git:** `feature/task-13-1`

---

## 1. Objectif Technique

Créer un système de classification automatique des commandes aklo avec apprentissage intelligent pour les nouvelles commandes, permettant de déterminer le profil de chargement optimal (minimal/normal/full) sans intervention manuelle.

## 2. Contexte et Fichiers Pertinents

**Fichiers concernés :**
- `aklo/bin/aklo` : Script principal avec logique de commandes
- Nouveau fichier : `aklo/modules/core/command_classifier.sh`
- Nouveau fichier : `aklo/modules/core/learning_engine.sh`

**Commandes identifiées par diagnostic :**
```bash
# Profil MINIMAL (core)
get_config, status, version, help

# Profil NORMAL (core, cache_basic)  
plan, dev, debug, review, new, template

# Profil FULL (core, cache_basic, cache_advanced, io, perf)
optimize, benchmark, cache, monitor, diagnose

# Profil AUTO (apprentissage automatique)
[nouvelles commandes détectées automatiquement]
```

**Architecture cible selon ARCH-13-1 :**
Classification automatique avec apprentissage intelligent des nouvelles commandes et comportement unifié MCP/CLI.

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Créer le module de classification** `aklo/modules/core/command_classifier.sh`
2. **Implémenter `classify_command()`** avec apprentissage automatique pour nouvelles commandes
3. **Créer le module d'apprentissage** `aklo/modules/core/learning_engine.sh`
4. **Définir les constantes de profils** MINIMAL, NORMAL, FULL, AUTO avec leurs modules
5. **Créer `get_required_modules()`** qui liste les modules nécessaires pour un profil
6. **Implémenter `detect_command_from_args()`** pour analyser les arguments CLI
7. **Ajouter la base de données d'apprentissage** pour stocker les patterns d'usage
8. **Implémenter l'algorithme d'apprentissage** pour classifier automatiquement les nouvelles commandes
9. **Créer des tests unitaires** pour valider la classification et l'apprentissage
10. **Documenter la logique** de classification automatique et les critères de profils

## 4. Définition de "Terminé" (Definition of Done)

- [ ] Module `command_classifier.sh` créé et fonctionnel
- [ ] Module `learning_engine.sh` créé avec apprentissage automatique
- [ ] Fonction `classify_command()` implémentée avec 4 profils (MINIMAL, NORMAL, FULL, AUTO)
- [ ] Classification correcte de toutes les commandes aklo existantes
- [ ] Système d'apprentissage automatique pour nouvelles commandes
- [ ] Base de données d'apprentissage fonctionnelle
- [ ] Algorithme de classification automatique opérationnel
- [ ] Tests unitaires écrits et passent avec succès
- [ ] Documentation complète des profils et de l'apprentissage automatique
- [ ] Code respecte les standards bash et les conventions aklo
- [ ] Aucune régression sur les commandes existantes