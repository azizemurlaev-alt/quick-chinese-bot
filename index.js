// Quick Chinese — Telegram-бот на Cloudflare Workers + D1
// Секреты (НЕ в коде): BOT_TOKEN, WEBHOOK_SECRET. База: binding DB.

import APP_HTML from "./app.js";
import LESSONS from "./lessons.js";

const PACK = 20; // слов в одном наборе
let ORIGIN = ""; // адрес воркера, нужен для кнопки мини-приложения
const INTERVAL_MIN = [10, 1440, 2880, 5760, 10080, 20160]; // по рекорду 0..5: 10 мин, 1, 2, 4, 7, 14 дней

export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);
    ORIGIN = url.origin;

    // Мини-приложение и его API
    if (url.pathname === "/app") {
      return new Response(APP_HTML, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-cache" } });
    }
    if (url.pathname.startsWith("/api/")) {
      try { return await apiRoute(req, url, env); }
      catch (e) { console.error("api error", e && e.stack || e); return jsonResp({ error: "server" }, 500); }
    }

    // Одноразовая регистрация вебхука: /setup?secret=WEBHOOK_SECRET
    if (url.pathname === "/setup") {
      if (url.searchParams.get("secret") !== env.WEBHOOK_SECRET) return new Response("forbidden", { status: 403 });
      const r = await tg(env, "setWebhook", {
        url: `${url.origin}/webhook`,
        secret_token: env.WEBHOOK_SECRET,
        allowed_updates: ["message", "callback_query"],
      });
      await sleep(1200);
      await tg(env, "setMyCommands", {
        commands: [
          { command: "start", description: "Главное меню" },
          { command: "progress", description: "Мой прогресс" },
        ],
      });
      await sleep(1200);
      await tg(env, "setChatMenuButton", {
        menu_button: { type: "web_app", text: "Учить", web_app: { url: `${url.origin}/app` } },
      });
      return new Response(JSON.stringify(r, null, 2), { headers: { "content-type": "application/json" } });
    }

    if (url.pathname === "/webhook" && req.method === "POST") {
      if (req.headers.get("X-Telegram-Bot-Api-Secret-Token") !== env.WEBHOOK_SECRET)
        return new Response("forbidden", { status: 403 });
      const update = await req.json();
      ctx.waitUntil(handle(update, env).catch((e) => console.error("handle error", e && e.stack || e)));
      return new Response("ok");
    }

    return new Response("Quick Chinese bot is running");
  },
};

/* ---------- Telegram helpers ---------- */

const sleep = (ms) => new Promise((res) => setTimeout(res, ms));

