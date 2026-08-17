import { readFile, writeFile, mkdtemp, rm } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '..');
const defaultDataPath = resolve(repoRoot, 'cocolifestyle-reference/data/public-monitor.json');
const allowedAccounts = new Set(['stay_sparkle', 'AIstudylog']);

const args = process.argv.slice(2);
const command = args[0] ?? 'list';
const option = name => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 ? args[i + 1] : undefined;
};
const integer = (name, fallback = 0) => {
  const raw = option(name);
  if (raw === undefined) return fallback;
  const value = Number(raw);
  if (!Number.isInteger(value) || value < 0) throw new Error(`--${name} は0以上の整数で指定してください。`);
  return value;
};
const yesNo = value => {
  if (value === 'yes') return true;
  if (value === 'no') return false;
  throw new Error('--identifiable は yes または no で指定してください。');
};
const load = async path => JSON.parse(await readFile(path, 'utf8'));
const save = async (path, data) => writeFile(path, JSON.stringify(data, null, 2) + '\n', 'utf8');

function accountFromUrl(raw) {
  const url = new URL(raw);
  if (!['x.com', 'www.x.com'].includes(url.hostname)) throw new Error('公開X URLだけを記録できます。');
  const account = url.pathname.split('/').filter(Boolean)[0];
  if (!allowedAccounts.has(account)) throw new Error(`対象外アカウントです: ${account}`);
  return account;
}

function latestByAccount(observations) {
  const result = {};
  for (const item of observations.filter(x => x.kind === 'x-post')) {
    const account = accountFromUrl(item.url);
    if (!result[account] || String(result[account].observedAt) < String(item.observedAt)) result[account] = item;
  }
  return result;
}

async function record(dataPath) {
  const url = option('url');
  const summary = option('summary');
  if (!url || !summary) throw new Error('record には --url と --summary が必要です。');
  const account = accountFromUrl(url);
  const data = await load(dataPath);
  const now = new Date().toISOString();
  const prior = [...data.observations].reverse().find(x => x.kind === 'x-post' && accountFromUrl(x.url) === account);
  const metrics = {
    views: integer('views'),
    likes: integer('likes'),
    reposts: integer('reposts'),
    visibleReplies: integer('replies')
  };
  const deltas = prior?.metrics ? Object.fromEntries(Object.entries(metrics).map(([k, v]) => [k, v - Number(prior.metrics[k] ?? 0)])) : null;
  data.checkedAt = now;
  data.observations.push({
    id: `${account}-${Date.now()}`,
    kind: 'x-post',
    account,
    url,
    observedAt: now,
    summary,
    identifiableReference: yesNo(option('identifiable') ?? 'no'),
    metrics,
    deltas
  });
  await save(dataPath, data);
  console.log(`recorded ${account} ${url}`);
  console.log(deltas ? `delta ${JSON.stringify(deltas)}` : 'delta baseline');
}

async function list(dataPath) {
  const data = await load(dataPath);
  console.log(`checkedAt ${data.checkedAt}`);
  const latest = latestByAccount(data.observations);
  for (const account of allowedAccounts) {
    const item = latest[account];
    if (!item) console.log(`missing   @${account}`);
    else console.log(`recorded  @${account} ${item.observedAt} ${item.url}`);
  }
}

async function selftest() {
  const dir = await mkdtemp(resolve(tmpdir(), 'coco-account-check-'));
  const path = resolve(dir, 'monitor.json');
  try {
    await save(path, { checkedAt: '', scope: [], overall: {}, observations: [] });
    const originalArgv = [...process.argv];
    process.argv = ['node', 'script', 'record', '--url', 'https://x.com/stay_sparkle/status/1', '--summary', '公開投稿のテスト記録', '--views', '10', '--likes', '2', '--reposts', '1', '--replies', '0', '--identifiable', 'no'];
    args.splice(0, args.length, ...process.argv.slice(2));
    await record(path);
    const saved = await load(path);
    if (saved.observations.length !== 1 || saved.observations[0].metrics.views !== 10 || saved.observations[0].identifiableReference !== false) throw new Error('記録結果が不正です。');
    process.argv = originalArgv;
    console.log('selftest passed');
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

if (command === 'list') await list(defaultDataPath);
else if (command === 'record') await record(defaultDataPath);
else if (command === 'selftest') await selftest();
else throw new Error('使用可能なコマンド: list / record / selftest');
