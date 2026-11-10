import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ERTH — Libyan heritage platform. Self-contained: no router, no extra packages
// beyond supabase_flutter. Every network call is wrapped so the UI always works
// with local seed data.
// ─────────────────────────────────────────────────────────────────────────────

const _supabaseUrl = 'https://agjmzujptenllpqpkffv.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnam16dWpwdGVubGxwcXBrZmZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQzMjA3NDIsImV4cCI6MjEwOTg5Njc0Mn0.LG1qTX4JoJNCQJEfJoOrqID2JO8THyTbJBvAA7XHP-0';

// Palette
const kBronze = Color(0xFF8D4925);
const kGold = Color(0xFFD4AF37);
const kSurface = Color(0xFF1C1917);
const kCard = Color(0xFF282422);
const kMuted = Color(0xFFA8A29E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  } catch (e) {
    debugPrint('[ERTH] Supabase init failed, running offline: $e');
  }
  runApp(const ErthApp());
}

// ─────────────────────────────── Models ─────────────────────────────────────

enum Preservation { good, needsCare, underTreatment, critical }

extension PreservationX on Preservation {
  String get label => switch (this) {
        Preservation.good => 'حالة جيدة',
        Preservation.needsCare => 'تحتاج صيانة',
        Preservation.underTreatment => 'قيد المعالجة',
        Preservation.critical => 'تنبيه طارئ',
      };
  Color get color => switch (this) {
        Preservation.good => const Color(0xFF6BAA75),
        Preservation.needsCare => kGold,
        Preservation.underTreatment => const Color(0xFFE08A4F),
        Preservation.critical => const Color(0xFFE05A4F),
      };
}

class HeritageSite {
  final String id;
  final String nameAr;
  final String nameEn;
  final String location;
  final String category;
  final Preservation status;
  final String imageUrl;
  final IconData icon;
  final String story;
  final List<(String year, String event)> history;

  const HeritageSite({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.location,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.icon,
    required this.story,
    required this.history,
  });
}

class RestorationLog {
  final String siteName;
  final String materials;
  final String report;
  final DateTime createdAt;
  final bool synced;

  const RestorationLog({
    required this.siteName,
    required this.materials,
    required this.report,
    required this.createdAt,
    required this.synced,
  });
}

const kCategories = ['الكل', 'آثار رومانية', 'نقوش صخرية', 'مدن قديمة'];

