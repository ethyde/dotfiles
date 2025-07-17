# 📋 Référence Complète des Commandes Aklo - Serveurs MCP

## 🎯 Vue d'ensemble

Aklo propose **19 types d'artefacts** couvrant **100% des protocoles** de la Charte IA, tous accessibles via les serveurs MCP.

## 🚀 Commandes d'artefacts (`aklo new`)

### 📋 Product Backlog Items
```bash
aklo new pbi "Titre du PBI"
```
- **Protocole :** 00-PRODUCT-OWNER
- **Répertoire :** `docs/backlog/00-pbi/`
- **Format :** `PBI-{ID}-{titre}-PROPOSED.xml`

### 📝 Tâches de développement
```bash
aklo new task "Titre de la tâche"
```
- **Protocole :** 01-PLANIFICATION
- **Répertoire :** `docs/backlog/01-tasks/`
- **Format :** `TASK-{ID}-{titre}-TODO.xml`

### 🐛 Rapports de débogage
```bash
aklo new debug "Problème à déboguer"
```
- **Protocole :** 04-DEBOGAGE
- **Répertoire :** `docs/backlog/04-debug/`
- **Format :** `DEBUG-{ID}-INVESTIGATING.xml`

### 🔄 Plans de refactoring
```bash
aklo new refactor "Code à refactorer"
```
- **Protocole :** 05-REFACTORING
- **Répertoire :** `docs/backlog/05-refactor/`
- **Format :** `REFACTOR-{ID}-ANALYSIS.xml`

### ⚡ Plans d'optimisation
```bash
aklo new optimize "Performance à optimiser"
```
- **Protocole :** 06-OPTIMISATION
- **Répertoire :** `docs/backlog/06-optim/`
- **Format :** `OPTIM-{ID}-BENCHMARKING.xml`

### 🔒 Audits de sécurité
```bash
aklo new security "Audit de sécurité"
```
- **Protocole :** 13-SECURITE-AUDIT
- **Répertoire :** `docs/backlog/13-security/`
- **Format :** `SECURITY-{ID}-PROPOSED.xml`

### 📚 Documentation utilisateur
```bash
aklo new docs "Documentation à créer"
```
- **Protocole :** 17-USER-DOCS
- **Répertoire :** `docs/backlog/14-user-docs/`
- **Format :** `USERDOCS-{ID}-PROPOSED.xml`

### 🧪 Expérimentations
```bash
aklo new experiment "Hypothèse à tester"
```
- **Protocole :** 11-EXPERIMENTATION
- **Répertoire :** `docs/backlog/11-experimentation/`
- **Format :** `EXPERIMENT-{ID}-PROPOSED.xml`

### 📝 Scratchpads
```bash
aklo new scratchpad "Note temporaire"
```
- **Protocole :** 19-SCRATCHPAD
- **Répertoire :** `docs/backlog/19-scratchpad/`
- **Format :** `SCRATCHPAD-{ID}-ACTIVE.xml`

### 🔧 Propositions d'amélioration
```bash
aklo new meta "Amélioration du système"
```
- **Protocole :** 21-META-IMPROVEMENT
- **Répertoire :** `docs/backlog/18-improvements/`
- **Format :** `IMPROVE-{ID}-PROPOSED.xml`

### 📖 Journaux quotidiens
```bash
aklo new journal "Journal du jour"
```
- **Protocole :** 18-JOURNAL
- **Répertoire :** `docs/backlog/15-journal/`
- **Format :** `JOURNAL-{YYYY-MM-DD}.xml`
- **Spécial :** Vérifie l'existence du journal du jour

### 👀 Revues de code
```bash
aklo new review "Code à revoir"
```
- **Protocole :** 07-REVUE-DE-CODE
- **Répertoire :** `docs/backlog/03-reviews/`
- **Format :** `REVIEW-{ID}-PENDING.xml`

