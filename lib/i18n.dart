part of 'main.dart';

// ─────────────────────────────── i18n ───────────────────────────────────────
// 8-language engine. Arabic and English live inline at each call site
// (`s.t('عربي', 'English')`); the six other languages are looked up here by
// the English string. Anything not in a table falls back to English, so a
// missing entry can never crash or blank the UI.

/// (code, native name, Arabic name, flag)
const kLanguages = <(String, String, String, String)>[
  ('ar', 'العربية', 'العربية', '🇱🇾'),
  ('en', 'English', 'الإنجليزية', '🇬🇧'),
  ('it', 'Italiano', 'الإيطالية', '🇮🇹'),
  ('fr', 'Français', 'الفرنسية', '🇫🇷'),
  ('tr', 'Türkçe', 'التركية', '🇹🇷'),
  ('zh', '中文', 'الصينية', '🇨🇳'),
  ('ru', 'Русский', 'الروسية', '🇷🇺'),
  ('ja', '日本語', 'اليابانية', '🇯🇵'),
];

const kLangCodes = ['ar', 'en', 'it', 'fr', 'tr', 'zh', 'ru', 'ja'];

/// Current UI language, set by ErthApp on every rebuild (like [gLight]).
String gLang = 'ar';

/// Translate an English UI string into the current non-Arabic language.
String L(String en) {
  if (gLang == 'en' || gLang == 'ar') return en;
  return kI18n[gLang]?[en] ?? en;
}

/// Pick Arabic or the localized English string, usable without an AppState.
String tr(String ar, String en) => gLang == 'ar' ? ar : L(en);

String langNative(String code) =>
    kLanguages.firstWhere((l) => l.$1 == code, orElse: () => kLanguages[1]).$2;

