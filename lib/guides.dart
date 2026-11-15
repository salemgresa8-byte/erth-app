part of 'main.dart';

// ───────────────────── Historical AI guides (personas) ──────────────────────
// The Smart Guide chat can be led by Emperor Septimius Severus or by Medusa of
// Leptis Magna. Each guide has its own greeting, tone (system prompt), quick
// questions, animated marble bust and Web Speech voice profile.

enum GuideId { severus, medusa }

class GuideProfile {
  final GuideId id;
  final bool male;
  final double pitch, rate;
  const GuideProfile(this.id, {required this.male, required this.pitch, required this.rate});

  String name(AppState s) => id == GuideId.severus
      ? s.t('الإمبراطور سيبتيموس سيفيروس', 'Emperor Septimius Severus')
      : s.t('ميدوسا اللبدية', 'Medusa of Leptis Magna');

  String short(AppState s) =>
      id == GuideId.severus ? s.t('سيفيروس', 'Severus') : s.t('ميدوسا', 'Medusa');

  String badge(AppState s) => id == GuideId.severus
      ? s.t('إمبراطور روما وابن لبدة الكبرى', 'Emperor of Rome and son of Leptis Magna')
      : s.t('حارسة الفنون وأسرار الحضارة', 'Guardian of the arts and the secrets of civilization');

  String desc(AppState s) => id == GuideId.severus
      ? s.t('جولة استراتيجية ومعمارية في تاريخ الإمبراطوريات، المسارح، الأقواس، والحصون الليبية.',
          'A strategic, architectural journey through the history of empires, theatres, arches and Libyan fortresses.')
      : s.t('رحلة شاعرية في روائع الفسيفساء، المنحوتات، الفلسفة القورينائية، وتراث الواحات.',
          'A poetic journey through masterpiece mosaics, sculpture, Cyrenaic philosophy and oasis heritage.');

  String cta(AppState s) => id == GuideId.severus
      ? s.t('تحدث مع سيفيروس', 'Talk with Severus')
      : s.t('تحدث مع ميدوسا', 'Talk with Medusa');

  String greeting(AppState s) => id == GuideId.severus
      ? s.t('سلامٌ عليك أيها الرحّالة! أنا سيبتيموس سيفيروس، ابن لبدة الكبرى وإمبراطور روما. سلني عن الأقواس والمسارح والحصون والخطط التي صنعت مجد ليبيا.',
          'Salve, traveller! I am Septimius Severus, son of Leptis Magna and emperor of Rome. Ask me about the arches, theatres, forts and strategies that shaped Libya.')
      : s.t('أهلًا بك يا باحثًا عن الجمال. أنا ميدوسا، حارسة الفوروم السيفيري في لبدة الكبرى. سلني عن الفسيفساء والمنحوتات والفلسفة القورينائية وأسرار الواحات.',
          'Welcome, seeker of beauty. I am Medusa, guardian of the Severan Forum of Leptis Magna. Ask me about mosaics, sculpture, Cyrenaic philosophy and the secrets of the oases.');

  String speaking(AppState s) => id == GuideId.severus
      ? s.t('يتحدث الآن…', 'Speaking…')
      : s.t('تتحدث الآن…', 'Speaking…');

  String thinking(AppState s) =>
      id == GuideId.severus ? s.t('يفكر…', 'Thinking…') : s.t('تفكر…', 'Thinking…');

  List<String> chips(AppState s) => id == GuideId.severus
      ? [
          s.t('حدثني عن قوسك في لبدة الكبرى', 'Tell me about your arch in Leptis Magna'),
          s.t('كيف بُني مسرح لبدة الكبرى؟', 'How was the Leptis Magna theatre built?'),
          s.t('ما الحصون الرومانية التي حرست ليبيا؟', 'Which Roman forts guarded Libya?'),
          if (s.isExpertRole) s.t('ما هو Paraloid B-72؟', 'What is Paraloid B-72?'),
        ]
      : [
          s.t('حدثيني عن فسيفساء زليتن', 'Tell me about the Zliten mosaics'),
          s.t('من هم فلاسفة المدرسة القورينائية؟', 'Who were the Cyrenaic philosophers?'),
          s.t('ما أسرار غدامس؟', 'What secrets does Ghadames hold?'),
          if (s.isExpertRole) s.t('كيف أعالج تزهر الأملاح؟', 'How do I treat salt efflorescence?'),
        ];

