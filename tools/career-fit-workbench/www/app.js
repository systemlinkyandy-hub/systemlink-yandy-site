// Career Fit Workbench v0.1 — フロントエンド（依存ライブラリなし）

const state = {
  stagedImages: [], // [{ name, dataUrl }]
  lastAnalyzed: null, // 直近の解析結果（未保存）
  jobs: [],
  activeFilter: 'all',
};

// --- タブ切り替え ---
document.querySelectorAll('.tab-btn').forEach((btn) => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach((b) => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach((p) => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('tab-' + btn.dataset.tab).classList.add('active');
    if (btn.dataset.tab === 'list') loadJobs();
  });
});

// --- ドロップゾーン ---
const dropzone = document.getElementById('dropzone');
const fileInput = document.getElementById('fileInput');
const pickFilesBtn = document.getElementById('pickFilesBtn');
const stagedImagesEl = document.getElementById('stagedImages');
const analyzeBtn = document.getElementById('analyzeBtn');

pickFilesBtn.addEventListener('click', () => fileInput.click());
fileInput.addEventListener('change', (e) => addFiles(e.target.files));

['dragenter', 'dragover'].forEach((evt) => {
  dropzone.addEventListener(evt, (e) => {
    e.preventDefault();
    dropzone.classList.add('drag-over');
  });
});
['dragleave', 'drop'].forEach((evt) => {
  dropzone.addEventListener(evt, (e) => {
    e.preventDefault();
    dropzone.classList.remove('drag-over');
  });
});
dropzone.addEventListener('drop', (e) => {
  const files = e.dataTransfer.files;
  addFiles(files);
});

function addFiles(fileList) {
  Array.from(fileList).forEach((file) => {
    if (!file.type.startsWith('image/')) return;
    const reader = new FileReader();
    reader.onload = () => {
      state.stagedImages.push({ name: file.name, dataUrl: reader.result });
      renderStagedImages();
    };
    reader.readAsDataURL(file);
  });
}

function renderStagedImages() {
  stagedImagesEl.innerHTML = '';
  state.stagedImages.forEach((img, idx) => {
    const div = document.createElement('div');
    div.className = 'staged-thumb';
    div.innerHTML = `<img src="${img.dataUrl}" alt="${img.name}"><button class="remove-thumb" data-idx="${idx}">×</button>`;
    stagedImagesEl.appendChild(div);
  });
  stagedImagesEl.querySelectorAll('.remove-thumb').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.stagedImages.splice(Number(btn.dataset.idx), 1);
      renderStagedImages();
    });
  });
  analyzeBtn.disabled = state.stagedImages.length === 0;
}

// --- 解析 ---
const analyzeStatus = document.getElementById('analyzeStatus');
const resultCard = document.getElementById('resultCard');

analyzeBtn.addEventListener('click', async () => {
  analyzeBtn.disabled = true;
  showStatus('解析中…（画像枚数によっては数十秒かかります）', false);
  resultCard.hidden = true;
  try {
    const res = await fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ images: state.stagedImages.map((i) => i.dataUrl) }),
    });
    const body = await res.json();
    if (!res.ok || !body.success) {
      showStatus('解析に失敗しました: ' + (body.error || res.statusText), true);
      analyzeBtn.disabled = false;
      return;
    }
    state.lastAnalyzed = body.data;
    hideStatus();
    renderResultCard(body.data);
  } catch (err) {
    showStatus('通信エラー: ' + err.message, true);
  }
  analyzeBtn.disabled = false;
});

function showStatus(text, isError) {
  analyzeStatus.hidden = false;
  analyzeStatus.textContent = text;
  analyzeStatus.classList.toggle('error', !!isError);
}
function hideStatus() {
  analyzeStatus.hidden = true;
}

function starsText(n) {
  const count = Math.max(0, Math.min(5, Number(n) || 0));
  return '★'.repeat(count) + '☆'.repeat(5 - count);
}

function renderResultCard(data) {
  const s = data.scoring || {};
  const comp = data.compensation || {};
  const income = (comp.minAnnual && comp.minAnnual !== '不明') || (comp.maxAnnual && comp.maxAnnual !== '不明')
    ? `${comp.minAnnual || '不明'}〜${comp.maxAnnual || '不明'}万円`
    : '不明';

  resultCard.innerHTML = `
    <span class="badge class-${s.classification}">${s.classification || '不明'}</span>
    <div class="result-title">${escapeHtml(data.title || '(タイトル不明)')}</div>
    <div class="result-company">${escapeHtml(data.company || '(会社名不明)')} ／ ${escapeHtml(data.location || '不明')}</div>

    <div class="stat-row">
      <div><span class="stat-label">リモート度</span><span class="stars">${starsText(s.remoteStars)}</span></div>
      <div><span class="stat-label">年収</span>${escapeHtml(income)}</div>
      <div><span class="stat-label">適合度</span><span class="stars">${starsText(s.fitStars)}</span></div>
      <div><span class="stat-label">長期継続性</span><span class="stars">${starsText(s.sustainabilityStars)}</span></div>
      <div><span class="stat-label">応募価値</span>${escapeHtml(s.applicationValue || '不明')}</div>
    </div>

    <div class="point-list">
      <h4>合うところ</h4>
      <ul>${(s.goodPoints || []).map((p) => `<li>${escapeHtml(p)}</li>`).join('') || '<li>(なし)</li>'}</ul>
      <h4>危ないところ</h4>
      <ul>${(s.riskPoints || []).map((p) => `<li>${escapeHtml(p)}</li>`).join('') || '<li>(なし)</li>'}</ul>
    </div>

    ${(data.missingInfo && data.missingInfo.length)
      ? `<div class="missing-info">不足情報：${data.missingInfo.map(escapeHtml).join(' / ')}</div>`
      : ''}

    <div class="one-liner">${escapeHtml(s.oneLiner || '')}</div>

    <div class="save-row">
      <button id="saveJobBtn">この求人を保存</button>
      <button class="secondary" id="discardJobBtn">破棄してやり直す</button>
    </div>
  `;
  resultCard.hidden = false;

  document.getElementById('saveJobBtn').addEventListener('click', saveAnalyzedJob);
  document.getElementById('discardJobBtn').addEventListener('click', () => {
    state.stagedImages = [];
    state.lastAnalyzed = null;
    renderStagedImages();
    resultCard.hidden = true;
  });
}

