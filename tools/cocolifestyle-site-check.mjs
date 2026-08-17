import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '..');
const statePath = resolve(repoRoot, 'research/cocolifestyle/monitor/.site-check-state.json');
const reportPath = resolve(repoRoot, 'research/cocolifestyle/monitor/latest-site-check.json');
const targets = [
  'https://cocolifestyle.net/',
  'https://cocolifestyle.net/introduction',
  'https://cocolifestyle.net/reference',
  'https://cocolifestyle.net/journal'
];

const normalize = html => html
  .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, '')
  .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, '')
  .replace(/<!--([\s\S]*?)-->/g, '')
  .replace(/\s+/g, ' ')
  .trim();
const digest = text => createHash('sha256').update(text).digest('hex');

let previous = {};
try { previous = JSON.parse(await readFile(statePath, 'utf8')); } catch {}

const checkedAt = new Date().toISOString();
const nextState = {};
const results = [];
for (const url of targets) {
  try {
    const response = await fetch(url, { headers: { 'user-agent': 'cocolifestyle-public-check/1.0' } });
    const body = normalize(await response.text());
    const hash = digest(body);
    const oldHash = previous[url]?.hash ?? null;
    nextState[url] = { hash, checkedAt, status: response.status };
    results.push({ url, status: response.status, state: oldHash === null ? 'baseline' : oldHash === hash ? 'unchanged' : 'changed', previousHash: oldHash, currentHash: hash });
  } catch (error) {
    results.push({ url, state: 'error', error: String(error?.message ?? error) });
  }
}

await mkdir(dirname(statePath), { recursive: true });
await writeFile(statePath, JSON.stringify(nextState, null, 2) + '\n', 'utf8');
await writeFile(reportPath, JSON.stringify({ checkedAt, results, note: 'ハッシュ変化は更新候補です。内容の意味、人物の意図、医療的妥当性は人が確認してください。Xは動的表示のためこの自動チェック対象外です。' }, null, 2) + '\n', 'utf8');
console.log(reportPath);
for (const item of results) console.log(`${item.state.padEnd(9)} ${item.url}`);