  String systemPrompt(AppState s) {
    final expertAr = s.isExpertRole
        ? ' المستخدم مرمّم محترف، فأجب بدقة علمية عن كيمياء الترميم (بارالويد B-72، الجير النانوي، سيليكات الإيثيل، الشمع دقيق التبلور، إزالة الأملاح).'
        : '';
    final expertEn = s.isExpertRole
        ? ' The user is a professional conservator: answer conservation-chemistry questions (Paraloid B-72, nano-lime, ethyl silicate, micro-crystalline wax, desalination) with scientific precision.'
        : '';
    if (id == GuideId.severus) {
      return s.ar
          ? 'أنت تؤدي دور الإمبراطور سيبتيموس سيفيروس (145–211م)، ابن لبدة الكبرى وإمبراطور روما منذ 193م، داخل تطبيق «إرث» للتراث الليبي. تحدّث بصيغة المتكلم بوقار القائد الاستراتيجي والباني: ركّز على الإمبراطوريات والاستراتيجية العسكرية والعمارة والمسارح والأقواس والحصون ومدن ليبيا الرومانية، وأنت أيضًا مرشد خبير بكل التراث الليبي (لبدة، صبراتة، قورينا، غدامس، أكاكوس...). التزم بالدقة التاريخية، وإذا سُئلت عن أحداث بعد عصرك فأجب كمرشد درسها، وصرّح عندما لا تكون متأكدًا. أجب بالعربية بإيجاز (أقل من 160 كلمة).$expertAr'
          : 'You are role-playing Emperor Septimius Severus (145–211 AD), son of Leptis Magna and Roman emperor from 193 AD, inside the ERTH Libyan heritage app. Speak in the first person with the calm authority of a strategist and builder: focus on empires, military strategy, architecture, theatres, triumphal arches, forts and the cities of Roman Libya. You are also an expert guide to all Libyan heritage (Leptis Magna, Sabratha, Cyrene, Ghadames, Acacus…). Stay historically accurate; for events after your lifetime answer as a guide who has studied them, and say when you are unsure. Be concise (under 160 words).$expertEn Always reply in ${langNative(s.lang)}.';
    }
    return s.ar
        ? 'أنت تؤدين دور «ميدوسا اللبدية»، الروح الحارسة الرقيقة لميداليات ميدوسا في الفوروم السيفيري بلبدة الكبرى، داخل تطبيق «إرث». تحدّثي بصيغة المتكلمة بصوت دافئ شاعري حكيم: ركّزي على الفسيفساء (زليتن، فيلا سيلين)، والنحت، وقورينا الإغريقية والمدرسة القورينائية في الفلسفة (أريستيبوس)، وغدامس وتراث الواحات والحرف. أنتِ رمز للفن والحماية لا وحش، فحافظي على أسلوب لائق للعائلة. التزمي بالدقة التاريخية وصرّحي عندما لا تكونين متأكدة. أجيبي بالعربية بإيجاز (أقل من 160 كلمة).$expertAr'
        : 'You are role-playing “Medusa of Leptis Magna”, the gentle guardian spirit of the Medusa medallions of the Severan Forum, inside the ERTH Libyan heritage app. Speak in the first person with a warm, poetic, wise voice: focus on mosaics (Zliten, Villa Silin), sculpture, Greek Cyrene and the Cyrenaic school of philosophy (Aristippus), Ghadames, oasis heritage and crafts. You are a symbol of art and protection, not a monster: stay family-friendly. Stay historically accurate and say when you are unsure. Be concise (under 160 words).$expertEn Always reply in ${langNative(s.lang)}.';
  }
}

const kGuides = {
  GuideId.severus: GuideProfile(GuideId.severus, male: true, pitch: 0.85, rate: 0.95),
  GuideId.medusa: GuideProfile(GuideId.medusa, male: false, pitch: 1.15, rate: 0.98),
};

/// BCP-47 voice language for each UI language.
String ttsLang(String code) => const {
      'ar': 'ar-SA',
      'en': 'en-GB',
      'it': 'it-IT',
      'fr': 'fr-FR',
      'tr': 'tr-TR',
      'zh': 'zh-CN',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
    }[code] ??
    'en-GB';

