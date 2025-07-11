#!/usr/bin/env bash
#==============================================================================
# Amélioration UX : Templates pré-remplis pour Aklo
# Templates intelligents pour PBI et tâches
#==============================================================================

# Templates pour PBI selon le type
generate_pbi_template() {
    local type="$1"
    local title="$2"
    local priority="${3:-MEDIUM}"
    
    case "$type" in
        "feature")
            generate_feature_pbi_template "$title" "$priority"
            ;;
        "bug")
            generate_bug_pbi_template "$title" "$priority"
            ;;
        "epic")
            generate_epic_pbi_template "$title" "$priority"
            ;;
        "research")
            generate_research_pbi_template "$title" "$priority"
            ;;
        *)
            generate_default_pbi_template "$title" "$priority"
            ;;
    esac
}

# Template pour nouvelle fonctionnalité
generate_feature_pbi_template() {
    local title="$1"
    local priority="$2"
    
    cat << EOF
# $title

**Type:** Feature  
**Status:** PROPOSED  
**Priority:** $priority  
**Created:** $(date +%Y-%m-%d)  
**Estimate:** TBD

## 👤 User Story

En tant que [type d'utilisateur],  
Je veux [objectif/désir],  
Afin de [bénéfice/valeur].

## 📋 Description détaillée

Décrivez la fonctionnalité en détail :
- Contexte et problème à résoudre
- Solution proposée
- Impact attendu

## ✅ Critères d'acceptation

- [ ] **Critère 1:** Description précise du comportement attendu
- [ ] **Critère 2:** Cas nominal fonctionnel
- [ ] **Critère 3:** Gestion des cas d'erreur
- [ ] **Critère 4:** Interface utilisateur intuitive
- [ ] **Critère 5:** Performance acceptable (< 2s)

## 🎨 Maquettes/Wireframes

[Ajoutez ici les liens vers les maquettes ou descriptions visuelles]

## 🔧 Considérations techniques

- **Architecture:** Composants/modules impactés
- **Base de données:** Nouvelles tables/champs requis
- **API:** Nouveaux endpoints ou modifications
- **Sécurité:** Contrôles d'accès nécessaires
- **Performance:** Optimisations requises

## 🧪 Stratégie de test

- **Tests unitaires:** Fonctions critiques
- **Tests d'intégration:** Flux complets
- **Tests utilisateur:** Scénarios d'usage
- **Tests de performance:** Charge et stress

## 📚 Documentation requise

- [ ] Documentation utilisateur
- [ ] Documentation technique/API
- [ ] Guide de déploiement
- [ ] Notes de release

## 🔗 Dépendances

- **Bloqué par:** [PBI ou tâches prérequises]
- **Bloque:** [PBI dépendants]
- **Lié à:** [PBI connexes]

## 📊 Métriques de succès

- **Métrique 1:** Objectif mesurable
- **Métrique 2:** KPI d'adoption
- **Métrique 3:** Indicateur de performance

## 💡 Notes et questions

- Question ouverte 1
- Décision en attente 2
- Risque identifié 3

---

**Définition de "Terminé":**
- [ ] Code développé selon les standards
- [ ] Tests automatisés passants (couverture > 80%)
- [ ] Documentation mise à jour
- [ ] Review de code approuvée
- [ ] Tests utilisateur validés
- [ ] Déployé en environnement de test
- [ ] Critères d'acceptation validés
EOF
}

# Template pour correction de bug
generate_bug_pbi_template() {
    local title="$1"
    local priority="$2"
    
    cat << EOF
# 🐛 $title

**Type:** Bug Fix  
**Status:** PROPOSED  
**Priority:** $priority  
**Created:** $(date +%Y-%m-%d)  
**Severity:** [Critical/High/Medium/Low]

## 🔍 Description du problème

### Comportement actuel
Décrivez précisément ce qui ne fonctionne pas.

### Comportement attendu
Décrivez ce qui devrait se passer normalement.

### Impact utilisateur
- **Utilisateurs affectés:** [Tous/Certains rôles/Cas spécifiques]
- **Fréquence:** [Systématique/Intermittent/Rare]
- **Gravité:** [Bloquant/Gênant/Mineur]

## 🔄 Étapes de reproduction

1. Étape 1 précise
2. Étape 2 avec données exactes
3. Étape 3 avec contexte
4. **Résultat observé:** [Ce qui se passe]
5. **Résultat attendu:** [Ce qui devrait se passer]

## 🌍 Environnement

- **Navigateur:** [Chrome 119, Firefox 120, etc.]
- **OS:** [Windows 11, macOS 14, Ubuntu 22.04]
- **Version app:** [v2.1.3]
- **Environnement:** [Production/Staging/Dev]

## 📊 Données de test

```
[Données spécifiques pour reproduire le bug]
- Utilisateur test: user@example.com
- ID produit: 12345
- Configuration: {"param": "value"}
```

## 🔧 Investigation technique

### Hypothèses initiales
- Hypothèse 1: Problème de validation côté client
- Hypothèse 2: Race condition dans l'API
- Hypothèse 3: Problème de cache

### Logs d'erreur
```
[Coller ici les logs d'erreur pertinents]
```

### Composants suspectés
- Module/fichier 1
- API endpoint 2
- Base de données table 3

## ✅ Critères de résolution

- [ ] **Bug reproduit:** Problème confirmé en dev
- [ ] **Cause identifiée:** Root cause analysée
- [ ] **Solution implémentée:** Fix développé
- [ ] **Tests de non-régression:** Anciens cas OK
- [ ] **Validation:** Scénario initial corrigé

## 🧪 Plan de test

### Tests de validation
- [ ] Scénario de reproduction initial
- [ ] Cas limites identifiés
- [ ] Tests de régression sur fonctionnalités liées

### Tests exploratoires
- [ ] Navigation autour du fix
- [ ] Différents types d'utilisateurs
- [ ] Différents navigateurs/OS

## 🚀 Plan de déploiement

- **Urgence:** [Hotfix immédiat/Prochaine release/Peut attendre]
- **Rollback:** [Procédure en cas de problème]
- **Communication:** [Qui prévenir, comment]

## 📋 Checklist de résolution

- [ ] Bug reproduit et documenté
- [ ] Cause racine identifiée
- [ ] Solution développée et testée
- [ ] Tests de non-régression passés
- [ ] Review de code approuvée
- [ ] Documentation mise à jour
- [ ] Fix déployé et validé
- [ ] Monitoring post-déploiement OK

## 🔗 Références

- **Issue tracker:** #[numéro]
- **Logs monitoring:** [lien vers dashboards]
- **Discussion:** [liens vers Slack/Teams]
- **PBI liés:** [numéros des PBI connexes]
EOF
}

# Template pour epic (grande fonctionnalité)
generate_epic_pbi_template() {
    local title="$1"
    local priority="$2"
    
    cat << EOF
# 🎯 Epic: $title

**Type:** Epic  
**Status:** PROPOSED  
**Priority:** $priority  
**Created:** $(date +%Y-%m-%d)  
**Timeline:** [Q1 2024 / 3-6 mois]

## 🎯 Vision et objectifs

### Vision produit
Description de la vision à long terme et de la valeur business.

### Objectifs stratégiques
- **Objectif 1:** Améliorer l'engagement utilisateur de 25%
- **Objectif 2:** Réduire le temps de traitement de 50%
- **Objectif 3:** Augmenter la satisfaction client (NPS > 8)

## 👥 Personas et utilisateurs cibles

### Persona principal
- **Nom:** [Marie, Chef de projet]
- **Besoins:** [Gestion efficace des équipes]
- **Pain points:** [Manque de visibilité, outils dispersés]

### Personas secondaires
- **Développeurs:** Besoin d'outils intégrés
- **Managers:** Besoin de reporting avancé

## 📊 Métriques de succès

### KPIs business
- **Adoption:** 80% des utilisateurs actifs
- **Engagement:** +30% de temps passé
- **Conversion:** +15% de taux de conversion

### KPIs techniques
- **Performance:** Temps de réponse < 2s
- **Fiabilité:** Uptime > 99.9%
- **Qualité:** Bug rate < 0.1%

## 🗺️ Roadmap et jalons

### Phase 1: Fondations (Mois 1-2)
- [ ] PBI-X: Architecture de base
- [ ] PBI-Y: Authentification avancée
- [ ] PBI-Z: Interface utilisateur core

### Phase 2: Fonctionnalités core (Mois 3-4)
- [ ] PBI-A: Gestion des données
- [ ] PBI-B: Workflows automatisés
- [ ] PBI-C: Intégrations externes

### Phase 3: Optimisation (Mois 5-6)
- [ ] PBI-D: Performance et scalabilité
- [ ] PBI-E: Analytics avancés
- [ ] PBI-F: Mobile et responsive

## 🔧 Architecture technique

### Composants principaux
- **Frontend:** React/Vue avec TypeScript
- **Backend:** Node.js/Python avec API REST
- **Base de données:** PostgreSQL + Redis cache
- **Infrastructure:** AWS/Azure avec CI/CD

### Défis techniques
- **Scalabilité:** Gestion de 10k+ utilisateurs
- **Intégration:** APIs tierces multiples
- **Sécurité:** Données sensibles et RGPD

## 💰 Estimation et ressources

### Effort estimé
- **Développement:** 120-150 jours/homme
- **Design:** 20-30 jours/homme
- **QA:** 30-40 jours/homme
- **DevOps:** 15-20 jours/homme

### Équipe requise
- **Tech Lead:** 1 personne (full-time)
- **Développeurs:** 3-4 personnes
- **Designer:** 1 personne (part-time)
- **QA:** 1-2 personnes

## 🎨 Design et UX

### Principes de design
- **Simplicité:** Interface intuitive et épurée
- **Cohérence:** Design system unifié
- **Accessibilité:** WCAG 2.1 AA compliance

### Wireframes et prototypes
- [Lien vers Figma/Sketch]
- [Prototype interactif]

## 🔗 Dépendances et risques

### Dépendances externes
- **API partenaire X:** Disponibilité Q2
- **Certification sécurité:** Process 3 mois
- **Budget infrastructure:** Validation CFO

### Risques identifiés
- **Technique:** Complexité d'intégration (Prob: Medium, Impact: High)
- **Business:** Changement de priorités (Prob: Low, Impact: High)
- **Ressources:** Disponibilité équipe (Prob: High, Impact: Medium)

## 📚 Documentation et formation

### Documentation requise
- [ ] Architecture decision records (ADR)
- [ ] Guide utilisateur complet
- [ ] Documentation API
- [ ] Runbooks opérationnels

### Plan de formation
- [ ] Formation équipe développement
- [ ] Formation utilisateurs finaux
- [ ] Documentation support client

## 🚀 Go-to-market

### Stratégie de lancement
- **Beta privée:** 50 utilisateurs sélectionnés
- **Beta publique:** 500 utilisateurs volontaires
- **Release générale:** Déploiement progressif

### Communication
- [ ] Annonce interne équipes
- [ ] Communication clients existants
- [ ] Marketing et acquisition
- [ ] Formation équipe support

---

**Prochaines étapes:**
1. Validation de l'epic par les stakeholders
2. Décomposition en PBI détaillés
3. Estimation et planification des sprints
4. Kick-off avec l'équipe
EOF
}

# Template pour recherche/investigation
generate_research_pbi_template() {
    local title="$1"
    local priority="$2"
    
    cat << EOF
# 🔍 Research: $title

**Type:** Research/Investigation  
**Status:** PROPOSED  
**Priority:** $priority  
**Created:** $(date +%Y-%m-%d)  
**Time-box:** [1-2 semaines]

## 🎯 Objectif de la recherche

### Question principale
Quelle est la question centrale à laquelle cette recherche doit répondre ?

### Contexte et motivation
- **Problème identifié:** Description du problème
- **Impact business:** Pourquoi c'est important maintenant
- **Décisions en attente:** Quelles décisions dépendent de cette recherche

## 🔍 Scope de l'investigation

### Dans le scope
- Aspect 1 à investiguer
- Aspect 2 à analyser
- Aspect 3 à valider

### Hors scope
- Ce qui ne sera PAS étudié
- Limitations volontaires
- Future investigations

## 📊 Méthodologie

### Approches d'investigation
- [ ] **Analyse de données:** Métriques existantes, logs, analytics
- [ ] **Recherche utilisateur:** Interviews, sondages, observation
- [ ] **Benchmark concurrentiel:** Analyse des solutions existantes
- [ ] **Prototypage:** POC technique ou maquettes
- [ ] **Tests A/B:** Expérimentations contrôlées

### Sources de données
- **Quantitatives:** Analytics, metrics, logs système
- **Qualitatives:** Interviews utilisateurs, feedback support
- **Externes:** Études de marché, documentation technique

## 📋 Questions de recherche

### Questions primaires
1. **Question 1:** [Question spécifique et mesurable]
2. **Question 2:** [Question avec critères de succès]
3. **Question 3:** [Question avec hypothèses à valider]

### Questions secondaires
- Question exploratoire A
- Question exploratoire B
- Question exploratoire C

## 🧪 Hypothèses à valider

### Hypothèse 1
- **Énoncé:** [Hypothèse claire et testable]
- **Méthode de validation:** [Comment la tester]
- **Critères de succès:** [Quand considérer validée]

### Hypothèse 2
- **Énoncé:** [Deuxième hypothèse]
- **Méthode de validation:** [Approche de test]
- **Critères de succès:** [Seuils de validation]

## 📅 Plan de travail

### Semaine 1: Collecte de données
- [ ] **Jour 1-2:** Setup et accès aux données
- [ ] **Jour 3-4:** Analyse quantitative
- [ ] **Jour 5:** Première synthèse

### Semaine 2: Analyse et validation
- [ ] **Jour 1-2:** Recherche qualitative
- [ ] **Jour 3:** Validation des hypothèses
- [ ] **Jour 4:** Rédaction du rapport
- [ ] **Jour 5:** Présentation des résultats

## 📊 Livrables attendus

### Rapport de recherche
- **Executive summary:** Synthèse en 1 page
- **Méthodologie:** Approches utilisées
- **Résultats:** Données et analyses
- **Recommandations:** Actions proposées
- **Appendices:** Données détaillées

### Présentation
- **Slides de synthèse:** 10-15 slides max
- **Session de partage:** 1h avec Q&A
- **Documentation:** Rapport complet

## 🎯 Critères de succès

### Objectifs de qualité
- [ ] **Complétude:** Toutes les questions ont une réponse
- [ ] **Fiabilité:** Sources crédibles et méthodologie solide
- [ ] **Actionnable:** Recommandations concrètes et priorisées
- [ ] **Timing:** Livré dans les délais

### Impact attendu
- **Décision éclairée:** Choix technique/business validé
- **Réduction de risque:** Incertitudes levées
- **Roadmap affinée:** Priorités clarifiées

## 🔗 Ressources et contraintes

### Ressources disponibles
- **Personnes:** [Qui peut aider, expertise requise]
- **Données:** [Accès aux systèmes, outils d'analyse]
- **Budget:** [Coûts pour outils, interviews, etc.]

### Contraintes
- **Temps:** Time-box strict de X semaines
- **Accès:** Limitations sur certaines données
- **Confidentialité:** Restrictions sur le partage

## 📈 Suivi et métriques

### Indicateurs de progression
- **Avancement:** % de questions traitées
- **Qualité:** Niveau de confiance dans les réponses
- **Risques:** Blockers ou retards identifiés

### Check-points
- **Mi-parcours:** Review intermédiaire
- **Pre-delivery:** Validation avant livraison
- **Post-delivery:** Feedback sur l'utilité

---

**Next steps après la recherche:**
1. Présentation des résultats aux stakeholders
2. Décisions basées sur les recommandations
3. Création de PBI de développement si applicable
4. Documentation des learnings pour futures recherches
EOF
}

# Template par défaut
generate_default_pbi_template() {
    local title="$1"
    local priority="$2"
    
    cat << EOF
# $title

**Status:** PROPOSED  
**Priority:** $priority  
**Created:** $(date +%Y-%m-%d)

## Description

Décrivez ici la fonctionnalité ou le besoin à adresser.

## Critères d'acceptation

- [ ] Critère 1
- [ ] Critère 2
- [ ] Critère 3

## Notes techniques

Ajoutez ici les considérations techniques importantes.

## Définition de "Terminé"

- [ ] Code développé et testé
- [ ] Documentation mise à jour
- [ ] Tests automatisés ajoutés
- [ ] Review de code effectuée
EOF
}

# Templates pour tâches selon le type de développement
generate_task_template() {
    local type="$1"
    local title="$2"
    local pbi_id="$3"
    local estimate="${4:-2h}"
    
    case "$type" in
        "api")
            generate_api_task_template "$title" "$pbi_id" "$estimate"
            ;;
        "frontend")
            generate_frontend_task_template "$title" "$pbi_id" "$estimate"
            ;;
        "backend")
            generate_backend_task_template "$title" "$pbi_id" "$estimate"
            ;;
        "database")
            generate_database_task_template "$title" "$pbi_id" "$estimate"
            ;;
        "test")
            generate_test_task_template "$title" "$pbi_id" "$estimate"
            ;;
        *)
            generate_default_task_template "$title" "$pbi_id" "$estimate"
            ;;
    esac
}