// Columns: it, fr, tr, zh, ru, ja
const _rows = <String, List<String>>{
  // ── brand ──
  'Libyan Heritage Platform': ['Piattaforma del Patrimonio Libico', 'Plateforme du Patrimoine Libyen', 'Libya Miras Platformu', '利比亚遗产平台', 'Платформа ливийского наследия', 'リビア遺産プラットフォーム'],
  'ERTH - Libyan Heritage Platform': ['ERTH - Piattaforma del Patrimonio Libico', 'ERTH - Plateforme du Patrimoine Libyen', 'ERTH - Libya Miras Platformu', 'ERTH - 利比亚遗产平台', 'ERTH - Платформа ливийского наследия', 'ERTH - リビア遺産プラットフォーム'],
  'Languages': ['Lingue', 'Langues', 'Diller', '语言', 'Языки', '言語'],
  'Language': ['Lingua', 'Langue', 'Dil', '语言', 'Язык', '言語'],
  'Choose your language': ['Scegli la tua lingua', 'Choisissez votre langue', 'Dilinizi seçin', '选择您的语言', 'Выберите язык', '言語を選択してください'],
  // ── top controls ──
  'Download app': ['Scarica l\'app', 'Télécharger l\'app', 'Uygulamayı indir', '下载应用', 'Скачать приложение', 'アプリをダウンロード'],
  'Account': ['Account', 'Compte', 'Hesap', '账户', 'Аккаунт', 'アカウント'],
  'Switch account': ['Cambia account', 'Changer de compte', 'Hesap değiştir', '切换账户', 'Сменить аккаунт', 'アカウント切替'],
  'Register new account': ['Registra un nuovo account', 'Créer un nouveau compte', 'Yeni hesap oluştur', '注册新账户', 'Зарегистрировать новый аккаунт', '新規アカウント登録'],
  'Log out': ['Esci', 'Se déconnecter', 'Çıkış yap', '退出登录', 'Выйти', 'ログアウト'],
  'Light mode': ['Modalità chiara', 'Mode clair', 'Açık mod', '浅色模式', 'Светлая тема', 'ライトモード'],
  'Dark mode': ['Modalità scura', 'Mode sombre', 'Koyu mod', '深色模式', 'Тёмная тема', 'ダークモード'],
  // ── auth ──
  'Required': ['Obbligatorio', 'Obligatoire', 'Zorunlu', '必填', 'Обязательно', '必須'],
  'Login': ['Accedi', 'Connexion', 'Giriş', '登录', 'Вход', 'ログイン'],
  'Register': ['Registrati', 'S\'inscrire', 'Kayıt ol', '注册', 'Регистрация', '登録'],
  'Visitor': ['Turista / Visitatore', 'Touriste / Visiteur', 'Turist / Ziyaretçi', '游客 / 访客', 'Турист / Посетитель', '観光客 / 訪問者'],
  'Conservator': ['Restauratore certificato', 'Restaurateur certifié', 'Sertifikalı restoratör', '认证文物修复师', 'Сертифицированный реставратор', '認定修復士'],
  'Admin': ['Amministratore di sistema', 'Administrateur système', 'Sistem yöneticisi', '系统管理员', 'Системный администратор', 'システム管理者'],
  'Enter the administrator email and password, or use the quick login button below.': ['Inserisci email e password dell\'amministratore oppure usa il pulsante di accesso rapido qui sotto.', 'Saisissez l\'e-mail et le mot de passe administrateur, ou utilisez le bouton de connexion rapide ci-dessous.', 'Yönetici e-postasını ve şifresini girin veya aşağıdaki hızlı giriş düğmesini kullanın.', '请输入管理员邮箱和密码，或使用下方的快速登录按钮。', 'Введите e-mail и пароль администратора или воспользуйтесь кнопкой быстрого входа ниже.', '管理者のメールアドレスとパスワードを入力するか、下のクイックログインボタンを使用してください。'],
  'Full name': ['Nome completo', 'Nom complet', 'Ad soyad', '全名', 'Полное имя', '氏名'],
  'Invalid email': ['Email non valida', 'E-mail invalide', 'Geçersiz e-posta', '邮箱无效', 'Неверный e-mail', '無効なメールアドレス'],
  'Email': ['Email', 'E-mail', 'E-posta', '电子邮箱', 'Эл. почта', 'メールアドレス'],
  'City / phone': ['Città / telefono', 'Ville / téléphone', 'Şehir / telefon', '城市 / 电话', 'Город / телефон', '都市 / 電話'],
  'At least 6 characters': ['Almeno 6 caratteri', 'Au moins 6 caractères', 'En az 6 karakter', '至少 6 个字符', 'Не менее 6 символов', '6文字以上'],
  'Password': ['Password', 'Mot de passe', 'Şifre', '密码', 'Пароль', 'パスワード'],
  'Passwords do not match': ['Le password non coincidono', 'Les mots de passe ne correspondent pas', 'Şifreler eşleşmiyor', '两次密码不一致', 'Пароли не совпадают', 'パスワードが一致しません'],
  'Confirm password': ['Conferma password', 'Confirmer le mot de passe', 'Şifreyi onayla', '确认密码', 'Подтвердите пароль', 'パスワード確認'],
  'Academic specialization': ['Specializzazione accademica', 'Spécialisation académique', 'Akademik uzmanlık', '学术专业', 'Научная специализация', '専門分野'],
  'Membership / license no.': ['N. iscrizione / licenza', 'N° d\'adhésion / licence', 'Üyelik / lisans no.', '会员 / 执照编号', '№ членства / лицензии', '会員 / 資格番号'],
  'Create account': ['Crea account', 'Créer un compte', 'Hesap oluştur', '创建账户', 'Создать аккаунт', 'アカウント作成'],
  'Demo admin quick login': ['Accesso rapido admin demo', 'Connexion rapide admin démo', 'Demo yönetici hızlı giriş', '演示管理员快速登录', 'Быстрый вход демо-админа', 'デモ管理者クイックログイン'],
  'Quick demo access': ['Accesso demo rapido', 'Accès démo rapide', 'Hızlı demo girişi', '快速演示登录', 'Быстрый демо-вход', 'クイックデモログイン'],
  'Quick login: System admin': ['Accesso rapido: Amministratore', 'Connexion rapide : Administrateur', 'Hızlı giriş: Sistem yöneticisi', '快速登录：系统管理员', 'Быстрый вход: администратор', 'クイックログイン：システム管理者'],
  // ── shell / navigation ──
  'Add restoration report': ['Aggiungi rapporto di restauro', 'Ajouter un rapport de restauration', 'Restorasyon raporu ekle', '添加修复报告', 'Добавить отчёт о реставрации', '修復レポートを追加'],
  'AI Heritage Guide': ['Guida AI del patrimonio', 'Guide IA du patrimoine', 'Yapay zekâ miras rehberi', 'AI 遗产导览', 'ИИ-гид по наследию', 'AI遺産ガイド'],
  'Home': ['Home', 'Accueil', 'Ana sayfa', '首页', 'Главная', 'ホーム'],
  'Sites': ['Siti', 'Sites', 'Alanlar', '遗址', 'Объекты', '遺跡'],
  'Scanner': ['Scanner', 'Scanner', 'Tarayıcı', '扫描仪', 'Сканер', 'スキャナー'],
  'Logs': ['Registro restauri', 'Journal de restauration', 'Restorasyon kaydı', '修复日志', 'Журнал реставрации', '修復記録'],
  'Explore': ['Siti', 'Sites', 'Alanlar', '遗址', 'Объекты', '遺跡'],
  'AI guide': ['Guida smart', 'Guide intelligent', 'Akıllı rehber', '智能导览', 'Умный гид', 'スマートガイド'],
  'Overview': ['Panoramica', 'Aperçu', 'Genel bakış', '概览', 'Обзор', '概要'],
  'Reports': ['Rapporti', 'Rapports', 'Raporlar', '报告', 'Отчёты', 'レポート'],
  'Content': ['Contenuti', 'Contenu', 'İçerik', '内容', 'Контент', 'コンテンツ'],
  'Add site': ['Aggiungi sito', 'Ajouter un site', 'Alan ekle', '添加遗址', 'Добавить объект', '遺跡を追加'],
  // ── home ──
  'Local mode: showing demo data, not synced with the server.': ['Modalità locale: dati demo, non sincronizzati con il server.', 'Mode local : données de démonstration, non synchronisées avec le serveur.', 'Yerel mod: demo verileri gösteriliyor, sunucuyla eşitlenmedi.', '本地模式：显示演示数据，未与服务器同步。', 'Локальный режим: демо-данные, без синхронизации с сервером.', 'ローカルモード：デモデータを表示中（サーバー未同期）。'],
  'Welcome': ['Benvenuto', 'Bienvenue', 'Hoş geldiniz', '欢迎', 'Добро пожаловать', 'ようこそ'],
  'Guest': ['Ospite', 'Invité', 'Misafir', '访客', 'Гость', 'ゲスト'],
  'Restoration and equipment dashboard': ['Pannello restauro e attrezzature', 'Tableau de bord restauration et équipement', 'Restorasyon ve ekipman paneli', '修复与设备面板', 'Панель реставрации и оборудования', '修復・機材ダッシュボード'],
  'Maintenance mode: some updates may be temporarily delayed.': ['Modalità manutenzione: alcuni aggiornamenti potrebbero subire ritardi.', 'Mode maintenance : certaines mises à jour peuvent être retardées.', 'Bakım modu: bazı güncellemeler geçici olarak gecikebilir.', '维护模式：部分更新可能暂时延迟。', 'Режим обслуживания: некоторые обновления могут задерживаться.', 'メンテナンス中：一部の更新が遅れる場合があります。'],
  'Evaluation build: some data and results are for demonstration only.': ['Versione di valutazione: alcuni dati e risultati sono solo dimostrativi.', 'Version d\'évaluation : certaines données sont uniquement démonstratives.', 'Değerlendirme sürümü: bazı veriler yalnızca gösterim amaçlıdır.', '评估版本：部分数据和结果仅供演示。', 'Ознакомительная версия: часть данных только для демонстрации.', '評価版：一部のデータと結果はデモ用です。'],
  'Approved reports': ['Rapporti approvati', 'Rapports approuvés', 'Onaylı raporlar', '已批准报告', 'Одобренные отчёты', '承認済みレポート'],
  'Sites in treatment': ['Siti in restauro', 'Sites en traitement', 'Tedavideki alanlar', '修复中的遗址', 'Объекты на реставрации', '修復中の遺跡'],
  'Urgent alerts': ['Allerte urgenti', 'Alertes urgentes', 'Acil uyarılar', '紧急警报', 'Срочные оповещения', '緊急アラート'],
  'Sites in catalog': ['Siti in catalogo', 'Sites au catalogue', 'Katalogdaki alanlar', '目录中的遗址', 'Объекты в каталоге', '登録遺跡数'],
  'UNESCO sites': ['Siti UNESCO', 'Sites UNESCO', 'UNESCO alanları', '联合国教科文组织遗址', 'Объекты ЮНЕСКО', 'ユネスコ遺産'],
  'Stories': ['Storie', 'Récits', 'Hikâyeler', '故事', 'Истории', 'ストーリー'],
  'Equipment & artifact scanner': ['Scanner attrezzature e reperti', 'Scanner d\'équipement et d\'artefacts', 'Ekipman ve eser tarayıcı', '设备与文物扫描仪', 'Сканер оборудования и артефактов', '機材・遺物スキャナー'],
  'Sites needing attention': ['Siti che richiedono attenzione', 'Sites nécessitant une attention', 'İlgi gerektiren alanlar', '需要关注的遗址', 'Объекты, требующие внимания', '要注意の遺跡'],
  'Featured sites': ['Siti in evidenza', 'Sites à la une', 'Öne çıkan alanlar', '精选遗址', 'Избранные объекты', '注目の遺跡'],
  'Browse all {n} sites': ['Sfoglia tutti i {n} siti', 'Parcourir les {n} sites', '{n} alanın tümüne göz at', '浏览全部 {n} 个遗址', 'Все объекты ({n})', '全{n}件の遺跡を見る'],
  'Search heritage sites...': ['Cerca siti del patrimonio...', 'Rechercher des sites...', 'Miras alanlarını ara...', '搜索遗产遗址...', 'Поиск объектов наследия...', '遺産を検索...'],
  'No matching sites': ['Nessun sito trovato', 'Aucun site correspondant', 'Eşleşen alan yok', '没有匹配的遗址', 'Ничего не найдено', '該当する遺跡はありません'],
  'UNESCO World Heritage': ['Patrimonio mondiale UNESCO', 'Patrimoine mondial de l\'UNESCO', 'UNESCO Dünya Mirası', '联合国教科文组织世界遗产', 'Всемирное наследие ЮНЕСКО', 'ユネスコ世界遺産'],
  // ── quiz & recommendations ──
  'Heritage interests quiz': ['Quiz sui tuoi interessi', 'Quiz de vos intérêts patrimoniaux', 'Miras ilgi alanları testi', '遗产兴趣问卷', 'Тест интересов', '遺産の興味診断'],
  'Question {q} of {n}': ['Domanda {q} di {n}', 'Question {q} sur {n}', 'Soru {q} / {n}', '第 {q} 题，共 {n} 题', 'Вопрос {q} из {n}', '質問 {q} / {n}'],
  'Q{q}': ['D{q}', 'Q{q}', 'S{q}', '问{q}', 'В{q}', 'Q{q}'],
  'Cancel': ['Annulla', 'Annuler', 'İptal', '取消', 'Отмена', 'キャンセル'],
  'Your heritage persona: ': ['Il tuo profilo: ', 'Votre profil : ', 'Miras kişiliğiniz: ', '您的遗产人格：', 'Ваш профиль: ', 'あなたのタイプ：'],
  'Retake my interests': ['Rifai il quiz', 'Refaire le quiz', 'Testi yeniden yap', '重新测试', 'Пройти заново', 'もう一度診断する'],
  'Recommended for You': ['Consigliati per te', 'Recommandés pour vous', 'Size önerilenler', '为您推荐', 'Рекомендуем вам', 'あなたへのおすすめ'],
  'You have not taken the quiz yet': ['Non hai ancora fatto il quiz', 'Vous n\'avez pas encore fait le quiz', 'Henüz testi yapmadınız', '您尚未完成问卷', 'Вы ещё не прошли тест', 'まだ診断していません'],
  'Start the quiz': ['Inizia il quiz', 'Commencer le quiz', 'Teste başla', '开始问卷', 'Начать тест', '診断を始める'],
  // ── scanner / logs ──
  'Equipment & Artifact Scanner': ['Scanner attrezzature e reperti', 'Scanner d\'équipement et d\'artefacts', 'Ekipman ve eser tarayıcı', '设备与文物扫描仪', 'Сканер оборудования и артефактов', '機材・遺物スキャナー'],
  'Equipment & materials': ['Attrezzature e materiali', 'Équipement et matériaux', 'Ekipman ve malzemeler', '设备与材料', 'Оборудование и материалы', '機材・材料'],
  'Artifact diagnosis': ['Diagnosi del reperto', 'Diagnostic de l\'artefact', 'Eser teşhisi', '文物诊断', 'Диагностика артефакта', '遺物診断'],
  'Scanning...': ['Scansione...', 'Analyse...', 'Taranıyor...', '扫描中...', 'Сканирование...', 'スキャン中...'],
  'Take photo': ['Scatta foto', 'Prendre une photo', 'Fotoğraf çek', '拍照', 'Сделать фото', '写真を撮る'],
  'Upload photo': ['Carica foto', 'Importer une photo', 'Fotoğraf yükle', '上传照片', 'Загрузить фото', '写真をアップロード'],
  'Live scan (simulated)': ['Scansione live (simulata)', 'Scan en direct (simulé)', 'Canlı tarama (simülasyon)', '实时扫描（模拟）', 'Живое сканирование (симуляция)', 'ライブスキャン（シミュレーション）'],
  'Damage severity': ['Gravità del danno', 'Gravité des dégâts', 'Hasar şiddeti', '损坏程度', 'Степень повреждения', '損傷度'],
  'Recommended treatment': ['Trattamento consigliato', 'Traitement recommandé', 'Önerilen tedavi', '推荐处理方法', 'Рекомендуемая обработка', '推奨処置'],
  'Restoration log': ['Registro restauri', 'Journal de restauration', 'Restorasyon kaydı', '修复日志', 'Журнал реставрации', '修復記録'],
  '{n} technical reports': ['{n} rapporti tecnici', '{n} rapports techniques', '{n} teknik rapor', '{n} 份技术报告', 'Технических отчётов: {n}', '技術レポート {n}件'],
  'No reports yet': ['Ancora nessun rapporto', 'Aucun rapport pour l\'instant', 'Henüz rapor yok', '暂无报告', 'Отчётов пока нет', 'レポートはまだありません'],
  'Monument name': ['Nome del monumento', 'Nom du monument', 'Anıt adı', '古迹名称', 'Название памятника', '遺跡名'],
  'Save report': ['Salva rapporto', 'Enregistrer le rapport', 'Raporu kaydet', '保存报告', 'Сохранить отчёт', 'レポートを保存'],
  // ── account ──
  'Profile saved': ['Profilo salvato', 'Profil enregistré', 'Profil kaydedildi', '资料已保存', 'Профиль сохранён', 'プロフィールを保存しました'],
  'Change password': ['Cambia password', 'Changer le mot de passe', 'Şifreyi değiştir', '修改密码', 'Сменить пароль', 'パスワード変更'],
  'New password': ['Nuova password', 'Nouveau mot de passe', 'Yeni şifre', '新密码', 'Новый пароль', '新しいパスワード'],
  'Password changed': ['Password modificata', 'Mot de passe modifié', 'Şifre değiştirildi', '密码已修改', 'Пароль изменён', 'パスワードを変更しました'],
  'Save': ['Salva', 'Enregistrer', 'Kaydet', '保存', 'Сохранить', '保存'],
  'Name': ['Nome', 'Nom', 'Ad', '姓名', 'Имя', '名前'],
  'Title / specialty': ['Titolo / specialità', 'Titre / spécialité', 'Unvan / uzmanlık', '职称 / 专长', 'Должность / специальность', '肩書き / 専門'],
  'Bio': ['Biografia', 'Bio', 'Biyografi', '简介', 'О себе', '自己紹介'],
  'Save changes': ['Salva modifiche', 'Enregistrer les modifications', 'Değişiklikleri kaydet', '保存更改', 'Сохранить изменения', '変更を保存'],
  'Account type': ['Tipo di account', 'Type de compte', 'Hesap türü', '账户类型', 'Тип аккаунта', 'アカウント種別'],
  'License ID': ['ID licenza', 'N° de licence', 'Lisans no.', '执照编号', 'Номер лицензии', '資格ID'],
  'My heritage interests': ['I miei interessi', 'Mes intérêts patrimoniaux', 'Miras ilgi alanlarım', '我的遗产兴趣', 'Мои интересы', '私の興味'],
  'Preferences': ['Preferenze', 'Préférences', 'Tercihler', '偏好设置', 'Настройки', '設定'],
  'Notifications': ['Notifiche', 'Notifications', 'Bildirimler', '通知', 'Уведомления', '通知'],
  'Light mode (glossy beige)': ['Modalità chiara (beige lucido)', 'Mode clair (beige brillant)', 'Açık mod (parlak bej)', '浅色模式（亮米色）', 'Светлая тема (глянцевый беж)', 'ライトモード（光沢ベージュ）'],
  'Install app': ['Installa l\'app', 'Installer l\'app', 'Uygulamayı yükle', '安装应用', 'Установить приложение', 'アプリをインストール'],
  'Install ERTH on your home screen for faster access without a browser.': ['Installa ERTH nella schermata Home per un accesso più rapido senza browser.', 'Installez ERTH sur votre écran d\'accueil pour un accès plus rapide sans navigateur.', 'Tarayıcısız, daha hızlı erişim için ERTH\'i ana ekranınıza yükleyin.', '将 ERTH 安装到主屏幕，无需浏览器即可快速访问。', 'Установите ERTH на главный экран для быстрого доступа без браузера.', 'ERTHをホーム画面に追加すると、ブラウザなしですばやく開けます。'],
  'Security': ['Sicurezza', 'Sécurité', 'Güvenlik', '安全', 'Безопасность', 'セキュリティ'],
  'Privacy & data': ['Privacy e dati', 'Confidentialité et données', 'Gizlilik ve veriler', '隐私与数据', 'Конфиденциальность и данные', 'プライバシーとデータ'],
  'Privacy Policy & Terms of Use': ['Informativa privacy e Termini d\'uso', 'Politique de confidentialité et conditions d\'utilisation', 'Gizlilik Politikası ve Kullanım Koşulları', '隐私政策与使用条款', 'Политика конфиденциальности и условия', 'プライバシーポリシーと利用規約'],
  'Delete account & data': ['Elimina account e dati', 'Supprimer le compte et les données', 'Hesabı ve verileri sil', '删除账户和数据', 'Удалить аккаунт и данные', 'アカウントとデータを削除'],
  // ── chat ──
  'Tell me about Leptis Magna': ['Parlami di Leptis Magna', 'Parle-moi de Leptis Magna', 'Bana Leptis Magna\'yı anlat', '介绍一下大莱普提斯', 'Расскажи о Лептис-Магне', 'レプティス・マグナについて教えて'],
  'What is Paraloid B-72?': ['Cos\'è il Paraloid B-72?', 'Qu\'est-ce que le Paraloid B-72 ?', 'Paraloid B-72 nedir?', '什么是 Paraloid B-72？', 'Что такое Paraloid B-72?', 'Paraloid B-72とは？'],
  'How do I treat salt efflorescence?': ['Come si tratta l\'efflorescenza salina?', 'Comment traiter les efflorescences salines ?', 'Tuz çiçeklenmesi nasıl tedavi edilir?', '如何处理盐析？', 'Как лечить солевые высолы?', '塩類風化はどう処置する？'],
  'Local reply (offline)': ['Risposta locale (offline)', 'Réponse locale (hors ligne)', 'Yerel yanıt (çevrimdışı)', '本地回复（离线）', 'Локальный ответ (офлайн)', 'ローカル回答（オフライン）'],
  'Type your question...': ['Scrivi la tua domanda...', 'Posez votre question...', 'Sorunuzu yazın...', '输入您的问题...', 'Введите вопрос...', '質問を入力...'],
  // ── install ──
  'Installing the app...': ['Installazione dell\'app...', 'Installation de l\'app...', 'Uygulama yükleniyor...', '正在安装应用...', 'Установка приложения...', 'アプリをインストール中...'],
  'How to install ERTH': ['Come installare ERTH', 'Comment installer ERTH', 'ERTH nasıl yüklenir', '如何安装 ERTH', 'Как установить ERTH', 'ERTHのインストール方法'],
  'Got it': ['Ho capito', 'Compris', 'Anladım', '知道了', 'Понятно', '了解'],
  'Install ERTH App': ['Installa l\'app ERTH', 'Installer l\'app ERTH', 'ERTH uygulamasını yükle', '安装 ERTH 应用', 'Установить ERTH', 'ERTHアプリをインストール'],
  'Download & install now': ['Scarica e installa ora', 'Télécharger et installer', 'Şimdi indir ve yükle', '立即下载安装', 'Скачать и установить', '今すぐインストール'],
  'Continue on the web for now': ['Continua sul web per ora', 'Continuer sur le web pour l\'instant', 'Şimdilik web\'de devam et', '暂时继续使用网页版', 'Пока продолжить в браузере', '今はWebで続ける'],
  // ── legal ──
  'By continuing you agree to the ': ['Continuando accetti i ', 'En continuant, vous acceptez les ', 'Devam ederek şunları kabul edersiniz: ', '继续即表示您同意', 'Продолжая, вы принимаете ', '続行すると、次に同意したことになります：'],
  'Terms of Use': ['Termini d\'uso', 'Conditions d\'utilisation', 'Kullanım Koşulları', '使用条款', 'Условия использования', '利用規約'],
  'Privacy Policy': ['Informativa sulla privacy', 'Politique de confidentialité', 'Gizlilik Politikası', '隐私政策', 'Политика конфиденциальности', 'プライバシーポリシー'],
  // ── status labels ──
  'Good condition': ['Buono stato', 'Bon état', 'İyi durumda', '状况良好', 'Хорошее состояние', '良好'],
  'Needs care': ['Richiede cure', 'Nécessite un entretien', 'Bakım gerekli', '需要维护', 'Требует ухода', '要手入れ'],
  'Under treatment': ['In restauro', 'En traitement', 'Tedavi altında', '修复中', 'На реставрации', '修復中'],
  'Urgent alert': ['Allerta urgente', 'Alerte urgente', 'Acil uyarı', '紧急警报', 'Срочное оповещение', '緊急警告'],
  'Pending review': ['In attesa di revisione', 'En attente de validation', 'İnceleme bekliyor', '待审核', 'Ожидает проверки', 'レビュー待ち'],
  'Approved': ['Approvato', 'Approuvé', 'Onaylandı', '已批准', 'Одобрено', '承認済み'],
  'Needs revision': ['Da rivedere', 'À réviser', 'Düzeltme gerekli', '需修改', 'Требует доработки', '要修正'],
  'Archived': ['Archiviato', 'Archivé', 'Arşivlendi', '已归档', 'В архиве', 'アーカイブ済み'],
  'Photo gallery': ['Galleria fotografica', 'Galerie photos', 'Fotoğraf galerisi', '图片库', 'Фотогалерея', 'フォトギャラリー'],
  'Historical Origins & Chronology': ['Origini e cronologia storica', 'Origines et chronologie', 'Tarihsel köken ve kronoloji', '历史起源与年表', 'Происхождение и хронология', '歴史的起源と年表'],
  'Architecture & Engineering': ['Architettura e ingegneria', 'Architecture et ingénierie', 'Mimari ve mühendislik', '建筑与工程', 'Архитектура и инженерия', '建築と工学'],
  'Cultural & Global Significance': ['Importanza culturale e mondiale', 'Portée culturelle et mondiale', 'Kültürel ve küresel önem', '文化与世界意义', 'Культурное и мировое значение', '文化的・世界的意義'],
  'UNESCO': ['UNESCO', 'UNESCO', 'UNESCO', '联合国教科文组织', 'ЮНЕСКО', 'ユネスコ'],
};