### 🏗️ Architectures
```bash
aklo new arch "Architecture à concevoir"
```
- **Protocole :** 02-ARCHITECTURE
- **Répertoire :** `docs/backlog/02-architecture/`
- **Format :** `ARCH-{ID}-DRAFT.xml`

### 🔍 Analyses de concurrence
```bash
aklo new analysis "Analyse concurrentielle"
```
- **Protocole :** 12-ANALYSE-CONCURRENCE
- **Répertoire :** `docs/backlog/10-competition/`
- **Format :** `COMPETITION-{ID}-ANALYSIS.xml`

### 👥 Plans d'onboarding
```bash
aklo new onboarding "Onboarding nouveau membre"
```
- **Protocole :** 14-ONBOARDING
- **Répertoire :** `docs/project/`
- **Format :** `ONBOARDING-SUMMARY-{YYYY-MM-DD}.xml`

### 🗑️ Plans de dépréciation
```bash
aklo new deprecation "Fonctionnalité à déprécier"
```
- **Protocole :** 15-DEPRECATION
- **Répertoire :** `docs/backlog/15-deprecation/`
- **Format :** `DEPRECATION-{ID}-PLANNED.xml`

### 📊 Plans de tracking
```bash
aklo new tracking "Métriques à suivre"
```
- **Protocole :** 16-TRACKING-PLAN
- **Répertoire :** `docs/backlog/16-tracking/`
- **Format :** `TRACKING-{ID}-ACTIVE.xml`

### ⚡ Fast-track
```bash
aklo new fast "Modification mineure"
```
- **Protocole :** 20-FAST-TRACK
- **Répertoire :** `docs/backlog/17-fast-track/`
- **Format :** `FAST-{ID}-TODO.xml`
- **Spécial :** Rappel d'utilisation appropriée

### 📚 Knowledge base
```bash
aklo new kb "Base de connaissances"
aklo kb add "Nouvelle entrée"
```
- **Protocole :** 22-KNOWLEDGE-BASE
- **Répertoire :** `docs/`
- **Format :** `KNOWLEDGE-BASE.xml`
- **Spécial :** Gestion intelligente du fichier principal

## 🔧 Commandes système

### 📊 Statut du projet
```bash
aklo status
```
- Affiche le statut complet du projet
- Compte les PBI et tâches
- Informations Git

### 🚀 Initialisation
```bash
aklo init
```
- Initialise un nouveau projet Aklo
- Crée la structure de répertoires
- Configure le fichier `.aklo.conf`

### 📋 Planification
```bash
aklo plan <PBI_ID>
```
- Décompose un PBI en tâches
- Crée les artefacts de planification

### 🔄 Gestion des tâches
```bash
aklo start-task <TASK_ID>
aklo submit-task
aklo merge-task <TASK_ID>
```
- Démarre une tâche (crée branche Git)
- Soumet une tâche (push + PR)
- Fusionne une tâche (merge + cleanup)

### 🚀 Releases et hotfixes
```bash
aklo release <major|minor|patch>
aklo hotfix start "Description"
aklo hotfix publish
```
- Gestion des releases versionnées
- Gestion des hotfixes urgents

### 💾 Cache et performance
```bash
aklo cache status
aklo cache clear
aklo cache benchmark
```
- Monitoring du cache
- Nettoyage du cache
- Benchmark des performances

### 🔍 Monitoring
```bash
aklo monitor dashboard
```
- Tableau de bord des métriques
- Monitoring I/O

### ⚙️ Configuration
```bash
aklo config diagnose
aklo config get_config
```
- Diagnostic du système
- Affichage de la configuration

## 🎯 Utilisation via MCP

### Dans Claude Desktop / Cursor
```
"Crée un nouveau PBI pour la fonctionnalité X"
"Lance aklo new pbi 'Nouvelle fonctionnalité'"

"Crée un journal pour aujourd'hui"
"Lance aklo new journal 'Journal quotidien'"

"Vérifie le statut du projet"
"Lance aklo status"
```

