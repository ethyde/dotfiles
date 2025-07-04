# TASK-6-3 : Intégration cache dans parse_and_generate_artefact

---
**Statut:** TODO
**Date de création:** 2025-01-27
**PBI Parent:** PBI-6 - Cache intelligent du parser générique
**Effort estimé:** 1.5 points
**Branche:** feature/task-6-3
**Dépendance:** TASK-6-1, TASK-6-2
---

## 1. Description Technique

Modifier la fonction `parse_and_generate_artefact` pour utiliser le système de cache intelligent avec fallback transparent vers l'ancien système.

## 2. Spécifications Détaillées

### 2.1. Fonction modifiée

```bash
parse_and_generate_artefact() {
  local protocol_name="$1"
  local artefact_type="$2"
  local assistance_level="$3"
  local output_file="$4"
  local context_vars="$5"
  
  # Construire le chemin du protocole
  local protocol_file="./aklo/charte/PROTOCOLES/${protocol_name}.md"
  
  # NOUVEAU: Tentative d'utilisation du cache
  local cache_file="/tmp/aklo_cache/protocol_${protocol_name}_${artefact_type}.parsed"
  local protocol_mtime=$(stat -f %m "$protocol_file")
  
  local artefact_structure=""
  if cache_is_valid "$cache_file" "$protocol_mtime"; then
    # Cache hit
    artefact_structure=$(use_cached_structure "$cache_file")
  else
    # Cache miss - extraction et mise en cache
    artefact_structure=$(extract_and_cache_structure "$protocol_file" "$artefact_type" "$cache_file")
  fi
  
  # Continuer avec le traitement normal
  local filtered_content=$(apply_intelligent_filtering "$artefact_structure" "$assistance_level" "$context_vars")
  echo "$filtered_content" > "$output_file"
}
```

### 2.2. Compatibilité et fallback

- **Fallback transparent :** En cas d'erreur cache, utiliser méthode originale
- **Rétrocompatibilité :** Aucun changement d'interface externe
- **Logging :** Traces pour debugging (cache hit/miss)

## 3. Definition of Done

- [x] Modification de `parse_and_generate_artefact` avec cache intégré
- [x] Fallback transparent vers méthode originale en cas d'erreur
- [x] Tests de régression : toutes les commandes aklo fonctionnent
- [x] Tests de performance : mesure des gains cache hit vs miss
- [x] Logging des statistiques cache (hit/miss ratio)
- [x] Configuration cache via .aklo.conf (enable/disable)
- [x] Tests avec tous les types d'artefacts (PBI, TASK, ARCH, etc.)
- [x] Documentation des changements
- [x] Validation linter et typage