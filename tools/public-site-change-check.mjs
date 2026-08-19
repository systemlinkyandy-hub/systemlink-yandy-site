import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '..');
const args = process.argv.slice(2);
const option = name => {
  const index = args.indexOf(`--${name}`);
  return index >= 0 ? args[index + 1] : undefined;
};
const configPath = resolve(repoRoot, option('config') ?? 'tools/public-change-check.config.json');

let config;
try {
  config = JSON.parse(await readFile(configPath, 'utf8'));
} catch {
  console.error('設定ファイルがありません。tools/public-change-check.config.example.json をコピーして、監視したい公開URLを設定してください。');
  process.exitCode = 2;
  process.exit();
}

if (!Array.isArray(config.targets) || config.targets.length === 0) throw new Error('config.targets に1件以上の公開URLを設定してください。');
for (const target of config.targets) {
  const url = new URL(target);
  if (!['http:', 'https:'].includes(url.protocol)) throw new Error(`HTTP(S)以外のURLは使用できません: ${target}`);
}

const statePath = resolve(repoRoot, config.statePath ?? '.local/public-change-check/site-state.json');
const reportPath = resolve(repoRoot, config.reportPath ?? '.local/public-change-check/latest-site-report.json');
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
for (const url of config.targets) {
  try {
    const response = await fetch(url, { headers: { 'user-agent': 'public-change-check/1.0' } });
    const hash = digest(normalize(await response.text()));
    const oldHash = previous[url]?.hash ?? null;
    nextState[url] = { hash, checkedAt, status: response.status };
    results.push({ url, status: response.status, state: oldHash === null ? 'baseline' : oldHash === hash ? 'unchanged' : 'changed', previousHash: oldHash, currentHash: hash });
  } catch (error) {
    results.push({ url, state: 'error', error: String(error?.message ?? error) });
  }
}

await mkdir(dirname(statePath), { recursive: true });
await mkdir(dirname(reportPath), { recursive: true });
await writeFile(statePath, JSON.stringify(nextState, null, 2) + '\n', 'utf8');
await writeFile(reportPath, JSON.stringify({ checkedAt, results, note: 'ハッシュ変化は更新候補です。内容の意味、人物の意図、医療的妥当性は人が確認してください。' }, null, 2) + '\n', 'utf8');
console.log(reportPath);
for (const item of results) console.log(`${item.state.padEnd(9)} ${item.url}`);
