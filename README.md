# Quick Chinese Bot

Telegram-бот для изучения китайского (HSK 1): карточки, тесты, повторение, прогресс.
Работает на Cloudflare Workers + база D1 (та, куда вы уже загрузили слова).

## Запуск (один раз)

Нужен Node.js (nodejs.org, версия LTS). Команды выполняйте в терминале, в папке проекта.

1. `npm install`
2. `npx wrangler login` — откроется браузер, нажмите Allow
3. `npx wrangler d1 list` — найдите свою базу, скопируйте её **name** и **uuid**
   и вставьте в `wrangler.toml` (поля `database_name` и `database_id`)
4. Секреты (вводятся в терминале, в файлы и в Git не попадают):
   - `npx wrangler secret put BOT_TOKEN` — токен от @BotFather
   - `npx wrangler secret put WEBHOOK_SECRET` — придумайте любую строку из латинских букв, цифр, `_` и `-` (например `qc_2026_secret_x7k2`)
5. `npx wrangler deploy` — в конце покажет адрес вида `https://quick-chinese-bot.ВАШ.workers.dev`
6. Откройте в браузере: `https://quick-chinese-bot.ВАШ.workers.dev/setup?secret=ВАШ_WEBHOOK_SECRET`
   Должно появиться `"ok": true` — бот подключён.
7. Напишите боту `/start`.

## GitHub

```
git init
git add .
git commit -m "Quick Chinese bot"
git branch -M main
git remote add origin https://github.com/ВАШ_ЛОГИН/ВАШ_РЕПОЗИТОРИЙ.git
git push -u origin main
```
`.gitignore` уже исключает `.dev.vars`, `.env` и `node_modules`. Токен в код не вставляйте.

## Обновление бота
Изменили `src/index.js` → `npx wrangler deploy`.

## Что умеет
- `/start` — меню, `/progress` — прогресс
- Наборы по 20 слов (319 слов = 16 наборов)
- Карточки: иероглиф → «Показать ответ» → «Знаю» / «Повторить»
- Тесты: иероглиф → перевод и перевод → иероглиф (4 варианта)
- Повторение по интервалам (10 мин → 1 → 2 → 4 → 7 → 14 дней)
- XP, серия дней, точность, статистика по дням