/// lang → (English → translation), built once from [_rows].
final Map<String, Map<String, String>> kI18n = () {
  const cols = ['it', 'fr', 'tr', 'zh', 'ru', 'ja'];
  final out = {for (final c in cols) c: <String, String>{}};
  for (final e in [..._rows.entries, ..._guideRows.entries]) {
    final en = e.key, v = e.value;
    for (var i = 0; i < cols.length && i < v.length; i++) {
      out[cols[i]]![en] = v[i];
    }
  }
  return out;
}();

// ── Tourist quiz (default questions) — every language except Arabic ──
const kQuizI18n = <String, List<(String, List<String>)>>{
  'en': [
    ('What catches your eye first when you see an artifact?', [
      'The detail of its carvings, the beauty of its design and its fine craftsmanship.',
      'The historical secret or mystery behind the piece.',
      'How it was used in daily life or in old folk practices.',
      'The engineering or technological innovation behind it.',
    ]),
    ('If you could read just one book about antiquities, which would you choose?', [
      '“The Finest Artworks and Sculptures of the Ancient World”.',
      '“The Greatest Archaeological Mysteries and Lost Tombs in History”.',
      '“Diary of an Ancient Person: How Ordinary People Lived”.',
      '“The Genius of Ancient Architecture: From Pyramids to Dams”.',
    ]),
    ('What kind of archaeological site do you dream of exploring?', [
      'A temple or palace full of statues, paintings and ornaments.',
      'A lost city under the sea or an excavation full of mystery.',
      'A whole ancient village showing how people cooked, dressed and lived.',
      'Ancient irrigation channels, Roman theatres with stunning acoustics, or road networks.',
    ]),
    ('Which of these questions sparks your curiosity most?', [
      'How did the ancient artist carve such fine details without modern tools?',
      'What happened to this civilisation that made it vanish suddenly?',
      'How did ancient families celebrate, heal and trade goods?',
      'How were these huge stones brought and raised without modern machines?',
    ]),
  ],
  'it': [
    ('Cosa ti colpisce per primo quando vedi un reperto?', [
      'I dettagli delle incisioni, la bellezza del design e la finezza della lavorazione.',
      'Il segreto storico o il mistero che si cela dietro il pezzo.',
      'Come veniva usato nella vita quotidiana o nelle antiche pratiche popolari.',
      'L\'innovazione ingegneristica o tecnologica della sua creazione.',
    ]),
    ('Se potessi leggere un solo libro di archeologia, quale sceglieresti?', [
      '«Le più belle opere d\'arte e sculture del mondo antico».',
      '«I più grandi misteri archeologici e le tombe perdute della storia».',
      '«Diario di un uomo antico: come viveva la gente comune?».',
      '«Il genio dell\'architettura antica: dalle piramidi alle dighe».',
    ]),
    ('Quale tipo di sito archeologico sogni di esplorare?', [
      'Un tempio o un palazzo pieno di statue, dipinti e decorazioni.',
      'Una città perduta sotto il mare o uno scavo pieno di mistero.',
      'Un intero villaggio antico che mostra come si cucinava, vestiva e viveva.',
      'Antichi canali d\'irrigazione, teatri romani dall\'acustica straordinaria o reti stradali.',
    ]),
    ('Quale di queste domande stimola di più la tua curiosità?', [
      'Come riusciva l\'artista antico a scolpire dettagli così fini senza strumenti moderni?',
      'Cosa accadde a questa civiltà da farla scomparire all\'improvviso?',
      'Come festeggiavano, si curavano e commerciavano le famiglie antiche?',
      'Come furono trasportate e sollevate queste enormi pietre senza macchine moderne?',
    ]),
  ],
  'fr': [
    ('Qu\'est-ce qui attire d\'abord votre regard devant un artefact ?', [
      'Le détail de ses gravures, la beauté de son design et la finesse de sa fabrication.',
      'Le secret historique ou l\'énigme qui se cache derrière la pièce.',
      'Son usage dans la vie quotidienne ou les anciennes pratiques populaires.',
      'L\'innovation technique ou technologique de sa conception.',
    ]),
    ('Si vous ne pouviez lire qu\'un seul livre d\'archéologie, lequel choisiriez-vous ?', [
      '« Les plus beaux chefs-d\'œuvre et sculptures du monde antique ».',
      '« Les plus grandes énigmes archéologiques et tombes perdues de l\'histoire ».',
      '« Journal d\'un homme antique : comment vivaient les gens ordinaires ? ».',
      '« Le génie de l\'architecture antique : des pyramides aux barrages ».',
    ]),
    ('Quel type de site archéologique rêvez-vous d\'explorer ?', [
      'Un temple ou un palais rempli de statues, de peintures et d\'ornements.',
      'Une cité engloutie ou un chantier de fouilles plein de mystère.',
      'Un village antique entier montrant comment on cuisinait, s\'habillait et vivait.',
      'D\'anciens canaux d\'irrigation, des théâtres romains à l\'acoustique étonnante ou des réseaux de routes.',
    ]),
    ('Laquelle de ces questions éveille le plus votre curiosité ?', [
      'Comment l\'artiste antique sculptait-il des détails si fins sans outils modernes ?',
      'Qu\'est-il arrivé à cette civilisation pour qu\'elle disparaisse soudainement ?',
      'Comment les familles antiques célébraient-elles, se soignaient-elles et commerçaient-elles ?',
      'Comment ces pierres géantes ont-elles été transportées et levées sans machines modernes ?',
    ]),
  ],
  'tr': [
    ('Bir eser gördüğünüzde ilk dikkatinizi ne çeker?', [
      'Oymalarının ayrıntıları, tasarımının güzelliği ve işçiliğinin inceliği.',
      'Parçanın ardındaki tarihî sır veya gizem.',
      'Günlük yaşamda ya da eski halk uygulamalarında nasıl kullanıldığı.',
      'Yapımındaki mühendislik veya teknolojik yenilik.',
    ]),
    ('Arkeoloji hakkında tek bir kitap okuyabilseydiniz hangisini seçerdiniz?', [
      '«Antik Dünyanın En Güzel Sanat Eserleri ve Heykelleri».',
      '«Tarihin En Büyük Arkeolojik Gizemleri ve Kayıp Mezarları».',
      '«Antik Bir İnsanın Günlüğü: Sıradan İnsanlar Nasıl Yaşardı?».',
      '«Antik Mimarinin Dehası: Piramitlerden Barajlara».',
    ]),
    ('Keşfetmeyi hayal ettiğiniz arkeolojik alan türü hangisi?', [
      'Heykeller, resimler ve süslemelerle dolu bir tapınak veya saray.',
      'Denizin altında kayıp bir şehir ya da gizemle dolu bir kazı alanı.',
      'İnsanların nasıl yemek pişirip giyindiğini ve yaşadığını gösteren eksiksiz bir antik köy.',
      'Antik sulama kanalları, muhteşem akustiğe sahip Roma tiyatroları veya yol ağları.',
    ]),
    ('Bu sorulardan hangisi merakınızı en çok uyandırır?', [
      'Antik sanatçı modern aletler olmadan bu ince ayrıntıları nasıl oydu?',
      'Bu medeniyete ne oldu da aniden yok oldu?',
      'Antik aileler nasıl kutlama yapar, tedavi olur ve ticaret yapardı?',
      'Bu dev taşlar modern makineler olmadan nasıl taşınıp kaldırıldı?',
    ]),
  ],
  'zh': [
    ('看到一件文物时，什么最先吸引您的目光？', [
      '雕刻的细节、设计之美与工艺之精。',
      '这件文物背后的历史秘密或谜团。',
      '它在日常生活或古代民俗中的用途。',
      '其制作中的工程或技术创新。',
    ]),
    ('如果只能读一本关于古迹的书，您会选哪一本？', [
      '《古代世界最美的艺术品与雕塑》。',
      '《历史上最大的考古之谜与失落的墓葬》。',
      '《古人日记：普通人如何生活？》。',
      '《古代建筑的智慧：从金字塔到水坝》。',
    ]),
    ('您梦想探索哪种考古遗址？', [
      '满是雕像、壁画与装饰的神庙或宫殿。',
      '海底失落之城或充满神秘的发掘现场。',
      '一座完整的古村落，展示人们如何烹饪、穿衣与居住。',
      '古代灌溉渠、声学惊人的罗马剧场或道路网络。',
    ]),
    ('以下哪个问题最能激发您的好奇心？', [
      '古代艺术家如何在没有现代工具的情况下雕出如此精细的细节？',
      '这个文明究竟发生了什么，导致它突然消失？',
      '古代家庭如何庆祝、治病和交换货物？',
      '没有现代机械，这些巨石是如何被运来并竖起的？',
    ]),
  ],
  'ru': [
    ('Что первым привлекает ваше внимание, когда вы видите артефакт?', [
      'Детали резьбы, красота дизайна и тонкость работы.',
      'Историческая тайна или загадка, скрытая за предметом.',
      'Как его использовали в повседневной жизни или в древних народных обычаях.',
      'Инженерное или технологическое новшество в его создании.',
    ]),
    ('Если бы вы могли прочитать только одну книгу об археологии, что бы вы выбрали?', [
      '«Прекраснейшие произведения искусства и скульптуры древнего мира».',
      '«Величайшие археологические загадки и затерянные гробницы истории».',
      '«Дневник древнего человека: как жили простые люди?».',
      '«Гений древней архитектуры: от пирамид до плотин».',
    ]),
    ('Какой археологический объект вы мечтаете исследовать?', [
      'Храм или дворец, полный статуй, росписей и орнаментов.',
      'Затонувший город или раскоп, полный тайн.',
      'Целую древнюю деревню, показывающую, как люди готовили, одевались и жили.',
      'Древние оросительные каналы, римские театры с потрясающей акустикой или сети дорог.',
    ]),
    ('Какой из этих вопросов вызывает у вас наибольшее любопытство?', [
      'Как древний мастер вырезал такие тонкие детали без современных инструментов?',
      'Что случилось с этой цивилизацией, что она внезапно исчезла?',
      'Как древние семьи праздновали, лечились и обменивались товарами?',
      'Как эти огромные камни доставили и подняли без современной техники?',
    ]),
  ],
  'ja': [
    ('遺物を見たとき、最初に目を引くものは何ですか？', [
      '彫刻の細部、デザインの美しさ、精巧な職人技。',
      'その遺物の背後にある歴史の秘密や謎。',
      '日常生活や昔の民間習慣での使われ方。',
      'その製作に込められた工学的・技術的な革新。',
    ]),
    ('考古学の本を一冊だけ読めるなら、どれを選びますか？', [
      '『古代世界の最も美しい美術品と彫刻』。',
      '『歴史上最大の考古学ミステリーと失われた墓』。',
      '『古代人の日記：普通の人々はどう暮らしたか』。',
      '『古代建築の天才：ピラミッドからダムまで』。',
    ]),
    ('探検してみたい遺跡はどんなタイプですか？', [
      '彫像や絵画、装飾で満ちた神殿や宮殿。',
      '海底に沈んだ失われた都市や、謎に満ちた発掘現場。',
      '人々の料理・服装・暮らしがわかる古代の村全体。',
      '古代の灌漑水路、驚くべき音響のローマ劇場、道路網。',
    ]),
    ('次のうち、最も好奇心をかき立てる問いはどれですか？', [
      '古代の芸術家は現代の道具なしでどうやってこれほど細かい彫刻をしたのか？',
      'この文明に何が起きて突然消えてしまったのか？',
      '古代の家族はどのように祝い、治療し、物を交換していたのか？',
      'これらの巨石は現代の機械なしでどう運ばれ、立てられたのか？',
    ]),
  ],
};