const kSeedSites = <HeritageSite>[
  HeritageSite(
    id: 'leptis',
    nameAr: 'لبدة الكبرى',
    nameEn: 'Leptis Magna',
    location: 'الخمس، ليبيا',
    category: 'آثار رومانية',
    status: Preservation.underTreatment,
    icon: Icons.account_balance,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Leptis_Magna_Theatre.jpg/960px-Leptis_Magna_Theatre.jpg',
    story:
        'مدينة رومانية عظيمة على ساحل المتوسط، وُلد فيها الإمبراطور سبتيموس سيفيروس. '
        'تضم قوس النصر والسوق والمسرح والحمامات، وتُعد من أفضل المدن الرومانية حفظًا في العالم.',
    history: [
      ('القرن 7 ق.م', 'تأسيس المدينة كمرفأ فينيقي'),
      ('193 م', 'سيفيروس إمبراطورًا وبدء التوسعة الكبرى'),
      ('1982', 'إدراجها ضمن مواقع التراث العالمي'),
      ('2023', 'ترميم أحجار الأرصفة وتثبيت الأعمدة'),
    ],
  ),
  HeritageSite(
    id: 'cyrene',
    nameAr: 'شحات (قورينا)',
    nameEn: 'Cyrene',
    location: 'الجبل الأخضر، ليبيا',
    category: 'آثار رومانية',
    status: Preservation.needsCare,
    icon: Icons.temple_hindu,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Temple_of_Zeus_in_Cyrene.jpg/960px-Temple_of_Zeus_in_Cyrene.jpg',
    story:
        'مستعمرة إغريقية عريقة تأسست في القرن السابع قبل الميلاد، وكانت مركزًا للعلم والفلسفة. '
        'يضم الموقع معبد زيوس ومعبد أبولو والأغورا.',
    history: [
      ('631 ق.م', 'تأسيس المدينة على يد مستوطنين من ثيرا'),
      ('96 ق.م', 'انتقالها إلى الحكم الروماني'),
      ('365 م', 'زلزال مدمّر يصيب المدينة'),
      ('2019', 'مسح توثيقي لمعبد زيوس'),
    ],
  ),
  HeritageSite(
    id: 'sabratha',
    nameAr: 'صبراتة',
    nameEn: 'Sabratha',
    location: 'صبراتة، ليبيا',
    category: 'آثار رومانية',
    status: Preservation.good,
    icon: Icons.theater_comedy,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Sabratha_Theatre.jpg/960px-Sabratha_Theatre.jpg',
    story:
        'محطة تجارية فينيقية تحولت إلى مدينة رومانية مزدهرة، ويشتهر مسرحها الروماني الضخم '
        'بواجهته المزخرفة المكونة من ثلاثة طوابق من الأعمدة.',
    history: [
      ('القرن 6 ق.م', 'محطة تجارية فينيقية'),
      ('القرن 2 م', 'بناء المسرح الروماني'),
      ('1920s', 'إعادة بناء واجهة المسرح'),
      ('2021', 'صيانة دورية للفسيفساء'),
    ],
  ),
  HeritageSite(
    id: 'acacus',
    nameAr: 'تادرارت أكاكوس',
    nameEn: 'Tadrart Acacus',
    location: 'غات، جنوب ليبيا',
    category: 'نقوش صخرية',
    status: Preservation.critical,
    icon: Icons.landscape,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Acacus_Mountains.jpg/960px-Acacus_Mountains.jpg',
    story:
        'سلسلة جبال صحراوية تضم آلاف الرسوم والنقوش الصخرية التي تعود إلى ما قبل التاريخ، '
        'وتروي تحولات المناخ والحياة في الصحراء الكبرى عبر 12 ألف عام.',
    history: [
      ('12000 ق.م', 'أقدم الرسوم الصخرية المعروفة'),
      ('5000 ق.م', 'عصر الرعاة ورسوم الماشية'),
      ('1985', 'إدراج الموقع في قائمة اليونسكو'),
      ('2024', 'رصد تآكل وتنبيه طارئ لحماية اللوحات'),
    ],
  ),
  HeritageSite(
    id: 'ghadames',
    nameAr: 'غدامس القديمة',
    nameEn: 'Ghadames',
    location: 'غدامس، ليبيا',
    category: 'مدن قديمة',
    status: Preservation.needsCare,
    icon: Icons.holiday_village,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Ghadames_old_town.jpg/960px-Ghadames_old_town.jpg',
    story:
        'لؤلؤة الصحراء؛ مدينة طينية بُنيت بأسلوب معماري فريد من الأزقة المسقوفة التي تقي من الحرارة، '
        'وبيوتها بطوابق مرتبطة بأسطح خاصة بالنساء.',
    history: [
      ('القرن 1 ق.م', 'ذكرها كواحة رومانية «كيداموس»'),
      ('القرن 7 م', 'دخول الإسلام وازدهار التجارة القوافلية'),
      ('1986', 'إدراجها ضمن التراث العالمي'),
      ('2022', 'ترميم جدران الطين وسقوف الأزقة'),
    ],
  ),
];

// ─────────────────────────────── State ──────────────────────────────────────

enum UserRole { tourist, expert }

class AppState extends ChangeNotifier {
  UserRole? role;
  int tab = 0;
  String query = '';
  String category = kCategories.first;
  bool loadingLogs = false;
  bool offline = false;

