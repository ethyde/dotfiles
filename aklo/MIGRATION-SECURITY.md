# Migration Sécurité Aklo - Guide de Mise à Jour

## 🔒 Problème Résolu

Les versions précédentes d'Aklo pouvaient accidentellement commiter des fichiers de configuration ou des liens symboliques dans Git. Cette version améliore la sécurité.

## 🚀 Nouveaux Projets

Pour les nouveaux projets, utilisez simplement :
```bash
aklo init
```

La nouvelle version configure automatiquement :
- `.gitignore` optimisé avec patterns `.aklo.*`
- Gestion correcte des liens symboliques  
- Vérification de sécurité Git automatique

## 🔄 Migration des Projets Existants

### Option 1 : Réinitialisation Complète (Recommandée)

```bash
# 1. Sauvegarder vos artefacts métier
cp -r docs/backlog /tmp/backup-backlog

# 2. Nettoyer l'ancienne installation
rm -rf docs/CHARTE_IA .aklo.conf
git rm --cached docs/CHARTE_IA 2>/dev/null || true

# 3. Réinitialiser avec la nouvelle version
aklo init

# 4. Restaurer vos artefacts
cp -r /tmp/backup-backlog/* docs/backlog/
rm -rf /tmp/backup-backlog
```

### Option 2 : Migration Manuelle

```bash
# 1. Mettre à jour .gitignore
cat >> .gitignore << 'EOF'

# Aklo Protocol
.aklo.*
docs/CHARTE_IA
EOF

# 2. Nettoyer Git
git rm --cached docs/CHARTE_IA 2>/dev/null || true
git rm --cached .aklo.conf 2>/dev/null || true

# 3. Commiter les changements
git add .gitignore
git commit -m "🔒 security: update Aklo gitignore patterns"
```

## ✅ Vérification Post-Migration

Après migration, vérifiez que :

```bash
# 1. Aklo fonctionne
aklo propose-pbi "Test migration"

# 2. Aucun fichier Aklo n'est tracké
git ls-files | grep -E "(aklo|CHARTE_IA)" || echo "✅ Sécurisé"

# 3. Git add n'ajoute pas les fichiers Aklo
git add . && git status | grep -E "(aklo|CHARTE_IA)" || echo "✅ Ignoré"

# 4. Nettoyer le test
rm docs/backlog/00-pbi/PBI-*-PROPOSED.md
```

## 🎯 Avantages de la Migration

- ✅ Plus de risque de commit accidentel des fichiers Aklo
- ✅ Patterns `.gitignore` optimisés et future-proof
- ✅ Gestion correcte des liens symboliques
- ✅ Vérification automatique de sécurité Git
- ✅ Meilleure expérience utilisateur

## 🆘 Support

Si vous rencontrez des problèmes lors de la migration :

1. Vérifiez que vous utilisez la dernière version d'Aklo
2. Assurez-vous d'être dans un dépôt Git valide
3. Vérifiez les permissions sur le répertoire de travail

---

**Version:** 1.5+security  
**Date:** 2025-07-01  
**Impact:** Amélioration de sécurité majeure