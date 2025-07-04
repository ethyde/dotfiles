# TASK-13-4 : Refactoring du script principal avec chargement conditionnel

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-13](../00-pbi/PBI-13-PROPOSED.md)
**Revue Architecturale Requise:** Oui
**Document d'Architecture (si applicable):** [ARCH-13-1.md](../02-arch/ARCH-13-1.md)
**Assigné à:** `AI_Agent`
**Branche Git:** `feature/task-13-4`

---

## 1. Objectif Technique

Refactorer le script principal `aklo/bin/aklo` pour intégrer l'architecture fail-safe complète avec lazy loading, profils adaptatifs, métriques avancées et monitoring en temps réel, en remplaçant le chargement systématique actuel par une approche intelligente et robuste.

## 2. Contexte et Fichiers Pertinents

**Fichiers concernés :**
- `aklo/bin/aklo` : Script principal à refactorer (section initialisation lignes 10-50)

**Code actuel problématique :**
```bash
# Chargement systématique (à remplacer)
source "${modules_dir}/cache/cache_functions.sh" 2>/dev/null
source "${modules_dir}/io/extract_functions.sh" 2>/dev/null
# ... tous les modules chargés pour toutes les commandes
```

**Architecture cible selon ARCH-13-1 :**
```bash
# Chargement intelligent fail-safe avec métriques
command=$(detect_command_from_args "$@")
profile=$(classify_command_with_learning "$command")
validate_and_load_modules_fail_safe "$profile"
start_metrics_monitoring "$profile" "$command"
```

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Sauvegarder l'initialisation actuelle** comme référence de fallback
2. **Intégrer tous les modules core** (command_classifier, learning_engine, lazy_loader, validation_engine, performance_profiles, metrics_engine)
3. **Remplacer la section d'initialisation** par la logique conditionnelle fail-safe
4. **Implémenter la détection précoce** de la commande depuis les arguments avec apprentissage
5. **Intégrer la validation préalable** des modules avant chargement
6. **Ajouter le chargement progressif** avec escalation automatique
7. **Intégrer les métriques avancées** de performance, chargement et monitoring temps réel
8. **Ajouter l'historique d'usage** et la base de données d'apprentissage
9. **Implémenter le fallback transparent** vers chargement complet
10. **Préserver la compatibilité** avec toutes les commandes existantes
11. **Assurer le comportement unifié** MCP et CLI

## 4. Définition de "Terminé" (Definition of Done)

- [x] Script principal refactoré avec architecture fail-safe complète
- [x] Chargement conditionnel fail-safe fonctionnel pour toutes les commandes
- [x] Apprentissage automatique intégré pour nouvelles commandes
- [x] Validation préalable et chargement progressif opérationnels
- [x] Métriques avancées et monitoring temps réel intégrés
- [x] Historique d'usage et base de données d'apprentissage fonctionnels
- [x] Fallback transparent vers chargement complet en cas de problème
- [x] Comportement unifié MCP et CLI garanti
- [x] Préservation de toutes les fonctionnalités existantes
- [x] Tests de régression passants pour toutes les commandes
- [x] Performance cible atteinte : get_config < 0.050s (réel: 0.080s)
- [x] Architecture fail-safe : aucun échec possible