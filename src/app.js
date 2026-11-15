// Мини-приложение (HTML/CSS/JS одним файлом). Отдаётся воркером по адресу /app
export default String.raw`<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover,user-scalable=no">
<title>Quick Chinese</title>
<script src="https://telegram.org/js/telegram-web-app.js"></script>
<style>
:root{--bg:#f4f6fb;--card:#fff;--text:#1d2433;--muted:#8a93a6;--line:#e4e8f1;--accent:#3b82f6;--accent-d:#2563eb;--accent-bg:#eaf2ff;--ok:#22c55e;--ok-bg:#e7f8ee;--bad:#ef4444;--bad-bg:#fdeaea;--warn:#f59e0b;--sh:0 3px 0 #dde2ee}
[data-theme=dark]{--bg:#0f131a;--card:#1a202b;--text:#eef1f7;--muted:#8d97ab;--line:#2a3141;--accent-bg:#1c2b47;--ok-bg:#12301f;--bad-bg:#3a1b1b;--sh:0 3px 0 #0b0e14}
*{box-sizing:border-box;-webkit-tap-highlight-color:transparent}
html,body{margin:0;background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,"Segoe UI",Roboto,"PingFang SC","Noto Sans SC","Microsoft YaHei",sans-serif;-webkit-text-size-adjust:100%}
button{font:inherit;color:inherit;border:0;background:none;cursor:pointer;padding:0}
#app{max-width:560px;margin:0 auto;min-height:100vh;padding:14px 14px calc(28px + env(safe-area-inset-bottom))}
.muted{color:var(--muted)}
.hdr{display:flex;align-items:center;gap:10px;margin-bottom:10px}
.hdr .x{width:34px;height:34px;border-radius:10px;font-size:18px;color:var(--muted)}
.hdr .ttl{flex:1;font-weight:700;font-size:16px}
.hdr .cnt{color:var(--muted);font-size:14px;font-variant-numeric:tabular-nums}
.bar{height:6px;background:var(--line);border-radius:6px;overflow:hidden;margin-bottom:18px}
.bar i{display:block;height:100%;background:var(--accent);border-radius:6px;transition:width .25s}
.stats{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}
.stats h1{margin:0;font-size:22px}
.pill{background:var(--card);border-radius:20px;padding:6px 12px;font-weight:600;font-size:14px;box-shadow:var(--sh);margin-left:6px;white-space:nowrap}
.chips{display:flex;gap:8px;overflow-x:auto;padding:4px 2px 12px;margin:0 -14px 4px;padding-left:14px;padding-right:14px;scrollbar-width:none}
.chips::-webkit-scrollbar{display:none}
.chip{flex:none;padding:8px 14px;border-radius:18px;background:var(--card);font-size:14px;font-weight:600;box-shadow:var(--sh)}
.chip.on{background:var(--accent);color:#fff}
.btn{display:block;width:100%;padding:15px;border-radius:16px;font-weight:700;font-size:16px;text-align:center;background:var(--card);box-shadow:var(--sh)}
.btn.primary{background:var(--accent);color:#fff;box-shadow:0 4px 0 var(--accent-d)}
.btn[disabled]{opacity:.45;pointer-events:none}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin:14px 0}
.tile{background:var(--card);border-radius:18px;padding:14px;text-align:left;box-shadow:var(--sh);min-height:104px}
.tile .e{font-size:28px;line-height:1}
.tile .t{font-weight:700;margin-top:8px;font-size:15px}
.tile .s{color:var(--muted);font-size:12.5px;margin-top:2px}
.prompt{background:var(--card);border-radius:22px;padding:22px 16px;text-align:center;margin:6px 0 14px;box-shadow:var(--sh)}
.prompt .q{font-size:13px;color:var(--muted);margin-bottom:8px}
.prompt .ru{font-size:22px;font-weight:700;color:#5b6479}
[data-theme=dark] .prompt .ru{color:#b9c2d6}
.prompt .hzb{font-size:42px;font-weight:700;letter-spacing:2px}
.prompt .py{color:var(--muted);margin-top:4px}
.opts{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.opt{background:var(--card);border-radius:16px;padding:16px 10px;min-height:62px;box-shadow:var(--sh);border:2px solid transparent;display:flex;align-items:center;justify-content:center;text-align:center;position:relative}
.opt .hz{font-size:26px;font-weight:700}
.opt .tx{font-size:15px;font-weight:600;line-height:1.25}
.opt.sel{border-color:var(--accent);background:var(--accent-bg)}
.opt.ok{border-color:var(--ok);background:var(--ok-bg)}
.opt.bad{border-color:var(--bad);background:var(--bad-bg)}
.opts.pic{grid-template-columns:1fr 1fr 1fr}
.opts.pic .opt{flex-direction:column;min-height:104px}
.opts.pic .emo{font-size:44px;line-height:1}
.opt .ltr{position:absolute;top:6px;left:8px;font-size:11px;font-weight:700;color:var(--muted);background:var(--bg);border-radius:50%;width:20px;height:20px;display:flex;align-items:center;justify-content:center}
.fb{margin:16px 0 4px;border-radius:16px;padding:12px 14px;font-size:15px}
.fb.ok{background:var(--ok-bg)}.fb.bad{background:var(--bad-bg)}
.fb b{display:block;margin-bottom:4px}
.fb .w{font-size:18px}
.spk{margin-top:8px;font-size:14px;color:var(--accent);font-weight:600}
.foot{margin-top:18px}
.center{text-align:center;padding-top:60px}
.center .big{font-size:64px}
.center h2{margin:10px 0 4px}
.cols{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.cols .col{display:flex;flex-direction:column;gap:10px}
.m{background:var(--card);border-radius:14px;padding:12px 8px;min-height:58px;box-shadow:var(--sh);border:2px solid transparent;text-align:center;display:flex;flex-direction:column;align-items:center;justify-content:center}
.m .a{font-size:20px;font-weight:700}.m .b{font-size:12px;color:var(--muted)}.m .c{font-size:13.5px;font-weight:600;line-height:1.2}
.m.sel{border-color:var(--accent);background:var(--accent-bg)}
.m.done{border-color:var(--ok);background:var(--ok-bg);opacity:.55;pointer-events:none}
.m.err{border-color:var(--bad);background:var(--bad-bg)}
.mem{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
.card{aspect-ratio:3/3.2;border-radius:16px;background:var(--accent);color:#fff;font-size:30px;font-weight:700;display:flex;flex-direction:column;align-items:center;justify-content:center;box-shadow:0 3px 0 var(--accent-d);text-align:center;padding:4px}
.card.open{background:var(--card);color:var(--text);box-shadow:var(--sh);border:2px solid var(--accent)}
.card.matched{background:var(--ok-bg);color:var(--text);border:2px solid var(--ok);box-shadow:none}
.card .hzc{font-size:26px}.card .pyc{font-size:11px;color:var(--muted);font-weight:500}.card .ruc{font-size:12.5px;font-weight:600;line-height:1.15}
.slots{display:flex;gap:8px;justify-content:center;margin:6px 0 16px;flex-wrap:wrap}
.slot{width:62px;height:70px;border-radius:14px;border:2px dashed var(--line);background:var(--card);font-size:34px;font-weight:700;display:flex;align-items:center;justify-content:center}
.slot.f{border-style:solid;border-color:var(--accent)}
.slot.ok{border-color:var(--ok);background:var(--ok-bg)}
.slot.bad{border-color:var(--bad);background:var(--bad-bg);animation:sh .35s}
@keyframes sh{25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}
.chs{display:flex;gap:10px;justify-content:center;flex-wrap:wrap}
.ch{width:62px;height:70px;border-radius:14px;background:var(--card);font-size:34px;font-weight:700;box-shadow:var(--sh)}
.ch.used{opacity:.25;pointer-events:none}
.link{display:block;margin:16px auto 0;color:var(--muted);font-size:14px}
.search{width:100%;padding:13px 14px;border-radius:14px;border:2px solid var(--line);background:var(--card);color:var(--text);font:inherit;font-size:15px;margin-bottom:10px;outline:none}
.search:focus{border-color:var(--accent)}
.list{display:flex;flex-direction:column;gap:8px}
.row{display:flex;align-items:center;gap:12px;background:var(--card);border-radius:14px;padding:10px 14px;box-shadow:var(--sh);text-align:left;width:100%}
.row .hzl{font-size:26px;font-weight:700;min-width:64px}
.row .mid{flex:1;min-width:0}.row .pl{font-size:13px;color:var(--muted)}.row .rl{font-size:14px;line-height:1.25;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.row .em{font-size:22px}
.dot{width:10px;height:10px;border-radius:50%;background:var(--line);flex:none}
.dot.k{background:var(--ok)}.dot.l{background:var(--warn)}
.ov{position:fixed;inset:0;background:rgba(0,0,0,.45);display:flex;align-items:flex-end;justify-content:center;z-index:9}
.sheet{background:var(--card);width:100%;max-width:560px;border-radius:24px 24px 0 0;padding:22px 18px calc(22px + env(safe-area-inset-bottom));text-align:center}
.sheet .hzx{font-size:64px;font-weight:700;line-height:1.1}
.sheet .em2{font-size:40px;margin:6px 0}
.sheet .py2{font-size:20px;color:var(--accent);font-weight:600}
.sheet .ru2{font-size:17px;margin:8px 0 10px}
.sheet .parts{display:flex;gap:8px;justify-content:center;margin:8px 0}
.sheet .parts span{background:var(--bg);border-radius:10px;padding:6px 12px;font-size:22px;font-weight:700}
.sheet .st{color:var(--muted);font-size:13px;margin-bottom:12px}
.toast{position:fixed;left:50%;bottom:calc(30px + env(safe-area-inset-bottom));transform:translateX(-50%);background:#222;color:#fff;padding:10px 16px;border-radius:12px;font-size:14px;z-index:20;max-width:90%;text-align:center}
.note{font-size:12.5px;text-align:center;margin-top:14px}
.sum{background:var(--card);border-radius:20px;padding:18px;margin:16px 0;box-shadow:var(--sh)}
.sum .sc{font-size:44px;font-weight:800}
</style>
</head>
<body>
<div id="app"></div>
<script>
(function () {
  'use strict';
  var tg = window.Telegram && window.Telegram.WebApp;
  var app = document.getElementById('app');
  var PACK = 20;
  var BAD_EMOJI = ['❓', '💬', '➕', '❌', '🔗', '🔢', '◐', '↔️', '📏', '📍', '🔤', '🔹'];
  var S = { words: [], byId: {}, scores: {}, user: null, pack: 0 };

  /* ---------- helpers ---------- */
  function add(el, c) {
    if (c == null || c === false) return;
    if (Array.isArray(c)) { c.forEach(function (x) { add(el, x); }); return; }
    el.appendChild(typeof c === 'object' ? c : document.createTextNode(String(c)));
  }
  function h(tag, a) {
    var el = document.createElement(tag); a = a || {};
    for (var k in a) {
      var v = a[k];
      if (k === 'class') el.className = v;
      else if (k === 'on') { for (var ev in v) el.addEventListener(ev, v[ev]); }
      else if (v !== false && v != null) el.setAttribute(k, v);
    }
    for (var i = 2; i < arguments.length; i++) add(el, arguments[i]);
    return el;
  }
  function render(node) { app.innerHTML = ''; app.appendChild(node); window.scrollTo(0, 0); }
  function shuffle(a) { a = a.slice(); for (var i = a.length - 1; i > 0; i--) { var j = Math.floor(Math.random() * (i + 1)); var t = a[i]; a[i] = a[j]; a[j] = t; } return a; }
  function rand(n) { return Math.floor(Math.random() * n); }
  function clean(s) { return String(s || '').replace(/\*/g, ''); }
  function norm(s) { return String(s || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, ''); }
  function cut(s, n) { return s.length > n ? s.slice(0, n - 1) + '…' : s; }
  function haptic(kind) { try { if (tg && tg.HapticFeedback) tg.HapticFeedback.notificationOccurred(kind); } catch (e) {} }
  function speak(t) {
    try {
      if (!window.speechSynthesis) return;
      var u = new SpeechSynthesisUtterance(t); u.lang = 'zh-CN'; u.rate = 0.8;
      window.speechSynthesis.cancel(); window.speechSynthesis.speak(u);
    } catch (e) {}
  }
  function toast(t) {
    var el = h('div', { class: 'toast' }, t); document.body.appendChild(el);
    setTimeout(function () { el.remove(); }, 2200);
  }
  function go(name) {
    if (!tg || !tg.BackButton) return;
    try { if (name === 'home') tg.BackButton.hide(); else tg.BackButton.show(); } catch (e) {}
  }
  function online() { return !!(tg && tg.initData); }

  /* ---------- API ---------- */
  function api(path, body) {
    body = body || {}; body.initData = tg.initData;
    return fetch(path, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body) })
      .then(function (r) { if (!r.ok) throw new Error('http ' + r.status); return r.json(); });
  }
  function submit(game, results, bonus) {
    if (!online()) return Promise.resolve(null);
    return api('/api/progress', { game: game, results: results.slice(0, 12), bonus_xp: bonus || 0 })
      .then(function (r) {
        if (r.user) S.user = r.user;
        if (r.scores) for (var k in r.scores) S.scores[k] = r.scores[k];
        return r;
      }).catch(function () { return null; });
  }

  /* ---------- data ---------- */
  function load() {
    return fetch('/api/words').then(function (r) { return r.json(); }).then(function (rows) {
      var cnt = {};
      rows.forEach(function (w) { cnt[w.emoji] = (cnt[w.emoji] || 0) + 1; });
      S.words = rows.map(function (w) {
        var o = { id: w.id, row: w.source_row, hz: clean(w.hanzi), py: w.pinyin, ru: w.meaning_ru, em: w.emoji || '' };
        o.pic = !!o.em && cnt[w.emoji] === 1 && BAD_EMOJI.indexOf(w.emoji) < 0;
        S.byId[o.id] = o; return o;
      });
      if (online()) {
        return api('/api/me', {}).then(function (me) { S.user = me.user; S.scores = me.scores || {}; }).catch(function () {});
      }
    });
  }
  function scope() {
    if (!S.pack) return S.words;
    var from = (S.pack - 1) * PACK + 1, to = S.pack * PACK;
    return S.words.filter(function (w) { return w.row >= from && w.row <= to; });
  }
  function bucket(w) { var s = S.scores[w.id]; return s == null ? 1 : (s >= 4 ? 3 : (s >= 2 ? 2 : 0)); }
  function pickWeak(ws, n) {
    return shuffle(ws).sort(function (a, b) { return bucket(a) - bucket(b); }).slice(0, n);
  }
  function distract(w, n, pool, keyFn) {
    var seen = {}; seen[keyFn(w)] = 1;
    var c = shuffle(pool).filter(function (o) { var k = keyFn(o); if (o.id === w.id || seen[k]) return false; seen[k] = 1; return true; });
    var same = c.filter(function (o) { return o.hz.length === w.hz.length; });
    var rest = c.filter(function (o) { return o.hz.length !== w.hz.length; });
    return same.concat(rest).slice(0, n);
  }

  /* ---------- home ---------- */
  function home() {
    go('home');
    var total = S.words.length, packs = Math.ceil(total / PACK);
    var chips = h('div', { class: 'chips' });
    function chip(label, val) {
      chips.appendChild(h('button', { class: 'chip' + (S.pack === val ? ' on' : ''), on: { click: function () { S.pack = val; home(); } } }, label));
    }
    chip('Все ' + total, 0);
    for (var i = 1; i <= packs; i++) chip(((i - 1) * PACK + 1) + '–' + Math.min(i * PACK, total), i);

    var games = [
      ['🔤', 'Выбери слово', 'Перевод → иероглиф', function () { startQuiz('word'); }],
      ['📖', 'Выбери перевод', 'Иероглиф → перевод', function () { startQuiz('meaning'); }],
      ['🖼️', 'Картинка', 'Иероглиф → картинка', function () { startQuiz('picture'); }],
      ['🔗', 'Пары', 'Соедини слово и перевод', runMatch],
      ['🧠', 'Мемори', 'Найди пары карточек', runMemory],
      ['🧩', 'Собери слово', 'Сложи из иероглифов', runBuild]
    ];
    var grid = h('div', { class: 'grid' });
    games.forEach(function (g) {
      grid.appendChild(h('button', { class: 'tile', on: { click: g[3] } }, h('div', { class: 'e' }, g[0]), h('div', { class: 't' }, g[1]), h('div', { class: 's' }, g[2])));
    });
    var known = 0; for (var k in S.scores) if (S.scores[k] >= 4) known++;
    var stats = h('div', { class: 'stats' }, h('h1', {}, '你好 👋'),
      h('div', {}, S.user ? [h('span', { class: 'pill' }, '⭐ ' + S.user.xp), h('span', { class: 'pill' }, '🔥 ' + S.user.streak)] : null));
    render(h('div', {},
      stats, chips,
      h('button', { class: 'btn primary', on: { click: function () { startQuiz('mix'); } } }, '▶  Практика · 10 заданий'),
      grid,
      h('button', { class: 'btn', on: { click: runList } }, '📚  Список иероглифов · ' + scope().length),
      online() ? h('div', { class: 'note muted' }, 'Выучено слов: ' + known + ' из ' + total) : h('div', { class: 'note muted' }, 'Открыто вне Telegram: прогресс не сохраняется')
    ));
  }

  /* ---------- header & summary ---------- */
  function header(title, right) {
    return h('div', { class: 'hdr' }, h('button', { class: 'x', on: { click: home } }, '✕'), h('div', { class: 'ttl' }, title), h('div', { class: 'cnt' }, right || ''));
  }
  function bar(p) { return h('div', { class: 'bar' }, h('i', { style: 'width:' + Math.round(p * 100) + '%' })); }

  function finish(title, game, results, bonus, again, note) {
    render(h('div', { class: 'center' }, h('div', { class: 'big' }, '⏳'), h('div', { class: 'muted' }, 'Сохраняю…')));
    submit(game, results, bonus).then(function (r) {
      var good = results.filter(function (x) { return x.ok; }).length;
      var main = note || (results.length ? good + ' / ' + results.length : 'Готово');
      render(h('div', { class: 'center' },
        h('div', { class: 'big' }, results.length && good === results.length || !results.length ? '🎉' : '👍'),
        h('h2', {}, title),
        h('div', { class: 'sum' }, h('div', { class: 'sc' }, main),
          r ? h('div', { class: 'muted' }, '+' + r.gained + ' XP') : h('div', { class: 'muted' }, online() ? 'Не удалось сохранить прогресс' : 'Прогресс не сохраняется вне Telegram')),
        h('button', { class: 'btn primary', on: { click: again } }, 'Ещё раз'),
        h('div', { style: 'height:10px' }),
        h('button', { class: 'btn', on: { click: home } }, 'В меню')
      ));
    });
  }

  /* ---------- quiz ---------- */
  var QLABEL = { word: 'Выбери слово', meaning: 'Выбери перевод', picture: 'Прочитай и выбери картинку' };
  function buildQ(t, w) {
    var opts, key;
    if (t === 'word') { opts = distract(w, 3, S.words, function (o) { return o.hz; }); key = 'hz'; }
    else if (t === 'meaning') { opts = distract(w, 3, S.words, function (o) { return o.ru; }); }
    else { opts = distract(w, 2, S.words.filter(function (o) { return o.pic; }), function (o) { return o.em; }); }
    opts = shuffle(opts.concat([w]));
    return { t: t, w: w, opts: opts, ans: opts.indexOf(w) };
  }
  function startQuiz(kind) {
    var ws = scope();
    if (kind === 'picture') ws = ws.filter(function (w) { return w.pic; });
    if (!ws.length) { toast('В этом наборе нет слов для такого задания. Выбери «Все».'); return; }
    var qs = pickWeak(ws, 10).map(function (w) {
      var t = kind;
      if (kind === 'mix') { var ty = ['word', 'meaning']; if (w.pic) ty.push('picture'); t = ty[rand(ty.length)]; }
      return buildQ(t, w);
    });
    var titles = { mix: 'Практика', word: 'Выбери слово', meaning: 'Выбери перевод', picture: 'Картинка' };
    runQuiz(titles[kind], kind, qs, function () { startQuiz(kind); });
  }
  function runQuiz(title, game, qs, again) {
    var i = 0, sel = null, checked = false, results = [];
    function draw() {
      var q = qs[i], w = q.w;
      var prompt;
      if (q.t === 'word') prompt = h('div', { class: 'prompt' }, h('div', { class: 'q' }, QLABEL.word), h('div', { class: 'ru' }, w.ru));
      else prompt = h('div', { class: 'prompt' }, h('div', { class: 'q' }, QLABEL[q.t]), h('div', { class: 'hzb' }, w.hz), h('div', { class: 'py' }, w.py));
      var opts = h('div', { class: 'opts' + (q.t === 'picture' ? ' pic' : '') });
      q.opts.forEach(function (o, k) {
        var cls = 'opt' + (sel === k ? ' sel' : '');
        if (checked) { if (k === q.ans) cls = 'opt ok'; else if (k === sel) cls = 'opt bad'; }
        var inner;
        if (q.t === 'picture') inner = [h('span', { class: 'ltr' }, 'ABC'.charAt(k)), h('span', { class: 'emo' }, o.em)];
        else if (q.t === 'word') inner = h('span', { class: 'hz' }, o.hz);
        else inner = h('span', { class: 'tx' }, o.ru);
        opts.appendChild(h('button', { class: cls, on: { click: function () { if (!checked) { sel = k; draw(); } } } }, inner));
      });
      var fb = null;
      if (checked) {
        var ok = sel === q.ans;
        fb = h('div', { class: 'fb ' + (ok ? 'ok' : 'bad') }, h('b', {}, ok ? '✅ Верно!' : '❌ Неверно'),
          h('div', { class: 'w' }, w.hz + ' · ' + w.py + ' ' + w.em), h('div', {}, w.ru),
          window.speechSynthesis ? h('button', { class: 'spk', on: { click: function () { speak(w.hz); } } }, '🔊 Произнести') : null);
      }
      var btn = h('button', {
        class: 'btn primary', disabled: !checked && sel === null,
        on: { click: function () {
          if (!checked) {
            var ok2 = sel === q.ans; results.push({ id: w.id, ok: ok2 }); haptic(ok2 ? 'success' : 'error'); checked = true; draw();
          } else {
            i++; sel = null; checked = false;
            if (i >= qs.length) finish(title, game, results, 0, again); else draw();
          }
        } }
      }, checked ? (i === qs.length - 1 ? 'Завершить' : 'Дальше') : 'Проверить');
      render(h('div', {}, header(title, (i + 1) + '/' + qs.length), bar(i / qs.length), prompt, opts, fb, h('div', { class: 'foot' }, btn)));
    }
    go('quiz'); draw();
  }

  /* ---------- match (pairs) ---------- */
  function runMatch() {
    var ws = pickWeak(scope(), 6);
    if (ws.length < 3) { toast('В наборе слишком мало слов'); return; }
    var L = shuffle(ws), R = shuffle(ws), done = {}, miss = {}, sel = null, flash = null;
    function draw() {
      function mk(side, w) {
        var cls = 'm' + (done[w.id] ? ' done' : '') + (sel && sel.side === side && sel.id === w.id ? ' sel' : '') + (flash && ((flash.side === side && flash.id === w.id) || (flash.side2 === side && flash.id2 === w.id)) ? ' err' : '');
        var inner = side === 'L' ? [h('div', { class: 'a' }, w.hz), h('div', { class: 'b' }, w.py)] : h('div', { class: 'c' }, cut(w.ru, 38));
        return h('button', { class: cls, on: { click: function () { tap(side, w); } } }, inner);
      }
      var left = h('div', { class: 'col' }, L.map(function (w) { return mk('L', w); }));
      var right = h('div', { class: 'col' }, R.map(function (w) { return mk('R', w); }));
      var n = Object.keys(done).length;
      render(h('div', {}, header('Пары', n + '/' + ws.length), bar(n / ws.length), h('div', { class: 'prompt' }, h('div', { class: 'q' }, 'Соедини слово и перевод')), h('div', { class: 'cols' }, left, right)));
    }
    function tap(side, w) {
      if (!sel || sel.side === side) { sel = { side: side, id: w.id }; draw(); return; }
      if (sel.id === w.id) {
        done[w.id] = true; sel = null; haptic('success'); draw();
        if (Object.keys(done).length === ws.length) setTimeout(function () {
          finish('Пары', 'match', ws.map(function (x) { return { id: x.id, ok: !miss[x.id] }; }), 0, runMatch);
        }, 450);
      } else {
        miss[sel.id] = true; miss[w.id] = true; haptic('error');
        flash = { side: sel.side, id: sel.id, side2: side, id2: w.id }; sel = null; draw();
        setTimeout(function () { flash = null; draw(); }, 450);
      }
    }
    go('match'); draw();
  }

  /* ---------- memory ---------- */
  function runMemory() {
    var ws = pickWeak(scope(), 6);
    if (ws.length < 3) { toast('В наборе слишком мало слов'); return; }
    var cards = [];
    ws.forEach(function (w) { cards.push({ id: w.id, k: 'hz' }); cards.push({ id: w.id, k: 'ru' }); });
    cards = shuffle(cards);
    var open = [], matched = {}, moves = 0, lock = false;
    function draw() {
      var grid = h('div', { class: 'mem' });
      cards.forEach(function (c, i) {
        var w = S.byId[c.id], isM = matched[c.id], isO = open.indexOf(i) >= 0;
        var inner = '?';
        if (isM || isO) inner = c.k === 'hz' ? [h('div', { class: 'hzc' }, w.hz), h('div', { class: 'pyc' }, w.py)] : h('div', { class: 'ruc' }, cut(w.ru, 30));
        grid.appendChild(h('button', { class: 'card' + (isM ? ' matched' : (isO ? ' open' : '')), on: { click: function () { tap(i); } } }, inner));
      });
      render(h('div', {}, header('Мемори', 'ходов: ' + moves), bar(Object.keys(matched).length / ws.length), grid));
    }
    function tap(i) {
      if (lock || matched[cards[i].id] || open.indexOf(i) >= 0) return;
      open.push(i); draw();
      if (open.length === 2) {
        moves++;
        var a = cards[open[0]], b = cards[open[1]];
        if (a.id === b.id && a.k !== b.k) {
          matched[a.id] = true; open = []; haptic('success'); draw();
          if (Object.keys(matched).length === ws.length) setTimeout(function () { finish('Мемори', 'memory', [], 10, runMemory, moves + ' ходов'); }, 500);
        } else {
          lock = true; haptic('error');
          setTimeout(function () { open = []; lock = false; draw(); }, 850);
        }
      }
    }
    go('memory'); draw();
  }

  /* ---------- build word ---------- */
  function runBuild() {
    var ws = pickWeak(scope().filter(function (w) { return w.hz.length >= 2 && w.hz.length <= 5; }), 8);
    if (!ws.length) { toast('В этом наборе нет составных слов. Выбери «Все».'); return; }
    var i = 0, results = [], slots, chips, wrong, shown, status;
    function setup() {
      var w = ws[i], letters = Array.from(w.hz), idx = letters.map(function (_, k) { return k; }), order = shuffle(idx), t = 0;
      while (letters.length > 1 && order.join() === idx.join() && t++ < 6) order = shuffle(idx);
      chips = order.map(function (k) { return { ch: letters[k], used: false }; });
      slots = []; wrong = false; shown = false; status = '';
    }
    function draw() {
      var w = ws[i], n = Array.from(w.hz).length;
      var slotEls = h('div', { class: 'slots' });
      for (var s = 0; s < n; s++) (function (s) {
        var c = slots[s];
        slotEls.appendChild(h('button', { class: 'slot' + (c ? ' f' : '') + (status === 'ok' ? ' ok' : '') + (status === 'bad' ? ' bad' : ''),
          on: { click: function () { if (status || !c) return; chips[c.ci].used = false; slots.splice(s, 1); draw(); } } }, c ? c.ch : ''));
      })(s);
      var chipEls = h('div', { class: 'chs' });
      chips.forEach(function (c, ci) {
        chipEls.appendChild(h('button', { class: 'ch' + (c.used ? ' used' : ''), on: { click: function () {
          if (status || c.used || slots.length >= n) return;
          c.used = true; slots.push({ ch: c.ch, ci: ci });
          if (slots.length === n) check(); else draw();
        } } }, c.ch));
      });
      var fb = status === 'ok' || shown ? h('div', { class: 'fb ' + (status === 'ok' ? 'ok' : 'bad') }, h('div', { class: 'w' }, w.hz + ' · ' + w.py + ' ' + w.em), h('div', {}, w.ru)) : null;
      var action = status === 'ok' || shown ? h('div', { class: 'foot' }, h('button', { class: 'btn primary', on: { click: next } }, i === ws.length - 1 ? 'Завершить' : 'Дальше')) :
        h('button', { class: 'link', on: { click: skip } }, 'Не знаю, показать ответ');
      render(h('div', {}, header('Собери слово', (i + 1) + '/' + ws.length), bar(i / ws.length),
        h('div', { class: 'prompt' }, h('div', { class: 'q' }, 'Сложи слово из иероглифов'), h('div', { class: 'ru' }, w.ru), h('div', { class: 'py' }, w.py)),
        slotEls, status === 'ok' || shown ? null : chipEls, fb, action));
    }
    function check() {
      var w = ws[i], got = slots.map(function (s) { return s.ch; }).join('');
      if (got === w.hz) { status = 'ok'; results.push({ id: w.id, ok: !wrong }); haptic('success'); draw(); }
      else {
        wrong = true; status = 'bad'; haptic('error'); draw();
        setTimeout(function () { status = ''; slots = []; chips.forEach(function (c) { c.used = false; }); draw(); }, 650);
      }
    }
    function skip() {
      var w = ws[i]; results.push({ id: w.id, ok: false }); shown = true;
      slots = Array.from(w.hz).map(function (c) { return { ch: c, ci: -1 }; }); status = 'ok'; draw();
    }
    function next() { i++; if (i >= ws.length) finish('Собери слово', 'build', results, 0, runBuild); else { setup(); draw(); } }
    go('build'); setup(); draw();
  }

  /* ---------- list ---------- */
  function runList() {
    go('list');
    var q = '', listEl = h('div', { class: 'list' }), count = h('div', { class: 'muted', style: 'margin:0 2px 8px;font-size:13px' });
    function fill() {
      listEl.innerHTML = '';
      var items = scope().filter(function (w) { return !q || norm(w.hz + ' ' + w.py + ' ' + w.ru).indexOf(q) >= 0; });
      count.textContent = 'Найдено: ' + items.length;
      items.forEach(function (w) {
        var s = S.scores[w.id], cls = s == null ? '' : (s >= 4 ? ' k' : ' l');
        listEl.appendChild(h('button', { class: 'row', on: { click: function () { showWord(w); } } },
          h('div', { class: 'hzl' }, w.hz), h('div', { class: 'mid' }, h('div', { class: 'pl' }, w.py), h('div', { class: 'rl' }, w.ru)),
          h('div', { class: 'em' }, w.em), h('div', { class: 'dot' + cls })));
      });
    }
    var input = h('input', { class: 'search', type: 'search', placeholder: 'Поиск: иероглиф, pinyin или перевод', on: { input: function (e) { q = norm(e.target.value.trim()); fill(); } } });
    render(h('div', {}, header('Иероглифы', S.pack ? 'набор ' + S.pack : 'все слова'), input, count, listEl));
    fill();
  }
  function showWord(w) {
    var s = S.scores[w.id];
    var st = s == null ? 'Новое слово' : (s >= 4 ? 'Выучено ✓' : 'В процессе: ' + s + ' из 5');
    var ov = h('div', { class: 'ov', on: { click: function (e) { if (e.target === ov) ov.remove(); } } },
      h('div', { class: 'sheet' },
        h('div', { class: 'hzx' }, w.hz), h('div', { class: 'em2' }, w.em), h('div', { class: 'py2' }, w.py), h('div', { class: 'ru2' }, w.ru),
        Array.from(w.hz).length > 1 ? h('div', { class: 'parts' }, Array.from(w.hz).map(function (c) { return h('span', {}, c); })) : null,
        h('div', { class: 'st' }, st),
        window.speechSynthesis ? h('button', { class: 'btn', on: { click: function () { speak(w.hz); } } }, '🔊  Произнести') : null,
        h('div', { style: 'height:10px' }),
        h('button', { class: 'btn primary', on: { click: function () { ov.remove(); } } }, 'Закрыть')));
    document.body.appendChild(ov);
  }

  /* ---------- start ---------- */
  try {
    if (tg) {
      tg.ready(); tg.expand();
      if (tg.disableVerticalSwipes) tg.disableVerticalSwipes();
      if (tg.colorScheme) document.documentElement.setAttribute('data-theme', tg.colorScheme);
      if (tg.BackButton) tg.BackButton.onClick(function () { home(); });
    }
  } catch (e) {}
  if (!document.documentElement.getAttribute('data-theme') && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    document.documentElement.setAttribute('data-theme', 'dark');
  }
  render(h('div', { class: 'center' }, h('div', { class: 'big' }, '📚'), h('div', { class: 'muted' }, 'Загрузка…')));
  load().then(home).catch(function () {
    render(h('div', { class: 'center' }, h('div', { class: 'big' }, '😕'), h('h2', {}, 'Не удалось загрузить слова'), h('div', { class: 'muted' }, 'Проверьте интернет и откройте приложение снова.')));
  });
})();
</script>
</body>
</html>
`;