// Columns: it, fr, tr, zh, ru, ja (merged into kI18n).
const _guideRows = <String, List<String>>{
  'Choose your historical guide for this journey': ['Scegli la tua guida storica per questo viaggio', 'Choisissez votre guide historique pour ce voyage', 'Bu yolculuk için tarihi rehberinizi seçin', '为这次旅程选择您的历史向导', 'Выберите исторического гида для этого путешествия', 'この旅の歴史ガイドを選んでください'],
  'Emperor Septimius Severus': ['Imperatore Settimio Severo', 'Empereur Septime Sévère', 'İmparator Septimius Severus', '塞普蒂米乌斯·塞维鲁皇帝', 'Император Септимий Север', 'セプティミウス・セウェルス帝'],
  'Emperor of Rome and son of Leptis Magna': ['Imperatore di Roma e figlio di Leptis Magna', 'Empereur de Rome et fils de Leptis Magna', 'Roma İmparatoru ve Leptis Magna\'nın oğlu', '罗马皇帝，大莱普提斯之子', 'Император Рима и сын Лептис-Магны', 'ローマ皇帝にしてレプティス・マグナの子'],
  'A strategic, architectural journey through the history of empires, theatres, arches and Libyan fortresses.': ['Un viaggio strategico e architettonico nella storia degli imperi, dei teatri, degli archi e delle fortezze libiche.', 'Un voyage stratégique et architectural à travers l\'histoire des empires, des théâtres, des arcs et des forteresses libyennes.', 'İmparatorlukların, tiyatroların, takların ve Libya kalelerinin tarihinde stratejik ve mimari bir yolculuk.', '一场穿越帝国、剧场、凯旋门与利比亚要塞历史的战略与建筑之旅。', 'Стратегическое и архитектурное путешествие по истории империй, театров, арок и ливийских крепостей.', '帝国、劇場、凱旋門、リビアの要塞の歴史をめぐる戦略と建築の旅。'],
  'Talk with Severus': ['Parla con Severo', 'Parler avec Sévère', 'Severus ile konuş', '与塞维鲁对话', 'Поговорить с Севером', 'セウェルスと話す'],
  'Medusa of Leptis Magna': ['Medusa di Leptis Magna', 'Méduse de Leptis Magna', 'Leptis Magna Medusası', '大莱普提斯的美杜莎', 'Медуза из Лептис-Магны', 'レプティス・マグナのメドゥーサ'],
  'Guardian of the arts and the secrets of civilization': ['Custode delle arti e dei segreti della civiltà', 'Gardienne des arts et des secrets de la civilisation', 'Sanatların ve medeniyetin sırlarının koruyucusu', '艺术与文明奥秘的守护者', 'Хранительница искусств и тайн цивилизации', '芸術と文明の秘密の守護者'],
  'A poetic journey through masterpiece mosaics, sculpture, Cyrenaic philosophy and oasis heritage.': ['Un viaggio poetico tra capolavori di mosaico, scultura, filosofia cirenaica e patrimonio delle oasi.', 'Un voyage poétique parmi les chefs-d\'œuvre de la mosaïque, la sculpture, la philosophie cyrénaïque et le patrimoine des oasis.', 'Mozaik şaheserleri, heykeller, Kirene felsefesi ve vaha mirası arasında şiirsel bir yolculuk.', '一场穿越马赛克杰作、雕塑、昔兰尼学派哲学与绿洲遗产的诗意之旅。', 'Поэтическое путешествие по шедеврам мозаики, скульптуре, киренской философии и наследию оазисов.', 'モザイクの傑作、彫刻、キュレネ派哲学、オアシスの遺産をめぐる詩的な旅。'],
  'Talk with Medusa': ['Parla con Medusa', 'Parler avec Méduse', 'Medusa ile konuş', '与美杜莎对话', 'Поговорить с Медузой', 'メドゥーサと話す'],
  'Severus': ['Severo', 'Sévère', 'Severus', '塞维鲁', 'Север', 'セウェルス'],
  'Medusa': ['Medusa', 'Méduse', 'Medusa', '美杜莎', 'Медуза', 'メドゥーサ'],
  'Salve, traveller! I am Septimius Severus, son of Leptis Magna and emperor of Rome. Ask me about the arches, theatres, forts and strategies that shaped Libya.': ['Salve, viaggiatore! Sono Settimio Severo, figlio di Leptis Magna e imperatore di Roma. Chiedimi degli archi, dei teatri, delle fortezze e delle strategie che hanno plasmato la Libia.', 'Salve, voyageur ! Je suis Septime Sévère, fils de Leptis Magna et empereur de Rome. Interroge-moi sur les arcs, les théâtres, les forts et les stratégies qui ont façonné la Libye.', 'Salve, yolcu! Ben Septimius Severus, Leptis Magna\'nın oğlu ve Roma imparatoruyum. Bana Libya\'yı şekillendiren takları, tiyatroları, kaleleri ve stratejileri sor.', '你好，旅人！我是塞普蒂米乌斯·塞维鲁，大莱普提斯之子、罗马皇帝。问我关于塑造利比亚的凯旋门、剧场、要塞与战略吧。', 'Salve, путник! Я Септимий Север, сын Лептис-Магны и император Рима. Спрашивай меня об арках, театрах, крепостях и стратегиях, создавших Ливию.', 'ようこそ、旅人よ！我はセプティミウス・セウェルス、レプティス・マグナの子にしてローマ皇帝である。リビアを形づくった凱旋門、劇場、要塞、戦略について尋ねよ。'],
  'Welcome, seeker of beauty. I am Medusa, guardian of the Severan Forum of Leptis Magna. Ask me about mosaics, sculpture, Cyrenaic philosophy and the secrets of the oases.': ['Benvenuto, cercatore di bellezza. Sono Medusa, custode del Foro Severiano di Leptis Magna. Chiedimi dei mosaici, della scultura, della filosofia cirenaica e dei segreti delle oasi.', 'Bienvenue, chercheur de beauté. Je suis Méduse, gardienne du Forum sévérien de Leptis Magna. Interroge-moi sur les mosaïques, la sculpture, la philosophie cyrénaïque et les secrets des oasis.', 'Hoş geldin, güzellik arayıcısı. Ben Medusa, Leptis Magna\'daki Severus Forumu\'nun koruyucusuyum. Bana mozaikleri, heykelleri, Kirene felsefesini ve vahaların sırlarını sor.', '欢迎你，追寻美的人。我是美杜莎，大莱普提斯塞维鲁广场的守护者。问我关于马赛克、雕塑、昔兰尼学派哲学和绿洲的秘密吧。', 'Добро пожаловать, искатель красоты. Я Медуза, хранительница Северова форума Лептис-Магны. Спрашивай меня о мозаиках, скульптуре, киренской философии и тайнах оазисов.', 'ようこそ、美を求める人よ。私はメドゥーサ、レプティス・マグナのセウェルス広場の守護者。モザイク、彫刻、キュレネ派哲学、オアシスの秘密について聞いてください。'],
  'Tell me about your arch in Leptis Magna': ['Parlami del tuo arco a Leptis Magna', 'Parle-moi de ton arc à Leptis Magna', 'Bana Leptis Magna\'daki takından bahset', '讲讲你在大莱普提斯的凯旋门', 'Расскажи о своей арке в Лептис-Магне', 'レプティス・マグナのあなたの凱旋門について教えて'],
  'How was the Leptis Magna theatre built?': ['Come fu costruito il teatro di Leptis Magna?', 'Comment le théâtre de Leptis Magna a-t-il été construit ?', 'Leptis Magna tiyatrosu nasıl inşa edildi?', '大莱普提斯剧场是如何建造的？', 'Как был построен театр Лептис-Магны?', 'レプティス・マグナの劇場はどのように建てられたの？'],
  'Which Roman forts guarded Libya?': ['Quali forti romani difendevano la Libia?', 'Quels forts romains gardaient la Libye ?', 'Libya\'yı hangi Roma kaleleri korudu?', '哪些罗马要塞守卫着利比亚？', 'Какие римские крепости охраняли Ливию?', 'どのローマの砦がリビアを守っていたの？'],
  'Tell me about the Zliten mosaics': ['Parlami dei mosaici di Zliten', 'Parle-moi des mosaïques de Zliten', 'Bana Zliten mozaiklerinden bahset', '讲讲兹利坦马赛克', 'Расскажи о мозаиках Злитена', 'ズリテンのモザイクについて教えて'],
  'Who were the Cyrenaic philosophers?': ['Chi erano i filosofi cirenaici?', 'Qui étaient les philosophes cyrénaïques ?', 'Kirene filozofları kimlerdi?', '昔兰尼学派的哲学家是谁？', 'Кто такие киренские философы?', 'キュレネ派の哲学者とは誰？'],
  'What secrets does Ghadames hold?': ['Quali segreti custodisce Ghadames?', 'Quels secrets recèle Ghadamès ?', 'Gadames hangi sırları saklıyor?', '古达米斯藏着哪些秘密？', 'Какие тайны хранит Гадамес?', 'ガダメスにはどんな秘密があるの？'],
  'Voice': ['Voce', 'Voix', 'Ses', '语音', 'Голос', '音声'],
  'Read aloud': ['Leggi ad alta voce', 'Lire à voix haute', 'Sesli oku', '朗读', 'Прочитать вслух', '読み上げ'],
  'Stop': ['Ferma', 'Arrêter', 'Durdur', '停止', 'Стоп', '停止'],
  'Speaking…': ['Sta parlando…', 'Parle…', 'Konuşuyor…', '正在讲述…', 'Говорит…', '話しています…'],
  'Thinking…': ['Sta pensando…', 'Réfléchit…', 'Düşünüyor…', '正在思考…', 'Думает…', '考えています…'],
  'Change guide': ['Cambia guida', 'Changer de guide', 'Rehberi değiştir', '更换向导', 'Сменить гида', 'ガイドを変更'],
  'AI role-play inspired by history — verify key facts.': ['Interpretazione IA ispirata alla storia: verifica i fatti principali.', 'Incarnation IA inspirée de l\'histoire — vérifiez les faits clés.', 'Tarihten esinlenen yapay zekâ canlandırması — önemli bilgileri doğrulayın.', '受历史启发的AI角色扮演——请核实关键事实。', 'ИИ-образ по мотивам истории — проверяйте ключевые факты.', '歴史に着想を得たAIロールプレイです。重要な事実は確認してください。'],
  'Voice playback is not supported in this browser': ['La riproduzione vocale non è supportata da questo browser', 'La lecture vocale n\'est pas prise en charge par ce navigateur', 'Sesli oynatma bu tarayıcıda desteklenmiyor', '此浏览器不支持语音播放', 'Озвучивание не поддерживается этим браузером', 'このブラウザは音声再生に対応していません'],
};

