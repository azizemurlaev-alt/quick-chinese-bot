CREATE TABLE IF NOT EXISTS course_levels (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  order_number INTEGER NOT NULL UNIQUE,
  is_published INTEGER NOT NULL DEFAULT 0 CHECK (is_published IN (0,1))
);

CREATE TABLE IF NOT EXISTS lessons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  level_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  order_number INTEGER NOT NULL,
  is_published INTEGER NOT NULL DEFAULT 0 CHECK (is_published IN (0,1)),
  UNIQUE(level_id, order_number),
  FOREIGN KEY(level_id) REFERENCES course_levels(id)
);

CREATE TABLE IF NOT EXISTS course_units (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  order_number INTEGER NOT NULL,
  is_published INTEGER NOT NULL DEFAULT 0 CHECK (is_published IN (0,1)),
  UNIQUE(lesson_id, order_number),
  FOREIGN KEY(lesson_id) REFERENCES lessons(id)
);

CREATE TABLE IF NOT EXISTS words (
  id INTEGER PRIMARY KEY,
  source_row INTEGER NOT NULL UNIQUE,
  hanzi TEXT NOT NULL UNIQUE,
  pinyin TEXT NOT NULL,
  meaning_ru TEXT NOT NULL,
  emoji TEXT,
  source_category TEXT,
  hsk_level INTEGER NOT NULL DEFAULT 1 CHECK (hsk_level BETWEEN 1 AND 6),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_unit_words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  unit_id INTEGER NOT NULL,
  word_id INTEGER NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 1,
  review_status TEXT NOT NULL DEFAULT 'draft' CHECK (review_status IN ('draft','approved')),
  UNIQUE(unit_id, word_id),
  FOREIGN KEY(unit_id) REFERENCES course_units(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS word_examples (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,
  sentence_hanzi TEXT NOT NULL,
  sentence_pinyin TEXT,
  translation_ru TEXT,
  audio_url TEXT,
  difficulty INTEGER NOT NULL DEFAULT 1,
  is_reviewed INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS word_components (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,
  component_hanzi TEXT NOT NULL,
  component_meaning_ru TEXT,
  explanation_ru TEXT,
  display_order INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS collocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,
  phrase_hanzi TEXT NOT NULL,
  phrase_pinyin TEXT,
  translation_ru TEXT,
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER,
  unit_id INTEGER,
  word_id INTEGER,
  exercise_type TEXT NOT NULL,
  question TEXT NOT NULL,
  options_json TEXT,
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  media_url TEXT,
  xp_reward INTEGER NOT NULL DEFAULT 5,
  is_published INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(lesson_id) REFERENCES lessons(id),
  FOREIGN KEY(unit_id) REFERENCES course_units(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS reading_texts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER,
  title TEXT NOT NULL,
  hsk_level INTEGER NOT NULL DEFAULT 1,
  content_hanzi TEXT NOT NULL,
  content_pinyin TEXT,
  translation_ru TEXT,
  audio_url TEXT,
  questions_json TEXT,
  is_published INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(lesson_id) REFERENCES lessons(id)
);

CREATE TABLE IF NOT EXISTS dialogues (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER,
  title TEXT NOT NULL,
  hsk_level INTEGER NOT NULL DEFAULT 1,
  description_ru TEXT,
  is_published INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(lesson_id) REFERENCES lessons(id)
);

CREATE TABLE IF NOT EXISTS dialogue_turns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dialogue_id INTEGER NOT NULL,
  turn_number INTEGER NOT NULL,
  speaker TEXT,
  text_hanzi TEXT NOT NULL,
  text_pinyin TEXT,
  translation_ru TEXT,
  audio_url TEXT,
  followup_question TEXT,
  UNIQUE(dialogue_id, turn_number),
  FOREIGN KEY(dialogue_id) REFERENCES dialogues(id)
);

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  telegram_id INTEGER NOT NULL UNIQUE,
  username TEXT,
  first_name TEXT,
  language TEXT NOT NULL DEFAULT 'ru',
  xp INTEGER NOT NULL DEFAULT 0,
  streak INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_active_at TEXT
);

CREATE TABLE IF NOT EXISTS user_words (
  user_id INTEGER NOT NULL,
  word_id INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'new',
  recognition_score INTEGER NOT NULL DEFAULT 0,
  meaning_score INTEGER NOT NULL DEFAULT 0,
  reading_score INTEGER NOT NULL DEFAULT 0,
  writing_score INTEGER NOT NULL DEFAULT 0,
  usage_score INTEGER NOT NULL DEFAULT 0,
  correct_count INTEGER NOT NULL DEFAULT 0,
  error_count INTEGER NOT NULL DEFAULT 0,
  next_review_at TEXT,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id, word_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  exercise_id INTEGER,
  word_id INTEGER,
  user_answer TEXT,
  is_correct INTEGER NOT NULL DEFAULT 0 CHECK(is_correct IN (0,1)),
  response_time_ms INTEGER,
  checked_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  xp_awarded INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(exercise_id) REFERENCES exercises(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS user_word_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  word_id INTEGER NOT NULL,
  skill TEXT NOT NULL,
  is_correct INTEGER NOT NULL DEFAULT 0 CHECK(is_correct IN (0,1)),
  response_time_ms INTEGER,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS user_daily_stats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  stat_date TEXT NOT NULL,
  xp_earned INTEGER NOT NULL DEFAULT 0,
  answers_total INTEGER NOT NULL DEFAULT 0,
  answers_correct INTEGER NOT NULL DEFAULT 0,
  study_minutes INTEGER NOT NULL DEFAULT 0,
  words_reviewed INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, stat_date),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS user_favorites (
  user_id INTEGER NOT NULL,
  word_id INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id, word_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(word_id) REFERENCES words(id)
);

CREATE TABLE IF NOT EXISTS user_reading_progress (
  user_id INTEGER NOT NULL,
  reading_text_id INTEGER NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  comprehension_score INTEGER NOT NULL DEFAULT 0,
  last_position INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id, reading_text_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(reading_text_id) REFERENCES reading_texts(id)
);

CREATE TABLE IF NOT EXISTS achievements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  xp_reward INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_achievements (
  user_id INTEGER NOT NULL,
  achievement_id INTEGER NOT NULL,
  earned_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(user_id, achievement_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(achievement_id) REFERENCES achievements(id)
);

CREATE INDEX IF NOT EXISTS idx_words_hsk ON words(hsk_level);
CREATE INDEX IF NOT EXISTS idx_course_units_lesson ON course_units(lesson_id, order_number);
CREATE INDEX IF NOT EXISTS idx_unit_words_unit ON course_unit_words(unit_id, display_order);
CREATE INDEX IF NOT EXISTS idx_exercises_unit ON exercises(unit_id, is_published);
CREATE INDEX IF NOT EXISTS idx_attempts_user_date ON attempts(user_id, checked_at);
CREATE INDEX IF NOT EXISTS idx_reading_level ON reading_texts(hsk_level, is_published);

INSERT OR IGNORE INTO course_levels(id, code, title, description, order_number, is_published) VALUES
(1,'HSK1','HSK 1 — Основы','Начальный уровень. В этой версии подготовлен исходный словарь курса 1.',1,0),
(2,'HSK2','HSK 2 — Повседневное общение','Будущий уровень HSK 2.',2,0),
(3,'HSK3','HSK 3 — Уверенное общение','Будущий уровень HSK 3.',3,0),
(4,'HSK4','HSK 4 — Свободнее выражаем мысли','Будущий уровень HSK 4.',4,0),
(5,'HSK5','HSK 5 — Продвинутое чтение','Будущий уровень HSK 5.',5,0),
(6,'HSK6','HSK 6 — Продвинутый уровень','Будущий уровень HSK 6.',6,0);

INSERT OR IGNORE INTO lessons(id, level_id, title, description, order_number, is_published)
VALUES (1,1,'HSK 1 — Основы','Первый курс Quick Chinese',1,0);

INSERT OR IGNORE INTO course_units(lesson_id,title,description,order_number,is_published) VALUES
(1,'Знакомство и приветствия','Приветствия, имена и представление',1,0),
(1,'Семья и люди','Родственники, люди и местоимения',2,0),
(1,'Числа и время','Числа, даты, часы и дни недели',3,0),
(1,'Страны и языки','Страны, города и китайский язык',4,0),
(1,'Еда и напитки','Продукты, блюда и напитки',5,0),
(1,'Покупки','Магазины, цены и деньги',6,0),
(1,'Дом и повседневная жизнь','Дом, предметы и повседневные действия',7,0),
(1,'Учёба и работа','Школа, учёба и работа',8,0),
(1,'Передвижение и места','Транспорт, направления и места',9,0),
(1,'Грамматика и общение','Вопросы, частицы и базовые конструкции',10,0);

INSERT OR IGNORE INTO achievements(code,title,description,xp_reward) VALUES
('first_lesson','Первый шаг','Завершить первый урок',10),
('ten_words','Первые 10 слов','Изучить 10 слов',20),
('streak_3','Три дня подряд','Заниматься три дня подряд',30),
('perfect_lesson','Без ошибок','Завершить урок без ошибок',25),
('hundred_xp','100 XP','Набрать 100 очков опыта',50);


INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (1,'爱','ài','любить; любовь','❤️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (2,'八','bā','восемь','8️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (3,'爸爸','bàba','папа; отец','👨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (4,'吧','ba','частица предложения; совет или просьба','💬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (5,'白天','báitiān','день; дневное время','☀️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (6,'百','bǎi','сто','💯','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (7,'半','bàn','половина; половина часа','◐','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (8,'包子','bāozi','паровые булочки с начинкой','🥟','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (9,'杯','bēi','чашка; стакан (счётное слово)','🥛','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (10,'杯子','bēizi','чашка; стакан','🥛','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (11,'本','běn','счётное слово для книг','📚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (12,'边','biān / biàn','сторона; край; местоположение','↔️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (13,'病','bìng','болеть; болезнь','🤒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (14,'病人*','bìngrén','пациент; больной','🔤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (15,'不客气','bú kèqi','не за что','😊','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (16,'不要','búyào','не нужно; не надо','🚫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (17,'不','bù','не; нет','❌','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (18,'菜','cài','блюдо; овощи','🥬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (19,'茶','chá','чай','🍵','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (20,'唱','chàng','петь','🎤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (21,'超市','chāoshì','супермаркет','🛒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (22,'车','chē','машина; транспорт','🚗','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (23,'吃','chī','есть; кушать','🍽️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (24,'出租车','chūzūchē','такси','🚕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (25,'穿','chuān','носить (одежду); надевать','👕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (26,'打电话','dǎ diànhuà','звонить; совершать телефонный звонок','📞','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (27,'大','dà','большой; старший','📏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (28,'大家','dàjiā','все; каждый','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (29,'大学','dàxué','университет','🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (30,'大学生','dàxuéshēng','студент университета','🎓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (31,'到','dào','прибывать; достигать','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (32,'的','de','притяжательная/определительная частица','🔗','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (33,'弟弟','dìdi','младший брат','👦','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (34,'第','dì','показатель порядкового числительного','🔢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (35,'点','diǎn','час; точка','⏰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (36,'电话','diànhuà','телефон; телефонный звонок','☎️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (37,'电脑','diànnǎo','компьютер','💻','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (38,'电视','diànshì','телевизор; телевидение','📺','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (39,'电影','diànyǐng','фильм; кино','🎬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (40,'电影院','diànyǐngyuàn','кинотеатр','🎥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (41,'店','diàn','магазин','🏬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (42,'东西','dōngxi','вещь; предмет','📦','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (43,'都','dōu','все; оба','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (44,'读','dú','читать','📖','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (45,'读书','dúshū','учиться; читать книги','📚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (46,'对','duì','правильный; верно; к','✅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (47,'对不起','duìbuqǐ','извините; прости','🙏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (48,'多','duō','много; насколько','➕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (49,'多少','duōshao','сколько','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (50,'儿子','érzi','сын','👦','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (51,'二','èr','два','2️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (52,'饭','fàn','еда; рис; приём пищи','🍚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (53,'饭店','fàndiàn','ресторан; гостиница','🍴','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (54,'房间','fángjiān','комната','🚪','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (55,'飞机','fēijī','самолёт','✈️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (56,'非常','fēicháng','очень; чрезвычайно','‼️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (57,'分','fēn','минута; делить','⏱️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (58,'分钟','fēnzhōng','минута','⏱️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (59,'服务员*','fúwùyuán','официант; обслуживающий персонал','😴','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (60,'高兴','gāoxìng','радостный; счастливый','😄','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (61,'哥哥','gēge','старший брат','👨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (62,'歌','gē','песня','🎵','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (63,'个','gè','универсальное счётное слово','🔢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (64,'给','gěi','давать; для; кому-либо','🤲','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (65,'工作','gōngzuò','работать; работа','💼','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (66,'公司','gōngsī','компания; фирма','🏢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (67,'狗','gǒu','собака','🐕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (68,'贵','guì','дорогой; дорогостоящий','💰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (69,'国','guó','страна; государство','🌍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (70,'还','hái','ещё; всё ещё','🔁','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (71,'孩子','háizi','ребёнок; дети','🧒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (72,'好','hǎo','хороший; хорошо','👍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (73,'好吃','hǎochī','вкусный','😋','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (74,'好看','hǎokàn','красивый; приятный на вид','👀','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (75,'好听','hǎotīng','приятный на слух','🎶','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (76,'好玩儿','hǎowánr','интересный; забавный','🎮','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (77,'号','hào','число месяца; номер','🔢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (78,'喝','hē','пить','🥤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (79,'和','hé','и; вместе с','➕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (80,'很','hěn','очень','📈','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (81,'后','hòu','после; позади','⬅️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (82,'回','huí','возвращаться','↩️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (83,'会','huì','уметь; мочь','🧠','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (84,'火车','huǒchē','поезд','🚆','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (85,'机场*','jīchǎng','аэропорт','✈️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (86,'鸡蛋','jīdàn','яйцо','🥚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (87,'几','jǐ','сколько; несколько','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (88,'家','jiā','дом; семья; счётное слово для семей/организаций','🏠','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (89,'家人','jiārén','члены семьи','👪','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (90,'见','jiàn','видеть; встречаться','👋','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (91,'件','jiàn','счётное слово для предметов одежды и вещей','👕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (92,'饺子','jiǎozi','цзяоцзы; китайские пельмени','🥟','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (93,'叫','jiào','зваться; называть','🗣️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (94,'接*','jiē','встречать; забирать','🔤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (95,'姐姐','jiějie','старшая сестра','👩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (96,'斤*','jīn','цзинь (китайская мера веса)','🔤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (97,'今年','jīnnián','этот год','📅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (98,'今天','jīntiān','сегодня','📆','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (99,'九','jiǔ','девять','9️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (100,'觉得','juéde','считать; чувствовать','🤔','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (101,'开','kāi','открывать; отправляться (о транспорте)','🔓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (102,'开车','kāichē','водить машину','🚘','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (103,'看','kàn','смотреть; читать','👀','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (104,'看病','kànbìng','обращаться к врачу; лечиться','🏥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (105,'看见','kànjiàn','увидеть','👁️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (106,'可以','kěyǐ','можно; мочь','👌','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (107,'课','kè','урок; занятие','📚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (108,'口','kǒu','рот; счётное слово для членов семьи','👄','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (109,'块','kuài','юань (разговорное); кусок','💴','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (110,'来','lái','приходить; приезжать','➡️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (111,'老师','lǎoshī','учитель; преподаватель','👩‍🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (112,'了','le','частица изменения ситуации или завершённого действия','🕒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (113,'冷','lěng','холодный; холодно','🥶','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (114,'里','lǐ / lī','внутри; в','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (115,'两','liǎng','два (перед счётным словом)','2️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (116,'零','líng','ноль','0️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (117,'六','liù','шесть','6️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (118,'妈妈','māma','мама; мать','👩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (119,'吗','ma','вопросительная частица','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (120,'买','mǎi','покупать','🛍️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (121,'卖','mài','продавать','🏷️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (122,'忙','máng','занятой; быть занятым','⏳','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (123,'猫','māo','кошка','🐈','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (124,'没','méi','не; нет; ещё не','🚫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (125,'没关系','méi guānxi','ничего страшного; неважно','🙂','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (126,'没事','méishì','ничего; всё в порядке','👌','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (127,'没有','méiyǒu','не иметь; нет','🚫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (128,'妹妹','mèimei','младшая сестра','👧','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (129,'们','men','суффикс множественного числа','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (130,'米饭','mǐfàn','варёный рис','🍚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (131,'面包','miànbāo','хлеб; булочка','🍞','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (132,'面条','miàntiáo','лапша','🍜','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (133,'名字','míngzi','имя','🪪','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (134,'明年','míngnián','следующий год','📅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (135,'明天','míngtiān','завтра','🌅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (136,'哪','nǎ','какой; который','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (137,'哪个','nǎge','какой; который','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (138,'哪里','nǎlǐ','где; куда','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (139,'哪儿','nǎr','где; куда','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (140,'哪些','nǎxiē','какие; которые','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (141,'那','nà','тот; та; то','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (142,'那边','nàbiān','вон там; та сторона','➡️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (143,'那个','nàge','тот; та; то','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (144,'那里','nàlǐ','там','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (145,'那儿','nàr','там; туда','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (146,'那些','nàxiē','те','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (147,'男','nán','мужской; мужчина','👨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (148,'男朋友','nánpéngyou','парень; молодой человек','💑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (149,'呢','ne','вопросительная/контекстная частица','💬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (150,'能','néng','мочь; быть в состоянии','💪','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (151,'你','nǐ','ты; вы (ед. число)','🫵','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (152,'你好','nǐ hǎo','привет; здравствуйте','👋','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (153,'你们','nǐmen','вы (множественное число)','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (154,'年','nián','год','📆','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (155,'您','nín','Вы (вежливое обращение)','🙏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (156,'牛奶','niúnǎi','молоко','🥛','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (157,'女','nǚ','женский; женщина','👩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (158,'女儿','nǚ’ér','дочь','👧','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (159,'女朋友','nǚpéngyou','девушка; подруга','💑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (160,'女士','nǚshì','госпожа; дама','👩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (161,'朋友','péngyou','друг','🧑‍🤝‍🧑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (162,'便宜','piányi','дешёвый; недорогой','🏷️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (163,'漂亮','piàoliang','красивый','🌸','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (164,'苹果','píngguǒ','яблоко','🍎','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (165,'七','qī','семь','7️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (166,'起床','qǐchuáng','вставать с постели','⏰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (167,'千','qiān','тысяча','🔢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (168,'前','qián','перед; впереди','⬆️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (169,'前边','qiánbian','впереди; перед','⬆️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (170,'钱','qián','деньги','💰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (171,'请','qǐng','пожалуйста; просить; приглашать','🙏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (172,'请问','qǐngwèn','скажите, пожалуйста; можно спросить','💬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (173,'去','qù','идти; ехать','➡️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (174,'去年','qùnián','прошлый год','📅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (175,'热','rè','жаркий; горячий','🔥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (176,'人','rén','человек; люди','🧍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (177,'认识','rènshi','знать; быть знакомым','🤝','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (178,'日','rì','день; число месяца','☀️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (179,'三','sān','три','3️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (180,'商店','shāngdiàn','магазин','🏬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (181,'上','shàng / shǎng','верх; идти вверх; садиться на транспорт','⬆️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (182,'上班','shàngbān','идти на работу; работать','💼','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (183,'上课','shàngkè','быть на уроке; проводить занятие','🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (184,'上午','shàngwǔ','утро; до полудня','🌤️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (185,'上学','shàngxué','ходить в школу; учиться','🎒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (186,'少','shǎo','мало; немного','🔽','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (187,'谁','shéi / shuí','кто','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (188,'什么','shénme','что; какой','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (189,'生病','shēngbìng','болеть; заболеть','🤒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (190,'十','shí','десять','🔟','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (191,'时候','shíhou','время; момент','⏰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (192,'时间','shíjiān','время; промежуток времени','🕒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (193,'事','shì','дело; вопрос; событие','📝','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (194,'是','shì','быть; являться','✅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (195,'手机','shǒujī','мобильный телефон','📱','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (196,'售货员*','shòuhuòyuán','продавец; продавец-консультант','🛒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (197,'书','shū','книга','📖','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (198,'书店','shūdiàn','книжный магазин','📚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (199,'水','shuǐ','вода','💧','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (200,'水果','shuǐguǒ','фрукты','🍉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (201,'睡','shuì','спать','😴','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (202,'睡觉','shuìjiào','спать; ложиться спать','🛌','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (203,'说','shuō','говорить; сказать','💬','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (204,'说话','shuōhuà','разговаривать','🗣️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (205,'四','sì','четыре','4️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (206,'岁','suì','лет (о возрасте)','🎂','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (207,'他','tā','он','👨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (208,'他们','tāmen','они (мужчины или смешанная группа)','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (209,'它','tā','оно; он/она (о неодушевлённом/животном)','🐾','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (210,'它们','tāmen','они (о предметах/животных)','🐾','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (211,'她','tā','она','👩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (212,'她们','tāmen','они (женщины)','👩‍👩‍👧','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (213,'太','tài','слишком; чересчур','☀️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (214,'天','tiān','день; небо','🌤️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (215,'天气','tiānqì','погода','🌦️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (216,'听','tīng','слушать','👂','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (217,'听见','tīngjiàn','услышать','👂','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (218,'同学','tóngxué','одноклассник; одногруппник','🧑‍🎓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (219,'外','wài','внешний; снаружи','🌐','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (220,'外边','wàibian','снаружи; за пределами','↗️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (221,'玩','wán','играть; развлекаться','🎮','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (222,'晚','wǎn','поздний; поздно','🌙','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (223,'晚饭','wǎnfàn','ужин','🍽️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (224,'晚上','wǎnshang','вечер; вечером','🌙','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (225,'喂','wèi','алло (по телефону)','📞','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (226,'问','wèn','спрашивать','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (227,'问题','wèntí','вопрос; проблема','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (228,'我','wǒ','я; мне','🙋','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (229,'我们','wǒmen','мы','👥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (230,'五','wǔ','пять','5️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (231,'午饭','wǔfàn','обед','🍱','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (232,'喜欢','xǐhuan','нравиться; любить','❤️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (233,'下','xià','вниз; под; следующий; спускаться','⬇️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (234,'下班','xiàbān','заканчивать работу','🏢','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (235,'下课','xiàkè','заканчивать урок; конец занятия','🔔','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (236,'下午','xiàwǔ','после полудня; днём','🌇','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (237,'下雨','xiàyǔ','идёт дождь; дождить','🌧️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (238,'先生','xiānsheng','господин; мистер','👨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (239,'现在','xiànzài','сейчас','⏱️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (240,'想','xiǎng','хотеть; думать; скучать','💭','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (241,'小','xiǎo','маленький; младший','🐣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (242,'小朋友','xiǎopéngyou','ребёнок; малыш','🧒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (243,'小时','xiǎoshí','час','⏰','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (244,'小学','xiǎoxué','начальная школа','🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (245,'小学生','xiǎoxuéshēng','ученик начальной школы','🎒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (246,'些','xiē','несколько; некоторые','➖','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (247,'写','xiě','писать','✍️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (248,'谢谢','xièxie','спасибо','🙏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (249,'新','xīn','новый','✨','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (250,'星期','xīngqī','неделя; день недели','📅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (251,'星期日','xīngqīrì','воскресенье','☀️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (252,'星期天','xīngqītiān','воскресенье','☀️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (253,'休息','xiūxi','отдыхать; отдых','🛋️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (254,'学','xué','учиться; изучать','📚','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (255,'学生','xuéshēng','ученик; студент','🎓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (256,'学习','xuéxí','учиться; изучать','📖','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (257,'学校','xuéxiào','школа','🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (258,'雪','xuě','снег','❄️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (259,'药*','yào','лекарство','🏥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (260,'要','yào','хотеть; нужно; следует','📌','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (261,'也','yě','тоже; также','➕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (262,'一','yī','один','1️⃣','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (263,'一半','yíbàn','половина','◐','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (264,'一下','yíxià','немного; один раз; попробовать','👇','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (265,'一点儿','yìdiǎnr','немного; чуть-чуть','🤏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (266,'一些','yìxiē','несколько; некоторое количество','🧩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (267,'衣服','yīfu','одежда','👕','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (268,'医*','yī','медицина; медицинский','🔤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (269,'医生','yīshēng','врач; доктор','🧑‍⚕️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (270,'医院','yīyuàn','больница','🏥','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (271,'椅子','yǐzi','стул','🪑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (272,'有','yǒu','иметь; есть','✅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (273,'有的','yǒude','некоторые','🧑‍🤝‍🧑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (274,'有点儿','yǒudiǎnr','немного; слегка','🤏','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (275,'有些','yǒuxiē','некоторые; немного','🧩','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (276,'雨','yǔ','дождь','🌧️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (277,'元','yuán','юань','💴','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (278,'月','yuè','месяц','🌙','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (279,'再','zài','снова; ещё раз','🔁','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (280,'再见','zàijiàn','до свидания','👋','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (281,'在','zài','находиться; в; находясь','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (282,'早','zǎo','ранний; рано','🌅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (283,'早饭','zǎofàn','завтрак','🍳','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (284,'早上','zǎoshang','утро; утром','🌅','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (285,'怎么','zěnme','как; каким образом','❓','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (286,'怎么样','zěnmeyàng','как; каким образом; как насчёт','🤔','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (287,'找','zhǎo','искать; искать/найти','🔎','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (288,'这','zhè','этот; это','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (289,'这边','zhèbiān','здесь; эта сторона','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (290,'这个','zhège','этот; это','👉','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (291,'这里','zhèlǐ','здесь','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (292,'这儿','zhèr','здесь; сюда','📍','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (293,'这些','zhèxiē','эти','👇','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (294,'真','zhēn','действительно; правда','💯','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (295,'正在','zhèngzài','в данный момент; быть в процессе','⏳','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (296,'只','zhǐ','счётное слово для некоторых животных','🐾','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (297,'知道','zhīdào','знать','💡','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (298,'中午','zhōngwǔ','полдень; в полдень','🌞','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (299,'中学','zhōngxué','средняя школа','🏫','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (300,'中学生','zhōngxuéshēng','ученик средней школы','🎒','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (301,'住','zhù','жить; проживать','🏠','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (302,'桌子','zhuōzi','стол','🪑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (303,'字','zì','иероглиф; знак','🔤','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (304,'昨天','zuótiān','вчера','📆','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (305,'坐','zuò','сидеть; ехать на транспорте','🪑','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (306,'做','zuò','делать','🛠️','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (307,'做饭','zuò fàn','готовить еду','🍳','Слово / выражение',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (308,'北京','Běijīng','Пекин','🏙️','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (309,'大兴机场','Dàxīng Jīchǎng','аэропорт Дасин','🛫','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (310,'法国','Fǎguó','Франция','🇫🇷','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (311,'汉语','Hànyǔ','китайский язык','🗣️','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (312,'汉字','Hànzì','китайские иероглифы','🈶','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (313,'胡医生','Hú yīshēng','доктор Ху','🧑‍⚕️','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (314,'泰国','Tàiguó','Таиланд','🇹🇭','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (315,'王老师','Wáng lǎoshī','учитель Ван','👩‍🏫','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (316,'西安','Xī’ān','Сиань','🏯','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (317,'西安饭店','Xī’ān Fàndiàn','ресторан Сиань','🍽️','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (318,'中国','Zhōngguó','Китай','🇨🇳','Имя собственное',1);
INSERT OR IGNORE INTO words(source_row,hanzi,pinyin,meaning_ru,emoji,source_category,hsk_level) VALUES (319,'中文','Zhōngwén','китайский язык (письменный/разговорный)','🀄','Имя собственное',1);
