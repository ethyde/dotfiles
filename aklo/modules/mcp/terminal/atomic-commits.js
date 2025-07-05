#!/usr/bin/env node
/**
 * @aklo/mcp-terminal - Extension Commits Atomiques
 * 
 * Extension du serveur MCP terminal pour supporter les commits atomiques
 * par protocole selon le META-IMPROVEMENT workflow-consistency-20250102.
 */

import { readFile, writeFile, mkdir } from 'fs/promises';
import { join, dirname } from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

class AtomicCommitManager {
  constructor() {
    this.stagingArea = new Map(); // Fichiers en attente de commit atomique
    this.journalPath = null;
    this.currentProtocol = null;
  }

  /**
   * Initialise une session de commit atomique pour un protocole
   */
  async initAtomicSession(protocol, workdir = process.cwd()) {
    this.currentProtocol = protocol;
    this.workdir = workdir;
    this.stagingArea.clear();
    
    // Initialiser le journal du jour
    const today = new Date().toISOString().split('T')[0];
    this.journalPath = join(workdir, 'docs', 'backlog', '15-journal', `JOURNAL-${today}.xml`);
    
    // Créer le répertoire journal si nécessaire
    await mkdir(dirname(this.journalPath), { recursive: true });
    
    // Créer le fichier journal du jour si nécessaire
    try {
      await readFile(this.journalPath);
    } catch (error) {
      if (error.code === 'ENOENT') {
        await this.createDailyJournal(today);
      }
    }
    
    return {
      protocol: this.currentProtocol,
      journalPath: this.journalPath,
      workdir: this.workdir
    };
  }

  /**
   * Crée le fichier journal quotidien
   */
  async createDailyJournal(date) {
    const timestamp = new Date().toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
    
    const journalContent = `# JOURNAL DE TRAVAIL : ${date}
---
**Responsable:** Human_Developer & AI_Agent
**Objectif(s) de la journée:** [À définir]
---

## Entrées Chronologiques

### ${timestamp} - Début de session

- **Action :** Ouverture du journal quotidien
- **Contexte :** Utilisation du système de commits atomiques par protocole

`;

    await writeFile(this.journalPath, journalContent);
  }

  /**
   * Ajoute un fichier à la zone de staging pour le commit atomique
   */
  stageFile(filePath, content, description) {
    this.stagingArea.set(filePath, {
      content,
      description,
      timestamp: new Date()
    });
  }

  /**
   * Met à jour le journal avec une entrée de protocole
   */
  async updateJournal(action, description, artefacts) {
    const timestamp = new Date().toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
    
    const journalEntry = `
### ${timestamp} - [${this.currentProtocol}] ${action}

- **Action :** ${description}
- **Artefacts :** ${artefacts}
- **Timestamp :** ${new Date().toISOString()}

`;

    // Ajouter l'entrée au journal existant
    const currentJournal = await readFile(this.journalPath, 'utf-8');
    const updatedJournal = currentJournal + journalEntry;
    
    // Stager le journal mis à jour
    this.stageFile(this.journalPath, updatedJournal, `Mise à jour journal - ${action}`);
  }