// ─────────────────────────────── Bust art ───────────────────────────────────

const _marbleHi = Color(0xFFF7F3EC);
const _marbleMid = Color(0xFFE4DCCF);
const _marbleLo = Color(0xFFBFB3A2);
const _marbleLine = Color(0xFF8E8070);

Paint _marbleFill(Rect r) => Paint()
  ..shader = const RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 1.0,
    colors: [_marbleHi, _marbleMid, _marbleLo],
    stops: [0, 0.6, 1],
  ).createShader(r);

Paint _goldFill(Rect r) => Paint()
  ..shader = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kGoldPale, kGoldLight, kGold],
    stops: [0, 0.4, 1],
  ).createShader(r);

Paint _line(Color c, double w) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..color = c;

/// Drapery (toga/peplos) shared by both busts: burgundy with gold trim.
void _drawDrape(Canvas c, {required bool sash}) {
  final drape = Path()
    ..moveTo(6, 100)
    ..cubicTo(8, 84, 20, 75, 34, 73)
    ..lineTo(66, 73)
    ..cubicTo(80, 75, 92, 84, 94, 100)
    ..close();
  c.drawPath(
      drape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9C2E23), kRedDeep, kWine],
        ).createShader(const Rect.fromLTWH(0, 70, 100, 30)));
  // Folds.
  final fold = _line(Colors.black.withValues(alpha: 0.25), 0.9);
  c.drawPath(Path()..moveTo(22, 84)..quadraticBezierTo(26, 92, 24, 100), fold);
  c.drawPath(Path()..moveTo(78, 84)..quadraticBezierTo(74, 92, 76, 100), fold);
  if (sash) {
    final s = Path()
      ..moveTo(28, 75)
      ..lineTo(40, 74)
      ..lineTo(76, 100)
      ..lineTo(60, 100)
      ..close();
    c.drawPath(s, _goldFill(const Rect.fromLTWH(28, 74, 48, 26)));
    c.drawPath(s, _line(kGold.withValues(alpha: 0.9), 0.6));
  }
  // Gold neckline trim.
  c.drawPath(
      Path()
        ..moveTo(34, 73.5)
        ..quadraticBezierTo(50, 84, 66, 73.5),
      _line(kGoldLight, 1.6));
}