# Template pour tâche API
generate_api_task_template() {
    local title="$1"
    local pbi_id="$2"
    local estimate="$3"
    
    cat << EOF
# 🔌 API: $title

**PBI:** $pbi_id  
**Type:** API Development  
**Status:** TODO  
**Estimate:** $estimate  
**Created:** $(date +%Y-%m-%d)

## 📋 Spécifications API

### Endpoint
- **Method:** [GET/POST/PUT/DELETE]
- **Path:** \`/api/v1/resource\`
- **Auth:** [Required/Optional/None]

### Request
```json
{
  "field1": "string",
  "field2": "number",
  "field3": "boolean"
}
```

### Response Success (200)
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "field1": "value",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### Response Error (400/500)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Description de l'erreur"
  }
}
```

## 🔧 Implémentation

### Checklist développement
- [ ] **Route:** Définir la route dans le router
- [ ] **Controller:** Implémenter la logique métier
- [ ] **Validation:** Valider les inputs (Joi/Yup/Zod)
- [ ] **Service:** Logique business dans service layer
- [ ] **Repository:** Accès aux données si nécessaire
- [ ] **Middleware:** Auth, logging, rate limiting
- [ ] **Error handling:** Gestion d'erreurs propre

### Considérations techniques
- **Performance:** Optimisations requises
- **Sécurité:** Validation, sanitization, auth
- **Cache:** Stratégie de mise en cache
- **Rate limiting:** Limites par utilisateur/IP

## 🧪 Tests

### Tests unitaires
- [ ] **Controller tests:** Logic et edge cases
- [ ] **Service tests:** Business logic
- [ ] **Validation tests:** Input validation

### Tests d'intégration
- [ ] **API tests:** End-to-end avec DB
- [ ] **Auth tests:** Permissions et sécurité
- [ ] **Error scenarios:** Gestion d'erreurs

### Tests de performance
- [ ] **Load testing:** Charge normale
- [ ] **Stress testing:** Pics de charge

## 📚 Documentation

- [ ] **OpenAPI/Swagger:** Spécification complète
- [ ] **README:** Guide d'utilisation
- [ ] **Postman collection:** Collection de tests
- [ ] **Changelog:** Modifications apportées

## 🔗 Références

- **Design doc:** [Lien vers spécifications]
- **API standards:** [Guide de l'équipe]
- **Related endpoints:** [APIs connexes]
EOF
}

# Fonction principale pour générer des templates
generate_template() {
    local template_type="$1"
    local item_type="$2"
    shift 2
    
    case "$template_type" in
        "pbi")
            generate_pbi_template "$item_type" "$@"
            ;;
        "task")
            generate_task_template "$item_type" "$@"
            ;;
        *)
            echo "Type de template inconnu: $template_type"
            return 1
            ;;
    esac
}

# Export des fonctions pour utilisation externe
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Tests des templates
    echo "🧪 Test des templates Aklo"
    echo "========================="
    
    echo -e "\n📋 Template PBI Feature:"
    generate_pbi_template "feature" "Authentification utilisateur" "HIGH" | head -20
    
    echo -e "\n🔌 Template Task API:"
    generate_task_template "api" "Endpoint de login" "1" "4h" | head -15
fi