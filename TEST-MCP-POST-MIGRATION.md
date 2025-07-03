# Test Post-Migration MCP

## Tests à Effectuer Après Réactivation

### 1. Test Serveur Documentation
```bash
# Devrait fonctionner depuis modules/mcp/
mcp_aklo-documentation_read_protocol DEVELOPPEMENT
```

### 2. Test Serveur Terminal  
```bash
# Devrait fonctionner depuis modules/mcp/
mcp_aklo-terminal_aklo_status
```

### 3. Test Commandes Aklo
```bash
# Test cache avec nouvelle architecture
aklo cache status

# Test monitoring avec nouvelle architecture  
aklo monitor dashboard

# Test configuration avec nouvelle architecture
aklo config diagnose
```

### 4. Validation Complète
- [ ] Serveurs MCP redémarrés ✅
- [ ] Cursor redémarré (action utilisateur)
- [ ] Outils MCP fonctionnels
- [ ] Commandes aklo opérationnelles
- [ ] Architecture modulaire validée

## En Cas de Problème

Si les serveurs MCP ne fonctionnent pas :
1. Vérifier chemins dans modules/mcp/
2. Relancer ./modules/mcp/restart-mcp.sh
3. Redémarrer Cursor à nouveau