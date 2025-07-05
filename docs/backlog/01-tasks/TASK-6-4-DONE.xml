# TASK-6-4 : Configuration et monitoring du système de cache

---
**Statut:** TODO
**Date de création:** 2025-01-27
**PBI Parent:** PBI-6 - Cache intelligent du parser générique
**Effort estimé:** 0.5 points
**Branche:** feature/task-6-4
**Dépendance:** TASK-6-3
---

## 1. Description Technique

Ajouter la configuration du cache dans .aklo.conf et implémenter le monitoring des performances avec métriques hit/miss ratio.

## 2. Spécifications Détaillées

### 2.1. Configuration .aklo.conf

```ini
[cache]
enabled=true
cache_dir=/tmp/aklo_cache
max_size_mb=100
ttl_days=7
cleanup_on_start=true
```

### 2.2. Commandes de monitoring

```bash
# Nouvelle commande aklo
aklo cache status    # Affiche statistiques cache
aklo cache clear     # Vide le cache
aklo cache benchmark # Benchmark avec/sans cache
```

### 2.3. Métriques à collecter

- **Hit ratio :** Pourcentage de cache hits
- **Miss ratio :** Pourcentage de cache misses  
- **Gain temps :** Temps économisé grâce au cache
- **Taille cache :** Espace disque utilisé
- **Dernière utilisation :** Timestamp des fichiers cache

## 3. Definition of Done

- [x] Configuration cache ajoutée à .aklo.conf
- [x] Fonction `get_cache_config()` pour lire configuration
- [x] Commande `aklo cache status` implémentée
- [x] Commande `aklo cache clear` implémentée  
- [x] Commande `aklo cache benchmark` implémentée
- [x] Collecte automatique des métriques hit/miss
- [x] Affichage des gains de performance
- [x] Nettoyage automatique selon TTL configuré
- [x] Tests de toutes les commandes cache
- [x] Documentation utilisateur des nouvelles commandes