# TASK-9-5 : Tests d'intégration et validation de performance

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-9](../00-pbi/PBI-9-PROPOSED.md)
**Revue Architecturale Requise:** Non
**Document d'Architecture (si applicable):** [ARCH-9-1.md](../02-architecture/ARCH-9-1.md)
**Assigné à:** `Non assigné`
**Branche Git:** `feature/task-9-5`

---

## 1. Objectif Technique

Créer une suite de tests d'intégration complète pour valider le bon fonctionnement des 4 outils MCP shell natifs étendus et mesurer les gains de performance par rapport au serveur Node.js.

**Fichiers à créer :**
- `/aklo/tests/test_mcp_shell_native_extended.sh`
- `/aklo/tests/benchmark_mcp_shell_vs_node.sh`

**Résultat attendu :**
- Tests automatisés pour tous les outils MCP shell natifs
- Benchmark de performance shell vs Node.js
- Validation de la parité fonctionnelle
- Rapport de performance détaillé

## 2. Contexte et Fichiers Pertinents

### Outils à tester
```bash
# Les 4 outils MCP shell natifs étendus
1. aklo_execute_shell (étendu)
2. aklo_status_shell (étendu)
3. safe_shell (nouveau)
4. project_info (nouveau)
```

### Tests existants de référence
```bash
# aklo/tests/ - Structure existante
test_aklo_functions.sh
test_framework.sh
benchmark_profiles.sh
```

### Scénarios de test
```bash
# Tests fonctionnels
test_aklo_execute_validation()
test_aklo_status_metrics()
test_safe_shell_security()
test_project_info_parsing()

# Tests de performance
benchmark_startup_time()
benchmark_memory_usage()
benchmark_response_time()
```

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Créer le script de test d'intégration** `test_mcp_shell_native_extended.sh`
2. **Implémenter les tests pour chaque outil** :
   - `aklo_execute_shell` : validation commandes, arguments, contexte
   - `aklo_status_shell` : métriques, artefacts, rapport
   - `safe_shell` : sécurité, whitelist, timeout
   - `project_info` : parsing JSON, informations Git, métriques
3. **Créer le script de benchmark** `benchmark_mcp_shell_vs_node.sh`
4. **Mesurer les performances** :
   - Temps de démarrage serveur
   - Temps de réponse par outil
   - Utilisation mémoire
   - Comparaison shell vs Node.js
5. **Valider la parité fonctionnelle** avec le serveur Node.js
6. **Générer un rapport** de performance détaillé
7. **Intégrer aux tests existants** du framework aklo

## 4. Définition de "Terminé" (Definition of Done)

- [ ] Suite de tests d'intégration complète créée
- [ ] Tests automatisés pour les 4 outils MCP shell natifs
- [ ] Benchmark de performance shell vs Node.js implémenté
- [ ] Validation de la parité fonctionnelle réussie
- [ ] Rapport de performance généré avec métriques claires
- [ ] Gains de performance mesurés et documentés (+50% visé)
- [ ] Intégration aux tests existants du framework aklo
- [ ] Tests passent sur macOS et Linux
- [ ] Documentation des résultats de performance