void _drawNeck(Canvas c) {
  final r = const Rect.fromLTWH(42, 56, 16, 22);
  c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), _marbleFill(r));
  c.drawLine(const Offset(44, 60), const Offset(45, 74),
      _line(_marbleLine.withValues(alpha: 0.35), 0.8));
}

/// Almond eye with a soft marble iris and brow.
void _drawEye(Canvas c, Offset o, {required bool female, required double blink}) {
  final w = female ? 7.0 : 6.4;
  final h = (female ? 2.6 : 2.2) * (1 - blink);
  final eye = Path()
    ..moveTo(o.dx - w / 2, o.dy)
    ..quadraticBezierTo(o.dx, o.dy - h * 1.4, o.dx + w / 2, o.dy)
    ..quadraticBezierTo(o.dx, o.dy + h, o.dx - w / 2, o.dy)
    ..close();
  c.drawPath(eye, Paint()..color = const Color(0xFFFBF8F2));
  if (blink < 0.6) {
    c.drawCircle(o.translate(0, -0.2), 1.25,
        Paint()..color = female ? const Color(0xFF8C7A60) : const Color(0xFF9A8B78));
  }
  c.drawPath(eye, _line(_marbleLine, female ? 0.9 : 0.8));
  if (female) {
    // Lashes.
    c.drawPath(
        Path()
          ..moveTo(o.dx - w / 2 - 0.4, o.dy - 0.2)
          ..quadraticBezierTo(o.dx, o.dy - h * 1.6 - 0.4, o.dx + w / 2 + 0.4, o.dy - 0.2),
        _line(const Color(0xFF6F6150), 1.1));
  }
  // Brow.
  c.drawPath(
      Path()
        ..moveTo(o.dx - w / 2 - 0.6, o.dy - 3.2)
        ..quadraticBezierTo(o.dx, o.dy - (female ? 5.2 : 4.6), o.dx + w / 2 + 0.6, o.dy - 3.0),
      _line(_marbleLine.withValues(alpha: 0.8), female ? 0.8 : 1.3));
}

/// Emperor Septimius Severus: marble bust, forked curly beard, laurel wreath,
/// burgundy toga with a gold sash.
class _SeverusPainter extends CustomPainter {
  final double talk, blink;
  _SeverusPainter(this.talk, this.blink);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 100;
    canvas.save();
    canvas.translate((size.width - 100 * k) / 2, (size.height - 100 * k) / 2);
    canvas.scale(k);

    _drawDrape(canvas, sash: true);
    _drawNeck(canvas);

    // Head.
    final head = Rect.fromCenter(center: const Offset(50, 40), width: 34, height: 42);
    canvas.drawOval(head, _marbleFill(head));

    // Ears.
    for (final x in [32.5, 67.5]) {
      final ear = Rect.fromCenter(center: Offset(x, 42), width: 4.5, height: 9);
      canvas.drawOval(ear, _marbleFill(ear));
      canvas.drawOval(ear, _line(_marbleLine.withValues(alpha: 0.5), 0.6));
    }

    // Curly hair cap.
    final curl = _line(_marbleLine.withValues(alpha: 0.55), 0.7);
    for (var i = 0; i <= 12; i++) {
      final a = math.pi * (1.05 + 0.9 * i / 12);
      final o = Offset(50 + 17.5 * math.cos(a), 37 + 20 * math.sin(a));
      final r = Rect.fromCircle(center: o, radius: 4.2);
      canvas.drawCircle(o, 4.2, _marbleFill(r));
      canvas.drawArc(Rect.fromCircle(center: o, radius: 2.4), 0.3, 4.4, false, curl);
    }

    // Forked, curly beard.
    final beard = Path()
      ..moveTo(34, 43)
      ..cubicTo(33, 58, 38, 68, 45, 71)
      ..quadraticBezierTo(50, 68, 55, 71)
      ..cubicTo(62, 68, 67, 58, 66, 43)
      ..cubicTo(62, 51, 57, 53, 50, 53)
      ..cubicTo(43, 53, 38, 51, 34, 43)
      ..close();
    canvas.drawPath(beard, Paint()..color = _marbleMid);
    for (final o in const [
      Offset(38, 54), Offset(42, 60), Offset(46, 66), Offset(54, 66),
      Offset(58, 60), Offset(62, 54), Offset(45, 70), Offset(55, 70),
      Offset(40, 49), Offset(60, 49),
    ]) {
      canvas.drawCircle(o, 2.3, Paint()..color = _marbleHi.withValues(alpha: 0.5));
      canvas.drawArc(Rect.fromCircle(center: o, radius: 2.2), 0.6, 4.2, false, curl);
    }

