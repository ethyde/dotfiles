# ARCH-13-1 : Architecture lazy loading et profils adaptatifs pour optimisations aklo

---

## DO NOT EDIT THIS SECTION MANUALLY
**PBI Parent:** [PBI-13-PROPOSED.md](../00-pbi/PBI-13-PROPOSED.md)
**Document d'Architecture:** [ARCH-13-1.md](../02-architecture/ARCH-13-1.md)
**Assigné à:** `Human_Developer`
**Branche Git:** `feature/arch-13-lazy-loading`

---

## 1. Problème à Résoudre

Le système aklo souffre d'un **paradoxe de performance** identifié lors du diagnostic MCP : les optimisations de performance implémentées dans PBI-7 (TASK-7-1 à TASK-7-5) ont créé une surcharge d'initialisation qui ralentit les commandes simples.

### Analyse du Problème Actuel

**Chargement Systématique :**
- Tous les modules d'optimisation sont chargés pour toutes les commandes
- `get_config` prend 0.080s au lieu de <0.050s ciblé
- Initialisation lourde même pour les opérations triviales

**Modules Concernés :**
```bash
# Modules chargés systématiquement (problématique)
cache/cache_functions.sh      # Toujours chargé
cache/regex_cache.sh          # 24 patterns, même pour get_config
cache/batch_io.sh             # I/O batch, même pour status
cache/id_cache.sh             # Génération IDs, même pour version
io/io_monitoring.sh           # Monitoring I/O, même pour help
performance/performance_tuning.sh # Tuning avancé, même pour config
```

**Impact Mesuré :**
- Commandes simples : 0.080s (vs 0.050s cible)
- Timeout MCP : 30s dépassé lors de l'initialisation
- Sur-engineering : optimisations utilisées <10% du temps

### Contraintes Architecturales

**Préservation des Optimisations :**
- Les optimisations TASK-7-x doivent rester intactes pour les commandes complexes
- Aucune régression sur les performances des commandes avancées
- Maintien de la compatibilité avec l'interface MCP

**Exigences de Performance :**
- `get_config`, `status` : < 0.050s
- `plan`, `dev`, `debug` : < 0.200s (avec cache essentiel)
- `optimize`, `benchmark` : < 1.000s (avec toutes les optimisations)

**Complexité Technique :**
- Dépendances entre modules à gérer intelligemment
- Fallback robuste en cas d'échec de chargement
- Gestion des commandes inconnues ou futures

## 2. Options Explorées et Analyse des Compromis (Trade-Offs)

### Option A : Profils Statiques avec Classification Manuelle

**Description :**
Définir 3 profils fixes (MINIMAL, NORMAL, FULL) avec classification manuelle des commandes dans un fichier de configuration.

**Avantages :**
- Simplicité d'implémentation
- Contrôle total sur le mapping commande → profil
- Prévisibilité des performances par profil
- Facilité de maintenance et debug

**Inconvénients :**
- Maintenance manuelle lors de l'ajout de nouvelles commandes
- Pas d'adaptabilité automatique selon le contexte
- Risque d'obsolescence des classifications
- Inflexibilité pour les cas d'usage mixtes

### Option B : Chargement Dynamique avec Détection de Dépendances

**Description :**
Système de chargement à la demande qui analyse les dépendances requises par chaque commande au moment de l'exécution.

**Avantages :**
- Adaptabilité automatique aux nouveaux besoins
- Optimisation maximale : charge uniquement le strict nécessaire
- Évolutivité sans maintenance manuelle
- Gestion intelligente des dépendances transitives

**Inconvénients :**
- Complexité d'implémentation élevée
- Risque de latence lors de la détection des dépendances
- Difficile à déboguer en cas de problème
- Overhead de l'analyse dynamique

### Option C : Profils Adaptatifs avec Heuristiques Intelligentes

**Description :**
Combinaison de profils prédéfinis et d'heuristiques pour adapter le chargement selon le contexte (arguments, historique, environnement).

**Avantages :**
- Équilibre optimal entre simplicité et adaptabilité
- Heuristiques basées sur l'usage réel
- Fallback robuste vers profils statiques
- Possibilité d'apprentissage et d'amélioration

**Inconvénients :**
- Complexité intermédiaire des heuristiques
- Besoin de métriques pour ajuster les heuristiques
- Risque de sur-optimisation des heuristiques
- Maintenance des règles d'adaptation

## 3. Décision et Justification

**Option Retenue : Option C - Profils Adaptatifs avec Heuristiques Intelligentes**

### Justification de la Décision

