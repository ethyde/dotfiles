# TASK-7-1 : Implémentation du cache des patterns regex

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-7](../00-pbi/PBI-7-PROPOSED.md)
**Revue Architecturale Requise:** Oui
**Document d'Architecture (si applicable):** [ARCH-7-1.md](../02-arch/ARCH-7-1.md)
**Assigné à:** `[Nom du Human_Developer]`
**Branche Git:** `feature/task-7-1`

---

## 1. Objectif Technique

Créer un système de cache intelligent pour les patterns regex fréquemment utilisés dans aklo, permettant la pré-compilation et la réutilisation des expressions régulières pour améliorer les performances.

## 2. Contexte et Fichiers Pertinents

**Fichiers concernés :**
- `aklo/bin/aklo` : Script principal contenant de nombreuses regex
- `aklo/bin/aklo_cache_functions.sh` : Fonctions de cache existantes
- `aklo/bin/aklo_extract_functions.sh` : Fonctions d'extraction avec regex

**Patterns regex identifiés :**
- Extraction d'IDs dans les noms de fichiers (`PBI-[0-9]*`, `TASK-[0-9]*-[0-9]*`)
- Validation de formats de dates (`YYYY-MM-DD`)
- Parsing de configurations (`KEY=VALUE`)
- Extraction de sections de protocoles

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Analyser les patterns regex existants** dans le script aklo principal
2. **Identifier les 10 patterns les plus fréquents** utilisés dans les fonctions
3. **Créer une fonction `init_regex_cache()`** qui pré-compile les patterns
4. **Implémenter `get_cached_regex(pattern_name)`** pour récupérer les patterns compilés
5. **Remplacer les appels directs** aux regex par les versions cachées
6. **Ajouter des métriques** de performance (hits/misses du cache)
7. **Créer des tests unitaires** pour valider le cache regex
8. **Documenter les patterns** et leur utilisation

## 4. Définition de "Terminé" (Definition of Done)

- [ ] Cache des patterns regex implémenté et fonctionnel
- [ ] Au moins 10 patterns fréquents identifiés et cachés
- [ ] Fonction d'initialisation du cache créée
- [ ] Métriques de performance intégrées
- [ ] Tests unitaires écrits et passent avec succès
- [ ] Performance améliorée de 20-30% sur les opérations regex
- [ ] Documentation complète des patterns cachés
- [ ] Code respecte les standards bash et la PEP 8 (pour les parties Python)