    // Eyes, nose.
    _drawEye(canvas, const Offset(43, 37.5), female: false, blink: blink);
    _drawEye(canvas, const Offset(57, 37.5), female: false, blink: blink);
    canvas.drawPath(
        Path()
          ..moveTo(50.5, 36)
          ..lineTo(48.6, 46)
          ..quadraticBezierTo(50.5, 47.6, 52.4, 46.4),
        _line(_marbleLine.withValues(alpha: 0.7), 0.9));

    // Moustache and speaking mouth.
    canvas.drawPath(
        Path()
          ..moveTo(42, 52)
          ..quadraticBezierTo(50, 48.5, 58, 52),
        _line(_marbleLo, 2.4));
    final open = 0.6 + talk * 4.2;
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 55.6), width: 6.5, height: open),
        Paint()..color = const Color(0xFF4A3A2C));

    // Golden laurel wreath across the brow.
    final stem = _line(kGold, 1.1);
    final wreath = Path();
    for (var i = 0; i <= 20; i++) {
      final a = math.pi * (1.0 + i / 20);
      final o = Offset(50 + 18.8 * math.cos(a), 33 + 15 * math.sin(a));
      i == 0 ? wreath.moveTo(o.dx, o.dy) : wreath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(wreath, stem);
    final leafRect = const Rect.fromLTWH(28, 14, 44, 22);
    for (var i = 0; i <= 10; i++) {
      final a = math.pi * (1.02 + 0.96 * i / 10);
      final o = Offset(50 + 18.8 * math.cos(a), 33 + 15 * math.sin(a));
      final tangent = math.atan2(15 * math.cos(a), -18.8 * math.sin(a));
      for (final side in [-0.6, 0.6]) {
        canvas.save();
        canvas.translate(o.dx, o.dy);
        canvas.rotate(tangent + side);
        final leaf = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(3.2, -1.8, 6.4, 0)
          ..quadraticBezierTo(3.2, 1.8, 0, 0)
          ..close();
        canvas.drawPath(leaf, _goldFill(leafRect.shift(-o)));
        canvas.drawPath(leaf, _line(kGold.withValues(alpha: 0.8), 0.35));
        canvas.restore();
      }
    }
    // Ribbon ends at the nape.
    for (final d in [-1.0, 1.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(50 + d * 18, 36)
            ..quadraticBezierTo(50 + d * 21, 44, 50 + d * 19, 50),
          _line(kGoldLight, 1.2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeverusPainter old) => old.talk != talk || old.blink != blink;
}

/// Medusa of Leptis Magna: a modest, regal marble portrait inspired by the
/// Severan Forum medallions: wavy hair, small temple wings, golden coiled
/// locks and an ornate diadem.
class _MedusaPainter extends CustomPainter {
  final double talk, blink;
  _MedusaPainter(this.talk, this.blink);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 100;
    canvas.save();
    canvas.translate((size.width - 100 * k) / 2, (size.height - 100 * k) / 2);
    canvas.scale(k);

    // Hair mass behind the head, falling to the shoulders.
    final back = Path()
      ..moveTo(50, 12)
      ..cubicTo(26, 12, 22, 36, 24, 52)
      ..cubicTo(25, 64, 22, 72, 28, 78)
      ..lineTo(72, 78)
      ..cubicTo(78, 72, 75, 64, 76, 52)
      ..cubicTo(78, 36, 74, 12, 50, 12)
      ..close();
    canvas.drawPath(back, _marbleFill(const Rect.fromLTWH(22, 12, 56, 66)));
    canvas.drawPath(back, _line(_marbleLine.withValues(alpha: 0.35), 0.6));

    _drawDrape(canvas, sash: false);
    _drawNeck(canvas);

    // Necklace with a gold medallion.
    canvas.drawPath(
        Path()
          ..moveTo(40, 75)
          ..quadraticBezierTo(50, 84, 60, 75),
        _line(kGoldLight, 1.0));
    for (var i = 0; i <= 6; i++) {
      final t = i / 6;
      final x = 40 + 20 * t;
      final y = 75 + 18 * t * (1 - t);
      canvas.drawCircle(Offset(x, y + 0.6), 0.9, Paint()..color = kGoldLight);
    }
    final med = Rect.fromCircle(center: const Offset(50, 82.5), radius: 3.4);
    canvas.drawCircle(med.center, 3.4, _goldFill(med));
    canvas.drawCircle(med.center, 1.4, Paint()..color = kRed);

    // Face.
    final head = Rect.fromCenter(center: const Offset(50, 42), width: 30, height: 40);
    canvas.drawOval(head, _marbleFill(head));

    // Wavy locks framing the face.
    final lock = _line(_marbleLine.withValues(alpha: 0.55), 0.9);
    for (final d in [-1.0, 1.0]) {
      for (var j = 0; j < 3; j++) {
        final x0 = 50 + d * (13 + j * 3.2);
        canvas.drawPath(
            Path()
              ..moveTo(x0, 26 + j * 2)
              ..cubicTo(x0 + d * 4, 38, x0 - d * 3, 50, x0 + d * 2, 62 + j * 4),
            lock);
      }
    }
    // Centre parting.
    canvas.drawPath(
        Path()
          ..moveTo(50, 22.5)
          ..quadraticBezierTo(42, 23, 36, 31)
          ..moveTo(50, 22.5)
          ..quadraticBezierTo(58, 23, 64, 31),
        _line(_marbleLine.withValues(alpha: 0.6), 1.0));

    // Golden coiled locks (stylised, jewel-like) at the sides.
    final goldStroke = _line(kGoldLight, 1.1);
    for (final o in const [Offset(28, 46), Offset(72, 46), Offset(29, 60), Offset(71, 60)]) {
      final spiral = Path();
      for (var i = 0; i <= 28; i++) {
        final a = i * 0.42;
        final r = 0.5 + i * 0.12;
        final p = o + Offset(r * math.cos(a), r * math.sin(a));
        i == 0 ? spiral.moveTo(p.dx, p.dy) : spiral.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(spiral, goldStroke);
    }

    // Small wings at the temples (as on the Severan medallions).
    for (final d in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(50 + d * 12, 24)
        ..cubicTo(50 + d * 18, 14, 50 + d * 25, 12, 50 + d * 27, 15)
        ..cubicTo(50 + d * 23, 16, 50 + d * 22, 18, 50 + d * 24, 19.5)
        ..cubicTo(50 + d * 20, 19.5, 50 + d * 19, 21, 50 + d * 20.5, 23)
        ..cubicTo(50 + d * 17, 23, 50 + d * 15, 24.5, 50 + d * 13, 27)
        ..close();
      canvas.drawPath(wing, _goldFill(const Rect.fromLTWH(22, 12, 56, 16)));
      canvas.drawPath(wing, _line(kGold, 0.5));
    }

    // Ornate diadem.
    final band = Path()
      ..moveTo(35, 29)
      ..quadraticBezierTo(50, 19, 65, 29);
    canvas.drawPath(band, _line(kGold, 3.2));
    canvas.drawPath(band, _line(kGoldPale.withValues(alpha: 0.8), 1.0));
    for (var i = 0; i < 5; i++) {
      final t = 0.1 + 0.8 * i / 4;
      final x = (1 - t) * (1 - t) * 35 + 2 * (1 - t) * t * 50 + t * t * 65;
      final y = (1 - t) * (1 - t) * 29 + 2 * (1 - t) * t * 19 + t * t * 29;
      final h = i == 2 ? 6.5 : 4.0;
      final petal = Path()
        ..moveTo(x - 1.8, y - 1)
        ..quadraticBezierTo(x, y - h * 1.4, x + 1.8, y - 1)
        ..close();
      canvas.drawPath(petal, _goldFill(Rect.fromLTWH(x - 2, y - h * 1.4, 4, h * 1.4)));
    }
    canvas.drawCircle(const Offset(50, 23.2), 1.6, Paint()..color = kRed);
    canvas.drawCircle(const Offset(50, 23.2), 1.6, _line(kGoldPale, 0.5));

    // Eyes, nose, lips.
    _drawEye(canvas, const Offset(44, 40), female: true, blink: blink);
    _drawEye(canvas, const Offset(56, 40), female: true, blink: blink);
    canvas.drawPath(
        Path()
          ..moveTo(50.4, 39)
          ..lineTo(49, 48)
          ..quadraticBezierTo(50.4, 49.2, 51.8, 48.4),
        _line(_marbleLine.withValues(alpha: 0.6), 0.8));
    final open = talk * 3.4;
    const lip = Color(0xFFB98A7E);
    canvas.drawPath(
        Path()
          ..moveTo(46, 53.4)
          ..quadraticBezierTo(48, 52, 50, 52.8)
          ..quadraticBezierTo(52, 52, 54, 53.4)
          ..quadraticBezierTo(50, 54.4 + open * 0.3, 46, 53.4)
          ..close(),
        Paint()..color = lip);
    if (open > 0.15) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(50, 54.2 + open / 2), width: 6, height: open),
          Paint()..color = const Color(0xFF5A3A34));
    }
    canvas.drawPath(
        Path()
          ..moveTo(46.4, 54.4 + open)
          ..quadraticBezierTo(50, 57 + open, 53.6, 54.4 + open),
        _line(lip, 1.4));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MedusaPainter old) => old.talk != talk || old.blink != blink;
}