  /**
   * Génère le message de commit selon le protocole
   */
  generateCommitMessage(protocol, summary, details = {}) {
    const { artefacts = [], taskCount = 0, version = null } = details;
    
    let commitMsg = '';
    
    switch (protocol) {
      case 'PLANIFICATION':
        commitMsg = `feat(planning): ${summary}

- Création de ${taskCount} tasks techniques
- PBI mis à jour avec la liste des tasks associées
- Journal mis à jour avec le processus de planification

Tasks créées:`;
        artefacts.forEach(task => {
          commitMsg += `\n- ${task}`;
        });
        commitMsg += '\n\nProchaine étape: DEVELOPPEMENT';
        break;

      case 'ARCHITECTURE':
        commitMsg = `feat(arch): ${summary}

- Document d'architecture validé
- Tasks modifiées selon l'impact architectural
- Journal mis à jour avec les décisions architecturales

Architecture retenue: ${details.solution || '[À spécifier]'}

Tasks impactées:`;
        artefacts.forEach(task => {
          commitMsg += `\n- ${task}`;
        });
        commitMsg += '\n\nProchaine étape: DEVELOPPEMENT';
        break;

      case 'DEVELOPPEMENT':
        commitMsg = `feat(${details.taskId}): ${summary}

${details.description || ''}

- Implémentation complète selon Definition of Done
- Tous les tests passent (linter, typage, suite de tests)
- ${details.taskId} marquée comme DONE
- Journal mis à jour avec le processus d'implémentation

Closes ${details.taskId}`;
        break;

      case 'RELEASE':
        commitMsg = `release: Version ${version}

${summary}

- Rapport RELEASE-${version} finalisé
- CHANGELOG.xml mis à jour avec nouvelles fonctionnalités
- Version mise à jour : ${details.oldVersion} → ${version}
- Journal mis à jour avec le processus de release
- Tous les tests passent, build de production validé

Type de release: ${details.releaseType}`;
        break;

      case 'META-IMPROVEMENT':
        commitMsg = `refactor(meta): ${summary}

${details.description || ''}

- Correction des incohérences de workflow identifiées
- Mise à jour des protocoles selon le nouveau framework
- Journal mis à jour avec le processus d'amélioration

Protocoles modifiés:`;
        artefacts.forEach(protocol => {
          commitMsg += `\n- ${protocol}`;
        });
        break;

      default:
        commitMsg = `feat(${protocol.toLowerCase()}): ${summary}

- Artefacts créés/modifiés selon le protocole ${protocol}
- Journal mis à jour avec le processus d'exécution

Artefacts:`;
        artefacts.forEach(artefact => {
          commitMsg += `\n- ${artefact}`;
        });
    }
    
    return commitMsg;
  }

  /**
   * Valide et effectue le commit atomique
   */
  async executeAtomicCommit(summary, details = {}) {
    if (this.stagingArea.size === 0) {
      throw new Error('Aucun fichier en staging pour le commit atomique');
    }

    // Écrire tous les fichiers stagés
    const filePaths = [];
    for (const [filePath, fileData] of this.stagingArea) {
      await mkdir(dirname(filePath), { recursive: true });
      await writeFile(filePath, fileData.content);
      filePaths.push(filePath);
    }

    // Générer le message de commit
    const commitMessage = this.generateCommitMessage(this.currentProtocol, summary, details);

    try {
      // Ajouter les fichiers à Git
      const addCommand = `git add ${filePaths.map(p => `"${p}"`).join(' ')}`;
      await execAsync(addCommand, { cwd: this.workdir });

      // Créer le commit
      const commitCommand = `git commit -m "${commitMessage.replace(/"/g, '\\"')}"`;
      const { stdout } = await execAsync(commitCommand, { cwd: this.workdir });

      // Nettoyer la zone de staging
      this.stagingArea.clear();

      return {
        success: true,
        commitHash: stdout.match(/\[.*?\s([a-f0-9]+)\]/)?.[1] || 'unknown',
        message: commitMessage,
        filesCommitted: filePaths.length
      };

    } catch (error) {
      throw new Error(`Échec du commit atomique: ${error.message}`);
    }
  }

  /**
   * Annule la session de commit atomique
   */
  cancelAtomicSession() {
    this.stagingArea.clear();
    this.currentProtocol = null;
    this.journalPath = null;
    this.workdir = null;
  }

  /**
   * Retourne l'état actuel de la session
   */
  getSessionStatus() {
    return {
      protocol: this.currentProtocol,
      stagedFiles: Array.from(this.stagingArea.keys()),
      stagedCount: this.stagingArea.size,
      journalPath: this.journalPath,
      workdir: this.workdir
    };
  }
}

// Export pour utilisation dans le serveur MCP principal
export { AtomicCommitManager };

// Utilisation autonome pour tests
if (import.meta.url === `file://${process.argv[1]}`) {
  const manager = new AtomicCommitManager();
  
  // Test basique
  console.log('Test du gestionnaire de commits atomiques...');
  
  const session = await manager.initAtomicSession('PLANIFICATION', process.cwd());
  console.log('Session initialisée:', session);
  
  // Simuler la création d'une task
  manager.stageFile(
    join(process.cwd(), 'test-task.xml'),
    '# TASK-42-01: Test Task\n\nContenu de test',
    'Création task de test'
  );
  
  await manager.updateJournal(
    'Création Task',
    'Création d\'une task de test pour validation du système',
    'TASK-42-01'
  );
  
  console.log('État de la session:', manager.getSessionStatus());
  
  // Annuler pour le test
  manager.cancelAtomicSession();
  console.log('Test terminé - session annulée');
}