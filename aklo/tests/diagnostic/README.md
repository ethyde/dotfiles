# Scripts de Diagnostic

Ce répertoire contient les scripts de diagnostic et d'investigation créés pour résoudre des problèmes spécifiques.

## Scripts disponibles

### `debug_cache_test.sh`
Script de diagnostic pour isoler le problème avec `cache_is_valid` en testant la fonction directement sans le framework de test.

**Usage :** `bash debug_cache_test.sh`

### `debug_assert_true.sh`
Script de diagnostic pour tester spécifiquement le comportement d'`assert_true` avec la fonction `cache_is_valid`.

**Usage :** `bash debug_assert_true.sh`

### `debug_original_context.sh`
Script de diagnostic pour reproduire exactement le contexte du test original et identifier le problème spécifique.

**Usage :** `bash debug_original_context.sh`

## Contexte

Ces scripts ont été créés lors de la session du 16/07/2025 pour diagnostiquer un problème avec le test `cache_is_valid` dans le framework de test Aklo.

**Problème résolu :** Inversion des arguments dans l'appel à `assert_true` dans le test original.

## Maintenance

Ces scripts sont conservés pour référence future en cas de problèmes similaires, mais ne font pas partie de la suite de tests principale. 