**Alignement avec les Spécifications Validées :**
- **Performance** : Optimisation ciblée selon les besoins réels
- **Automatisation** : Détection automatique des nouvelles commandes
- **Robustesse** : Architecture fail-safe sans possibilité d'échec
- **Monitoring Avancé** : Métriques complètes et historique d'apprentissage

**Analyse des Compromis :**
L'Option C répond parfaitement aux exigences : elle offre l'adaptabilité automatique requise tout en maintenant des performances optimales et une architecture robuste qui ne peut pas échouer.

### Architecture Retenue

**Profils de Base :**
```bash
PROFILE_MINIMAL="core"                    # get_config, status, version, help
PROFILE_NORMAL="core,cache_basic"         # plan, dev, debug, review
PROFILE_FULL="core,cache_basic,cache_advanced,io,perf"  # optimize, benchmark
```

**Heuristiques d'Adaptation Automatique :**
1. **Détection d'arguments** : Analyse des flags pour adapter le profil automatiquement
2. **Contexte unifié** : Comportement identique MCP et CLI (pas de différenciation)
3. **Historique d'usage** : Apprentissage automatique des patterns pour nouvelles commandes
4. **Classification automatique** : Détection intelligente des besoins sans intervention manuelle

**Système Fail-Safe (Pas d'Échec Possible) :**
- **Chargement progressif** : Minimal → Normal → Full en cas de dépendance manquante
- **Validation préalable** : Vérification de tous les modules avant chargement
- **Fallback automatique** : Chargement complet transparent en cas de problème
- **Pas de mode debug** : Système transparent sans override manuel

## 4. Schéma de la Solution

```
┌─────────────────────────────────────────────────────────────────┐
│                AKLO FAIL-SAFE LAZY LOADING ARCHITECTURE        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Command Args  │───▶│  Auto Command   │───▶│  Intelligent    │
│   (any command) │    │  Classifier     │    │  Profile        │
│                 │    │  + Learning     │    │  Detector       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                 ADAPTIVE PROFILE SELECTION                     │
│                                                                 │
│  MINIMAL ──────────▶ core (get_config, status)                 │
│  NORMAL  ──────────▶ core + cache_basic (plan, dev)            │
│  FULL    ──────────▶ core + cache_basic + cache_advanced +     │
│                      io + perf (optimize, benchmark)           │
│  AUTO    ──────────▶ Learning-based for unknown commands       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FAIL-SAFE LAZY LOADER                       │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Progressive│  │  Validation │  │  Advanced   │             │
│  │   Loading   │  │   & Retry   │  │  Metrics    │             │
│  │   Engine    │  │   Engine    │  │  Engine     │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  Minimal → Normal → Full (automatic escalation)                │
│  + Complete fallback if any issue detected                     │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LOADED MODULES + METRICS                    │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    Core     │  │    Cache    │  │  Performance│             │
│  │  Functions  │  │  Functions  │  │  Functions  │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Load Time  │  │  Usage      │  │  Learning   │             │
│  │  Metrics    │  │  History    │  │  Database   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## 5. Impact sur les Tâches

### Tasks à Modifier

**TASK-13-1 : Détection et classification des commandes**
- **Modification** : Ajouter les heuristiques d'adaptation
- **Nouveau scope** : Inclure la détection de contexte (MCP vs CLI)
- **Ajout** : Système d'apprentissage des patterns d'usage

**TASK-13-2 : Système de chargement paresseux**
- **Modification** : Intégrer le système de profils adaptatifs
- **Nouveau scope** : Ajouter la gestion des heuristiques
- **Ajout** : Cache intelligent des modules chargés

**TASK-13-4 : Refactoring du script principal**
- **Modification** : Intégrer les heuristiques dans l'initialisation
- **Nouveau scope** : Ajouter la gestion des variables d'environnement
- **Ajout** : Mode debug pour tracer les décisions de chargement

### Nouvelles Tasks à Créer

**TASK-13-6 : Système d'apprentissage automatique pour nouvelles commandes**
- Implémenter la détection automatique des patterns d'usage
- Créer la base de données d'apprentissage des commandes inconnues
- Développer l'algorithme de classification automatique

**TASK-13-7 : Système de métriques avancées et monitoring**
- Développer les métriques complètes de performance par profil
- Créer l'historique d'usage et d'apprentissage
- Implémenter le monitoring en temps réel du lazy loading

**TASK-13-8 : Architecture fail-safe et validation préalable**
- Implémenter le système de validation des modules avant chargement
- Créer le mécanisme de chargement progressif (escalation automatique)
- Développer le fallback transparent vers chargement complet

### Tasks Inchangées

**TASK-13-3 : Création des profils adaptatifs**
- Reste identique, les profils de base sont confirmés

**TASK-13-5 : Tests de performance et validation**
- Reste identique, les critères de performance sont maintenus