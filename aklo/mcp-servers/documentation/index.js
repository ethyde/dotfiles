#!/usr/bin/env node
/**
 * @aklo/mcp-documentation
 * 
 * Serveur MCP spécialisé pour la gestion de la documentation dans l'écosystème Aklo.
 * Fournit un accès structuré à la Charte IA, aux protocoles, et aux artefacts de projet.
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { 
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { readFile, readdir, stat } from 'fs/promises';
import { join, basename, extname } from 'path';

// Version et timestamp pour détecter les redémarrages nécessaires
const SERVER_VERSION = '1.1.0';
const SERVER_START_TIME = new Date().toISOString();

class AkloDocumentationServer {
  constructor() {
    this.server = new Server(
      {
        name: '@aklo/mcp-documentation',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'read_protocol',
          description: 'Lit et analyse un protocole spécifique de la Charte IA',
          inputSchema: {
            type: 'object',
            properties: {
              protocol_name: {
                type: 'string',
                description: 'Nom du protocole (ex: "DEVELOPPEMENT", "PLANIFICATION", "JOURNAL")',
              },
              section: {
                type: 'string',
                description: 'Section spécifique à extraire (optionnel)',
              },
              charte_path: {
                type: 'string',
                description: 'Chemin vers la charte (optionnel, détecté automatiquement)',
              },
            },
            required: ['protocol_name'],
          },
        },
        {
          name: 'list_protocols',
          description: 'Liste tous les protocoles disponibles dans la Charte IA',
          inputSchema: {
            type: 'object',
            properties: {
              charte_path: {
                type: 'string',
                description: 'Chemin vers la charte (optionnel)',
              },
            },
          },
        },
        {
          name: 'search_documentation',
          description: 'Recherche dans la documentation Aklo par mots-clés',
          inputSchema: {
            type: 'object',
            properties: {
              query: {
                type: 'string',
                description: 'Termes à rechercher',
              },
              scope: {
                type: 'string',
                enum: ['protocols', 'artefacts', 'all'],
                description: 'Portée de la recherche',
                default: 'all',
              },
              charte_path: {
                type: 'string',
                description: 'Chemin vers la charte (optionnel)',
              },
            },
            required: ['query'],
          },
        },
        {
          name: 'read_artefact',
          description: 'Lit un artefact de projet (PBI, Task, Debug, etc.)',
          inputSchema: {
            type: 'object',
            properties: {
              artefact_path: {
                type: 'string',
                description: 'Chemin vers l\'artefact à lire',
              },
              extract_metadata: {
                type: 'boolean',
                description: 'Extraire les métadonnées de l\'en-tête',
                default: true,
              },
            },
            required: ['artefact_path'],
          },
        },
        {
          name: 'project_documentation_summary',
          description: 'Génère un résumé de la documentation du projet',
          inputSchema: {
            type: 'object',
            properties: {
              project_path: {
                type: 'string',
                description: 'Chemin vers le projet',
              },
              include_artefacts: {
                type: 'boolean',
                description: 'Inclure les artefacts dans le résumé',
                default: true,
              },
            },
            required: ['project_path'],
          },
        },
        {
          name: 'validate_artefact',
          description: 'Valide la structure d\'un artefact selon les protocoles Aklo',
          inputSchema: {
            type: 'object',
            properties: {
              artefact_path: {
                type: 'string',
                description: 'Chemin vers l\'artefact à valider',
              },
              artefact_type: {
                type: 'string',
                enum: ['PBI', 'TASK', 'DEBUG', 'ARCH', 'REVIEW'],
                description: 'Type d\'artefact à valider',
              },
            },
            required: ['artefact_path', 'artefact_type'],
          },
        },
        {
          name: 'server_info',
          description: 'Informations sur le serveur MCP (version, démarrage)',
          inputSchema: {
            type: 'object',
            properties: {},
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        switch (name) {
          case 'read_protocol':
            return await this.handleReadProtocol(args);
          case 'list_protocols':
            return await this.handleListProtocols(args);
          case 'search_documentation':
            return await this.handleSearchDocumentation(args);
          case 'read_artefact':
            return await this.handleReadArtefact(args);
          case 'project_documentation_summary':
            return await this.handleProjectDocumentationSummary(args);
          case 'validate_artefact':
            return await this.handleValidateArtefact(args);
          case 'server_info':
            return await this.handleServerInfo(args);
          default:
            throw new Error(`Outil inconnu: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Erreur lors de l'exécution de ${name}: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  async handleReadProtocol(args) {
    const { protocol_name, section, charte_path } = args;
    
    const chartePath = charte_path || await this.findChartePath();
    const protocolsPath = join(chartePath, 'PROTOCOLES');
    
    // Rechercher le fichier par nom de protocole dans tous les fichiers
    let content = '';
    let foundPath = '';
    let debugInfo = '';
    
    try {
      const files = await readdir(protocolsPath);
      const protocolFiles = files.filter(file => file.endsWith('.md'));
      
      // Chercher le fichier qui contient le nom du protocole
      const targetProtocol = protocol_name.toUpperCase();
      debugInfo += `Recherche de: "${targetProtocol}"\n`;
      debugInfo += `Fichiers disponibles: ${protocolFiles.join(', ')}\n`;
      
      const matchingFile = protocolFiles.find(file => {
        // Format: XX-PROTOCOLE.md
        const match = file.match(/^\d+-(.+)\.md$/);
        const extracted = match ? match[1] : null;
        debugInfo += `Fichier: ${file} -> Extrait: "${extracted}" (match: ${extracted === targetProtocol})\n`;
        return match && match[1] === targetProtocol;
      });
      
      debugInfo += `Fichier trouvé: ${matchingFile || 'AUCUN'}\n`;
      
      if (matchingFile) {
        foundPath = join(protocolsPath, matchingFile);
        content = await readFile(foundPath, 'utf-8');
      }
    } catch (error) {
      throw new Error(`Erreur lors de la lecture du répertoire des protocoles: ${error.message}`);
    }
    
    if (!content) {
      throw new Error(`Protocole ${protocol_name} introuvable dans ${chartePath}\n\nDébogage:\n${debugInfo}`);
    }
    
    let result = `📋 Protocole: ${protocol_name.toUpperCase()}\n`;
    result += `📁 Fichier: ${foundPath}\n\n`;
    
    if (section) {
      // Extraire une section spécifique
      const sectionContent = this.extractSection(content, section);
      if (sectionContent) {
        result += `## Section: ${section}\n\n${sectionContent}`;
      } else {
        result += `⚠️  Section "${section}" non trouvée dans le protocole.\n\n`;
        result += content;
      }
    } else {
      result += content;
    }
    
    return {
      content: [{ type: 'text', text: result }],
    };
  }

  async handleListProtocols(args) {
    const { charte_path } = args;
    
    const chartePath = charte_path || await this.findChartePath();
    const protocolsPath = join(chartePath, 'PROTOCOLES');
    
    try {
      const files = await readdir(protocolsPath);
      const protocols = files
        .filter(file => file.endsWith('.md'))
        .map(file => {
          const match = file.match(/^(\d+)-(.+)\.md$/);
          return match ? {
            number: match[1],
            name: match[2],
            filename: file,
          } : {
            number: '??',
            name: basename(file, '.md'),
            filename: file,
          };
        })
        .sort((a, b) => a.number.localeCompare(b.number));
      
      let result = '📚 Protocoles Aklo Disponibles\n\n';
      
      for (const protocol of protocols) {
        result += `${protocol.number}. **${protocol.name}**\n`;
        
        // Lire la première ligne pour obtenir la description
        try {
          const protocolContent = await readFile(join(protocolsPath, protocol.filename), 'utf-8');
          const lines = protocolContent.split('\n');
          const descLine = lines.find(line => line.startsWith('# PROTOCOLE SPÉCIFIQUE :'));
          if (descLine) {
            const desc = descLine.replace('# PROTOCOLE SPÉCIFIQUE :', '').trim();
            result += `   ${desc}\n`;
          }
        } catch {
          // Ignorer si on ne peut pas lire le fichier
        }
        
        result += '\n';
      }
      
      return {
        content: [{ type: 'text', text: result }],
      };
    } catch (error) {
      throw new Error(`Impossible de lister les protocoles: ${error.message}`);
    }
  }

  async handleSearchDocumentation(args) {
    const { query, scope = 'all', charte_path } = args;
    
    const chartePath = charte_path || await this.findChartePath();
    const searchTerms = query.toLowerCase().split(' ');
    let results = [];
    
    if (scope === 'protocols' || scope === 'all') {
      // Rechercher dans les protocoles
      const protocolsPath = join(chartePath, 'PROTOCOLES');
      try {
        const protocolFiles = await readdir(protocolsPath);
        
        for (const file of protocolFiles.filter(f => f.endsWith('.md'))) {
          const content = await readFile(join(protocolsPath, file), 'utf-8');
          const contentLower = content.toLowerCase();
          
          const matches = searchTerms.filter(term => contentLower.includes(term));
          if (matches.length > 0) {
            results.push({
              type: 'Protocol',
              file: file,
              path: join(protocolsPath, file),
              matches: matches.length,
              relevance: matches.length / searchTerms.length,
            });
          }
        }
      } catch {
        // Ignorer si le répertoire n'existe pas
      }
    }
    
    // Trier par pertinence
    results.sort((a, b) => b.relevance - a.relevance);
    
    let output = `🔍 Résultats de recherche pour: "${query}"\n\n`;
    
    if (results.length === 0) {
      output += 'Aucun résultat trouvé.\n';
    } else {
      output += `${results.length} résultat(s) trouvé(s):\n\n`;
      
      for (const result of results.slice(0, 10)) { // Limiter à 10 résultats
        output += `📄 **${result.type}**: ${result.file}\n`;
        output += `   Pertinence: ${Math.round(result.relevance * 100)}%\n`;
        output += `   Chemin: ${result.path}\n\n`;
      }
    }
    
    return {
      content: [{ type: 'text', text: output }],
    };
  }

  async handleReadArtefact(args) {
    const { artefact_path, extract_metadata = true } = args;
    
    try {
      const content = await readFile(artefact_path, 'utf-8');
      let result = `📄 Artefact: ${basename(artefact_path)}\n`;
      result += `📁 Chemin: ${artefact_path}\n\n`;
      
      if (extract_metadata) {
        const metadata = this.extractArtefactMetadata(content);
        if (Object.keys(metadata).length > 0) {
          result += '📊 Métadonnées:\n';
          for (const [key, value] of Object.entries(metadata)) {
            result += `   ${key}: ${value}\n`;
          }
          result += '\n';
        }
      }
      
      result += '📝 Contenu:\n\n';
      result += content;
      
      return {
        content: [{ type: 'text', text: result }],
      };
    } catch (error) {
      throw new Error(`Impossible de lire l'artefact: ${error.message}`);
    }
  }

  async handleProjectDocumentationSummary(args) {
    const { project_path, include_artefacts = true } = args;
    
    let summary = `📊 Résumé de la Documentation du Projet\n`;
    summary += `📁 Projet: ${project_path}\n\n`;
    
    // Vérifier la configuration Aklo
    try {
      const akloConfig = await readFile(join(project_path, '.aklo.conf'), 'utf-8');
      summary += '✅ Projet initialisé avec Aklo\n\n';
    } catch {
      summary += '❌ Projet non initialisé avec Aklo\n\n';
      return {
        content: [{ type: 'text', text: summary }],
      };
    }
    
    if (include_artefacts) {
      // Compter les différents types d'artefacts
      const backlogPath = join(project_path, 'docs', 'backlog');
      
      const artefactTypes = [
        { name: 'PBI', path: '00-pbi', pattern: 'PBI-*.md' },
        { name: 'Tasks', path: '01-tasks', pattern: 'TASK-*.md' },
        { name: 'Architecture', path: '02-architecture', pattern: 'ARCH-*.md' },
        { name: 'Debug', path: '04-debug', pattern: 'DEBUG-*.md' },
        { name: 'Reviews', path: '07-reviews', pattern: 'REVIEW-*.md' },
        { name: 'Journal', path: '15-journal', pattern: 'JOURNAL-*.md' },
      ];
      
      summary += '📋 Artefacts du Projet:\n';
      
      for (const type of artefactTypes) {
        try {
          const typePath = join(backlogPath, type.path);
          const files = await readdir(typePath);
          const count = files.filter(f => f.match(type.pattern.replace('*', '.*'))).length;
          summary += `   ${type.name}: ${count} fichier(s)\n`;
        } catch {
          summary += `   ${type.name}: 0 fichier(s)\n`;
        }
      }
    }
    
    return {
      content: [{ type: 'text', text: summary }],
    };
  }

  async handleValidateArtefact(args) {
    const { artefact_path, artefact_type } = args;
    
    try {
      const content = await readFile(artefact_path, 'utf-8');
      const metadata = this.extractArtefactMetadata(content);
      
      let validation = `✅ Validation de l'Artefact\n`;
      validation += `📄 Fichier: ${basename(artefact_path)}\n`;
      validation += `📋 Type: ${artefact_type}\n\n`;
      
      const issues = [];
      
      // Validations communes
      if (!content.includes('---')) {
        issues.push('❌ En-tête de métadonnées manquant (---)');
      }
      
      if (!metadata.Statut && !metadata.Status) {
        issues.push('❌ Statut manquant dans les métadonnées');
      }
      
      // Validations spécifiques par type
      switch (artefact_type) {
        case 'PBI':
          if (!content.includes('## 1. Description de la User Story')) {
            issues.push('❌ Section "Description de la User Story" manquante');
          }
          if (!content.includes('## 2. Critères d\'Acceptation')) {
            issues.push('❌ Section "Critères d\'Acceptation" manquante');
          }
          break;
          
        case 'TASK':
          if (!content.includes('## Definition of Done')) {
            issues.push('❌ Section "Definition of Done" manquante');
          }
          break;
      }
      
      if (issues.length === 0) {
        validation += '✅ Artefact valide selon les protocoles Aklo\n';
      } else {
        validation += '⚠️  Problèmes détectés:\n\n';
        validation += issues.join('\n') + '\n';
      }
      
      return {
        content: [{ type: 'text', text: validation }],
      };
    } catch (error) {
      throw new Error(`Erreur lors de la validation: ${error.message}`);
    }
  }

  async handleServerInfo(args) {
    const uptime = Math.floor((Date.now() - new Date(SERVER_START_TIME).getTime()) / 1000);
    const uptimeFormatted = `${Math.floor(uptime / 60)}m ${uptime % 60}s`;
    
    let result = `🤖 Serveur MCP Documentation Aklo\n\n`;
    result += `📦 Version: ${SERVER_VERSION}\n`;
    result += `🕐 Démarré: ${SERVER_START_TIME}\n`;
    result += `⏱️  Uptime: ${uptimeFormatted}\n`;
    result += `🔧 PID: ${process.pid}\n`;
    result += `📁 Répertoire: ${process.cwd()}\n\n`;
    
    // Informations sur les fichiers surveillés
    const watchedFiles = [
      __filename,
      join(process.cwd(), 'package.json'),
    ];
    
    result += `📝 Fichiers surveillés:\n`;
    for (const file of watchedFiles) {
      try {
        const stats = await stat(file);
        const modTime = stats.mtime.toISOString();
        result += `  • ${basename(file)}: ${modTime}\n`;
      } catch {
        result += `  • ${basename(file)}: non trouvé\n`;
      }
    }
    
    result += `\n💡 Pour redémarrer après modification:\n`;
    result += `   cd aklo/mcp-servers && ./restart-mcp.sh\n`;
    result += `\n🔍 Mode développement:\n`;
    result += `   cd aklo/mcp-servers && ./watch-mcp.sh\n`;
    
    return {
      content: [{ type: 'text', text: result }],
    };
  }

  async findChartePath() {
    // Chercher la charte dans plusieurs emplacements possibles
    const possiblePaths = [
      join(process.cwd(), 'docs', 'CHARTE_IA'),
      join(process.env.HOME, '.dotfiles', 'aklo', 'charte'),
      join(process.env.HOME, 'dotfiles', 'aklo', 'charte'),
      join(process.env.HOME, 'Projets', 'dotfiles', 'aklo', 'charte'),
      // Chemin relatif depuis le répertoire du serveur MCP
      join(process.cwd(), 'aklo', 'charte'),
      // Chemin depuis le répertoire parent du serveur MCP
      join(process.cwd(), '..', 'charte'),
      join(process.cwd(), '..', '..', 'charte'),
    ];
    
    for (const path of possiblePaths) {
      try {
        await stat(path);
        return path;
      } catch {
        continue;
      }
    }
    
    throw new Error('Charte IA introuvable. Assurez-vous qu\'Aklo est initialisé.');
  }

  extractSection(content, sectionName) {
    const lines = content.split('\n');
    let inSection = false;
    let sectionContent = [];
    
    for (const line of lines) {
      if (line.toLowerCase().includes(sectionName.toLowerCase())) {
        inSection = true;
        continue;
      }
      
      if (inSection) {
        if (line.startsWith('##') && !line.toLowerCase().includes(sectionName.toLowerCase())) {
          break;
        }
        sectionContent.push(line);
      }
    }
    
    return sectionContent.join('\n').trim();
  }

  extractArtefactMetadata(content) {
    const metadata = {};
    const lines = content.split('\n');
    let inMetadata = false;
    
    for (const line of lines) {
      if (line.trim() === '---') {
        if (inMetadata) break;
        inMetadata = true;
        continue;
      }
      
      if (inMetadata && line.includes(':')) {
        const [key, ...valueParts] = line.split(':');
        const value = valueParts.join(':').trim();
        if (key.startsWith('**') && key.endsWith('**')) {
          const cleanKey = key.replace(/\*\*/g, '');
          metadata[cleanKey] = value;
        }
      }
    }
    
    return metadata;
  }

  setupErrorHandling() {
    this.server.onerror = (error) => {
      console.error('[MCP Documentation Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('📚 Serveur MCP Documentation Aklo démarré');
  }
}

// Démarrer le serveur
const server = new AkloDocumentationServer();
server.start().catch(console.error);