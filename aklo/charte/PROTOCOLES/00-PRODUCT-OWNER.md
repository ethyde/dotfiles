---
created: 2025-06-27 15:16
modified: 2025-06-28 12:25
---

# PROTOCOLE SPÉCIFIQUE : GESTION PRODUIT (PRODUCT OWNER)

Ce protocole s'active pour transformer une idée ou un besoin métier en un "Product Backlog Item" (PBI) formel, prêt pour le développement. C'est le point d'entrée de tout le flux de travail.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

La mission de ce mode est de définir, clarifier et formaliser une exigence pour s'assurer qu'elle est :

- **Compréhensible :** L'équipe technique doit comprendre sans ambiguïté ce qui est demandé.
- **Valorisable :** L'exigence doit apporter une valeur ajoutée claire pour l'utilisateur final.
- **Réalisable :** La demande doit être suffisamment définie pour être évaluée et décomposée.
- **Note :** Une exigence peut provenir d'une demande directe du `Human_Developer` ou être le résultat d'autres protocoles comme [ANALYSE-CONCURRENCE], [EXPERIMENTATION] ou [SECURITE-AUDIT].

### 1.2. Livrable Attendu

- Un nouveau fichier `PBI-[ID]-PROPOSED.md` dans le répertoire `/docs/pbi/`, respectant la structure définie et les critères de qualité **INVEST**.

## SECTION 2 : ARTEFACT PBI - GESTION ET STRUCTURE

### 2.1. Nommage

- `PBI-[ID]-[Status].md`
  - `[ID]` : Identifiant numérique unique (ex: 42).
  - `[Status]` : Le statut du PBI dans son cycle de vie.

### 2.2. Statuts

- `PROPOSED` : Proposé, en attente de validation pour la planification.
- `AGREED` : Spécifications validées, prêt pour décomposition en tâches.
- `IN_PROGRESS` : Au moins une `Task` associée est en cours de développement.
- `DONE` : Toutes les `Tasks` associées sont terminées.
- `ACCEPTED` : La fonctionnalité a été validée par le `Human_Developer`.

### 2.3. Structure Obligatoire Du Fichier PBI

```markdown
# PBI-%%ID%% : %%TITLE%%

---
**Statut:** PROPOSED
**Date de création:** $(date +'%Y-%m-%d')
---

## 1. Description de la User Story

_En tant que [type d'utilisateur], je veux [réaliser une action], afin de [obtenir un bénéfice]._

## 2. Critères d'Acceptation

- [ ] Critère 1 : Condition binaire et testable.
- [ ] Critère 2 : Autre condition binaire et testable.
- [ ] ...

## 3. Spécifications Techniques Préliminaires & Contraintes (Optionnel)

_Section pour l'architecte/lead dev. Décrit les impacts, les dépendances, les choix techniques à haut niveau qui pourraient influencer la planification._

## 4. Documents d'Architecture Associés (Optionnel)

_Lien vers un ou plusieurs documents du répertoire `/docs/backlog/02-architecture/` si une phase de conception a été nécessaire._

- [ARCH-[ID]-1.md](../../02-architecture/ARCH-[ID]-1.md)

## 5. Tasks Associées

_Cette section sera remplie par le protocole [PLANIFICATION]._

- [ ] TASK-[ID]-1
- [ ] TASK-[ID]-2
- [ ] ...
```

## SECTION 3 : PROCÉDURE DE DÉFINITION D'UN PBI

1. **[ANALYSE] Phase 1 : Capture du Besoin Initial**
   - Prendre en entrée l'idée, la fonctionnalité ou le problème à résoudre.
   - Clarifier l'objectif principal : "Quel problème cherchons-nous à résoudre pour qui ?"

2. **[PROCEDURE] Phase 2 : Rédaction de la User Story**
   - Formuler le besoin en utilisant le format standardisé : `En tant que [type d'utilisateur], je veux [réaliser une action], afin de [obtenir un bénéfice]`.
   - Cette formulation doit être centrée sur l'utilisateur et la valeur, pas sur la solution technique.

3. **[PROCEDURE] Phase 3 : Définition des Critères d'Acceptation**
   - Lister les conditions spécifiques et testables qui, si elles sont remplies, confirmeront que la User Story est complétée avec succès.
   - Chaque critère doit être binaire (vrai/faux) et sans ambiguïté.

4. **[ANALYSE] Phase 4 : Validation "INVEST"**
   - Évaluer le PBI fraîchement rédigé par rapport aux critères **INVEST**
     - **I - Indépendant :** Le PBI doit être aussi autonome que possible pour pouvoir être développé et livré sans dépendre d'un autre PBI.
     - **N - Négociable :** Le PBI n'est pas un contrat figé. Il doit laisser de la place à la discussion entre le Product Owner et l'équipe technique sur les détails de l'implémentation.
     - **V - Valorisable (Valuable) :** Le PBI doit apporter une valeur claire et identifiable pour l'utilisateur final ou le client. Si la valeur n'est pas évidente, il faut questionner la pertinence du PBI.
     - **E - Estimable :** L'équipe de développement doit être capable de donner une estimation de l'effort nécessaire pour réaliser le PBI. S'il est trop vague ou trop grand, il ne peut pas être estimé.
     - **S - Suffisamment petit (Small) :** Le PBI doit être assez petit pour pouvoir être réalisé en une seule itération (par exemple, un sprint). Les PBI trop gros ("épics") doivent être décomposés.
     - **T - Testable :** Il doit être possible de vérifier que le PBI est terminé. Les critères d'acceptation sont la clé pour rendre un PBI testable.
   - Si un critère n'est pas rempli, itérer sur les étapes précédentes pour affiner le PBI (ex: le découper en deux PBI plus petits).

5. **[CONCLUSION] Phase 5 : Formalisation**
   - **Action Requise :** 
      Créer le fichier `PBI-[ID]-PROPOSED.md` dans `/docs/backlog/00-pbi/` en respectant la structure obligatoire.
   - **⚡ Automatisation `aklo` :** `aklo propose-pbi "[Titre du PBI]"`
   - [ATTENTE_VALIDATION] Présenter le PBI finalisé au `Human_Developer` pour approbation avant de passer au protocole [PLANIFICATION].