async function tg(env, method, body, retried = false) {
  const r = await fetch(`https://api.telegram.org/bot${env.BOT_TOKEN}/${method}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  const j = await r.json();
  if (!j.ok && j.error_code === 429 && !retried) {
    await sleep(((j.parameters && j.parameters.retry_after) || 1) * 1000 + 300);
    return tg(env, method, body, true);
  }
  if (!j.ok && !String(j.description).includes("not modified")) console.error(method, j);
  return j;
}

const esc = (s) => String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const btn = (text, data) => ({ text, callback_data: data });
const hz = (s) => String(s ?? "").replace(/\*/g, ""); // убираем служебную звёздочку у некоторых слов
const cut = (s, n) => (s.length > n ? s.slice(0, n - 1) + "…" : s);

// c = { chat, msg? }: если есть msg — редактируем сообщение, иначе отправляем новое
async function show(env, c, text, rows) {
  const body = { chat_id: c.chat, text, parse_mode: "HTML", reply_markup: { inline_keyboard: rows } };
  if (c.msg) return tg(env, "editMessageText", { ...body, message_id: c.msg });
  return tg(env, "sendMessage", body);
}

/* ---------- Пользователь ---------- */

async function getUser(env, from) {
  await env.DB.prepare(
    `INSERT INTO users(telegram_id, username, first_name) VALUES(?,?,?)
     ON CONFLICT(telegram_id) DO UPDATE SET username=excluded.username, first_name=excluded.first_name`
  ).bind(from.id, from.username ?? null, from.first_name ?? null).run();

  const u = await env.DB.prepare("SELECT * FROM users WHERE telegram_id=?").bind(from.id).first();

  const today = new Date().toISOString().slice(0, 10);
  const last = u.last_active_at ? u.last_active_at.slice(0, 10) : null;
  if (last !== today) {
    const yesterday = new Date(Date.now() - 864e5).toISOString().slice(0, 10);
    const streak = last === yesterday ? u.streak + 1 : 1;
    await env.DB.prepare("UPDATE users SET streak=?, last_active_at=? WHERE id=?")
      .bind(streak, new Date().toISOString(), u.id).run();
    u.streak = streak;
  }
  return u;
}

/* ---------- Роутинг ---------- */

async function handle(u, env) {
  if (u.message && u.message.text) {
    const m = u.message;
    const user = await getUser(env, m.from);
    const t = m.text.trim();
    const c = { chat: m.chat.id };
    if (t.startsWith("/progress")) return screenProgress(env, c, user);
    return screenMenu(env, c, user);
  }

  if (u.callback_query) {
    const q = u.callback_query;
    await tg(env, "answerCallbackQuery", { callback_query_id: q.id });
    if (!q.message) return;
    const user = await getUser(env, q.from);
    const c = { chat: q.message.chat.id, msg: q.message.message_id };
    const [a, ...p] = String(q.data).split(":");
    const n = Number(p[0]);

    switch (a) {
      case "m": return screenMenu(env, c, user);
      case "l": return screenPacks(env, c, user);
      case "p": return screenPack(env, c, user, n);
      case "c": return screenCard(env, c, n, Number(p[1]), false);
      case "r": return screenCard(env, c, n, Number(p[1]), true);
      case "k": return answerCard(env, c, user, n, Number(p[1]), p[2] === "1");
      case "q": return screenQuiz(env, c, user, n);
      case "a": return answerQuiz(env, c, user, n, Number(p[1]), Number(p[2]), Number(p[3]));
      case "s": return screenProgress(env, c, user);
      default: return screenMenu(env, c, user);
    }
  }
}

/* ---------- Экраны ---------- */

async function screenMenu(env, c, user) {
  const name = esc(user.first_name || "друг");
  const text = `你好, <b>${name}</b>! 👋\n\nЯ помогу выучить китайские слова курса HSK 1.\nВыбери, с чего начнём:`;
  return show(env, c, text, [
    [{ text: "🎮 Мини-приложение", web_app: { url: `${ORIGIN}/app` } }],
    [btn("📚 Учить слова", "l")],
    [btn("🔁 Повторение", "q:0")],
    [btn("📊 Мой прогресс", "s")],
  ]);
}

async function totalWords(env) {
  return (await env.DB.prepare("SELECT COUNT(*) n FROM words").first()).n;
}

async function screenPacks(env, c, user) {
  const total = await totalWords(env);
  const packs = Math.ceil(total / PACK);
  const rows = [];
  let row = [];
  for (let i = 1; i <= packs; i++) {
    const from = (i - 1) * PACK + 1;
    const to = Math.min(i * PACK, total);
    row.push(btn(`${from}–${to}`, `p:${i}`));
    if (row.length === 3) { rows.push(row); row = []; }
  }
  if (row.length) rows.push(row);
  rows.push([btn("« В меню", "m")]);
  return show(env, c, "📚 <b>Наборы слов</b>\nВыбери набор:", rows);
}

async function packWords(env, n) {
  const from = (n - 1) * PACK + 1, to = n * PACK;
  const { results } = await env.DB.prepare(
    "SELECT * FROM words WHERE source_row BETWEEN ? AND ? ORDER BY source_row"
  ).bind(from, to).all();
  return results;
}

async function screenPack(env, c, user, n) {
  const words = await packWords(env, n);
  if (!words.length) return screenPacks(env, c, user);
  const known = await env.DB.prepare(
    `SELECT COUNT(*) n FROM user_words uw JOIN words w ON w.id=uw.word_id
     WHERE uw.user_id=? AND uw.status='known' AND w.source_row BETWEEN ? AND ?`
  ).bind(user.id, words[0].source_row, words[words.length - 1].source_row).first();
  const text = `📦 <b>Набор ${n}</b> · слова ${words[0].source_row}–${words[words.length - 1].source_row}\nВыучено: ${known.n} из ${words.length}`;
  return show(env, c, text, [
    [btn("🃏 Карточки", `c:${n}:0`), btn("❓ Тест", `q:${n}`)],
    [btn("« К наборам", "l")],
  ]);
}

async function screenCard(env, c, n, i, reveal) {
  const words = await packWords(env, n);
  const w = words[i];
  if (!w) {
    return show(env, c, "🎉 <b>Набор пройден!</b>\nТеперь проверь себя в тесте.", [
      [btn("❓ Тест", `q:${n}`)],
      [btn("« К набору", `p:${n}`)],
    ]);
  }
  let text = `🃏 <b>Карточка ${i + 1}/${words.length}</b>\n\n<b>${esc(hz(w.hanzi))}</b> ${esc(w.emoji || "")}`;
  let rows;
  if (reveal) {
    text += `\n${esc(w.pinyin)}\n<i>${esc(w.meaning_ru)}</i>`;
    rows = [[btn("✅ Знаю", `k:${n}:${i}:1`), btn("🔁 Повторить", `k:${n}:${i}:0`)]];
  } else {
    text += "\n\nВспомни перевод и произношение";
    rows = [[btn("👁 Показать ответ", `r:${n}:${i}`)]];
  }
  rows.push([btn("« К набору", `p:${n}`)]);
  return show(env, c, text, rows);
}

async function answerCard(env, c, user, n, i, ok) {
  const words = await packWords(env, n);
  const w = words[i];
  if (w) await record(env, user, w.id, ok, ok ? 1 : 0, "card");
  return screenCard(env, c, n, i + 1, false);
}

/* ---------- Тест / повторение ---------- */

async function screenQuiz(env, c, user, n) {
  let w;
  if (n > 0) {
    w = await env.DB.prepare(
      `SELECT w.* FROM words w
       LEFT JOIN user_words uw ON uw.word_id=w.id AND uw.user_id=?
       WHERE w.source_row BETWEEN ? AND ?
       ORDER BY COALESCE(uw.recognition_score,0), RANDOM() LIMIT 1`
    ).bind(user.id, (n - 1) * PACK + 1, n * PACK).first();
  } else {
    w = await env.DB.prepare(
      `SELECT w.* FROM user_words uw JOIN words w ON w.id=uw.word_id
       WHERE uw.user_id=? AND uw.next_review_at <= datetime('now')
       ORDER BY uw.next_review_at LIMIT 1`
    ).bind(user.id).first();
    if (!w) {
      return show(env, c, "🎉 Сейчас нечего повторять!\nИзучи новые слова или загляни позже.", [
        [btn("📚 Учить слова", "l")],
        [btn("« В меню", "m")],
      ]);
    }
  }
  if (!w) return screenMenu(env, c, user);

  const { results: others } = await env.DB.prepare(
    "SELECT id, hanzi, pinyin, meaning_ru FROM words WHERE id != ? ORDER BY RANDOM() LIMIT 8"
  ).bind(w.id).all();
  const seen = new Set([w.meaning_ru]);
  const distractors = [];
  for (const o of others) {
    if (seen.has(o.meaning_ru)) continue;
    seen.add(o.meaning_ru);
    distractors.push(o);
    if (distractors.length === 3) break;
  }

  const t = Math.random() < 0.5 ? 0 : 1; // 0: иероглиф→перевод, 1: перевод→иероглиф
  const options = [w, ...distractors].sort(() => Math.random() - 0.5);
  const question = t === 0
    ? `❓ Что означает <b>${esc(hz(w.hanzi))}</b>?`
    : `❓ Как по-китайски: <b>${esc(w.meaning_ru)}</b>?`;
  const rows = options.map((o) => [
    btn(t === 0 ? cut(o.meaning_ru, 45) : cut(`${hz(o.hanzi)} · ${o.pinyin}`, 45), `a:${n}:${w.id}:${o.id}:${t}`),
  ]);
  rows.push([btn("« Назад", n > 0 ? `p:${n}` : "m")]);
  return show(env, c, (n === 0 ? "🔁 <b>Повторение</b>\n\n" : "") + question, rows);
}

async function answerQuiz(env, c, user, n, wid, chosen, t) {
  const w = await env.DB.prepare("SELECT * FROM words WHERE id=?").bind(wid).first();
  if (!w) return screenMenu(env, c, user);
  const ok = wid === chosen;
  const xp = ok ? 5 : 0;
  await record(env, user, wid, ok, xp, t === 0 ? "meaning" : "recognition");
  const head = ok ? `✅ <b>Верно!</b> +${xp} XP` : "❌ <b>Неверно</b>";
  const text = `${head}\n\n<b>${esc(hz(w.hanzi))}</b> ${esc(w.emoji || "")}\n${esc(w.pinyin)} — <i>${esc(w.meaning_ru)}</i>`;
  return show(env, c, text, [
    [btn("▶ Дальше", `q:${n}`)],
    [btn("« Назад", n > 0 ? `p:${n}` : "m")],
  ]);
}

// Записать результат: оценка слова (0..5), интервал повторения, XP, дневная статистика
async function record(env, user, wordId, ok, xp, skill) {
  const cur = await env.DB.prepare(
    "SELECT recognition_score s FROM user_words WHERE user_id=? AND word_id=?"
  ).bind(user.id, wordId).first();
  const old = cur ? cur.s : 0;
  const score = ok ? Math.min(5, old + 1) : Math.max(0, old - 1);
  const status = score >= 4 ? "known" : "learning";
  const next = `+${INTERVAL_MIN[score]} minutes`;

  await env.DB.batch([
    env.DB.prepare(
      `INSERT INTO user_words(user_id, word_id, status, recognition_score, correct_count, error_count, next_review_at, updated_at)
       VALUES(?,?,?,?,?,?, datetime('now', ?), datetime('now'))
       ON CONFLICT(user_id, word_id) DO UPDATE SET
         status=excluded.status,
         recognition_score=excluded.recognition_score,
         correct_count=correct_count+excluded.correct_count,
         error_count=error_count+excluded.error_count,
         next_review_at=excluded.next_review_at,
         updated_at=excluded.updated_at`
    ).bind(user.id, wordId, status, score, ok ? 1 : 0, ok ? 0 : 1, next),
    env.DB.prepare(
      "INSERT INTO user_word_events(user_id, word_id, skill, is_correct) VALUES(?,?,?,?)"
    ).bind(user.id, wordId, skill, ok ? 1 : 0),
    env.DB.prepare("UPDATE users SET xp = xp + ? WHERE id=?").bind(xp, user.id),
    env.DB.prepare(
      `INSERT INTO user_daily_stats(user_id, stat_date, xp_earned, answers_total, answers_correct, words_reviewed)
       VALUES(?, date('now'), ?, 1, ?, 1)
       ON CONFLICT(user_id, stat_date) DO UPDATE SET
         xp_earned=xp_earned+excluded.xp_earned,
         answers_total=answers_total+1,
         answers_correct=answers_correct+excluded.answers_correct,
         words_reviewed=words_reviewed+1`
    ).bind(user.id, xp, ok ? 1 : 0),
  ]);
}

/* ---------- Прогресс ---------- */

async function screenProgress(env, c, user) {
  const u = await env.DB.prepare("SELECT xp, streak FROM users WHERE id=?").bind(user.id).first();
  const s = await env.DB.prepare(
    `SELECT COUNT(*) total,
            COALESCE(SUM(status='known'),0) known,
            COALESCE(SUM(correct_count),0) ok,
            COALESCE(SUM(error_count),0) bad,
            COALESCE(SUM(next_review_at <= datetime('now')),0) due
     FROM user_words WHERE user_id=?`
  ).bind(user.id).first();
  const total = await totalWords(env);
  const answers = s.ok + s.bad;
  const acc = answers ? Math.round((s.ok / answers) * 100) : 0;
  const text =
    `📊 <b>Мой прогресс</b>\n\n` +
    `⭐ XP: <b>${u.xp}</b>\n` +
    `🔥 Серия дней: <b>${u.streak}</b>\n` +
    `📖 Слов начато: <b>${s.total}</b> из ${total}\n` +
    `✅ Выучено: <b>${s.known}</b>\n` +
    `🔁 Ждут повторения: <b>${s.due}</b>\n` +
    `🎯 Точность ответов: <b>${acc}%</b>`;
  return show(env, c, text, [
    [btn("🔁 Повторение", "q:0")],
    [btn("« В меню", "m")],
  ]);
}

/* ---------- Мини-приложение: API ---------- */

const jsonResp = (o, status = 200) =>
  new Response(JSON.stringify(o), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
  });

// Проверка подписи Telegram (initData), чтобы нельзя было писать прогресс за другого человека
async function verifyInitData(initData, token) {
  if (!initData || typeof initData !== "string") return null;
  const params = new URLSearchParams(initData);
  const hash = params.get("hash");
  if (!hash) return null;
  params.delete("hash");
  const dcs = [...params.entries()].sort((a, b) => (a[0] < b[0] ? -1 : 1)).map(([k, v]) => `${k}=${v}`).join("\n");
  const enc = new TextEncoder();
  const hmac = async (key, data) => {
    const k = await crypto.subtle.importKey("raw", key, { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
    return new Uint8Array(await crypto.subtle.sign("HMAC", k, enc.encode(data)));
  };
  const secret = await hmac(enc.encode("WebAppData"), token);
  const hex = [...(await hmac(secret, dcs))].map((b) => b.toString(16).padStart(2, "0")).join("");
  if (hex.length !== hash.length) return null;
  let diff = 0;
  for (let i = 0; i < hex.length; i++) diff |= hex.charCodeAt(i) ^ hash.charCodeAt(i);
  if (diff !== 0) return null;
  const age = Date.now() / 1000 - Number(params.get("auth_date") || 0);
  if (!(age < 172800)) return null; // не старше 48 часов
  try { return JSON.parse(params.get("user")); } catch { return null; }
}

async function apiRoute(req, url, env) {
  if (url.pathname === "/api/words" && req.method === "GET") {
    const { results } = await env.DB.prepare(
      "SELECT id, source_row, hanzi, pinyin, meaning_ru, emoji FROM words ORDER BY source_row"
    ).all();
    const withLessons = results.map((w) => ({ ...w, lessons: LESSONS[hz(w.hanzi)] || [] }));
    return new Response(JSON.stringify(withLessons), {
      headers: { "content-type": "application/json; charset=utf-8", "cache-control": "public, max-age=300" },
    });
  }
  if (req.method !== "POST") return jsonResp({ error: "method" }, 405);
  if (Number(req.headers.get("content-length") || 0) > 20000) return jsonResp({ error: "too large" }, 413);

  let body;
  try { body = await req.json(); } catch { return jsonResp({ error: "bad json" }, 400); }
  const tgUser = await verifyInitData(body.initData, env.BOT_TOKEN);
  if (!tgUser || !tgUser.id) return jsonResp({ error: "unauthorized" }, 401);
  const user = await getUser(env, tgUser);

  if (url.pathname === "/api/me") {
    const { results } = await env.DB.prepare(
      "SELECT word_id, recognition_score s, (next_review_at <= datetime('now')) AS due FROM user_words WHERE user_id=?"
    ).bind(user.id).all();
    const scores = {};
    const due = [];
    for (const r of results) { scores[r.word_id] = r.s; if (r.due) due.push(r.word_id); }
    return jsonResp({ user: { name: user.first_name, xp: user.xp, streak: user.streak }, scores, due });
  }

  if (url.pathname === "/api/progress") {
    const out = await applyProgress(env, user, body);
    return jsonResp(out);
  }
  return jsonResp({ error: "not found" }, 404);
}

const GAMES = ["mix", "word", "meaning", "picture", "match", "memory", "build", "learn", "review"];

// Записать результаты раунда: оценки слов, интервалы повторения, XP, статистика дня.
// Всё сделано в нескольких запросах (у D1 есть лимит запросов на один вызов воркера).
async function applyProgress(env, user, body) {
  const game = GAMES.includes(body.game) ? body.game : "app";
  const bonus = Math.max(0, Math.min(20, parseInt(body.bonus_xp, 10) || 0));
  const raw = Array.isArray(body.results) ? body.results.slice(0, 12) : [];
  const items = [];
  for (const r of raw) {
    const id = Number(r && r.id);
    if (Number.isInteger(id) && id > 0) items.push({ id, ok: !!r.ok });
  }

  const ids = [...new Set(items.map((r) => r.id))];
  const state = new Map(); // id -> { score, c, e }
  let valid = [];
  if (ids.length) {
    const ph = ids.map(() => "?").join(",");
    const ex = await env.DB.prepare(`SELECT id FROM words WHERE id IN (${ph})`).bind(...ids).all();
    valid = ex.results.map((r) => r.id);
    const cur = await env.DB.prepare(
      `SELECT word_id, recognition_score s FROM user_words WHERE user_id=? AND word_id IN (${ph})`
    ).bind(user.id, ...ids).all();
    const old = new Map(cur.results.map((r) => [r.word_id, r.s]));
    for (const it of items) {
      if (!valid.includes(it.id)) continue;
      const st = state.get(it.id) || { score: old.get(it.id) ?? 0, c: 0, e: 0 };
      if (it.ok) { st.c++; st.score = Math.min(5, st.score + 1); }
      else { st.e++; st.score = Math.max(0, st.score - 1); }
      state.set(it.id, st);
    }
  }

  const good = items.filter((r) => r.ok && valid.includes(r.id)).length;
  const total = items.filter((r) => valid.includes(r.id)).length;
  const gained = good * 3 + bonus;

  const stmts = [];
  if (state.size) {
    const rows = [...state.entries()];
    const vals = rows.map(() => "(?,?,?,?,?,?,datetime('now', ?),datetime('now'))").join(",");
    const args = [];
    for (const [id, st] of rows) {
      args.push(user.id, id, st.score >= 4 ? "known" : "learning", st.score, st.c, st.e, `+${INTERVAL_MIN[st.score]} minutes`);
    }
    stmts.push(env.DB.prepare(
      `INSERT INTO user_words(user_id, word_id, status, recognition_score, correct_count, error_count, next_review_at, updated_at)
       VALUES ${vals}
       ON CONFLICT(user_id, word_id) DO UPDATE SET
         status=excluded.status,
         recognition_score=excluded.recognition_score,
         correct_count=correct_count+excluded.correct_count,
         error_count=error_count+excluded.error_count,
         next_review_at=excluded.next_review_at,
         updated_at=excluded.updated_at`
    ).bind(...args));

    const valid_items = items.filter((r) => valid.includes(r.id));
    const evVals = valid_items.map(() => "(?,?,?,?)").join(",");
    const evArgs = [];
    for (const it of valid_items) evArgs.push(user.id, it.id, `app_${game}`, it.ok ? 1 : 0);
    stmts.push(env.DB.prepare(
      `INSERT INTO user_word_events(user_id, word_id, skill, is_correct) VALUES ${evVals}`
    ).bind(...evArgs));
  }
  if (gained > 0 || total > 0) {
    stmts.push(env.DB.prepare("UPDATE users SET xp = xp + ? WHERE id=?").bind(gained, user.id));
    stmts.push(env.DB.prepare(
      `INSERT INTO user_daily_stats(user_id, stat_date, xp_earned, answers_total, answers_correct, words_reviewed)
       VALUES(?, date('now'), ?, ?, ?, ?)
       ON CONFLICT(user_id, stat_date) DO UPDATE SET
         xp_earned=xp_earned+excluded.xp_earned,
         answers_total=answers_total+excluded.answers_total,
         answers_correct=answers_correct+excluded.answers_correct,
         words_reviewed=words_reviewed+excluded.words_reviewed`
    ).bind(user.id, gained, total, good, state.size));
  }
  if (stmts.length) await env.DB.batch(stmts);

  const u = await env.DB.prepare("SELECT xp, streak FROM users WHERE id=?").bind(user.id).first();
  const scores = {};
  for (const [id, st] of state) scores[id] = st.score;
  return { gained, scores, user: { name: user.first_name, xp: u.xp, streak: u.streak } };
}
