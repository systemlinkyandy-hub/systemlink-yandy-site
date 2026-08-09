const labels={literature:'文献で確認',interpretation:'著者の解釈',experience:'個人体験',unresolved:'未検証・適用注意'};
const statusLabels={verified:'原典照合済み',partial:'部分照合',unverified:'未照合'};
const relationLabels={direct:'直接根拠',indirect:'関連資料',candidate:'候補資料'};
let claims=[];
const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function render(){
  const q=document.querySelector('#search').value.toLowerCase(),type=document.querySelector('#type').value,status=document.querySelector('#status').value,etiology=document.querySelector('#etiology').value;
  const shown=claims.filter(c=>(!type||c.type===type)&&(!status||c.status===status)&&(!etiology||c.etiology.includes(etiology))&&JSON.stringify(c).toLowerCase().includes(q));
  document.querySelector('#count').textContent=`${shown.length} / ${claims.length} 件`;
  document.querySelector('#cards').innerHTML=shown.map(c=>`<article class="card" data-type="${c.type}"><span class="tag ${c.type}">${labels[c.type]}</span> <span class="meta">${statusLabels[c.status]}</span><h2>${esc(c.title)}</h2><p>${esc(c.summary)}</p><p class="scope"><strong>言える範囲：</strong>${esc(c.scope)}</p><p class="meta">対象：${esc(c.population)}<br>病型・病因：${c.etiology.map(esc).join(' · ')}<br>種別：${esc(c.design)}<br>タグ：${c.tags.map(esc).join(' · ')}</p><div class="verification"><strong>照合位置：</strong>${esc(c.sourceLocator||'未特定')}<br><strong>サイト位置：</strong>${esc(c.siteLocator)}<br><strong>確認内容：</strong>${esc(c.verificationNote)}<br><strong>確認日：</strong>${esc(c.checkedAt)}</div><p class="links"><a href="${esc(c.siteUrl)}" target="_blank" rel="noreferrer">サイト記載</a>${c.sourceUrl?`<a href="${esc(c.sourceUrl)}" target="_blank" rel="noreferrer">${relationLabels[c.sourceRelation]}</a>`:''}</p></article>`).join('')||'<p>該当項目はありません。</p>';
}
fetch('data/claims.json').then(r=>r.json()).then(x=>{claims=x;render()}).catch(()=>{document.querySelector('#cards').innerHTML='<p>データを読み込めません。READMEのローカルサーバー手順で開いてください。</p>'});
['search','type','status','etiology'].forEach(id=>document.querySelector('#'+id).addEventListener('input',render));
