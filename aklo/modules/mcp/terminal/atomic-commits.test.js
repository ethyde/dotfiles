const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const { XMLParser } = require('fast-xml-parser');
const AtomicCommitManager = require('./atomic-commits');

const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);
const rm = promisify(fs.rm);

describe('AtomicCommitManager (journal XML)', () => {
  const tmpDir = path.join(__dirname, '__test_tmp__');
  const journalPath = path.join(tmpDir, 'JOURNAL-2099-01-01.xml');
  let manager;

  beforeAll(async () => {
    await mkdir(tmpDir, { recursive: true });
    manager = new AtomicCommitManager();
    await manager.initAtomicSession('PRODUCT-OWNER', tmpDir);
  });

  afterAll(async () => {
    await rm(tmpDir, { recursive: true, force: true });
  });

  test('Le journal généré est du XML valide (pas de markdown)', async () => {
    await manager.updateJournal('Création PBI', 'Nouveau PBI-42: Test XML', 'PBI-42-PROPOSED.xml');
    const xml = await readFile(journalPath, 'utf-8');
    // Il ne doit pas y avoir de markdown
    expect(xml).not.toMatch(/###|\*\*|\-/);
    // Il doit y avoir des balises XML principales
    expect(xml).toMatch(/<journal_day/);
    expect(xml).toMatch(/<entree/);
    expect(xml).toMatch(/<item>/);
    // Le XML doit être parsable
    const parser = new XMLParser();
    expect(() => parser.parse(xml)).not.toThrow();
  });

  test('Le message de commit reste en markdown', () => {
    const msg = manager.generateCommitMessage('PRODUCT-OWNER', 'Création PBI', {
      artefacts: ['PBI-42-PROPOSED.xml'],
      description: 'Nouveau PBI-42: Test XML',
    });
    expect(msg).toMatch(/\*\*|-/); // Markdown attendu
    expect(msg).toMatch(/Création PBI/);
  });
}); 