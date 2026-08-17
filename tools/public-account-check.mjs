import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '..');
const args = process.argv.slice(2);
const command = args[0] ?? 'list';
const option = name => {
  const index = args.indexOf(`--${name}`);
  return index >= 0 ? args[index + 1] : undefined;
};
const configPath = resolve(repoRoot, option('config') ?? 'tools/public-change-check.config.json');
let config;
try {
  config = JSON.parse(await readFile(configPath, 'utf8'));
} catch {
  console.error('設定ファイルがありません。tools/public-change-check.config.example.json をコピーして、確認したい公開アカウントを設定してください。');
  process.exitCode = 2;
  process.exit();
}

const allowedAccounts = new Set(config.accounts ?? []);
const dataPath = resolve(repoRoot, config.accountDataPath ?? '.local/public-change-check/account-observations.json');
const integer = (name, fallback = 0) => {
  const raw = option(name);
  if (raw === undefined) return fallback;
  const value = Number(raw);
  if (!Number.isInteger(value) || value < 0) throw new Error(`--${name} は0以上の整数で指定してください。`);
  return value;
};
const yesNo = value => value === 'yes' ? true : value === 'no' ? false : (() => { throw new Error('--identifiable は yes または no で指定してください。'); })();
const load = async () => {
  try { return JSON.parse(await readFile(dataPath, 'utf8')); }
  catch { return { checkedAt: '', observations: [] }; }
};
const save = async data => {
  await mkdir(dirname(dataPath), { recursive: true });
  await writeFile(dataPath, JSON.stringify(data, null, 2) + '\n', 'utf8');
};
const accountFromUrl = raw => {
  const url = new URL(raw);
  if (!['x.com', 'www.x.com'].includes(url.hostname)) throw new Error('公開X URLだけを記録できます。');
  const account = url.pathname.split('/').filter(Boolean)[0];
  if (!allowedAccounts.has(account)) throw new Error(`設定ファイルにないアカウントです: ${account}`);
  return account;
};

if (command === 'list') {
  const data = await load();
  console.log(`checkedAt ${data.checkedAt || 'not recorded'}`);
  for (const account of allowedAccounts) {
    const latest = [...data.observations].reverse().find(x => accountFromUrl(x.url) === account);
    console.log(latest ? `recorded  @${account} ${latest.observedAt} ${latest.url}` : `missing   @${account}`);
  }
} else if (command === 'record') {
  const url = option('url');
  const summary = option('summary');
  if (!url || !summary) throw new Error('record には --url と --summary が必要です。');
  const account = accountFromUrl(url);
  const data = await load();
  const prior = [...data.observations].reverse().find(x => accountFromUrl(x.url) === account);
  const metrics = { views: integer('views'), likes: integer('likes'), reposts: integer('reposts'), visibleReplies: integer('replies') };
  const deltas = prior?.metrics ? Object.fromEntries(Object.entries(metrics).map(([key, value]) => [key, value - Number(prior.metrics[key] ?? 0)])) : null;
  const observedAt = new Date().toISOString();
  data.checkedAt = observedAt;
  data.observations.push({ id: `${account}-${Date.now()}`, kind: 'x-post', account, url, observedAt, summary, identifiableReference: yesNo(option('identifiable') ?? 'no'), metrics, deltas });
  await save(data);
  console.log(`recorded @${account} ${url}`);
  console.log(deltas ? `delta ${JSON.stringify(deltas)}` : 'delta baseline');
} else {
  throw new Error('使用可能なコマンド: list / record');
}