// ── Quiz personas: (name, recommendation title) per language ──
const kPersonaI18n = <String, Map<String, (String, String)>>{
  'en': {
    'A': ('Lover of arts & antiques', 'Sites that match your passion for art and sculpture'),
    'B': ('Explorer of mysteries & civilisations', 'Sites that match your passion for mysteries and prehistory'),
    'C': ('Lover of daily life & heritage', 'Sites that tell how our ancestors lived'),
    'D': ('Architecture & acoustics engineer', 'Masterpieces of ancient architecture and acoustics'),
  },
  'it': {
    'A': ('Amante delle arti e dell\'antiquariato', 'Siti per la tua passione per l\'arte e la scultura'),
    'B': ('Esploratore di misteri e civiltà', 'Siti per la tua passione per i misteri e la preistoria'),
    'C': ('Amante della vita quotidiana e delle tradizioni', 'Siti che raccontano come vivevano i nostri antenati'),
    'D': ('Ingegnere di architettura e acustica', 'Capolavori di architettura e acustica antiche'),
  },
  'fr': {
    'A': ('Amoureux des arts et des antiquités', 'Des sites pour votre passion de l\'art et de la sculpture'),
    'B': ('Explorateur d\'énigmes et de civilisations', 'Des sites pour votre passion des énigmes et de la préhistoire'),
    'C': ('Amoureux de la vie quotidienne et du patrimoine', 'Des sites qui racontent la vie de nos ancêtres'),
    'D': ('Ingénieur en architecture et acoustique', 'Chefs-d\'œuvre de l\'architecture et de l\'acoustique antiques'),
  },
  'tr': {
    'A': ('Sanat ve antika tutkunu', 'Sanat ve heykel tutkunuza uygun alanlar'),
    'B': ('Gizem ve medeniyet kâşifi', 'Gizem ve tarih öncesi tutkunuza uygun alanlar'),
    'C': ('Gündelik yaşam ve miras tutkunu', 'Atalarımızın nasıl yaşadığını anlatan alanlar'),
    'D': ('Mimari ve akustik mühendisi', 'Antik mimari ve akustiğin başyapıtları'),
  },
  'zh': {
    'A': ('艺术与古董爱好者', '契合您对艺术与雕塑热爱的遗址'),
    'B': ('谜团与文明探索者', '契合您对谜团与史前史热爱的遗址'),
    'C': ('日常生活与遗产爱好者', '讲述祖先如何生活的遗址'),
    'D': ('建筑与声学工程师', '古代建筑与声学杰作'),
  },
  'ru': {
    'A': ('Ценитель искусства и древностей', 'Объекты для любителя искусства и скульптуры'),
    'B': ('Исследователь тайн и цивилизаций', 'Объекты для любителя тайн и доистории'),
    'C': ('Любитель быта и наследия', 'Объекты, рассказывающие, как жили предки'),
    'D': ('Инженер архитектуры и акустики', 'Шедевры древней архитектуры и акустики'),
  },
  'ja': {
    'A': ('芸術・骨董愛好家', '芸術と彫刻への情熱に合う遺跡'),
    'B': ('謎と文明の探検家', '謎と先史時代への情熱に合う遺跡'),
    'C': ('暮らしと伝統の愛好家', '祖先の暮らしを伝える遺跡'),
    'D': ('建築・音響エンジニア', '古代建築と音響の傑作'),
  },
};