// ───────────────────────── Animated talking bust ────────────────────────────

/// Marble bust in a gold medallion frame. While [active] it "speaks": the
/// mouth moves, the bust breathes deeper, a gold aura pulses and (with
/// [wave]) a gold equalizer waveform animates underneath.
class GuideBust extends StatefulWidget {
  final GuideId id;
  final double size;
  final bool active;
  final bool wave;
  const GuideBust(
      {super.key, required this.id, this.size = 120, this.active = false, this.wave = false});

  @override
  State<GuideBust> createState() => _GuideBustState();
}

class _GuideBustState extends State<GuideBust> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4800))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = widget.size;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final a = widget.active;
          final breathe = math.sin(t * 2 * math.pi * 2);
          final talk = a
              ? ((math.sin(t * 2 * math.pi * 26) + 1) / 2) *
                  (0.45 + 0.55 * math.sin(t * 2 * math.pi * 5).abs())
              : 0.0;
          // Blink once per cycle.
          final bt = (t * 4.8) % 4.8;
          final blink = bt < 0.14 ? math.sin(bt / 0.14 * math.pi) : 0.0;
          final glow = a ? 0.55 + 0.25 * math.sin(t * 2 * math.pi * 6) : 0.18;
          final painter = widget.id == GuideId.severus
              ? _SeverusPainter(talk, blink)
              : _MedusaPainter(talk, blink);
          final bust = SizedBox(
            width: sz,
            height: sz,
            child: Stack(alignment: Alignment.center, children: [
              // Aura.
              Container(
                width: sz,
                height: sz,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    kGoldLight.withValues(alpha: 0.30 * glow),
                    kGold.withValues(alpha: 0.10 * glow),
                    Colors.transparent,
                  ], stops: const [0.55, 0.8, 1]),
                  boxShadow: [
                    BoxShadow(
                        color: kGold.withValues(alpha: 0.45 * glow),
                        blurRadius: sz * 0.16,
                        spreadRadius: a ? sz * 0.02 : 0),
                  ],
                ),
              ),
              // Medallion with the bust.
              Container(
                width: sz * 0.9,
                height: sz * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                      colors: [Color(0xFF4A1218), kWine, kObsidian],
                      stops: [0, 0.7, 1]),
                  border: Border.all(
                      color: kGoldLight.withValues(alpha: a ? 1 : 0.75),
                      width: sz * 0.022),
                ),
                child: ClipOval(
                  child: Transform.translate(
                    offset: Offset(0, -breathe * sz * (a ? 0.012 : 0.006)),
                    child: Transform.scale(
                      scale: 1.14 + breathe * (a ? 0.018 : 0.008),
                      alignment: Alignment.bottomCenter,
                      child: CustomPaint(size: Size.square(sz * 0.9), painter: painter),
                    ),
                  ),
                ),
              ),
              // Outer pulsing ring.
              if (a)
                Container(
                  width: sz * (0.94 + 0.05 * ((t * 6) % 1)),
                  height: sz * (0.94 + 0.05 * ((t * 6) % 1)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: kGoldLight.withValues(alpha: 0.6 * (1 - (t * 6) % 1)),
                        width: 1.5),
                  ),
                ),
            ]),
          );
          if (!widget.wave) return bust;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            bust,
            const SizedBox(height: 6),
            GoldWaveform(t: t, active: a, width: sz),
          ]);
        },
      ),
    );
  }
}

