# DEBUG-aklo-status-timeout-20250102 : Timeout MCP pour aklo status mode standard

---
**Statut:** AWAITING_FIX
**Date de création:** 2025-01-02
**Priorité:** BASSE
**Composant:** Interface MCP aklo-terminal
---

## 1. Description du Problème

**Symptôme :** La commande `aklo status` (mode standard, sans options) provoque un timeout/échec via le serveur MCP aklo-terminal, bien qu'elle fonctionne parfaitement en CLI direct.

**Impact :** 
- Utilisabilité dégradée via interface MCP
- Aucun impact sur l'utilisation CLI directe
- Les autres modes (--brief, --detailed, --json) fonctionnent parfaitement

## 2. Contexte et Environnement

**Version :** Aklo Interface Unifiée (META-IMPROVEMENT command-coverage-20250102)
**Environnement :** 
- macOS 24.5.0
- Node.js MCP Server (@aklo/mcp-terminal v1.0.0)
- Script aklo v2.0+ (Interface complète)

**Commandes Affectées :**
- ❌ `aklo status` (via MCP) → Timeout/échec
- ✅ `aklo status --brief` (via MCP) → Fonctionne
- ✅ `aklo status --detailed` (via MCP) → Fonctionne  
- ✅ `aklo status --json` (via MCP) → Fonctionne
- ✅ `./aklo/bin/aklo status` (CLI direct) → Fonctionne

## 3. Analyse Technique

**Hypothèses :**

1. **Timeout MCP :** Le mode standard génère plus de sortie et dépasse le timeout MCP (30s)
2. **Boucle infinie :** Possible problème dans `show_status_standard()` du script status-command.sh
3. **Problème de buffering :** La sortie standard peut causer des problèmes de flush
4. **Interaction shell :** Différence de comportement entre exécution CLI et MCP

**Code Concerné :**
```bash
# aklo/bin/aklo - function command_status()
aklo_status "${mode:-standard}"

# aklo/ux-improvements/status-command.sh - function show_status_standard()
```

## 4. Tests de Reproduction

**Reproduction :**
```bash
# ❌ Échoue via MCP
mcp_aklo-terminal_aklo_execute("status", [])

# ✅ Fonctionne en CLI
cd /Users/eplouvie/Projets/dotfiles && ./aklo/bin/aklo status
```

**Résultats :**
- CLI : Affiche le dashboard complet puis se termine normalement
- MCP : Timeout après délai d'attente, aucune sortie retournée

## 5. Investigation Préliminaire

**Actions Effectuées :**
1. ✅ Vérification que `show_status_standard()` existe dans status-command.sh
2. ✅ Test des autres modes (--brief, --detailed, --json) → Tous fonctionnent
3. ✅ Test CLI direct → Fonctionne parfaitement
4. ✅ Vérification des permissions et chemins de fichiers

**Pistes à Explorer :**
1. Ajouter des logs/debug dans `show_status_standard()`
2. Comparer la taille de sortie entre les modes
3. Tester avec timeout MCP augmenté
4. Vérifier les appels système dans `show_status_standard()`

## 6. Contournement Temporaire

**Solution de contournement :**
Utiliser les modes spécifiques qui fonctionnent :
- `aklo status --brief` pour un aperçu rapide
- `aklo status --detailed` pour le dashboard complet
- CLI direct `./aklo/bin/aklo status` si nécessaire

## 7. Priorité et Impact

**Priorité :** BASSE
- Les fonctionnalités critiques fonctionnent
- Contournements disponibles
- N'affecte pas l'utilisation CLI

**Impact Business :** MINIMAL
- Interface MCP légèrement dégradée
- Productivité non affectée

## 8. Plan de Résolution

**Étapes Proposées :**
1. Analyser la fonction `show_status_standard()` pour identifier les goulots d'étranglement
2. Ajouter du logging pour identifier où se produit le blocage
3. Optimiser ou simplifier la sortie du mode standard
4. Tester avec différents timeouts MCP
5. Valider la correction avec tous les modes

**Effort Estimé :** 1-2h de debugging