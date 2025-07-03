# TASK-7-3 : Optimisation de la fonction get_next_id

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-7](../00-pbi/PBI-7-PROPOSED.md)
**Revue Architecturale Requise:** Non
**Document d'Architecture (si applicable):** N/A
**Assigné à:** `[Nom du Human_Developer]`
**Branche Git:** `feature/task-7-3`

---

## 1. Objectif Technique

Optimiser la fonction `get_next_id()` en implémentant un cache des derniers IDs calculés pour éviter les opérations `ls` répétitives et améliorer les performances lors de la création d'artefacts multiples.

## 2. Contexte et Fichiers Pertinents

**Fichiers concernés :**
- `aklo/bin/aklo` : Fonction get_next_id() ligne 522-528
- `aklo/bin/aklo_cache_functions.sh` : Infrastructure de cache existante

**Fonction actuelle :**
```bash
get_next_id() {
  SEARCH_PATH="$1"
  PREFIX="$2"
  LAST_ID=$(ls "${SEARCH_PATH}/${PREFIX}"*-*.md 2>/dev/null | sed -n "s/.*${PREFIX}\([0-9]*\)-.*/\1/p" | sort -n | tail -1 || echo 0)
  NEXT_ID=$((LAST_ID + 1))
  echo "$NEXT_ID"
}
```

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

1. **Créer un cache global des IDs** avec clé `${SEARCH_PATH}_${PREFIX}`
2. **Implémenter `get_next_id_cached()`** qui utilise le cache
3. **Ajouter une fonction `invalidate_id_cache()`** pour invalider le cache
4. **Créer `update_id_cache()`** pour mettre à jour après création d'artefact
5. **Implémenter la détection de changements** externes pour invalidation
6. **Ajouter des métriques** de hits/misses du cache
7. **Créer des tests unitaires** pour valider le comportement
8. **Documenter les fonctions** et leur utilisation

## 4. Définition de "Terminé" (Definition of Done)

- [ ] Cache des IDs implémenté avec clés composites
- [ ] Fonction get_next_id_cached() créée et fonctionnelle
- [ ] Système d'invalidation du cache implémenté
- [ ] Détection de changements externes pour invalidation
- [ ] Métriques de performance intégrées
- [ ] Tests unitaires écrits et passent avec succès
- [ ] Performance améliorée de 50-70% sur opérations répétitives
- [ ] Compatibilité avec la fonction existante maintenue