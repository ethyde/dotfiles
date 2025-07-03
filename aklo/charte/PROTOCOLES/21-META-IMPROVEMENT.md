---
created: 2025-06-28 14:14
modified: 2025-06-28 14:31
---
# PROTOCOLE SPÉCIFIQUE : META-IMPROVEMENT (AMÉLIORATION DE LA CHARTE)

Ce protocole s'active pour gérer l'évolution de la charte elle-même, afin qu'elle reste un outil vivant, pertinent et efficace.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Identifier les frictions dans les processus de travail, proposer des améliorations aux protocoles existants, et formaliser leur mise à jour de manière tracée.

### 1.2. Livrables Attendus

1.  **Proposition d'Amélioration :** Un fichier `IMPROVE-[ID].md` créé dans `/docs/backlog/18-improvements/`.
2.  **Mise à jour de la Charte :** Un `commit` contenant les modifications apportées aux fichiers de protocole concernés.

## SECTION 2 : ARTEFACT IMPROVE - GESTION ET STRUCTURE

### 2.1. Nommage

-   `IMPROVE-[ID]-[Status].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    -   `[Status]` : Le statut de la proposition.

### 2.2. Statuts

-   `PROPOSED` : La proposition est rédigée et en attente de discussion.
-   `ACCEPTED` : La proposition est validée, prête pour implémentation.
-   `IMPLEMENTED` : La charte a été mise à jour.

### 2.3. Structure Obligatoire du Fichier Improve
```markdown
# PROPOSITION D'AMÉLIORATION : [ID]
---
**Responsable:** [Nom du Human_Developer / AI_Agent]
**Statut:** [PROPOSED | ACCEPTED | IMPLEMENTED]
**Date de Proposition:** $(date +'%Y-%m-%d')
---

## 1. Diagnostic et Contexte

- **Protocole(s) Concerné(s) :** (Liste des protocoles à modifier. Ex: `04-DEBOGAGE.md`)
- **Friction Observée (Le Problème) :** (Description détaillée du problème, avec si possible un exemple concret ou un lien vers un artefact qui a révélé le problème. Ex: "Lors du `DEBUG-login-issue`, la nécessité de remplir le 'Journal d'Investigation' a pris plus de temps que la correction elle-même pour un bug évident.")
- **Impact Actuel :** (Qu'est-ce que cette friction engendre ? Ex: "Perte de temps sur les corrections simples, frustration, tendance à vouloir contourner le protocole.")

## 2. Analyse de la Proposition d'Amélioration

- **Solution Proposée :** (Description claire de la modification. Ex: "Introduire une section 'Diagnostic Rapide' dans le protocole `DEBOGAGE` pour les cas où la cause racine est évidente, permettant de sauter le 'Journal d'Investigation'.")
- **Avantages Attendus :** - (Ex: "Gain de temps significatif pour les bugs simples.")
  - (Ex: "Meilleure adhésion au protocole en le rendant plus flexible.")
- **Inconvénients ou Risques Potentiels :**
  - (Ex: "Risque qu'un bug jugé 'évident' à tort ne soit pas assez investigué, masquant un problème plus profond.")
  - (Ex: "Nécessite une plus grande discipline de la part du développeur pour ne pas abuser de la procédure allégée.")

## 3. Plan d'Action pour l'Implémentation

- **Modifications à Apporter :** (Un `diff` ou une description précise des changements à effectuer dans les fichiers de la charte.)
- **Effort d'Implémentation Estimé :** (Faible / Moyen / Élevé. Ex: "Faible, ne concerne que la mise à jour d'un fichier Markdown.")

## 4. Checklist de Validation

- [ ] L'impact de cette modification sur les autres protocoles a été évalué.
- [ ] La proposition est alignée avec les principes fondamentaux de la charte (Traçabilité, Qualité, etc.).
- [ ] Les risques potentiels ont été identifiés et sont jugés acceptables.
```

## SECTION 3 : PROCÉDURE D'AMÉLIORATION

1.  **[ANALYSE] Phase 1 : Identification**

      - Le `Human_Developer` ou l'`AI_Agent` identifie une friction dans les opérations quotidiennes.
      - **Action Requise :**  Créer un fichier `IMPROVE-[ID]-PROPOSED.md` dans `/docs/backlog/18-improvements/`.
      - **⚡ Automatisation `aklo` :** `aklo meta "<Titre de l'amélioration>"`
      - Remplir les sections "Diagnostic" et "Proposition de Solution".

2.  **[ATTENTE\_VALIDATION] Phase 2 : Validation**

      - Soumettre la proposition pour discussion et validation au `Human_Developer`.

3.  **[PROCEDURE] Phase 3 : Implémentation**

      - Une fois la proposition `ACCEPTED`, l'`AI_Agent` prépare un `diff` des modifications à apporter aux fichiers de la charte.
      - Ce `diff` est soumis à une validation finale.

4.  **[CONCLUSION] Phase 4 : Finalisation**

      - Une fois le `diff` approuvé, créer un `commit` (ex: `chore(charte): refine debug protocol`).
      - Mettre à jour l'artefact `IMPROVE-[ID]` au statut `IMPLEMENTED`.