### Exemples d'utilisation
```
# Créer un PBI
aklo new pbi "Système d'authentification OAuth2"

# Créer une tâche
aklo new task "Implémenter l'endpoint /auth/oauth2"

# Créer un journal
aklo new journal "Développement du système d'auth"

# Créer une revue de code
aklo new review "Revue du code d'authentification"

# Créer une architecture
aklo new arch "Architecture du système d'auth"

# Créer un fast-track
aklo new fast "Correction de typo dans README"

# Créer une knowledge base
aklo new kb "Base de connaissances du projet"
aklo kb add "Leçon sur OAuth2"
```

## 📊 Statistiques

- **19 types d'artefacts** disponibles
- **100% des protocoles** de la Charte IA couverts
- **Répertoires automatiques** créés selon les protocoles
- **Gestion d'erreurs robuste** avec messages informatifs
- **Intégration complète** dans les serveurs MCP

## 🔗 Intégration MCP

Toutes ces commandes sont accessibles via :
- **Serveur Terminal MCP** : `aklo_execute`
- **Serveur Documentation MCP** : `read_protocol`, `search_documentation`
- **Configuration universelle** : Compatible avec tous les clients MCP

## ✅ Validation et Tests

### Test de toutes les commandes via MCP
```bash
# Test des 19 types d'artefacts
aklo new pbi "Test PBI via MCP"           # ✅ Fonctionne
aklo new task "Test Task via MCP"         # ✅ Fonctionne
aklo new debug "Test Debug via MCP"       # ✅ Fonctionne
aklo new refactor "Test Refactor via MCP" # ✅ Fonctionne
aklo new optimize "Test Optimize via MCP" # ✅ Fonctionne
aklo new security "Test Security via MCP" # ✅ Fonctionne
aklo new docs "Test Docs via MCP"         # ✅ Fonctionne
aklo new experiment "Test Experiment via MCP" # ✅ Fonctionne
aklo new scratchpad "Test Scratchpad via MCP" # ✅ Fonctionne
aklo new meta "Test Meta via MCP"         # ✅ Fonctionne
aklo new journal "Test Journal via MCP"   # ✅ Fonctionne
aklo new review "Test Review via MCP"     # ✅ Fonctionne
aklo new arch "Test Arch via MCP"         # ✅ Fonctionne
aklo new analysis "Test Analysis via MCP" # ✅ Fonctionne
aklo new onboarding "Test Onboarding via MCP" # ✅ Fonctionne
aklo new deprecation "Test Deprecation via MCP" # ✅ Fonctionne
aklo new tracking "Test Tracking via MCP" # ✅ Fonctionne
aklo new fast "Test Fast via MCP"         # ✅ Fonctionne
aklo new kb "Test KB via MCP"             # ✅ Fonctionne

# Test des commandes système
aklo status                               # ✅ Fonctionne
aklo cache status                         # ✅ Fonctionne
aklo monitor dashboard                    # ✅ Fonctionne
```

### Validation des serveurs MCP
```bash
# Serveur Terminal
echo '{"method":"tools/list"}' | ./shell-native/aklo-terminal.sh
# ✅ Retourne la liste des outils disponibles

# Serveur Documentation  
echo '{"method":"tools/list"}' | ./shell-native/aklo-documentation.sh
# ✅ Retourne la liste des outils disponibles

# Test d'exécution via MCP
echo '{"method":"tools/call","params":{"name":"aklo_status","arguments":{}}}' | ./shell-native/aklo-terminal.sh
# ✅ Exécute la commande aklo status
```

### Compatibilité clients MCP
- ✅ **Claude Desktop** - Testé et fonctionnel
- ✅ **Cursor** - Testé et fonctionnel  
- ✅ **VS Code** - Compatible
- ✅ **Continue Dev** - Compatible
- ✅ **Zed Editor** - Compatible
- ✅ **CLI Direct** - Testé et fonctionnel

---

**🎉 Aklo : 19 types d'artefacts, 100% des protocoles, 0% de complexité !**

**✅ Toutes les commandes sont documentées et accessibles via les serveurs MCP !** 