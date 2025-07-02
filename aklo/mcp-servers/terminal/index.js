#!/usr/bin/env node
/**
 * @aklo/mcp-terminal
 * 
 * Serveur MCP spécialisé pour la gestion du terminal dans l'écosystème Aklo.
 * Fournit des outils sécurisés et contextuels pour l'exécution de commandes
 * en respectant les protocoles de sécurité définis dans la Charte IA.
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { 
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { spawn, exec } from 'child_process';
import { readFile, access } from 'fs/promises';
import { join, resolve } from 'path';
import { promisify } from 'util';

const execAsync = promisify(exec);

class AkloTerminalServer {
  constructor() {
    this.server = new Server(
      {
        name: '@aklo/mcp-terminal',
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
          name: 'aklo_execute',
          description: 'Exécute une commande aklo de manière sécurisée avec validation du contexte',
          inputSchema: {
            type: 'object',
            properties: {
              command: {
                type: 'string',
                description: 'Commande aklo à exécuter (ex: "init", "propose-pbi", "plan")',
              },
              args: {
                type: 'array',
                items: { type: 'string' },
                description: 'Arguments pour la commande aklo',
              },
              workdir: {
                type: 'string',
                description: 'Répertoire de travail (optionnel, utilise le répertoire courant par défaut)',
              },
            },
            required: ['command'],
          },
        },
        {
          name: 'aklo_status',
          description: 'Affiche le statut actuel du projet Aklo (PBI, Tasks, configuration)',
          inputSchema: {
            type: 'object',
            properties: {
              workdir: {
                type: 'string',
                description: 'Répertoire du projet à analyser',
              },
            },
          },
        },
        {
          name: 'safe_shell',
          description: 'Exécute une commande shell sécurisée avec restrictions Aklo',
          inputSchema: {
            type: 'object',
            properties: {
              command: {
                type: 'string',
                description: 'Commande shell à exécuter',
              },
              workdir: {
                type: 'string',
                description: 'Répertoire de travail',
              },
              timeout: {
                type: 'number',
                description: 'Timeout en millisecondes (défaut: 30000)',
                default: 30000,
              },
            },
            required: ['command'],
          },
        },
        {
          name: 'project_info',
          description: 'Récupère les informations sur le projet courant (package.json, git, aklo config)',
          inputSchema: {
            type: 'object',
            properties: {
              workdir: {
                type: 'string',
                description: 'Répertoire du projet',
              },
            },
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        switch (name) {
          case 'aklo_execute':
            return await this.handleAkloExecute(args);
          case 'aklo_status':
            return await this.handleAkloStatus(args);
          case 'safe_shell':
            return await this.handleSafeShell(args);
          case 'project_info':
            return await this.handleProjectInfo(args);
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

  async handleAkloExecute(args) {
    const { command, args: cmdArgs = [], workdir = process.cwd() } = args;
    
    // Validation des commandes aklo autorisées
    const allowedCommands = [
      // Commandes legacy
      'init', 'propose-pbi', 'pbi', 'plan', 'start-task', 'submit-task', 
      'merge-task', 'release', 'hotfix', 'new', 'get_config',
      
      // Commandes système (PHASE 1)
      'status', 'validate', 'mcp', 'template', 'install-ux',
      
      // Commandes développement (PHASE 2)
      'arch', 'dev', 'debug', 'review', 'refactor',
      
      // Commandes qualité (PHASE 3)
      'optimize', 'security', 'diagnose', 'experiment', 'docs',
      
      // Commandes spécialisées (PHASE 4)
      'analyze', 'track', 'onboard', 'deprecate', 'kb', 'fast', 'meta'
    ];
    
    if (!allowedCommands.includes(command)) {
      throw new Error(`Commande aklo non autorisée: ${command}`);
    }
    
    // Construire la commande complète
    const akloPath = await this.findAkloScript(workdir);
    const fullCommand = [akloPath, command, ...cmdArgs].join(' ');
    
    try {
      const { stdout, stderr } = await execAsync(fullCommand, { 
        cwd: workdir,
        timeout: 30000,
      });
      
      return {
        content: [
          {
            type: 'text',
            text: `Commande: aklo ${command} ${cmdArgs.join(' ')}\n\nSortie:\n${stdout}${stderr ? `\nErreurs:\n${stderr}` : ''}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Échec de la commande aklo: ${error.message}`);
    }
  }

  async handleAkloStatus(args) {
    const { workdir = process.cwd() } = args;
    
    try {
      // Vérifier si le projet est initialisé avec Aklo
      const akloConfigPath = join(workdir, '.aklo.conf');
      const charteLink = join(workdir, 'docs', 'CHARTE_IA');
      
      let status = '📊 Statut du Projet Aklo\n\n';
      
      // Vérifier l'initialisation
      try {
        await access(akloConfigPath);
        await access(charteLink);
        status += '✅ Projet initialisé avec Aklo\n';
        
        // Lire la configuration
        const config = await readFile(akloConfigPath, 'utf-8');
        const workdirMatch = config.match(/PROJECT_WORKDIR=(.+)/);
        if (workdirMatch) {
          status += `📁 Répertoire de travail: ${workdirMatch[1]}\n`;
        }
      } catch {
        status += '❌ Projet non initialisé avec Aklo\n';
        return {
          content: [{ type: 'text', text: status }],
        };
      }
      
      // Compter les PBI
      try {
        const { stdout } = await execAsync('find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l', { cwd: workdir });
        const pbiCount = parseInt(stdout.trim());
        status += `📋 PBI: ${pbiCount} définis\n`;
      } catch {
        status += '📋 PBI: Aucun répertoire de backlog trouvé\n';
      }
      
      // Vérifier Git
      try {
        const { stdout } = await execAsync('git branch --show-current 2>/dev/null', { cwd: workdir });
        status += `🌿 Branche Git actuelle: ${stdout.trim()}\n`;
      } catch {
        status += '🌿 Git: Non initialisé\n';
      }
      
      return {
        content: [{ type: 'text', text: status }],
      };
    } catch (error) {
      throw new Error(`Erreur lors de la récupération du statut: ${error.message}`);
    }
  }

  async handleSafeShell(args) {
    const { command, workdir = process.cwd(), timeout = 30000 } = args;
    
    // Liste des commandes dangereuses interdites
    const dangerousCommands = [
      'rm -rf /', 'sudo', 'chmod 777', 'mv /', 'cp -r /', 
      'dd if=', 'mkfs', 'fdisk', 'format', 'del *', 'deltree'
    ];
    
    const isDangerous = dangerousCommands.some(dangerous => 
      command.toLowerCase().includes(dangerous.toLowerCase())
    );
    
    if (isDangerous) {
      throw new Error(`Commande potentiellement dangereuse refusée: ${command}`);
    }
    
    try {
      const { stdout, stderr } = await execAsync(command, { 
        cwd: workdir,
        timeout,
      });
      
      return {
        content: [
          {
            type: 'text',
            text: `Commande: ${command}\nRépertoire: ${workdir}\n\nSortie:\n${stdout}${stderr ? `\nErreurs:\n${stderr}` : ''}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Échec de la commande shell: ${error.message}`);
    }
  }

  async handleProjectInfo(args) {
    const { workdir = process.cwd() } = args;
    
    let info = '📁 Informations du Projet\n\n';
    
    try {
      // Package.json
      const packagePath = join(workdir, 'package.json');
      try {
        const packageContent = await readFile(packagePath, 'utf-8');
        const packageJson = JSON.parse(packageContent);
        info += `📦 Nom: ${packageJson.name || 'Non défini'}\n`;
        info += `🏷️  Version: ${packageJson.version || 'Non définie'}\n`;
        info += `📝 Description: ${packageJson.description || 'Non définie'}\n\n`;
      } catch {
        info += '📦 package.json: Non trouvé\n\n';
      }
      
      // Configuration Aklo
      const akloConfigPath = join(workdir, '.aklo.conf');
      try {
        const akloConfig = await readFile(akloConfigPath, 'utf-8');
        info += '⚙️  Configuration Aklo:\n';
        info += akloConfig.split('\n')
          .filter(line => line.trim() && !line.startsWith('#'))
          .map(line => `   ${line}`)
          .join('\n');
        info += '\n\n';
      } catch {
        info += '⚙️  Configuration Aklo: Non trouvée\n\n';
      }
      
      // Informations Git
      try {
        const { stdout: branch } = await execAsync('git branch --show-current 2>/dev/null', { cwd: workdir });
        const { stdout: status } = await execAsync('git status --porcelain 2>/dev/null', { cwd: workdir });
        info += `🌿 Git - Branche: ${branch.trim()}\n`;
        info += `🌿 Git - Fichiers modifiés: ${status.split('\n').filter(l => l.trim()).length}\n`;
      } catch {
        info += '🌿 Git: Non initialisé\n';
      }
      
      return {
        content: [{ type: 'text', text: info }],
      };
    } catch (error) {
      throw new Error(`Erreur lors de la récupération des informations: ${error.message}`);
    }
  }

  async findAkloScript(workdir) {
    // Chercher le script aklo dans plusieurs emplacements possibles
    const possiblePaths = [
      join(workdir, 'aklo', 'bin', 'aklo'),
      join(process.env.HOME, 'Projets', 'dotfiles', 'aklo', 'bin', 'aklo'),
      join(process.env.HOME, '.dotfiles', 'aklo', 'bin', 'aklo'),
      join(process.env.HOME, 'dotfiles', 'aklo', 'bin', 'aklo'),
      'aklo', // Dans le PATH
    ];
    
    for (const path of possiblePaths) {
      try {
        await access(path);
        return path;
      } catch {
        continue;
      }
    }
    
    throw new Error('Script aklo introuvable. Assurez-vous qu\'Aklo est installé.');
  }

  setupErrorHandling() {
    this.server.onerror = (error) => {
      console.error('[MCP Terminal Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('🖥️  Serveur MCP Terminal Aklo démarré');
  }
}

// Démarrer le serveur
const server = new AkloTerminalServer();
server.start().catch(console.error);