  final List<RestorationLog> logs = [
    RestorationLog(
      siteName: 'لبدة الكبرى',
      materials: 'محلول كربونات الكالسيوم، راتنج أكريليك',
      report: 'تثبيت أحجار الرصيف الشمالي وإزالة الأملاح المتبلورة. الضرر: تآكل متوسط.',
      createdAt: DateTime(2026, 10, 28),
      synced: false,
    ),
    RestorationLog(
      siteName: 'غدامس القديمة',
      materials: 'ملاط طيني، جير مطفأ',
      report: 'إعادة ترميم سقف الزقاق الشرقي بعد تشققات ناتجة عن الأمطار.',
      createdAt: DateTime(2026, 10, 12),
      synced: false,
    ),
  ];

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  List<HeritageSite> get filteredSites {
    final q = query.trim().toLowerCase();
    return kSeedSites.where((s) {
      final matchCat = category == kCategories.first || s.category == category;
      final matchQ = q.isEmpty ||
          s.nameAr.contains(q) ||
          s.nameEn.toLowerCase().contains(q) ||
          s.location.contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  int get approvedReports => logs.length;
  int get underTreatment =>
      kSeedSites.where((s) => s.status == Preservation.underTreatment).length;
  int get urgentAlerts =>
      kSeedSites.where((s) => s.status == Preservation.critical).length;

  void setRole(UserRole r) {
    role = r;
    tab = 0;
    notifyListeners();
    loadLogs();
  }

  void signOut() {
    role = null;
    tab = 0;
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setCategory(String c) {
    category = c;
    notifyListeners();
  }

  /// Fetch remote logs; on any failure keep the local seed data.
  Future<void> loadLogs() async {
    final client = _client;
    if (client == null) {
      offline = true;
      notifyListeners();
      return;
    }
    loadingLogs = true;
    notifyListeners();
    try {
      final artifacts = await client.from('artifacts').select('id, name');
      final names = <String, String>{
        for (final a in (artifacts as List)) '${a['id']}': '${a['name']}',
      };
      final rows = await client
          .from('restoration_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      final remote = (rows as List).map((r) {
        final enName = names['${r['artifact_id']}'];
        final site = kSeedSites.where((s) => s.nameEn == enName).firstOrNull;
        return RestorationLog(
          siteName: site?.nameAr ?? enName ?? 'موقع أثري',
          materials: '${r['chemical_materials'] ?? ''}',
          report: '${r['technical_report'] ?? ''}',
          createdAt: DateTime.tryParse('${r['created_at']}')?.toLocal() ??
              DateTime.now(),
          synced: true,
        );
      }).toList();
      logs
        ..removeWhere((l) => l.synced)
        ..insertAll(0, remote);
      offline = false;
    } catch (e) {
      debugPrint('[ERTH] fetch restoration_logs failed: $e');
      offline = true;
    }
    loadingLogs = false;
    notifyListeners();
  }

  /// Insert a log. Always shows up locally; `synced` tells whether it reached
  /// Supabase.
  Future<bool> addLog({
    required String siteName,
    required String materials,
    required String report,
  }) async {
    var synced = false;
    final client = _client;
    if (client != null) {
      try {
        String? artifactId;
        final match = kSeedSites
            .where((s) => s.nameAr == siteName.trim() || s.nameEn.toLowerCase() == siteName.trim().toLowerCase())
            .firstOrNull;
        if (match != null) {
          final res = await client
              .from('artifacts')
              .select('id')
              .eq('name', match.nameEn)
              .limit(1);
          if ((res as List).isNotEmpty) artifactId = '${res.first['id']}';
        }
        await client.from('restoration_logs').insert({
          'artifact_id': artifactId,
          'expert_id': client.auth.currentUser?.id,
          'chemical_materials': materials,
          'technical_report': 'الموقع: $siteName\n$report',
        });
        synced = true;
      } catch (e) {
        debugPrint('[ERTH] insert restoration_logs failed: $e');
      }
    }
    logs.insert(
      0,
      RestorationLog(
        siteName: siteName,
        materials: materials,
        report: report,
        createdAt: DateTime.now(),
        synced: synced,
      ),
    );
    offline = !synced;
    notifyListeners();
    return synced;
  }
}

// ─────────────────────────────── App ────────────────────────────────────────

class ErthApp extends StatefulWidget {
  const ErthApp({super.key});

  @override
  State<ErthApp> createState() => _ErthAppState();
}

class _ErthAppState extends State<ErthApp> {
  final AppState state = AppState();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  ThemeData _theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBronze,
      brightness: Brightness.dark,
    ).copyWith(
      primary: kBronze,
      onPrimary: Colors.white,
      secondary: kGold,
      onSecondary: Colors.black,
      surface: kSurface,
      surfaceContainer: kCard,
      surfaceContainerHigh: kCard,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: kSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kCard,
        indicatorColor: kBronze.withValues(alpha: 0.55),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kGold, width: 1.4),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERTH — تراث ليبيا',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      themeMode: ThemeMode.dark,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: ListenableBuilder(
        listenable: state,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: state.role == null
              ? RoleGate(key: const ValueKey('gate'), state: state)
              : AppShell(key: const ValueKey('shell'), state: state),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Role gate ──────────────────────────────────

class RoleGate extends StatefulWidget {
  final AppState state;
  const RoleGate({super.key, required this.state});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  UserRole selected = UserRole.tourist;

  @override
  Widget build(BuildContext context) {
    final isTourist = selected == UserRole.tourist;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A2314), kSurface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBronze,
                        border: Border.all(color: kGold, width: 2),
                      ),
                      child: const Icon(Icons.account_balance,
                          size: 44, color: kGold),
                    ),
                    const SizedBox(height: 20),
                    const Text('ERTH',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: kGold)),
                    const SizedBox(height: 6),
                    const Text('منصة التراث الليبي',
                        style: TextStyle(fontSize: 16, color: kMuted)),
                    const SizedBox(height: 36),
                    _RoleToggle(
                      selected: selected,
                      onChanged: (r) => setState(() => selected = r),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(selected),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: kGold.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                isTourist
                                    ? Icons.explore
                                    : Icons.biotech,
                                color: kGold,
                                size: 34),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                isTourist
                                    ? 'اكتشف المواقع الأثرية في ليبيا، واطّلع على قصصها وتاريخ ترميمها.'
                                    : 'سجّل تقارير الترميم الفنية، وتابع حالة المواقع والتنبيهات الطارئة.',
                                style: const TextStyle(height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kBronze,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => widget.state.setRole(selected),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('متابعة',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(UserRole r, String label, IconData icon) {
      final on = selected == r;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: on ? kBronze : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: on
                  ? [
                      BoxShadow(
                          color: kBronze.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: on ? kGold : kMuted),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: on ? Colors.white : kMuted)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          seg(UserRole.tourist, 'زائر / سائح', Icons.hiking),
          seg(UserRole.expert, 'خبير مرمم معتمد', Icons.verified),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Shell ──────────────────────────────────────

class AppShell extends StatelessWidget {
  final AppState state;
  const AppShell({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isExpert = state.role == UserRole.expert;
    final pages = <Widget>[
      HomeTab(state: state),
      SitesTab(state: state),
      LogsTab(state: state),
      ProfileTab(state: state),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(state.tab),
                child: pages[state.tab],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isExpert && state.tab == 2
          ? FloatingActionButton.extended(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              onPressed: () => showAddLogSheet(context, state),
              icon: const Icon(Icons.add),
              label: const Text('إضافة تقرير ترميم فني',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tab,
        onDestinationSelected: state.setTab,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: kGold),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance, color: kGold),
              label: 'المواقع'),
          NavigationDestination(
              icon: Icon(Icons.history_edu_outlined),
              selectedIcon: Icon(Icons.history_edu, color: kGold),
              label: 'سجل الترميم'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kGold),
              label: 'الملف الشخصي'),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Home ───────────────────────────────────────

class HomeTab extends StatelessWidget {
  final AppState state;
  const HomeTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isExpert = state.role == UserRole.expert;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(isExpert ? 'مرحبًا أيها الخبير' : 'اكتشف ليبيا',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
            isExpert
                ? 'لوحة متابعة أعمال الترميم'
                : 'رحلة عبر آلاف السنين من الحضارات',
            style: const TextStyle(color: kMuted)),
        const SizedBox(height: 20),
        if (state.offline) const _OfflineBanner(),
        if (isExpert) ...[
          LayoutBuilder(builder: (context, c) {
            final cards = [
              _KpiCard('تقارير معتمدة', '${state.approvedReports}',
                  Icons.verified, kGold),
              _KpiCard('مواقع قيد المعالجة', '${state.underTreatment}',
                  Icons.construction, const Color(0xFFE08A4F)),
              _KpiCard('تنبيهات طارئة', '${state.urgentAlerts}',
                  Icons.warning_amber_rounded, const Color(0xFFE05A4F)),
            ];
            if (c.maxWidth > 640) {
              return Row(children: [
                for (final k in cards) Expanded(child: k),
              ]);
            }
            return Column(children: cards);
          }),
          const SizedBox(height: 24),
          const Text('مواقع تحتاج اهتمامًا',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final s in kSeedSites.where((s) =>
              s.status == Preservation.critical ||
              s.status == Preservation.underTreatment))
            _SiteListTile(site: s),
        ] else ...[
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in kSeedSites)
                  SizedBox(
                      width: 260,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 14),
                        child: SiteCard(site: s),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => state.setTab(1),
                  icon: const Icon(Icons.search),
                  label: const Text('استعرض جميع المواقع'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  Text(label, style: const TextStyle(color: kMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: kGold),
          SizedBox(width: 10),
          Expanded(
            child: Text('وضع محلي: تُعرض بيانات تجريبية ولم تتم المزامنة مع الخادم.',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Sites ──────────────────────────────────────

class SitesTab extends StatelessWidget {
  final AppState state;
  const SitesTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final sites = state.filteredSites;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: TextField(
            onChanged: state.setQuery,
            decoration: const InputDecoration(
              hintText: 'ابحث عن موقع أثري...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = kCategories[i];
              final on = state.category == c;
              return ChoiceChip(
                label: Text(c),
                selected: on,
                showCheckmark: false,
                elevation: on ? 4 : 0,
                pressElevation: 6,
                backgroundColor: kCard,
                selectedColor: kBronze,
                labelStyle: TextStyle(
                    color: on ? Colors.white : kMuted,
                    fontWeight: FontWeight.w600),
                side: BorderSide(color: on ? kGold : Colors.transparent),
                onSelected: (_) => state.setCategory(c),
              );
            },
          ),
        ),
        Expanded(
          child: sites.isEmpty
              ? const Center(
                  child: Text('لا توجد مواقع مطابقة',
                      style: TextStyle(color: kMuted)))
              : LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 300,
                    ),
                    itemCount: sites.length,
                    itemBuilder: (_, i) => SiteCard(site: sites[i]),
                  );
                }),
        ),
      ],
    );
  }
}

class _SiteImage extends StatelessWidget {
  final HeritageSite site;
  const _SiteImage(this.site);

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF8D4925), Color(0xFF3A2314)],
            ),
          ),
          child: Center(
              child: Icon(site.icon,
                  size: 56, color: kGold.withValues(alpha: 0.8))),
        );
    return Image.network(
      site.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => fallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Preservation status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: status.color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SiteCard extends StatefulWidget {
  final HeritageSite site;
  const SiteCard({super.key, required this.site});

  @override
  State<SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends State<SiteCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.site;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: GestureDetector(
          onTap: () => showSiteSheet(context, s),
          child: Container(
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: hover ? 0.5 : 0.3),
                    blurRadius: hover ? 24 : 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _SiteImage(s),
                      Positioned(
                          top: 12, right: 12, child: _StatusBadge(s.status)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nameAr,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      Text(s.nameEn,
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 15, color: kGold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(s.location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kBronze.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(s.category,
                                style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SiteListTile extends StatelessWidget {
  final HeritageSite site;
  const _SiteListTile({required this.site});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showSiteSheet(context, site),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(site.icon, color: site.status.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(site.nameAr,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(site.location,
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                    ],
                  ),
                ),
                _StatusBadge(site.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSiteSheet(BuildContext context, HeritageSite s) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kSurface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(height: 220, child: _SiteImage(s)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(s.nameAr,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                ),
                _StatusBadge(s.status),
              ],
            ),
            Text(s.nameEn, style: const TextStyle(color: kMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                    avatar: const Icon(Icons.place, size: 16, color: kGold),
                    label: Text(s.location)),
                Chip(label: Text(s.category)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('القصة والتراث',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: kGold)),
            const SizedBox(height: 8),
            Text(s.story, style: const TextStyle(height: 1.8, fontSize: 15)),
            const SizedBox(height: 20),
            const Text('تاريخ الترميم والأحداث',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: kGold)),
            const SizedBox(height: 12),
            for (final h in s.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                                color: kBronze, shape: BoxShape.circle)),
                        Container(width: 2, height: 28, color: kBronze),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.$1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, color: kGold)),
                          Text(h.$2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────── Logs ───────────────────────────────────────

class LogsTab extends StatelessWidget {
  final AppState state;
  const LogsTab({super.key, required this.state});

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final logs = state.logs;
    return RefreshIndicator(
      onRefresh: state.loadLogs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text('سجل الترميم',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${logs.length} تقرير فني',
              style: const TextStyle(color: kMuted)),
          const SizedBox(height: 16),
          if (state.offline) const _OfflineBanner(),
          if (state.loadingLogs) const LinearProgressIndicator(color: kGold),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                  child: Text('لا توجد تقارير بعد',
                      style: TextStyle(color: kMuted))),
            ),
          for (final l in logs)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu, color: kGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l.siteName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      Icon(l.synced ? Icons.cloud_done : Icons.cloud_off,
                          size: 16, color: l.synced ? Colors.green : kMuted),
                      const SizedBox(width: 6),
                      Text(_fmt(l.createdAt),
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.science, size: 16, color: kBronze),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(l.materials,
                              style: const TextStyle(color: kMuted))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l.report, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void showAddLogSheet(BuildContext context, AppState state) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kSurface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: _AddLogForm(state: state),
    ),
  );
}

class _AddLogForm extends StatefulWidget {
  final AppState state;
  const _AddLogForm({required this.state});

  @override
  State<_AddLogForm> createState() => _AddLogFormState();
}

class _AddLogFormState extends State<_AddLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _site = TextEditingController();
  final _materials = TextEditingController();
  final _report = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    _site.dispose();
    _materials.dispose();
    _report.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final synced = await widget.state.addLog(
      siteName: _site.text.trim(),
      materials: _materials.text.trim(),
      report: _report.text.trim(),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(
      content: Text(synced
          ? 'تم حفظ التقرير ومزامنته بنجاح'
          : 'تم حفظ التقرير محليًا (بدون اتصال بالخادم)'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة تقرير ترميم فني',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _site,
                validator: _required,
                decoration: const InputDecoration(
                    labelText: 'اسم المعلم الأثري',
                    prefixIcon: Icon(Icons.account_balance)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _materials,
                validator: _required,
                decoration: const InputDecoration(
                    labelText: 'المواد الكيميائية المستخدمة',
                    prefixIcon: Icon(Icons.science)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _report,
                validator: _required,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                    labelText: 'التقرير الفني وحالة الضرر',
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kBronze,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: saving ? null : _submit,
                  child: saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('حفظ التقرير',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Profile ────────────────────────────────────

class ProfileTab extends StatelessWidget {
  final AppState state;
  const ProfileTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isExpert = state.role == UserRole.expert;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: kBronze,
            child: Icon(isExpert ? Icons.verified_user : Icons.hiking,
                size: 44, color: kGold),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(isExpert ? 'خبير مرمم معتمد' : 'زائر / سائح',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(state.offline ? 'وضع محلي' : 'متصل بالخادم',
              style: TextStyle(color: state.offline ? kMuted : Colors.green)),
        ),
        const SizedBox(height: 28),
        _ProfileRow(Icons.history_edu, 'التقارير', '${state.logs.length}'),
        _ProfileRow(Icons.account_balance, 'المواقع', '${kSeedSites.length}'),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: kGold,
            side: const BorderSide(color: kGold),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: state.signOut,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('تبديل الدور'),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: kGold, fontSize: 16)),
        ],
      ),
    );
  }
}