async function saveAnalyzedJob() {
  if (!state.lastAnalyzed) return;
  const saveBtn = document.getElementById('saveJobBtn');
  saveBtn.disabled = true;
  saveBtn.textContent = '保存中…';
  try {
    const res = await fetch('/api/jobs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(state.lastAnalyzed),
    });
    const body = await res.json();
    if (!res.ok || !body.success) {
      showStatus('保存に失敗しました: ' + (body.error || res.statusText), true);
      saveBtn.disabled = false;
      saveBtn.textContent = 'この求人を保存';
      return;
    }
    state.stagedImages = [];
    state.lastAnalyzed = null;
    renderStagedImages();
    resultCard.hidden = true;
    if (body.data.duplicateOf) {
      showStatus('保存しました（以前確認した求人の可能性があります）', false);
    } else {
      showStatus('保存しました', false);
    }
    document.querySelector('.tab-btn[data-tab="list"]').click();
  } catch (err) {
    showStatus('通信エラー: ' + err.message, true);
    saveBtn.disabled = false;
    saveBtn.textContent = 'この求人を保存';
  }
}

// --- 一覧 ---
const jobListEl = document.getElementById('jobList');
const jobListEmptyEl = document.getElementById('jobListEmpty');

document.querySelectorAll('.filter-btn').forEach((btn) => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.filter-btn').forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    state.activeFilter = btn.dataset.filter;
    renderJobList();
  });
});

async function loadJobs() {
  try {
    const res = await fetch('/api/jobs');
    const body = await res.json();
    state.jobs = body.data || [];
    renderJobList();
  } catch (err) {
    jobListEl.innerHTML = '';
    jobListEmptyEl.hidden = false;
    jobListEmptyEl.textContent = '読み込みに失敗しました: ' + err.message;
  }
}

function jobMatchesFilter(job, filter) {
  const s = job.scoring || {};
  const comp = job.compensation || {};
  switch (filter) {
    case 'a-only': return s.classification === 'A';
    case 'a-b': return s.classification === 'A' || s.classification === 'B';
    case 'fully-remote': return (job.workStyle || {}).type === 'Fully Remote';
    case 'income600': {
      const max = parseInt(String(comp.maxAnnual || '').replace(/[^0-9]/g, ''), 10);
      const min = parseInt(String(comp.minAnnual || '').replace(/[^0-9]/g, ''), 10);
      return (!isNaN(max) && max >= 600) || (!isNaN(min) && min >= 600);
    }
    case 'candidate': return job.status === '応募候補';
    case 'missing-info': return (job.missingInfo || []).length > 0;
    case 'hide-pass': return s.classification !== '見送り';
    default: return true;
  }
}

function renderJobList() {
  const filtered = state.jobs.filter((j) => jobMatchesFilter(j, state.activeFilter));
  jobListEl.innerHTML = '';
  jobListEmptyEl.hidden = state.jobs.length > 0;

  filtered
    .slice()
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .forEach((job) => {
      const s = job.scoring || {};
      const comp = job.compensation || {};
      const income = (comp.minAnnual && comp.minAnnual !== '不明') || (comp.maxAnnual && comp.maxAnnual !== '不明')
        ? `${comp.minAnnual || '不明'}〜${comp.maxAnnual || '不明'}万円`
        : '不明';

      const card = document.createElement('div');
      card.className = 'job-card';
      card.innerHTML = `
        <span class="badge class-${s.classification}">${s.classification || '不明'}</span>
        ${job.duplicateOf ? '<div class="duplicate-warning">以前確認した求人の可能性あり</div>' : ''}
        <div class="job-company">${escapeHtml(job.company || '(会社名不明)')}</div>
        <div class="job-title">${escapeHtml(job.title || '(タイトル不明)')}</div>
        <div class="job-stats">
          <span>年収：${escapeHtml(income)}</span>
          <span>Remote：${starsText(s.remoteStars)}</span>
          <span>適合度：${starsText(s.fitStars)}</span>
          <span>長期継続性：${starsText(s.sustainabilityStars)}</span>
          <span>応募価値：${escapeHtml(s.applicationValue || '不明')}</span>
        </div>
        <select data-id="${job.id}">
          ${['未判定', 'A', 'B', 'C', '見送り', '応募候補', '応募済', '保留']
            .map((st) => `<option value="${st}" ${job.status === st ? 'selected' : ''}>${st}</option>`)
            .join('')}
        </select>
      `;
      jobListEl.appendChild(card);
    });

  jobListEl.querySelectorAll('select').forEach((sel) => {
    sel.addEventListener('change', async () => {
      const id = sel.dataset.id;
      const status = sel.value;
      try {
        const res = await fetch('/api/jobs/' + id, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ status }),
        });
        const body = await res.json();
        if (res.ok && body.success) {
          const job = state.jobs.find((j) => j.id === id);
          if (job) job.status = status;
        }
      } catch (err) {
        // 失敗時は次回一覧再取得時に実状態へ戻る
      }
    });
  });
}

function escapeHtml(str) {
  return String(str == null ? '' : str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

renderStagedImages();