String personaName(String key) {
  final p = kPersonas[key];
  if (p == null) return '';
  return gLang == 'ar' ? p.nameAr : (kPersonaI18n[gLang]?[key]?.$1 ?? p.nameAr);
}

String personaTitle(String key) {
  final p = kPersonas[key];
  if (p == null) return '';
  return gLang == 'ar' ? p.titleAr : (kPersonaI18n[gLang]?[key]?.$2 ?? p.titleAr);
}

// ─────────────────────────── Language selector ──────────────────────────────

/// `🌐 العربية` pill that opens the 8-language picker.
class LanguagePill extends StatelessWidget {
  final AppState state;
  const LanguagePill({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Tooltip(
        message: 'اللغات / Languages',
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: BorderSide(color: kGold.withValues(alpha: 0.5)),
            minimumSize: const Size(52, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => showLanguagePicker(context, state),
          icon: Icon(Icons.language, size: 18, color: inkGold),
          label: Text(langNative(state.lang),
              style: TextStyle(fontWeight: FontWeight.w700, color: inkBody)),
        ),
      ),
    );
  }
}

Future<void> showLanguagePicker(BuildContext context, AppState s) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: surfaceColor,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🌐 اللغات / Languages',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: inkGold)),
          const SizedBox(height: 4),
          Text(s.t('اختر لغتك', 'Choose your language'),
              style: TextStyle(color: inkMuted)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final l in kLanguages)
                ChoiceChip(
                  selected: s.lang == l.$1,
                  showCheckmark: false,
                  avatar: Text(l.$4),
                  label: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(l.$2,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: inkTitle)),
                    Text(l.$3, style: TextStyle(fontSize: 11, color: inkMuted)),
                  ]),
                  selectedColor: kGold.withValues(alpha: 0.35),
                  side: BorderSide(color: kGold.withValues(alpha: 0.5)),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onSelected: (_) {
                    s.setLang(l.$1);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ]),
      ),
    ),
  );
}
