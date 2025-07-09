#!/usr/bin/env node
/**
 * @aklo/mcp-terminal - Extension Commits Atomiques
 * 
 * Extension du serveur MCP terminal pour supporter les commits atomiques
 * par protocole selon le META-IMPROVEMENT workflow-consistency-20250102.
 */

const { readFile, writeFile, mkdir } = require('fs/promises');
const { dirname } = require('path');

let XMLParser, XMLBuilder, hasFastXmlParser = false;
try {
  ({ XMLParser, XMLBuilder } = require('fast-xml-parser'));
  hasFastXmlParser = true;
} catch (e) {
  console.warn('[AKLO:WARN] fast-xml-parser non trouvé : fallback natif pour journal XML.');
}

class AtomicCommitManager {
  constructor() {
    this.stagingArea = new Map();
    this.currentProtocol = null;
    this.journalPath = null;
    this.workdir = null;
  }

  async initAtomicSession(protocol, workdir = process.cwd()) {
    this.currentProtocol = protocol;
    this.workdir = workdir;
    const today = '2099-01-01'; // Pour test, à remplacer par date réelle
    this.journalPath = `${workdir}/JOURNAL-${today}.xml`;
    await mkdir(dirname(this.journalPath), { recursive: true });
    // Squelette XML
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<journal_day date="${today}">
  <session update="morning">
    <responsable>Human_Developer &amp; AI_Agent</responsable>
    <objectif>À définir</objectif>
    <entrees>
    </entrees>
  </session>
</journal_day>
`;
    await writeFile(this.journalPath, xml);
  }

  stageFile(filePath, content, description) {
    this.stagingArea.set(filePath, {
      content,
      description,
      timestamp: new Date()
    });
  }

  async updateJournal(action, description, artefacts) {
    const now = new Date();
    const heure = now.toTimeString().slice(0,5);
    const xmlEntree = `  <entree heure="${heure}" protocole="${this.currentProtocol}" action="${action}">
    <details>
      <item>Action : ${description}</item>
      <item>Artefacts : ${artefacts}</item>
      <item>Timestamp : ${now.toISOString()}</item>
    </details>
  </entree>\n`;
    const xml = await readFile(this.journalPath, 'utf-8');
    let newXml;
    if (hasFastXmlParser) {
      // Parsing structuré
      const parser = new XMLParser({ ignoreAttributes: false });
      const builder = new XMLBuilder({ ignoreAttributes: false, format: true });
      let doc = parser.parse(xml);
      let entrees = doc.journal_day.session.entrees;
      if (typeof entrees === 'string') entrees = {};
      if (!Array.isArray(entrees.entree)) {
        entrees.entree = entrees.entree ? [entrees.entree] : [];
      }
      entrees.entree.push({
        '@_heure': heure,
        '@_protocole': this.currentProtocol,
        '@_action': action,
        details: {
          item: [
            `Action : ${description}`,
            `Artefacts : ${artefacts}`,
            `Timestamp : ${now.toISOString()}`
          ]
        }
      });
      doc.journal_day.session.entrees = entrees;
      newXml = builder.build(doc);
    } else {
      // Fallback natif : insertion textuelle
      if (!xml.includes('</entrees>')) {
        throw new Error('Journal XML corrompu : balise </entrees> manquante');
      }
      newXml = xml.replace('</entrees>', xmlEntree + '  </entrees>');
    }
    this.stageFile(this.journalPath, newXml, `Mise à jour journal - ${action}`);
  }

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
}

module.exports = AtomicCommitManager;