/// Gold equalizer bars ("موجات صوتية ذهبية"), driven by the bust's clock.
class GoldWaveform extends StatelessWidget {
  final double t;
  final bool active;
  final double width;
  final int bars;
  const GoldWaveform(
      {super.key, required this.t, required this.active, this.width = 110, this.bars = 13});

  @override
  Widget build(BuildContext context) {
    final bw = width / (bars * 1.8);
    return SizedBox(
      width: width,
      height: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < bars; i++)
            Container(
              width: bw,
              height: active
                  ? 4 +
                      17 *
                          (math.sin(t * 2 * math.pi * (9 + i % 4) + i * 0.9).abs() *
                              (1 - (i - bars / 2).abs() / bars))
                  : 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(bw),
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kGoldPale, kGoldLight, kGold]),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Persona selection screen ─────────────────────────

class GuidePicker extends StatelessWidget {
  final AppState state;
  final ValueChanged<GuideId> onPick;
  const GuidePicker({super.key, required this.state, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final cards = [
      for (final g in kGuides.values) _GuideCard(state: s, guide: g, onPick: onPick),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        const Center(child: ArchEmblem(size: 44)),
        const SizedBox(height: 10),
        Text(s.t('اختر مرشدك التاريخي في هذه الجولة', 'Choose your historical guide for this journey'),
            textAlign: TextAlign.center, style: titleStyle(21)),
        const SizedBox(height: 6),
        Text(s.t('المرشد الأثري الذكي', 'AI Heritage Guide'),
            textAlign: TextAlign.center,
            style: captionStyle(13).copyWith(color: inkGold)),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (context, c) {
          if (c.maxWidth >= 640) {
            return IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
              ]),
            );
          }
          return Column(children: [cards[0], const SizedBox(height: 16), cards[1]]);
        }),
        const SizedBox(height: 14),
        Text(
            s.t('محاكاة بالذكاء الاصطناعي مستوحاة من التاريخ — تحقّق من المعلومات المهمة.',
                'AI role-play inspired by history — verify key facts.'),
            textAlign: TextAlign.center,
            style: captionStyle(11.5)),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final AppState state;
  final GuideProfile guide;
  final ValueChanged<GuideId> onPick;
  const _GuideCard({required this.state, required this.guide, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final sev = guide.id == GuideId.severus;
    return Semantics(
      button: true,
      label: guide.cta(s),
      child: TapScale(
        onTap: () => onPick(guide.id),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: kGold.withValues(alpha: 0.55), width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [heroTop, surfaceColor],
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: gLight ? 0.08 : 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GuideBust(id: guide.id, size: 132),
            const SizedBox(height: 12),
            Text(guide.name(s), textAlign: TextAlign.center, style: titleStyle(19)),
            const SizedBox(height: 8),
            Pill(guide.badge(s),
                icon: sev ? Icons.military_tech_outlined : Icons.auto_awesome_outlined),
            const SizedBox(height: 10),
            Text(guide.desc(s),
                textAlign: TextAlign.center, style: subStyle(14).copyWith(height: 1.6)),
            const SizedBox(height: 14),
            GoldButton(
              height: 48,
              red: !sev,
              icon: Icons.forum_outlined,
              label: guide.cta(s),
              onPressed: () => onPick(guide.id),
            ),
          ]),
        ),
      ),
    );
  }
}
