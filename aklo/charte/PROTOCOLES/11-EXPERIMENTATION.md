---
created: 2025-06-28 10:55
modified: 2025-06-28 14:43
---

# PROTOCOLE SPÉCIFIQUE : GESTION D'EXPÉRIMENTATION (A/B TEST)

Ce protocole s'active pour valider une hypothèse produit, marketing ou technique par une expérience contrôlée (A/B Test) avant d'engager un développement complet.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Définir, implémenter, exécuter et analyser une expérience A/B de manière scientifique pour prendre une décision éclairée et basée sur des données mesurables.

### 1.2. Livrables Attendus

1. **Rapport d'Expérimentation :** Un fichier `EXPERIMENT-[ID].md` créé dans `/docs/backlog/09-experiments/`, qui sert de document de référence unique pour toute l'expérience.
2. **Tasks d'Implémentation :** Une ou plusieurs `Tasks` pour mettre en place l'expérience (développement, configuration d'outils, tracking…).
3. **Rapport d'Analyse Finale :** Une section complétée dans le rapport d'expérimentation avec les résultats et une décision claire.

## SECTION 2 : ARTEFACT EXPERIMENT - GESTION ET STRUCTURE

### 2.1. Nommage

- `EXPERIMENT-[ID]-[Status].md`
    - `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    - `[Status]` : Le statut de l'expérimentation.

### 2.2. Statuts

- `PLANNING` : La définition de l'hypothèse et des métriques est en cours.
- `AWAITING_IMPLEMENTATION` : Le plan est validé, en attente de développement.
- `RUNNING` : L'expérience est en ligne et collecte des données.
- `COMPLETED` : L'expérience est terminée, en attente d'analyse.
- `CONCLUDED` : L'analyse est terminée et une décision a été prise.

### 2.3. Structure Obligatoire Du Fichier Experiment

```markdown
# RAPPORT D'EXPÉRIMENTATION : [ID]

---
## DO NOT EDIT THIS SECTION MANUALLY
**Responsable:** [Nom du Human_Developer]
**Statut:** [PLANNING | AWAITING_IMPLEMENTATION | RUNNING | COMPLETED | CONCLUDED]
**PBI Associé (si applicable):** [PBI-XX](../../00-pbi/PBI-XX-PROPOSED.md)
**Outils:** [Ex: Google Analytics, Nom du Feature Flag, etc.]
---

## 1. Hypothèse et Métriques

- **Hypothèse :**
    - **Nous croyons que** [faire ce changement]
    - **Pour** [ce segment d'utilisateurs]
    - **Va résulter en** [cet impact qualitatif].
- **Validation Quantitative :**
    - **Métrique Principale (KPI) :** [Nom de la métrique. Ex: "Taux de conversion du bouton CTA"]
    - **Objectif :** Nous considérerons l'expérience comme un succès si le KPI [augmente/diminue] de [X%] avec une significativité statistique de [95%].
- **Métriques Secondaires à surveiller :**
    - [Métrique de garde-fou. Ex: "Temps de chargement de la page ne doit pas augmenter"]
    - [Autre métrique d'observation]

## 2. Description des Variantes

- **Variante A (Contrôle) :** Description du comportement actuel.
- **Variante B (Test) :** Description du nouveau comportement à tester.
- **Répartition du trafic :** (Ex: 50% / 50%)

## 3. Plan d'Implémentation Technique

*Description des `Tasks` à réaliser pour mettre en place le test (ex: création d'un feature flag, ajout d'événements de tracking, modification de l'interface).*

## 4. Analyse des Résultats et Décision

*(Cette section est remplie à la fin de l'expérience)*
- **Résultats Statistiques :** (Tableau avec les KPIs, la significativité statistique, etc.)
- **Analyse :** (Interprétation des résultats.)
- **Décision :** (Ex: "Implémenter la Variante B pour 100% des utilisateurs", "Arrêter l'expérience et rester sur la Variante A", "Lancer une nouvelle itération".)
- **PBI de Suivi (si applicable) :** [PBI-XX](../../00-pbi/PBI-XX-PROPOSED.md)
```

## SECTION 3 : PROCÉDURE D'EXPÉRIMENTATION

1. **[ANALYSE] Phase 1 : Planification et Définition de l'Hypothèse**
      - **Action Requise :** Créer un nouveau fichier `EXPERIMENT-[ID]-PLANNING.md` dans `/docs/backlog/09-experiments/`.
      - **⚡ Automatisation `aklo` :** `aklo experiment "<Titre de l'experience>"`
      - Remplir les sections "Hypothèse" et "Description des Variantes".
      - Rédiger une première version du "Plan d'Implémentation Technique".
      - **[ATTENTE\_VALIDATION]** Soumettre ce plan pour validation au `Human_Developer` pour s'assurer que l'hypothèse est solide et mesurable.

2. **[PROCEDURE] Phase 2 : Implémentation**
      - Une fois le plan validé, passer le statut à `AWAITING_IMPLEMENTATION`.
      - **Activer le protocole [PLANIFICATION]** pour créer les `Tasks` techniques nécessaires.
      - Une fois les `Tasks` implémentées et le code déployé, activer le feature flag pour démarrer l'expérience.

3. **[PROCEDURE] Phase 3 : Exécution et Monitoring**
      - Passer le statut à `RUNNING`.
      - Surveiller les métriques pour s'assurer que l'expérience fonctionne comme prévu et qu'elle n'a pas d'impact négatif inattendu.

4. **[ANALYSE] Phase 4 : Analyse et Conclusion**
      - Une fois la durée de l'expérience écoulée (ou la significativité statistique atteinte), désactiver l'expérience.
      - Passer le statut à `COMPLETED`.
      - Analyser les données collectées et remplir la section "Analyse des Résultats et Décision".
      - **[ATTENTE\_VALIDATION]** Soumettre l'analyse finale et la décision proposée au `Human_Developer`.

5. **[CONCLUSION] Phase 5 : Clôture**
      - Une fois la décision validée, passer le statut à `CONCLUDED`.
      - Activer le protocole [KNOWLEDGE-BASE] pour déterminer si l'analyse a produit une connaissance qui mérite d'être centralisée.
      - Si nécessaire, créer le `PBI` de suivi pour généraliser la variante gagnante ou nettoyer le code de l'expérience.
