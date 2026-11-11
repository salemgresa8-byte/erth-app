import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pwa/pwa.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ERTH (إرث) — Libyan heritage platform. Single file, no router.
// Every network call is wrapped: the UI always works with local data.
// ─────────────────────────────────────────────────────────────────────────────

const _supabaseUrl = 'https://agjmzujptenllpqpkffv.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnam16dWpwdGVubGxwcXBrZmZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQzMjA3NDIsImV4cCI6MjEwOTg5Njc0Mn0.LG1qTX4JoJNCQJEfJoOrqID2JO8THyTbJBvAA7XHP-0';

// Supplied at build time: flutter build web --dart-define=OPENROUTER_API_KEY=...
// (never commit the key). Without it the chat answers from the local engine.
// NOTE: any key compiled into a web app is readable by its visitors.
const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY');
const _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
const _openRouterModels = [
  'deepseek/deepseek-chat:free',
  'meta-llama/llama-3.3-70b-instruct:free',
  'google/gemma-3-27b-it:free',
  'openrouter/auto',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  } catch (e) {
    debugPrint('[ERTH] Supabase init failed, running offline: $e');
  }
  final state = AppState();
  await state.loadPrefs();
  runApp(ErthApp(state: state));
}

// ─────────────────────────────── Palette ────────────────────────────────────

class Pal {
  final Color bg, card, primary, accent, text, text2, line;
  const Pal(this.bg, this.card, this.primary, this.accent, this.text, this.text2,
      this.line);

  static const light = Pal(Color(0xFFF6F1E7), Color(0xFFFFFDF9),
      Color(0xFF8B261D), Color(0xFFC59B27), Color(0xFF231915),
      Color(0xFF6E5A4F), Color(0xFFE6DCCB));
  static const dark = Pal(Color(0xFF161210), Color(0xFF241E1B),
      Color(0xFFA8382B), Color(0xFFD4AF37), Color(0xFFF3EBDD),
      Color(0xFFB9A99B), Color(0xFF3A312C));

  static Pal of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  final base = ThemeData(brightness: b, useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: p.primary, brightness: b)
        .copyWith(
      primary: p.primary,
      onPrimary: Colors.white,
      secondary: p.accent,
      onSecondary: Colors.black,
      surface: p.card,
      onSurface: p.text,
    ),
    scaffoldBackgroundColor: p.bg,
    textTheme: base.textTheme.apply(bodyColor: p.text, displayColor: p.text),
    appBarTheme: AppBarTheme(
      backgroundColor: p.card,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      indicatorColor: p.primary.withValues(alpha: b == Brightness.dark ? 0.55 : 0.14),
      labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.accent, width: 1.6)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

// ─────────────────────────────── Logo ───────────────────────────────────────

class _ArchPainter extends CustomPainter {
  final Color red, bronze;
  _ArchPainter(this.red, this.bronze);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final stroke = Paint()
      ..color = red
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.butt;
    final fillBronze = Paint()..color = bronze;
    final fillRed = Paint()..color = red;
    final rayPaint = Paint()
      ..color = bronze
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // Libyan desert sun inside the arch opening, clipped by the base line.
    final sun = Offset(w * 0.5, h * 0.80);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h * 0.88));
    canvas.drawCircle(sun, w * 0.13, fillBronze);
    for (var i = 0; i < 5; i++) {
      final a = math.pi + (math.pi / 6) + i * (math.pi * 4 / 6 / 4);
      canvas.drawLine(
        sun + Offset(math.cos(a), math.sin(a)) * (w * 0.18),
        sun + Offset(math.cos(a), math.sin(a)) * (w * 0.25),
        rayPaint,
      );
    }
    canvas.restore();

    // Roman arch.
    final arch = Path()
      ..moveTo(w * 0.19, h * 0.90)
      ..lineTo(w * 0.19, h * 0.50)
      ..arcTo(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.50), radius: w * 0.31),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(w * 0.81, h * 0.90);
    canvas.drawPath(arch, stroke);

    // Corinthian capitals + keystone + base.
    for (final x in [0.19, 0.81]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * x, h * 0.49), width: w * 0.16, height: h * 0.07),
            Radius.circular(w * 0.02)),
        fillBronze,
      );
    }
    final key = Path()
      ..moveTo(w * 0.44, h * 0.14)
      ..lineTo(w * 0.56, h * 0.14)
      ..lineTo(w * 0.54, h * 0.26)
      ..lineTo(w * 0.46, h * 0.26)
      ..close();
    canvas.drawPath(key, fillBronze);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.90, w * 0.84, h * 0.06),
          Radius.circular(w * 0.02)),
      fillRed,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchPainter old) =>
      old.red != red || old.bronze != bronze;
}

class ErthLogo extends StatelessWidget {
  final double size;
  final bool showText;
  const ErthLogo({super.key, this.size = 40, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    // The logo art is light cream, so it sits on a Greek-red badge.
    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: p.accent, width: size * 0.04),
      ),
      clipBehavior: Clip.antiAlias,
      child: Transform.scale(
        scale: 1.7,
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => CustomPaint(
              painter: _ArchPainter(const Color(0xFFF6F1E7), p.accent)),
        ),
      ),
    );
    if (!showText) return icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        icon,
        SizedBox(width: size * 0.22),
        Text('إرث',
            style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                color: p.primary)),
        Text(' | ',
            style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w300,
                color: p.accent)),
        Text('ERTH',
            style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w800,
                letterSpacing: size * 0.06,
                color: p.accent)),
      ],
    );
  }
}

// ─────────────────────────────── Models ─────────────────────────────────────

enum UserRole { tourist, expert }

enum Preservation { good, needsCare, underTreatment, critical }

extension PreservationX on Preservation {
  String label(bool ar) => switch (this) {
        Preservation.good => ar ? 'حالة جيدة' : 'Good condition',
        Preservation.needsCare => ar ? 'تحتاج صيانة' : 'Needs care',
        Preservation.underTreatment => ar ? 'قيد المعالجة' : 'Under treatment',
        Preservation.critical => ar ? 'تنبيه طارئ' : 'Urgent alert',
      };
  Color get color => switch (this) {
        Preservation.good => const Color(0xFF4E9A5C),
        Preservation.needsCare => const Color(0xFFC59B27),
        Preservation.underTreatment => const Color(0xFFD9772F),
        Preservation.critical => const Color(0xFFD64535),
      };
}

class HeritageSite {
  final String id, nameAr, nameEn, regionAr, regionEn;
  final String category; // Arabic key, see kCategoryEn
  final String eraAr, eraEn;
  final bool unesco;
  final double lat, lon;
  final Preservation status;
  final String image;
  final IconData icon;
  final String storyAr, storyEn;
  final List<(String, String, String)> history; // year, ar, en

  const HeritageSite({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.regionAr,
    required this.regionEn,
    required this.category,
    required this.eraAr,
    required this.eraEn,
    required this.unesco,
    required this.lat,
    required this.lon,
    required this.status,
    required this.image,
    required this.icon,
    required this.storyAr,
    required this.storyEn,
    required this.history,
  });

  String name(bool ar) => ar ? nameAr : nameEn;
  String region(bool ar) => ar ? regionAr : regionEn;
  String era(bool ar) => ar ? eraAr : eraEn;
  String story(bool ar) => ar ? storyAr : storyEn;
}

const _commons = 'https://commons.wikimedia.org/wiki/Special:FilePath/';

const kAll = 'الكل';
const kCategoryEn = {
  'الكل': 'All',
  'آثار رومانية': 'Roman ruins',
  'آثار إغريقية': 'Greek ruins',
  'نقوش صخرية': 'Rock art',
  'مدن قديمة': 'Ancient towns',
  'قلاع إسلامية': 'Islamic forts',
  'واحات طبيعية': 'Natural oases',
};
final kCategories = kCategoryEn.keys.toList();

const kSites = <HeritageSite>[
  HeritageSite(
    id: 'leptis', nameAr: 'لبدة الكبرى', nameEn: 'Leptis Magna',
    regionAr: 'الخمس', regionEn: 'Khoms', category: 'آثار رومانية',
    eraAr: 'القرن 7 ق.م – القرن 4 م', eraEn: '7th c. BC – 4th c. AD',
    unesco: true, lat: 32.6385, lon: 14.2910,
    status: Preservation.underTreatment, icon: Icons.account_balance,
    image: '${_commons}Leptis_Magna_Septimius_Severus_Arch.jpg?width=900',
    storyAr: 'ميناء فينيقي تحول إلى إحدى أجمل المدن الرومانية، وفيها وُلد الإمبراطور سبتيموس سيفيروس. تضم قوس النصر والسوق والمسرح والحمامات والبازيليكا.',
    storyEn: 'A Phoenician port turned into one of the finest Roman cities, birthplace of Emperor Septimius Severus. It holds the triumphal arch, market, theatre, baths and basilica.',
    history: [
      ('القرن 7 ق.م', 'تأسيس المرفأ الفينيقي', 'Phoenician port founded'),
      ('193 م', 'سيفيروس إمبراطورًا وبدء التوسعة الكبرى', 'Severus becomes emperor; grand expansion begins'),
      ('1982', 'إدراج الموقع في قائمة التراث العالمي', 'Listed as a UNESCO World Heritage Site'),
    ],
  ),
  HeritageSite(
    id: 'cyrene', nameAr: 'شحات - قورينا', nameEn: 'Cyrene',
    regionAr: 'الجبل الأخضر', regionEn: 'Green Mountain', category: 'آثار إغريقية',
    eraAr: 'القرن 7 ق.م – القرن 4 م', eraEn: '7th c. BC – 4th c. AD',
    unesco: true, lat: 32.8250, lon: 21.8580,
    status: Preservation.needsCare, icon: Icons.temple_hindu,
    image: '${_commons}Temple_of_Zeus_in_Cyrene.jpg?width=900',
    storyAr: 'مستعمرة إغريقية أسسها مستوطنون من جزيرة ثيرا، وكانت مركزًا للطب والفلسفة. يضم الموقع معبد زيوس ومعبد أبولو والأغورا.',
    storyEn: 'A Greek colony founded by settlers from Thera, a centre of medicine and philosophy. The site includes the Temple of Zeus, the Temple of Apollo and the Agora.',
    history: [
      ('631 ق.م', 'تأسيس المدينة', 'City founded'),
      ('365 م', 'زلزال يدمّر أجزاء كبيرة من المدينة', 'Earthquake destroys much of the city'),
      ('1982', 'إدراج الموقع في قائمة التراث العالمي', 'Listed as a UNESCO World Heritage Site'),
    ],
  ),
  HeritageSite(
    id: 'sabratha', nameAr: 'صبراتة', nameEn: 'Sabratha',
    regionAr: 'صبراتة', regionEn: 'Sabratha', category: 'آثار رومانية',
    eraAr: 'القرن 6 ق.م – القرن 4 م', eraEn: '6th c. BC – 4th c. AD',
    unesco: true, lat: 32.8040, lon: 12.4850,
    status: Preservation.good, icon: Icons.theater_comedy,
    image: '${_commons}Sabratha_Theatre.jpg?width=900',
    storyAr: 'محطة تجارية فينيقية صارت مدينة رومانية مزدهرة. يشتهر مسرحها الضخم بواجهته المكونة من ثلاثة طوابق من الأعمدة.',
    storyEn: 'A Phoenician trading post that became a thriving Roman city. Its huge theatre is famed for a three-storey columned stage front.',
    history: [
      ('القرن 6 ق.م', 'محطة تجارية فينيقية', 'Phoenician trading post'),
      ('القرن 2 م', 'بناء المسرح الروماني', 'Roman theatre built'),
      ('1920–1930', 'إعادة بناء واجهة المسرح', 'Stage front reconstructed'),
    ],
  ),
  HeritageSite(
    id: 'acacus', nameAr: 'تادرارت أكاكوس', nameEn: 'Tadrart Acacus',
    regionAr: 'غات', regionEn: 'Ghat', category: 'نقوش صخرية',
    eraAr: '12000 ق.م – 100 م', eraEn: '12,000 BC – 100 AD',
    unesco: true, lat: 24.8000, lon: 10.5000,
    status: Preservation.critical, icon: Icons.landscape,
    image: '${_commons}Tadrart_Acacus_Libya.jpg?width=900',
    storyAr: 'جبال صحراوية تضم آلاف الرسوم والنقوش الصخرية التي توثق تحولات المناخ وحياة الإنسان في الصحراء الكبرى.',
    storyEn: 'Desert mountains holding thousands of rock paintings and engravings that record climate change and human life in the Sahara.',
    history: [
      ('12000 ق.م', 'أقدم الرسوم المعروفة', 'Earliest known paintings'),
      ('5000 ق.م', 'عصر الرعاة ورسوم الماشية', 'Pastoral period and cattle imagery'),
      ('1985', 'إدراج الموقع في قائمة التراث العالمي', 'Listed as a UNESCO World Heritage Site'),
    ],
  ),
  HeritageSite(
    id: 'ghadames', nameAr: 'غدامس القديمة', nameEn: 'Old Town of Ghadames',
    regionAr: 'غدامس', regionEn: 'Ghadames', category: 'مدن قديمة',
    eraAr: 'العصر الروماني – اليوم', eraEn: 'Roman era – present',
    unesco: true, lat: 30.1337, lon: 9.5000,
    status: Preservation.needsCare, icon: Icons.holiday_village,
    image: '${_commons}Ghadames_old_town.jpg?width=900',
    storyAr: 'لؤلؤة الصحراء؛ مدينة طينية ذات أزقة مسقوفة تقي من الحرارة، وبيوت متصلة بأسطح خاصة بالنساء.',
    storyEn: 'The pearl of the desert: a mud-brick town with covered alleys that shield from heat and linked rooftops used by women.',
    history: [
      ('العصر الروماني', 'واحة «كيداموس» الرومانية', 'Roman oasis of Cydamus'),
      ('القرون الوسطى', 'محطة رئيسية للقوافل التجارية', 'Key caravan trading hub'),
      ('1986', 'إدراجها في قائمة التراث العالمي', 'Listed as a UNESCO World Heritage Site'),
    ],
  ),
  HeritageSite(
    id: 'redcastle', nameAr: 'السرايا الحمراء', nameEn: 'Red Castle of Tripoli',
    regionAr: 'طرابلس', regionEn: 'Tripoli', category: 'قلاع إسلامية',
    eraAr: 'العصور القديمة – العثماني', eraEn: 'Antiquity – Ottoman',
    unesco: false, lat: 32.8997, lon: 13.1850,
    status: Preservation.underTreatment, icon: Icons.fort,
    image: '${_commons}Assai_al-Hamra_Tripoli.jpg?width=900',
    storyAr: 'قلعة مطلة على البحر في قلب طرابلس، توالت عليها حضارات عدة، وتضم اليوم المتحف الوطني.',
    storyEn: 'A seafront fortress in the heart of Tripoli, shaped by many civilisations; it houses the national museum.',
    history: [
      ('العصور القديمة', 'موقع حصين على الساحل', 'Fortified site on the coast'),
      ('العهد العثماني', 'توسعة القلعة واستخدامها قصرًا ومقرًا للحكم', 'Expanded and used as palace and seat of government'),
      ('القرن 20', 'تحويل أجزاء منها إلى متحف', 'Parts converted into a museum'),
    ],
  ),
  HeritageSite(
    id: 'marcus', nameAr: 'قوس ماركوس أوريليوس', nameEn: 'Arch of Marcus Aurelius',
    regionAr: 'طرابلس', regionEn: 'Tripoli', category: 'آثار رومانية',
    eraAr: 'القرن 2 م', eraEn: '2nd c. AD',
    unesco: false, lat: 32.8990, lon: 13.1870,
    status: Preservation.good, icon: Icons.account_balance_outlined,
    image: '${_commons}Arch_of_Marcus_Aurelius_in_Tripoli.jpg?width=900',
    storyAr: 'قوس نصر رخامي شُيّد تكريمًا للإمبراطور ماركوس أوريليوس، وهو أبرز معلم روماني في مدينة طرابلس القديمة.',
    storyEn: 'A marble triumphal arch raised in honour of Emperor Marcus Aurelius, the best-known Roman monument of old Tripoli.',
    history: [
      ('163 م', 'تشييد القوس', 'Arch built'),
      ('القرون الوسطى', 'دفن جزء منه تحت طبقات المدينة', 'Partly buried by the growing city'),
      ('القرن 20', 'الكشف عنه وترميمه', 'Uncovered and restored'),
    ],
  ),
  HeritageSite(
    id: 'ptolemais', nameAr: 'طلميثة - بطوليمايس', nameEn: 'Ptolemais',
    regionAr: 'المرج', regionEn: 'Al Marj', category: 'آثار إغريقية',
    eraAr: 'القرن 3 ق.م – العصر البيزنطي', eraEn: '3rd c. BC – Byzantine',
    unesco: false, lat: 32.7078, lon: 20.9467,
    status: Preservation.needsCare, icon: Icons.view_column,
    image: '${_commons}Ptolemais_Palace_of_Columns.jpg?width=900',
    storyAr: 'مدينة ساحلية هيلينستية سُميت على اسم بطليموس، اشتهرت بقصر الأعمدة وخزانات المياه الضخمة.',
    storyEn: 'A Hellenistic coastal city named for the Ptolemies, known for its Palace of Columns and vast cisterns.',
    history: [
      ('القرن 3 ق.م', 'تأسيس المدينة', 'City founded'),
      ('العصر الروماني', 'ازدهار عمراني وتجاري', 'Urban and commercial boom'),
      ('العصر البيزنطي', 'تراجع المدينة تدريجيًا', 'Gradual decline'),
    ],
  ),
  HeritageSite(
    id: 'apollonia', nameAr: 'أبولونيا', nameEn: 'Apollonia',
    regionAr: 'سوسة', regionEn: 'Susa', category: 'آثار إغريقية',
    eraAr: 'القرن 7 ق.م – العصر البيزنطي', eraEn: '7th c. BC – Byzantine',
    unesco: false, lat: 32.9000, lon: 21.9689,
    status: Preservation.critical, icon: Icons.sailing,
    image: '${_commons}Apollonia_theatre_Libya.jpg?width=900',
    storyAr: 'ميناء قورينا القديم على البحر المتوسط، تضم بقايا كنائس بيزنطية ومسرحًا وحمامات، وتتعرض أجزاء منها للغمر والتآكل البحري.',
    storyEn: 'The ancient port of Cyrene, with Byzantine churches, a theatre and baths; parts are being eroded and submerged by the sea.',
    history: [
      ('القرن 7 ق.م', 'تأسيسها ميناءً لقورينا', 'Founded as Cyrene’s port'),
      ('العصر البيزنطي', 'بناء الكنائس والأسوار', 'Churches and walls built'),
      ('العصر الحديث', 'رصد تآكل بحري وغمر لأجزاء من الموقع', 'Coastal erosion and submergence recorded'),
    ],
  ),
  HeritageSite(
    id: 'qasralhaj', nameAr: 'قصر الحاج', nameEn: 'Qasr al-Haj',
    regionAr: 'الجبل الغربي', regionEn: 'Nafusa Mountains', category: 'مدن قديمة',
    eraAr: 'القرن 13 م تقريبًا', eraEn: 'c. 13th c. AD',
    unesco: false, lat: 31.9167, lon: 12.1167,
    status: Preservation.needsCare, icon: Icons.warehouse,
    image: '${_commons}Qasr_el-Haj_granary_in_Libya.jpg?width=900',
    storyAr: 'مخزن حبوب محصن (قصر) بُني بحجرات مقببة متراصة في طوابق، ويُعد من أجمل نماذج العمارة الأمازيغية للتخزين.',
    storyEn: 'A fortified granary (ksar) of stacked vaulted cells, among the finest examples of Amazigh storage architecture.',
    history: [
      ('القرن 13 م', 'بناء المخزن المحصن', 'Fortified granary built'),
      ('العصر الحديث', 'استخدامه مخزنًا مجتمعيًا للمحاصيل', 'Used as community crop store'),
      ('اليوم', 'مشاريع صيانة للأسقف المقببة', 'Maintenance of vaulted roofs'),
    ],
  ),
  HeritageSite(
    id: 'garama', nameAr: 'جرمة الأثرية', nameEn: 'Garama',
    regionAr: 'فزان', regionEn: 'Fezzan', category: 'مدن قديمة',
    eraAr: 'القرن 1 ق.م – القرن 7 م', eraEn: '1st c. BC – 7th c. AD',
    unesco: false, lat: 26.5400, lon: 12.7300,
    status: Preservation.needsCare, icon: Icons.account_balance,
    image: '${_commons}Germa_ruins_Libya.jpg?width=900',
    storyAr: 'عاصمة الجرمنتيين، حضارة صحراوية متقدمة اعتمدت على قنوات الفقارة لجلب المياه الجوفية وتحكمت في تجارة القوافل.',
    storyEn: 'Capital of the Garamantes, an advanced desert civilisation that used foggara tunnels to tap groundwater and ran the caravan trade.',
    history: [
      ('القرن 1 ق.م', 'صعود مملكة الجرمنتيين', 'Rise of the Garamantian kingdom'),
      ('القرن 1 م', 'ازدهار التجارة مع روما', 'Trade with Rome flourishes'),
      ('القرن 7 م', 'انحسار المدينة', 'City declines'),
    ],
  ),
  HeritageSite(
    id: 'silin', nameAr: 'فيلا سيلين', nameEn: 'Villa Silin',
    regionAr: 'الخمس', regionEn: 'Khoms', category: 'آثار رومانية',
    eraAr: 'القرن 1–2 م', eraEn: '1st–2nd c. AD',
    unesco: false, lat: 32.5500, lon: 14.4500,
    status: Preservation.underTreatment, icon: Icons.grid_view,
    image: '${_commons}Villa_Silin_Mosaic.jpg?width=900',
    storyAr: 'فيلا رومانية ساحلية فاخرة اشتهرت بفسيفسائها الأرضية الملونة التي تصور مشاهد من الحياة اليومية والأساطير.',
    storyEn: 'A luxurious Roman coastal villa famed for its colourful floor mosaics of daily life and mythology.',
    history: [
      ('القرن 1–2 م', 'بناء الفيلا وزخرفتها بالفسيفساء', 'Villa built and decorated with mosaics'),
      ('العصر الحديث', 'اكتشاف الفسيفساء ونقل أجزاء منها', 'Mosaics uncovered; some moved'),
      ('اليوم', 'أعمال تثبيت وتنظيف للفسيفساء', 'Mosaic stabilisation and cleaning'),
    ],
  ),
  HeritageSite(
    id: 'gaberoun', nameAr: 'بحيرات قبرعون', nameEn: 'Gaberoun Oasis',
    regionAr: 'صحراء أوباري', regionEn: 'Ubari Desert', category: 'واحات طبيعية',
    eraAr: 'طبيعي', eraEn: 'Natural',
    unesco: false, lat: 26.5800, lon: 12.7700,
    status: Preservation.good, icon: Icons.water,
    image: '${_commons}Ubari_Lakes_Libya.jpg?width=900',
    storyAr: 'بحيرات مالحة وسط كثبان رملية ضخمة في صحراء أوباري، تحيط بها أشجار النخيل وتمثل بقايا مناخ أكثر رطوبة.',
    storyEn: 'Salt lakes set among giant dunes in the Ubari sand sea, ringed by palms — remnants of a wetter climate.',
    history: [
      ('عصور ما قبل التاريخ', 'تكوّن البحيرات من مياه جوفية', 'Lakes formed from groundwater'),
      ('العصر الحديث', 'سكن الطوارق حول الواحة', 'Tuareg communities settle nearby'),
      ('اليوم', 'مقصد سياحي صحراوي', 'Desert tourism destination'),
    ],
  ),
  HeritageSite(
    id: 'waw', nameAr: 'واو الناموس', nameEn: 'Waw an Namus',
    regionAr: 'فزان', regionEn: 'Fezzan', category: 'واحات طبيعية',
    eraAr: 'طبيعي - بركاني', eraEn: 'Natural – volcanic',
    unesco: false, lat: 24.9500, lon: 17.7500,
    status: Preservation.good, icon: Icons.volcano,
    image: '${_commons}Waw_an_Namus_ISS013-E-21583.jpg?width=900',
    storyAr: 'فوهة بركانية خامدة في قلب الصحراء، فيها بحيرات صغيرة ملونة محاطة برمال سوداء، وتُعرف بـ«واحة البعوض».',
    storyEn: 'An extinct volcanic caldera deep in the desert with small coloured lakes in black ash — nicknamed the “Mosquito Oasis”.',
    history: [
      ('عصور جيولوجية', 'تكوّن الفوهة البركانية', 'Caldera formed by volcanism'),
      ('العصر الحديث', 'توثيق الموقع علميًا', 'Scientific documentation'),
      ('اليوم', 'مقصد للمغامرين والباحثين', 'Destination for explorers and researchers'),
    ],
  ),
];

class RestorationLog {
  final String siteName, materials, report;
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

// ─────────────────────────────── State ──────────────────────────────────────

class AppState extends ChangeNotifier {
  bool dark = false;
  bool ar = true;
  bool notifications = true;
  bool loggedIn = false;
  bool offline = false;
  bool loadingLogs = false;
  UserRole role = UserRole.tourist;
  String name = '', email = '', title = '', bio = '', license = '';
  String city = '', specialization = '';
  bool startOnSignup = false;
  int tab = 0;
  String query = '';
  String category = kAll;
  String? notice;

  SharedPreferences? _prefs;

  final List<RestorationLog> logs = [
    RestorationLog(
      siteName: 'لبدة الكبرى',
      materials: 'Nano-Lime Ca(OH)₂, Paraloid B-72',
      report: 'تثبيت أحجار الرصيف الشمالي وإزالة الأملاح المتبلورة. الضرر: تآكل متوسط.',
      createdAt: DateTime(2026, 10, 28),
      synced: false,
    ),
    RestorationLog(
      siteName: 'غدامس القديمة',
      materials: 'Lime mortar, hydrated lime',
      report: 'إعادة ترميم سقف الزقاق الشرقي بعد تشققات ناتجة عن الأمطار.',
      createdAt: DateTime(2026, 10, 12),
      synced: false,
    ),
  ];

  String t(String a, String e) => ar ? a : e;

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ── preferences ──
  Future<void> loadPrefs() async {
    try {
      final p = _prefs = await SharedPreferences.getInstance();
      dark = p.getBool('dark') ?? false;
      ar = p.getBool('ar') ?? true;
      notifications = p.getBool('notifications') ?? true;
      loggedIn = p.getBool('loggedIn') ?? false;
      role = (p.getString('role') ?? 'tourist') == 'expert'
          ? UserRole.expert
          : UserRole.tourist;
      name = p.getString('name') ?? '';
      email = p.getString('email') ?? '';
      title = p.getString('title') ?? '';
      bio = p.getString('bio') ?? '';
      license = p.getString('license') ?? '';
      city = p.getString('city') ?? '';
      specialization = p.getString('specialization') ?? '';
    } catch (e) {
      debugPrint('[ERTH] prefs load failed: $e');
    }
  }

  Future<void> _save() async {
    try {
      final p = _prefs ??= await SharedPreferences.getInstance();
      await p.setBool('dark', dark);
      await p.setBool('ar', ar);
      await p.setBool('notifications', notifications);
      await p.setBool('loggedIn', loggedIn);
      await p.setString('role', role == UserRole.expert ? 'expert' : 'tourist');
      await p.setString('name', name);
      await p.setString('email', email);
      await p.setString('title', title);
      await p.setString('bio', bio);
      await p.setString('license', license);
      await p.setString('city', city);
      await p.setString('specialization', specialization);
    } catch (e) {
      debugPrint('[ERTH] prefs save failed: $e');
    }
  }

  void toggleDark() {
    dark = !dark;
    notifyListeners();
    _save();
  }

  void toggleLang() {
    ar = !ar;
    notifyListeners();
    _save();
  }

  void setNotifications(bool v) {
    notifications = v;
    notifyListeners();
    _save();
  }

  /// True only the very first time (marks the install prompt as seen).
  Future<bool> consumeInstallPrompt() async {
    try {
      final p = _prefs ??= await SharedPreferences.getInstance();
      if (p.getBool('has_seen_install_prompt') ?? false) return false;
      await p.setBool('has_seen_install_prompt', true);
      return true;
    } catch (e) {
      debugPrint('[ERTH] install prompt flag failed: $e');
      return false;
    }
  }

  // ── auth ──
  Future<String?> login(String mail, String password) async {
    final c = _client;
    if (c != null) {
      try {
        final res =
            await c.auth.signInWithPassword(email: mail, password: password);
        final meta = res.user?.userMetadata ?? {};
        _enter(
          mail: mail,
          fullName: '${meta['full_name'] ?? mail.split('@').first}',
          r: meta['role'] == 'expert' ? UserRole.expert : UserRole.tourist,
          lic: '${meta['license'] ?? ''}',
          cityName: '${meta['city'] ?? city}',
          spec: '${meta['specialization'] ?? specialization}',
        );
        return null;
      } on AuthException catch (e) {
        return e.message;
      } catch (e) {
        debugPrint('[ERTH] login offline fallback: $e');
      }
    }
    _enter(
        mail: mail,
        fullName: name.isNotEmpty && email == mail ? name : mail.split('@').first,
        r: role,
        lic: license,
        cityName: city,
        spec: specialization);
    notice = t('تم الدخول محليًا (بدون اتصال بالخادم)',
        'Signed in locally (server unreachable)');
    return null;
  }

  Future<String?> signUp({
    required String mail,
    required String password,
    required String fullName,
    required UserRole r,
    required String lic,
    String cityName = '',
    String spec = '',
  }) async {
    final c = _client;
    if (c != null) {
      try {
        final res = await c.auth.signUp(
          email: mail,
          password: password,
          data: {
            'full_name': fullName,
            'role': r == UserRole.expert ? 'expert' : 'tourist',
            'license': lic,
            'city': cityName,
            'specialization': spec,
          },
        );
        _enter(
            mail: mail, fullName: fullName, r: r, lic: lic, cityName: cityName, spec: spec);
        if (res.session == null) {
          notice = t('تحقق من بريدك الإلكتروني لتأكيد الحساب',
              'Check your email to confirm your account');
        }
        return null;
      } on AuthException catch (e) {
        final limited = e.statusCode == '429' ||
            e.message.toLowerCase().contains('rate limit');
        if (!limited) return e.message;
        debugPrint('[ERTH] signup rate-limited, continuing locally: ${e.message}');
      } catch (e) {
        debugPrint('[ERTH] signup offline fallback: $e');
      }
    }
    _enter(
        mail: mail, fullName: fullName, r: r, lic: lic, cityName: cityName, spec: spec);
    notice = t('تم إنشاء الحساب محليًا (بدون اتصال بالخادم)',
        'Account created locally (server unreachable)');
    return null;
  }

  void quickDemo(UserRole r) {
    _enter(
      mail: r == UserRole.expert ? 'expert@erth.demo' : 'guest@erth.demo',
      fullName: r == UserRole.expert ? 'د. خبير مرمم' : 'زائر تجريبي',
      r: r,
      lic: r == UserRole.expert ? 'LY-CONS-0001' : '',
    );
  }

  void _enter({
    required String mail,
    required String fullName,
    required UserRole r,
    required String lic,
    String cityName = '',
    String spec = '',
  }) {
    city = cityName;
    specialization = spec;
    email = mail;
    name = fullName;
    role = r;
    license = lic;
    if (title.isEmpty) {
      title = r == UserRole.expert ? 'Conservator' : 'Visitor';
    }
    loggedIn = true;
    tab = 0;
    notifyListeners();
    _save();
    loadLogs();
  }

  /// Log out; optionally land on the Register tab (for "create another account").
  void logout({bool toSignup = false}) {
    startOnSignup = toSignup;
    try {
      _client?.auth.signOut();
    } catch (e) {
      debugPrint('[ERTH] signOut failed: $e');
    }
    loggedIn = false;
    tab = 0;
    notifyListeners();
    _save();
  }

  void updateProfile({
    required String newName,
    required String newEmail,
    required String newTitle,
    required String newBio,
    String? newCity,
    String? newSpec,
    String? newLicense,
  }) {
    city = newCity ?? city;
    specialization = newSpec ?? specialization;
    license = newLicense ?? license;
    name = newName;
    email = newEmail;
    title = newTitle;
    bio = newBio;
    notifyListeners();
    _save();
  }

  void setRole(UserRole r) {
    role = r;
    notifyListeners();
    _save();
  }

  Future<String?> changePassword(String newPassword) async {
    final c = _client;
    if (c == null || c.auth.currentSession == null) {
      return t('لا توجد جلسة نشطة على الخادم؛ سجّل الدخول بحساب حقيقي أولًا',
          'No active server session; sign in with a real account first');
    }
    try {
      await c.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('[ERTH] change password failed: $e');
      return t('تعذر الاتصال بالخادم', 'Could not reach the server');
    }
  }

  // ── navigation / filters ──
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

  List<HeritageSite> get filteredSites {
    final q = query.trim().toLowerCase();
    return kSites.where((s) {
      final okCat = category == kAll || s.category == category;
      final okQ = q.isEmpty ||
          s.nameAr.contains(q) ||
          s.nameEn.toLowerCase().contains(q) ||
          s.regionAr.contains(q) ||
          s.regionEn.toLowerCase().contains(q);
      return okCat && okQ;
    }).toList();
  }

  int get approvedReports => logs.length;
  int get underTreatment =>
      kSites.where((s) => s.status == Preservation.underTreatment).length;
  int get urgentAlerts =>
      kSites.where((s) => s.status == Preservation.critical).length;

  // ── restoration logs (Supabase with local fallback) ──
  Future<void> loadLogs() async {
    final c = _client;
    if (c == null) {
      offline = true;
      notifyListeners();
      return;
    }
    loadingLogs = true;
    notifyListeners();
    try {
      final artifacts = await c.from('artifacts').select('id, name');
      final names = <String, String>{
        for (final a in (artifacts as List)) '${a['id']}': '${a['name']}',
      };
      final rows = await c
          .from('restoration_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      final remote = (rows as List).map((r) {
        final en = names['${r['artifact_id']}'];
        final site = kSites.where((s) => s.nameEn == en).firstOrNull;
        return RestorationLog(
          siteName: site?.nameAr ?? en ?? 'موقع أثري',
          materials: '${r['chemical_materials'] ?? ''}',
          report: '${r['technical_report'] ?? ''}',
          createdAt:
              DateTime.tryParse('${r['created_at']}')?.toLocal() ?? DateTime.now(),
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

  Future<bool> addLog({
    required String siteName,
    required String materials,
    required String report,
  }) async {
    var synced = false;
    final c = _client;
    if (c != null) {
      try {
        String? artifactId;
        final needle = siteName.trim().toLowerCase();
        final match = kSites
            .where((s) =>
                s.nameAr == siteName.trim() || s.nameEn.toLowerCase() == needle)
            .firstOrNull;
        if (match != null) {
          final res = await c
              .from('artifacts')
              .select('id')
              .eq('name', match.nameEn)
              .limit(1);
          if ((res as List).isNotEmpty) artifactId = '${res.first['id']}';
        }
        await c.from('restoration_logs').insert({
          'artifact_id': artifactId,
          'expert_id': c.auth.currentUser?.id,
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
  final AppState state;
  const ErthApp({super.key, required this.state});

  @override
  State<ErthApp> createState() => _ErthAppState();
}

class _ErthAppState extends State<ErthApp> {
  final _navKey = GlobalKey<NavigatorState>();
  Timer? _installTimer;

  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    _installTimer = Timer(const Duration(milliseconds: 1500), _maybeShowInstall);
  }

  @override
  void dispose() {
    _installTimer?.cancel();
    super.dispose();
  }

  Future<void> _maybeShowInstall() async {
    if (pwaIsStandalone()) return;
    if (!await state.consumeInstallPrompt()) return;
    final ctx = _navKey.currentState?.overlay?.context;
    if (ctx == null || !ctx.mounted) return;
    showInstallSheet(ctx, state);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        navigatorKey: _navKey,
        title: 'إرث | ERTH',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => Directionality(
          textDirection: state.ar ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.loggedIn
              ? AppShell(key: const ValueKey('shell'), state: state)
              : AuthScreen(key: const ValueKey('auth'), state: state),
        ),
      ),
    );
  }
}

// Language + theme controls shared by the AppBar and the auth screen.
List<Widget> topControls(BuildContext context, AppState s,
    {bool account = false}) {
  final narrow = MediaQuery.of(context).size.width < 720;
  final p = Pal.of(context);
  return [
    if (!pwaIsStandalone())
      narrow
          ? IconButton(
              tooltip: s.t('تنزيل التطبيق', 'Download app'),
              onPressed: () => installApp(context, s),
              icon: Icon(Icons.download_for_offline, color: p.accent),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                avatar: const Icon(Icons.download, size: 18, color: Colors.black),
                label: Text(s.t('تنزيل التطبيق', 'Download app'),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700)),
                backgroundColor: p.accent,
                side: BorderSide.none,
                onPressed: () => installApp(context, s),
              ),
            ),
    ..._langTheme(s),
    if (account)
      PopupMenuButton<String>(
        tooltip: s.t('الحساب', 'Account'),
        icon: const Icon(Icons.account_circle),
        onSelected: (v) {
          if (v == 'register') {
            s.logout(toSignup: true);
          } else {
            s.logout();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            enabled: false,
            child: Text(s.name.isEmpty ? s.email : s.name,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          PopupMenuItem(
              value: 'switch',
              child: Text(s.t('تبديل الحساب', 'Switch account'))),
          PopupMenuItem(
              value: 'register',
              child: Text(s.t('إنشاء حساب جديد', 'Register new account'))),
          PopupMenuItem(
              value: 'logout', child: Text(s.t('تسجيل الخروج', 'Log out'))),
        ],
      ),
  ];
}

List<Widget> _langTheme(AppState s) => [
      TextButton(
        onPressed: s.toggleLang,
        child: Text(s.ar ? 'EN' : 'AR',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      IconButton(
        tooltip: s.t('تبديل المظهر', 'Toggle theme'),
        onPressed: s.toggleDark,
        icon: Icon(s.dark ? Icons.light_mode : Icons.dark_mode),
      ),
    ];

// ─────────────────────────────── Auth ───────────────────────────────────────

class AuthScreen extends StatefulWidget {
  final AppState state;
  const AuthScreen({super.key, required this.state});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _license = TextEditingController();
  final _city = TextEditingController();
  final _confirm = TextEditingController();
  final _spec = TextEditingController();
  bool signup = false;
  bool busy = false;
  bool hide = true;
  UserRole role = UserRole.tourist;
  String? error;

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    signup = s.startOnSignup;
    s.startOnSignup = false;
  }

  @override
  void dispose() {
    _city.dispose();
    _confirm.dispose();
    _spec.dispose();
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _license.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    final err = signup
        ? await s.signUp(
            mail: _email.text.trim(),
            password: _pass.text,
            fullName: _name.text.trim(),
            r: role,
            lic: _license.text.trim(),
            cityName: _city.text.trim(),
            spec: _spec.text.trim(),
          )
        : await s.login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() {
      busy = false;
      error = err;
    });
    if (err == null && s.notice != null) {
      final msg = s.notice!;
      s.notice = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _tab(String label, bool on, VoidCallback tap) {
    final p = Pal.of(context);
    return Expanded(
      child: InkWell(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: on ? p.primary : p.line, width: on ? 3 : 1)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: on ? p.primary : p.text2)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    String? req(String? v) =>
        (v == null || v.trim().isEmpty) ? s.t('هذا الحقل مطلوب', 'Required') : null;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: topControls(context, s),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ErthLogo(size: 84),
                      const SizedBox(height: 8),
                      Text(s.t('منصة التراث الليبي', 'Libyan Heritage Platform'),
                          style: TextStyle(color: p.text2)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: p.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: p.line),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                _tab(s.t('تسجيل الدخول', 'Login'), !signup,
                                    () => setState(() => signup = false)),
                                _tab(s.t('إنشاء حساب جديد', 'Register'), signup,
                                    () => setState(() => signup = true)),
                              ]),
                              const SizedBox(height: 16),
                              SegmentedButton<UserRole>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                      value: UserRole.tourist,
                                      icon: const Icon(Icons.hiking, size: 18),
                                      label: Text(s.t('زائر / سائح', 'Visitor'))),
                                  ButtonSegment(
                                      value: UserRole.expert,
                                      icon: const Icon(Icons.verified, size: 18),
                                      label: Text(
                                          s.t('خبير مرمم معتمد', 'Conservator'))),
                                ],
                                selected: {role},
                                onSelectionChanged: (v) =>
                                    setState(() => role = v.first),
                              ),
                              const SizedBox(height: 14),
                              if (signup) ...[
                                TextFormField(
                                  controller: _name,
                                  validator: req,
                                  decoration: InputDecoration(
                                      labelText: s.t('الاسم الكامل', 'Full name'),
                                      prefixIcon: const Icon(Icons.person_outline)),
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    (v == null || !v.contains('@') || !v.contains('.'))
                                        ? s.t('بريد إلكتروني غير صالح', 'Invalid email')
                                        : null,
                                decoration: InputDecoration(
                                    labelText: s.t('البريد الإلكتروني', 'Email'),
                                    prefixIcon: const Icon(Icons.mail_outline)),
                              ),
                              if (signup) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _city,
                                  validator: req,
                                  decoration: InputDecoration(
                                      labelText: s.t('المدينة / الهاتف', 'City / phone'),
                                      prefixIcon: const Icon(Icons.location_city)),
                                ),
                              ],
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _pass,
                                obscureText: hide,
                                validator: (v) => (v == null || v.length < 6)
                                    ? s.t('6 أحرف على الأقل', 'At least 6 characters')
                                    : null,
                                decoration: InputDecoration(
                                  labelText: s.t('كلمة المرور', 'Password'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(hide
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(() => hide = !hide),
                                  ),
                                ),
                              ),
                              if (signup) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _confirm,
                                  obscureText: hide,
                                  validator: (v) => v != _pass.text
                                      ? s.t('كلمتا المرور غير متطابقتين',
                                          'Passwords do not match')
                                      : null,
                                  decoration: InputDecoration(
                                      labelText: s.t('تأكيد كلمة المرور', 'Confirm password'),
                                      prefixIcon: const Icon(Icons.lock_outline)),
                                ),
                              ],
                              if (signup && role == UserRole.expert) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _spec,
                                  validator: req,
                                  decoration: InputDecoration(
                                      labelText: s.t('التخصص الدقيق', 'Academic specialization'),
                                      prefixIcon: const Icon(Icons.school_outlined)),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _license,
                                  validator: req,
                                  decoration: InputDecoration(
                                      labelText: s.t('رقم العضوية / التصريح', 'Membership / license no.'),
                                      prefixIcon: const Icon(Icons.badge_outlined)),
                                ),
                              ],
                              if (error != null) ...[
                                const SizedBox(height: 10),
                                Text(error!,
                                    style: const TextStyle(color: Color(0xFFD64535))),
                              ],
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: busy ? null : _submit,
                                  child: busy
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : Text(
                                          signup
                                              ? s.t('إنشاء حساب', 'Create account')
                                              : s.t('دخول', 'Login'),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: p.accent,
                                    side: BorderSide(color: p.accent),
                                    minimumSize: const Size.fromHeight(48)),
                                onPressed: () => s.quickDemo(role),
                                icon: const Icon(Icons.bolt),
                                label: Text(
                                    s.t('دخول سريع (تجريبي)', 'Quick demo access')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final s = state;
    final p = Pal.of(context);
    final isExpert = s.role == UserRole.expert;
    final pages = <Widget>[
      HomeTab(state: s),
      SitesTab(state: s),
      ScannerTab(state: s),
      LogsTab(state: s),
      AccountTab(state: s),
    ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const ErthLogo(size: 34),
        actions: topControls(context, s, account: true),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: p.line),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(s.tab), child: pages[s.tab]),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isExpert && s.tab == 3) ...[
            FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: p.accent,
              foregroundColor: Colors.black,
              onPressed: () => showAddLogSheet(context, s),
              icon: const Icon(Icons.add),
              label: Text(s.t('إضافة تقرير ترميم فني', 'Add restoration report'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton.extended(
            heroTag: null,
            backgroundColor: p.primary,
            foregroundColor: Colors.white,
            onPressed: () => showChatSheet(context, s),
            icon: const Icon(Icons.auto_awesome),
            label: Text(s.t('المرشد الأثري الذكي', 'AI Heritage Guide'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: s.tab,
        onDestinationSelected: s.setTab,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: p.primary),
              label: s.t('الرئيسية', 'Home')),
          NavigationDestination(
              icon: const Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance, color: p.primary),
              label: s.t('المواقع', 'Sites')),
          NavigationDestination(
              icon: const Icon(Icons.document_scanner_outlined),
              selectedIcon: Icon(Icons.document_scanner, color: p.primary),
              label: s.t('الماسح', 'Scanner')),
          NavigationDestination(
              icon: const Icon(Icons.history_edu_outlined),
              selectedIcon: Icon(Icons.history_edu, color: p.primary),
              label: s.t('سجل الترميم', 'Logs')),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: p.primary),
              label: s.t('الحساب', 'Account')),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared widgets ─────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final AppState s;
  const _OfflineBanner(this.s);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(Icons.cloud_off, size: 18, color: p.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
              s.t('وضع محلي: تُعرض بيانات تجريبية ولم تتم المزامنة مع الخادم.',
                  'Local mode: showing demo data, not synced with the server.'),
              style: const TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Preservation status;
  final bool ar;
  const _StatusBadge(this.status, this.ar);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status.label(ar),
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    );
  }
}

class _Illustration extends StatelessWidget {
  final HeritageSite site;
  const _Illustration(this.site);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.accent.withValues(alpha: 0.55), p.primary.withValues(alpha: 0.85)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.35,
            child: CustomPaint(
                size: const Size(110, 110),
                painter: _ArchPainter(Colors.white, Colors.white)),
          ),
          Positioned(
            bottom: 10,
            child: Icon(site.icon, size: 26, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class SiteImage extends StatelessWidget {
  final HeritageSite site;
  const SiteImage(this.site, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      site.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, __, ___) => _Illustration(site),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _Illustration(site),
    );
  }
}

class SiteCard extends StatefulWidget {
  final HeritageSite site;
  final AppState state;
  const SiteCard({super.key, required this.site, required this.state});

  @override
  State<SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends State<SiteCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final s = widget.site;
    final ar = widget.state.ar;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: GestureDetector(
          onTap: () => showSiteSheet(context, widget.state, s),
          child: Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: hover ? 0.22 : 0.08),
                    blurRadius: hover ? 22 : 10,
                    offset: const Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                    SiteImage(s),
                    PositionedDirectional(
                        top: 10, start: 10, child: _StatusBadge(s.status, ar)),
                    if (s.unesco)
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: p.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.public,
                              size: 16, color: Colors.black),
                        ),
                      ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name(ar),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(s.era(ar),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.text2, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.place, size: 15, color: p.accent),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(s.region(ar),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                              ar ? s.category : kCategoryEn[s.category]!,
                              style: TextStyle(fontSize: 11, color: p.primary)),
                        ),
                      ]),
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

void showSiteSheet(BuildContext context, AppState state, HeritageSite s) {
  final p = Pal.of(context);
  final ar = state.ar;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.bg,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetCtx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(height: 230, child: SiteImage(s)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Text(s.name(ar),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ),
            _StatusBadge(s.status, ar),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(
                avatar: Icon(Icons.place, size: 16, color: p.accent),
                label: Text(s.region(ar))),
            Chip(label: Text(ar ? s.category : kCategoryEn[s.category]!)),
            Chip(
                avatar: Icon(Icons.schedule, size: 16, color: p.accent),
                label: Text(s.era(ar))),
            if (s.unesco)
              Chip(
                  avatar: Icon(Icons.public, size: 16, color: p.accent),
                  label: Text(ar ? 'تراث عالمي - اليونسكو' : 'UNESCO World Heritage')),
            Chip(
                avatar: Icon(Icons.my_location, size: 16, color: p.accent),
                label: Text(
                    '${s.lat.toStringAsFixed(4)}°N, ${s.lon.toStringAsFixed(4)}°E')),
          ]),
          const SizedBox(height: 16),
          Text(ar ? 'القصة والتراث' : 'Story & heritage',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: p.primary)),
          const SizedBox(height: 8),
          Text(s.story(ar), style: const TextStyle(height: 1.8, fontSize: 15)),
          const SizedBox(height: 20),
          Text(ar ? 'تاريخ الموقع والترميم' : 'Site & restoration history',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: p.primary)),
          const SizedBox(height: 12),
          for (final h in s.history)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(color: p.primary, shape: BoxShape.circle)),
                  Container(width: 2, height: 28, color: p.line),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.$1,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: p.accent)),
                      Text(ar ? h.$2 : h.$3),
                    ],
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              showChatSheet(
                context,
                state,
                initial: ar
                    ? 'حدثني عن ${s.nameAr} وأهم ما يميزها'
                    : 'Tell me about ${s.nameEn} and what makes it special',
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: Text(ar ? 'اسأل المرشد الذكي عن هذا الموقع' : 'Ask the AI guide about this site'),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────── Home ───────────────────────────────────────

class HomeTab extends StatelessWidget {
  final AppState state;
  const HomeTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final p = Pal.of(context);
    final isExpert = s.role == UserRole.expert;
    final unesco = kSites.where((x) => x.unesco).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [p.primary, p.primary.withValues(alpha: 0.75)],
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    s.name.isEmpty
                        ? s.t('مرحبًا بك', 'Welcome')
                        : s.t('مرحبًا، ${s.name}', 'Welcome, ${s.name}'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                    isExpert
                        ? s.t('لوحة متابعة أعمال الترميم والعتاد',
                            'Restoration and equipment dashboard')
                        : s.t('رحلة عبر آلاف السنين من الحضارات',
                            'A journey through thousands of years of civilisation'),
                    style: const TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.account_balance, size: 54, color: Color(0xFFE9CD7A)),
          ]),
        ),
        const SizedBox(height: 18),
        if (s.offline) _OfflineBanner(s),
        LayoutBuilder(builder: (context, c) {
          final cards = isExpert
              ? [
                  _Kpi(s.t('تقارير معتمدة', 'Approved reports'),
                      '${s.approvedReports}', Icons.verified, p.accent),
                  _Kpi(s.t('مواقع قيد المعالجة', 'Sites in treatment'),
                      '${s.underTreatment}', Icons.construction, const Color(0xFFD9772F)),
                  _Kpi(s.t('تنبيهات طارئة', 'Urgent alerts'), '${s.urgentAlerts}',
                      Icons.warning_amber_rounded, const Color(0xFFD64535)),
                ]
              : [
                  _Kpi(s.t('موقعًا في الدليل', 'Sites in catalog'),
                      '${kSites.length}', Icons.account_balance, p.primary),
                  _Kpi(s.t('مواقع اليونسكو', 'UNESCO sites'), '$unesco',
                      Icons.public, p.accent),
                  _Kpi(s.t('قصص وتواريخ', 'Stories'), '${kSites.length}',
                      Icons.menu_book, const Color(0xFF4E9A5C)),
                ];
          return c.maxWidth > 640
              ? Row(children: [for (final k in cards) Expanded(child: k)])
              : Column(children: cards);
        }),
        if (isExpert) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50)),
            onPressed: () => s.setTab(2),
            icon: const Icon(Icons.document_scanner),
            label: Text(s.t('ماسح العتاد والآثار', 'Equipment & artifact scanner'),
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
        const SizedBox(height: 22),
        Text(
            isExpert
                ? s.t('مواقع تحتاج اهتمامًا', 'Sites needing attention')
                : s.t('مواقع مميزة', 'Featured sites'),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final x in (isExpert
                  ? kSites.where((x) =>
                      x.status == Preservation.critical ||
                      x.status == Preservation.underTreatment)
                  : kSites.where((x) => x.unesco)))
                SizedBox(
                  width: 270,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: SiteCard(site: x, state: s),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: () => s.setTab(1),
          icon: const Icon(Icons.search),
          label: Text(s.t('استعرض جميع المواقع الـ 14', 'Browse all 14 sites')),
        ),
        const SizedBox(height: 90),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(color: p.text2)),
            ]),
          ),
        ]),
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
    final s = state;
    final p = Pal.of(context);
    final sites = s.filteredSites;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: TextField(
          onChanged: s.setQuery,
          decoration: InputDecoration(
            hintText: s.t('ابحث عن موقع أثري...', 'Search heritage sites...'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ),
      SizedBox(
        height: 54,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: kCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = kCategories[i];
            final on = s.category == c;
            return ChoiceChip(
              label: Text(s.ar ? c : kCategoryEn[c]!),
              selected: on,
              showCheckmark: false,
              elevation: on ? 3 : 0,
              pressElevation: 5,
              backgroundColor: p.card,
              selectedColor: p.primary,
              labelStyle: TextStyle(
                  color: on ? Colors.white : p.text, fontWeight: FontWeight.w600),
              side: BorderSide(color: on ? p.accent : p.line),
              onSelected: (_) => s.setCategory(c),
            );
          },
        ),
      ),
      Expanded(
        child: sites.isEmpty
            ? Center(
                child: Text(s.t('لا توجد مواقع مطابقة', 'No matching sites'),
                    style: TextStyle(color: p.text2)))
            : LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 330,
                  ),
                  itemCount: sites.length,
                  itemBuilder: (_, i) => SiteCard(site: sites[i], state: s),
                );
              }),
      ),
    ]);
  }
}

// ─────────────────────────────── Scanner ────────────────────────────────────

class _Material {
  final String ar, en, formula, batch, payload;
  final DateTime expiry;
  final String useAr, useEn;
  const _Material(this.ar, this.en, this.formula, this.batch, this.payload,
      this.expiry, this.useAr, this.useEn);
}

final _materials = <_Material>[
  _Material('بارالويد B-72', 'Paraloid B-72', 'Acrylic copolymer', 'PB-2407',
      'ERTH-MAT:PB72:PB-2407', DateTime(2027, 9, 30),
      'مثبّت وراتنج لاصق للحجر والسيراميك', 'Consolidant and adhesive for stone and ceramics'),
  _Material('جير نانوي', 'Nano-Lime Ca(OH)₂', 'Ca(OH)₂', 'NL-1192',
      'ERTH-MAT:NLIME:NL-1192', DateTime(2027, 3, 15),
      'تثبيت الحجر الجيري المتفتت', 'Consolidation of friable limestone'),
  _Material('سيليكات الإيثيل', 'Ethyl Silicate', 'Si(OC₂H₅)₄', 'ES-0558',
      'ERTH-MAT:ETSIL:ES-0558', DateTime.now().add(const Duration(days: 30)),
      'تقوية الأحجار الرملية', 'Strengthening of sandstone'),
  _Material('شمع دقيق التبلور', 'Micro-crystalline Wax', 'Hydrocarbon wax', 'MW-8841',
      'ERTH-MAT:MCWAX:MW-8841', DateTime(2026, 6, 30),
      'طبقة حماية نهائية للمعادن والحجر', 'Final protective coating for metal and stone'),
];

class _Finding {
  final String ar, en, recAr, recEn;
  final double severity;
  final String chemicals;
  const _Finding(this.ar, this.en, this.recAr, this.recEn, this.severity,
      this.chemicals);
}

const _findings = <_Finding>[
  _Finding('تآكل سطح الحجر', 'Stone surface erosion',
      'تنظيف ميكانيكي لطيف ثم تثبيت بالجير النانوي وتكرار التطبيق حتى التشبع.',
      'Gentle mechanical cleaning, then consolidate with nano-lime until saturation.',
      0.62, 'Nano-Lime Ca(OH)₂'),
  _Finding('تزهّر الأملاح', 'Salt efflorescence',
      'إزالة الأملاح بكمادات الورق المبلل، ومعالجة مصدر الرطوبة قبل أي تثبيت.',
      'Desalinate with wet-paper poultices and fix the moisture source before consolidating.',
      0.74, 'Deionized water poultice, Paraloid B-72 (after drying)'),
  _Finding('شقوق إنشائية', 'Structural cracks',
      'رصد الحركة بمقاييس الشقوق، ثم حقن ملاط جيري مرن ودعم مؤقت للعناصر المتأثرة.',
      'Monitor movement with crack gauges, then inject flexible lime grout and add temporary support.',
      0.88, 'Hydraulic lime grout, Ethyl Silicate'),
];

class ScannerTab extends StatefulWidget {
  final AppState state;
  const ScannerTab({super.key, required this.state});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laser = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  final _picker = ImagePicker();
  int mode = 0; // 0 equipment, 1 diagnosis
  Uint8List? image;
  bool scanning = false;
  int counter = 0;
  _Material? mat;
  _Finding? finding;

  AppState get s => widget.state;

  @override
  void dispose() {
    _laser.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final f = await _picker.pickImage(source: src, maxWidth: 1400);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      if (!mounted) return;
      setState(() => image = bytes);
      await _scan(seed: bytes.length);
    } catch (e) {
      debugPrint('[ERTH] image pick failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.t('تعذر الوصول إلى الكاميرا/الملفات',
              'Could not access camera/files'))));
    }
  }

  Future<void> _scan({int? seed}) async {
    setState(() {
      scanning = true;
      mat = null;
      finding = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    counter++;
    final n = (seed ?? 0) + counter;
    setState(() {
      scanning = false;
      if (mode == 0) {
        mat = _materials[n % _materials.length];
      } else {
        finding = _findings[n % _findings.length];
      }
    });
  }

  ({String label, Color color}) _expiry(_Material m) {
    final days = m.expiry.difference(DateTime.now()).inDays;
    if (days < 0) {
      return (label: s.t('منتهي الصلاحية', 'Expired'), color: const Color(0xFFD64535));
    }
    if (days < 60) {
      return (label: s.t('قارب على الانتهاء', 'Expiring soon'), color: const Color(0xFFD9772F));
    }
    return (label: s.t('صالح', 'Valid'), color: const Color(0xFF4E9A5C));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final isExpert = s.role == UserRole.expert;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text(s.t('ماسح العتاد والآثار', 'Equipment & Artifact Scanner'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.info_outline, size: 16, color: p.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
                s.t('نسخة تجريبية: النتائج محاكاة ولا تمثل تحليلًا حقيقيًا للصورة.',
                    'Demo: results are simulated and are not a real image analysis.'),
                style: TextStyle(color: p.text2, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 14),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
                value: 0,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: Text(s.t('فحص العتاد والمواد', 'Equipment & chemicals'))),
            ButtonSegment(
                value: 1,
                icon: const Icon(Icons.biotech, size: 18),
                label: Text(s.t('تشخيص حالة الأثر', 'Artifact diagnosis'))),
          ],
          selected: {mode},
          onSelectionChanged: (v) => setState(() {
            mode = v.first;
            mat = null;
            finding = null;
          }),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              color: Colors.black,
              child: Stack(fit: StackFit.expand, children: [
                if (image != null)
                  Image.memory(image!, fit: BoxFit.cover)
                else
                  Center(
                    child: Icon(
                        mode == 0 ? Icons.qr_code_2 : Icons.account_balance,
                        size: 90,
                        color: Colors.white12),
                  ),
                CustomPaint(painter: _BracketPainter(p.accent)),
                AnimatedBuilder(
                  animation: _laser,
                  builder: (_, __) => Align(
                    alignment: Alignment(0, _laser.value * 1.8 - 0.9),
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: p.primary,
                        boxShadow: [
                          BoxShadow(
                              color: p.primary.withValues(alpha: 0.9),
                              blurRadius: scanning ? 18 : 8,
                              spreadRadius: scanning ? 2 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
                if (scanning)
                  Container(
                    color: Colors.black38,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(14),
                    child: Text(s.t('جارٍ المسح...', 'Scanning...'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            onPressed: scanning ? null : () => _pick(ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: Text(s.t('التقاط صورة', 'Take photo')),
          ),
          FilledButton.tonalIcon(
            onPressed: scanning ? null : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.upload_file),
            label: Text(s.t('رفع صورة', 'Upload photo')),
          ),
          OutlinedButton.icon(
            onPressed: scanning ? null : () => _scan(),
            icon: const Icon(Icons.radar),
            label: Text(s.t('مسح مباشر (محاكاة)', 'Live scan (simulated)')),
          ),
        ]),
        const SizedBox(height: 18),
        if (mat != null) _equipmentResult(p, isExpert),
        if (finding != null) _diagnosisResult(p, isExpert),
      ],
    );
  }

  Widget _card(Pal p, List<Widget> children) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _equipmentResult(Pal p, bool isExpert) {
    final m = mat!;
    final e = _expiry(m);
    final d = m.expiry;
    return _card(p, [
      Row(children: [
        Expanded(
          child: Text(s.ar ? m.ar : m.en,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        Chip(
          label: Text(e.label,
              style: TextStyle(color: e.color, fontWeight: FontWeight.w700)),
          side: BorderSide(color: e.color),
        ),
      ]),
      const SizedBox(height: 6),
      Text(s.ar ? m.useAr : m.useEn, style: TextStyle(color: p.text2)),
      const Divider(height: 24),
      _kv(s.t('الصيغة', 'Formula'), m.formula),
      _kv(s.t('رقم الدفعة', 'Batch'), m.batch),
      _kv(s.t('تاريخ الانتهاء', 'Expiry'),
          '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}'),
      _kv('QR', m.payload),
      if (isExpert) ...[
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => showAddLogSheet(
            context,
            s,
            materials: '${m.en} (${s.t('دفعة', 'Batch')} ${m.batch})',
          ),
          icon: const Icon(Icons.note_add),
          label: Text(s.t('إنشاء تقرير ترميم تلقائي', 'Auto-fill restoration report')),
        ),
      ],
    ]);
  }

  Widget _diagnosisResult(Pal p, bool isExpert) {
    final f = finding!;
    return _card(p, [
      Text(s.ar ? f.ar : f.en,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Text(s.t('شدة الضرر', 'Damage severity')),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: f.severity,
          minHeight: 10,
          color: f.severity > 0.8
              ? const Color(0xFFD64535)
              : (f.severity > 0.6 ? const Color(0xFFD9772F) : p.accent),
          backgroundColor: p.line,
        ),
      ),
      const SizedBox(height: 14),
      Text(s.t('التوصية', 'Recommended treatment'),
          style: TextStyle(fontWeight: FontWeight.w800, color: p.primary)),
      const SizedBox(height: 4),
      Text(s.ar ? f.recAr : f.recEn, style: const TextStyle(height: 1.7)),
      if (isExpert) ...[
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => showAddLogSheet(
            context,
            s,
            materials: f.chemicals,
            report: '${s.ar ? f.ar : f.en} — ${s.ar ? f.recAr : f.recEn}',
          ),
          icon: const Icon(Icons.note_add),
          label: Text(s.t('إنشاء تقرير من التشخيص', 'Create report from diagnosis')),
        ),
      ],
    ]);
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: 110, child: Text(k, style: TextStyle(color: Pal.of(context).text2))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const m = 22.0, l = 34.0;
    final r = Rect.fromLTRB(m, m, size.width - m, size.height - m);
    void corner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o + Offset(dx * l, 0), paint);
      canvas.drawLine(o, o + Offset(0, dy * l), paint);
    }

    corner(r.topLeft, 1, 1);
    corner(r.topRight, -1, 1);
    corner(r.bottomLeft, 1, -1);
    corner(r.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter old) => old.color != color;
}

// ─────────────────────────────── Logs ───────────────────────────────────────

class LogsTab extends StatelessWidget {
  final AppState state;
  const LogsTab({super.key, required this.state});

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = state;
    final p = Pal.of(context);
    return RefreshIndicator(
      onRefresh: s.loadLogs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
        children: [
          Text(s.t('سجل الترميم', 'Restoration log'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s.t('${s.logs.length} تقرير فني', '${s.logs.length} technical reports'),
              style: TextStyle(color: p.text2)),
          const SizedBox(height: 16),
          if (s.offline) _OfflineBanner(s),
          if (s.loadingLogs) LinearProgressIndicator(color: p.accent),
          if (s.logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                  child: Text(s.t('لا توجد تقارير بعد', 'No reports yet'),
                      style: TextStyle(color: p.text2))),
            ),
          for (final l in s.logs)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.history_edu, color: p.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.siteName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  Icon(l.synced ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: l.synced ? const Color(0xFF4E9A5C) : p.text2),
                  const SizedBox(width: 6),
                  Text(_fmt(l.createdAt),
                      style: TextStyle(color: p.text2, fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.science, size: 16, color: p.primary),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(l.materials, style: TextStyle(color: p.text2))),
                ]),
                const SizedBox(height: 8),
                Text(l.report, style: const TextStyle(height: 1.6)),
              ]),
            ),
        ],
      ),
    );
  }
}

void showAddLogSheet(BuildContext context, AppState state,
    {String site = '', String materials = '', String report = ''}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Pal.of(context).bg,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _AddLogForm(
        state: state, site: site, materials: materials, report: report),
  );
}

class _AddLogForm extends StatefulWidget {
  final AppState state;
  final String site, materials, report;
  const _AddLogForm({
    required this.state,
    required this.site,
    required this.materials,
    required this.report,
  });

  @override
  State<_AddLogForm> createState() => _AddLogFormState();
}

class _AddLogFormState extends State<_AddLogForm> {
  final _formKey = GlobalKey<FormState>();
  late final _site = TextEditingController(text: widget.site);
  late final _materials = TextEditingController(text: widget.materials);
  late final _report = TextEditingController(text: widget.report);
  bool saving = false;

  AppState get s => widget.state;

  @override
  void dispose() {
    _site.dispose();
    _materials.dispose();
    _report.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final synced = await s.addLog(
      siteName: _site.text.trim(),
      materials: _materials.text.trim(),
      report: _report.text.trim(),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(
      content: Text(synced
          ? s.t('تم حفظ التقرير ومزامنته بنجاح', 'Report saved and synced')
          : s.t('تم حفظ التقرير محليًا (بدون اتصال بالخادم)',
              'Report saved locally (server unreachable)')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    String? req(String? v) =>
        (v == null || v.trim().isEmpty) ? s.t('هذا الحقل مطلوب', 'Required') : null;
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
              Text(s.t('إضافة تقرير ترميم فني', 'Add restoration report'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: widget.site),
                optionsBuilder: (v) => kSites
                    .map((x) => s.ar ? x.nameAr : x.nameEn)
                    .where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
                onSelected: (v) => _site.text = v,
                fieldViewBuilder: (context, controller, focus, onSubmit) {
                  controller.addListener(() => _site.text = controller.text);
                  return TextFormField(
                    controller: controller,
                    focusNode: focus,
                    validator: req,
                    decoration: InputDecoration(
                        labelText: s.t('اسم المعلم الأثري', 'Monument name'),
                        prefixIcon: const Icon(Icons.account_balance)),
                  );
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _materials,
                validator: req,
                decoration: InputDecoration(
                    labelText: s.t('المواد الكيميائية المستخدمة', 'Chemical materials used'),
                    prefixIcon: const Icon(Icons.science)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _report,
                validator: req,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                    labelText: s.t('التقرير الفني وحالة الضرر', 'Technical report & damage state'),
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: saving ? null : _submit,
                  child: saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(s.t('حفظ التقرير', 'Save report'),
                          style: const TextStyle(
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

// ─────────────────────────────── Account ────────────────────────────────────

class AccountTab extends StatefulWidget {
  final AppState state;
  const AccountTab({super.key, required this.state});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: s.name);
  late final _email = TextEditingController(text: s.email);
  late final _title = TextEditingController(text: s.title);
  late final _bio = TextEditingController(text: s.bio);
  late final _city = TextEditingController(text: s.city);
  late final _spec = TextEditingController(text: s.specialization);
  late final _lic = TextEditingController(text: s.license);

  AppState get s => widget.state;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _title.dispose();
    _bio.dispose();
    _city.dispose();
    _spec.dispose();
    _lic.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    s.updateProfile(
      newName: _name.text.trim(),
      newEmail: _email.text.trim(),
      newTitle: _title.text.trim(),
      newBio: _bio.text.trim(),
      newCity: _city.text.trim(),
      newSpec: _spec.text.trim(),
      newLicense: _lic.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.t('تم حفظ الملف الشخصي', 'Profile saved'))));
  }

  Future<void> _passwordDialog() async {
    final pass = TextEditingController();
    final confirm = TextEditingController();
    final key = GlobalKey<FormState>();
    String? serverError;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(s.t('تغيير كلمة المرور', 'Change password')),
          content: Form(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: pass,
                obscureText: true,
                validator: (v) => (v == null || v.length < 6)
                    ? s.t('6 أحرف على الأقل', 'At least 6 characters')
                    : null,
                decoration:
                    InputDecoration(labelText: s.t('كلمة المرور الجديدة', 'New password')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirm,
                obscureText: true,
                validator: (v) => v != pass.text
                    ? s.t('كلمتا المرور غير متطابقتين', 'Passwords do not match')
                    : null,
                decoration:
                    InputDecoration(labelText: s.t('تأكيد كلمة المرور', 'Confirm password')),
              ),
              if (serverError != null) ...[
                const SizedBox(height: 10),
                Text(serverError!, style: const TextStyle(color: Color(0xFFD64535))),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.t('إلغاء', 'Cancel'))),
            FilledButton(
              onPressed: () async {
                if (!key.currentState!.validate()) return;
                final err = await s.changePassword(pass.text);
                if (err == null) {
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(s.t('تم تغيير كلمة المرور', 'Password changed'))));
                  }
                } else {
                  setD(() => serverError = err);
                }
              },
              child: Text(s.t('حفظ', 'Save')),
            ),
          ],
        ),
      ),
    );
    pass.dispose();
    confirm.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final isExpert = s.role == UserRole.expert;
    Widget section(String t) => Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Text(t,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: p.primary)),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Row(children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: p.primary,
            child: Icon(isExpert ? Icons.verified_user : Icons.hiking,
                size: 32, color: p.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.t('إعدادات الحساب', 'Account settings'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(s.email, style: TextStyle(color: p.text2)),
            ]),
          ),
        ]),
        section(s.t('الملف الشخصي', 'Profile')),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _name,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? s.t('هذا الحقل مطلوب', 'Required')
                  : null,
              decoration: InputDecoration(
                  labelText: s.t('الاسم', 'Name'),
                  prefixIcon: const Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              validator: (v) => (v == null || !v.contains('@'))
                  ? s.t('بريد إلكتروني غير صالح', 'Invalid email')
                  : null,
              decoration: InputDecoration(
                  labelText: s.t('البريد الإلكتروني', 'Email'),
                  prefixIcon: const Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                  labelText: s.t('المسمى / التخصص', 'Title / specialty'),
                  prefixIcon: const Icon(Icons.work_outline)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              decoration: InputDecoration(
                  labelText: s.t('المدينة / الهاتف', 'City / phone'),
                  prefixIcon: const Icon(Icons.location_city)),
            ),
            if (isExpert) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _spec,
                decoration: InputDecoration(
                    labelText: s.t('التخصص الدقيق', 'Academic specialization'),
                    prefixIcon: const Icon(Icons.school_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lic,
                decoration: InputDecoration(
                    labelText: s.t('رقم العضوية / التصريح', 'Membership / license no.'),
                    prefixIcon: const Icon(Icons.badge_outlined)),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _bio,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: s.t('نبذة', 'Bio'), alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(s.t('حفظ التغييرات', 'Save changes')),
              ),
            ),
          ]),
        ),
        section(s.t('نوع الحساب', 'Account type')),
        SegmentedButton<UserRole>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
                value: UserRole.tourist,
                icon: const Icon(Icons.hiking, size: 18),
                label: Text(s.t('زائر / سائح', 'Visitor'))),
            ButtonSegment(
                value: UserRole.expert,
                icon: const Icon(Icons.verified, size: 18),
                label: Text(s.t('خبير مرمم معتمد', 'Conservator'))),
          ],
          selected: {s.role},
          onSelectionChanged: (v) => s.setRole(v.first),
        ),
        if (isExpert && s.license.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('${s.t('رقم الترخيص', 'License ID')}: ${s.license}',
              style: TextStyle(color: p.text2)),
        ],
        section(s.t('التفضيلات', 'Preferences')),
        Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Column(children: [
            SwitchListTile(
              value: s.notifications,
              onChanged: s.setNotifications,
              secondary: const Icon(Icons.notifications_outlined),
              title: Text(s.t('الإشعارات', 'Notifications')),
            ),
            SwitchListTile(
              value: s.dark,
              onChanged: (_) => s.toggleDark(),
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(s.t('الوضع الداكن', 'Dark mode')),
            ),
            SwitchListTile(
              value: s.ar,
              onChanged: (_) => s.toggleLang(),
              secondary: const Icon(Icons.translate),
              title: Text(s.t('اللغة العربية', 'Arabic language')),
            ),
          ]),
        ),
        section(s.t('تثبيت التطبيق', 'Install app')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Icon(Icons.install_mobile, color: p.accent, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  s.t('ثبّت إرث على شاشتك الرئيسية لوصول أسرع بدون متصفح.',
                      'Install ERTH on your home screen for faster access without a browser.'),
                  style: TextStyle(color: p.text2, height: 1.5)),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: p.accent, foregroundColor: Colors.black),
              onPressed: () => installApp(context, s),
              icon: const Icon(Icons.download),
              label: Text(s.t('تنزيل التطبيق', 'Download app')),
            ),
          ]),
        ),
        section(s.t('الأمان', 'Security')),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: _passwordDialog,
          icon: const Icon(Icons.lock_reset),
          label: Text(s.t('تغيير كلمة المرور', 'Change password')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: s.logout,
          icon: const Icon(Icons.switch_account),
          label: Text(s.t('تبديل الحساب', 'Switch account')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => s.logout(toSignup: true),
          icon: const Icon(Icons.person_add_alt),
          label: Text(s.t('إنشاء حساب جديد', 'Register new account')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD64535),
              side: const BorderSide(color: Color(0xFFD64535)),
              minimumSize: const Size.fromHeight(48)),
          onPressed: s.logout,
          icon: const Icon(Icons.logout),
          label: Text(s.t('تسجيل الخروج', 'Log out')),
        ),
      ],
    );
  }
}

// ─────────────────────────────── AI chat ────────────────────────────────────

class _Msg {
  final bool user;
  final String text;
  final bool local;
  const _Msg(this.user, this.text, {this.local = false});
}

void showChatSheet(BuildContext context, AppState state, {String? initial}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Pal.of(context).bg,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.86,
      child: ChatSheet(state: state, initial: initial),
    ),
  );
}

class ChatSheet extends StatefulWidget {
  final AppState state;
  final String? initial;
  const ChatSheet({super.key, required this.state, this.initial});

  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> msgs = [];
  bool sending = false;

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    msgs.add(_Msg(
        false,
        s.t(
            'مرحبًا! أنا المرشد الأثري الذكي لـ «إرث». اسألني عن المواقع الأثرية الليبية أو عن كيمياء الترميم والمواد.',
            'Hello! I am ERTH’s AI heritage guide. Ask me about Libyan archaeological sites or conservation chemistry.')));
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.initial!));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || sending) return;
    _input.clear();
    setState(() {
      msgs.add(_Msg(true, q));
      sending = true;
    });
    _toEnd();
    final reply = await _ask(q);
    if (!mounted) return;
    setState(() {
      msgs.add(reply);
      sending = false;
    });
    _toEnd();
  }

  Future<_Msg> _ask(String q) async {
    final system = s.ar
        ? 'أنت «المرشد الأثري الذكي» في تطبيق إرث. أنت خبير في علم الآثار الليبي (لبدة الكبرى، قورينا، صبراتة، أكاكوس، غدامس، وغيرها) وفي كيمياء الترميم والصيانة (بارالويد B-72، الجير النانوي، سيليكات الإيثيل، الشمع دقيق التبلور، إزالة الأملاح). أجب بالعربية بإيجاز ودقة، وصرّح عندما لا تكون متأكدًا.'
        : 'You are the “AI Heritage Guide” in the ERTH app. You are an expert in Libyan archaeology (Leptis Magna, Cyrene, Sabratha, Acacus, Ghadames and more) and conservation chemistry (Paraloid B-72, nano-lime, ethyl silicate, micro-crystalline wax, desalination). Answer concisely and accurately, and say when you are unsure.';
    final history = msgs
        .where((m) => m != msgs.first)
        .toList()
        .reversed
        .take(8)
        .toList()
        .reversed
        .map((m) => {'role': m.user ? 'user' : 'assistant', 'content': m.text})
        .toList();
    final body = [
      {'role': 'system', 'content': system},
      ...history,
    ];
    for (final model in openRouterApiKey.isEmpty ? <String>[] : _openRouterModels) {
      try {
        final r = await http
            .post(
              Uri.parse(_openRouterUrl),
              headers: {
                'Authorization': 'Bearer $openRouterApiKey',
                'Content-Type': 'application/json',
                'HTTP-Referer': 'https://erth-app.surge.sh',
                'X-Title': 'ERTH Libyan Heritage',
              },
              body: jsonEncode({'model': model, 'messages': body, 'max_tokens': 700}),
            )
            .timeout(const Duration(seconds: 25));
        if (r.statusCode == 200) {
          final j = jsonDecode(utf8.decode(r.bodyBytes));
          final c = j['choices']?[0]?['message']?['content'];
          if (c is String && c.trim().isNotEmpty) return _Msg(false, c.trim());
        }
        debugPrint('[ERTH] OpenRouter $model -> ${r.statusCode}');
      } catch (e) {
        debugPrint('[ERTH] OpenRouter $model failed: $e');
      }
    }
    return _Msg(false, _localAnswer(q), local: true);
  }

  String _localAnswer(String q) {
    final l = q.toLowerCase();
    final ar = s.ar;
    for (final x in kSites) {
      if (l.contains(x.nameEn.toLowerCase().split(' ').first.toLowerCase()) ||
          q.contains(x.nameAr.split(' ').first)) {
        return '${x.name(ar)} — ${x.era(ar)}\n${x.story(ar)}'
            '${x.unesco ? (ar ? '\nمُدرج في قائمة اليونسكو للتراث العالمي.' : '\nA UNESCO World Heritage Site.') : ''}';
      }
    }
    bool has(List<String> k) => k.any((w) => l.contains(w) || q.contains(w));
    if (has(['paraloid', 'بارالويد', 'باراويد', 'acrylic'])) {
      return ar
          ? 'Paraloid B-72 راتنج أكريليكي قابل للعكس، يُذاب عادةً بنسبة 3–10% في الأسيتون أو الإيثانول لتثبيت الحجر والسيراميك وكغراء.'
          : 'Paraloid B-72 is a reversible acrylic resin, typically dissolved at 3–10% in acetone or ethanol to consolidate stone and ceramics or to act as an adhesive.';
    }
    if (has(['lime', 'جير', 'نانو'])) {
      return ar
          ? 'الجير النانوي (Ca(OH)₂) معلق من جسيمات هيدروكسيد الكالسيوم الدقيقة في الكحول؛ يتغلغل في الحجر الجيري المتفتت ويتحول بالكربنة إلى كربونات الكالسيوم فيعيد تماسكه.'
          : 'Nano-lime (Ca(OH)₂) is a suspension of tiny calcium hydroxide particles in alcohol; it penetrates friable limestone and carbonates to CaCO₃, restoring cohesion.';
    }
    if (has(['silicate', 'سيليكات'])) {
      return ar
          ? 'سيليكات الإيثيل تتحلل مائيًا داخل مسام الحجر الرملي مكونةً هلام السيليكا الذي يقوّي الحبيبات. تُجرى اختبارات صغيرة أولًا.'
          : 'Ethyl silicate hydrolyses inside sandstone pores to form silica gel that binds the grains. Always test a small area first.';
    }
    if (has(['wax', 'شمع'])) {
      return ar
          ? 'الشمع دقيق التبلور طبقة حماية نهائية تقاوم الرطوبة وتُستخدم على المعادن والحجر، ويمكن إزالتها بمذيبات هيدروكربونية.'
          : 'Micro-crystalline wax is a final protective layer that resists moisture on metal and stone and can be removed with hydrocarbon solvents.';
    }
    if (has(['salt', 'ملح', 'أملاح', 'efflorescence', 'تزهر'])) {
      return ar
          ? 'لإزالة الأملاح: استخدم كمادات الورق أو الطين المبللة بماء منزوع الأيونات، وكرّرها حتى تنخفض الموصلية، وعالج مصدر الرطوبة أولًا.'
          : 'To desalinate: apply poultices of paper pulp or clay with deionised water, repeat until conductivity drops, and fix the moisture source first.';
    }
    if (has(['crack', 'شق', 'تشقق'])) {
      return ar
          ? 'ابدأ برصد حركة الشقوق بمقاييس مخصصة، ثم حقن ملاط جيري مرن ودعم مؤقت قبل أي تدخل دائم.'
          : 'Start by monitoring crack movement with gauges, then inject flexible lime grout and add temporary support before any permanent intervention.';
    }
    return ar
        ? 'يمكنني الحديث عن 14 موقعًا أثريًا ليبيًا (مثل لبدة الكبرى وقورينا وغدامس) وعن مواد الترميم مثل Paraloid B-72 والجير النانوي. (رد محلي: تعذر الاتصال بالنموذج الذكي حاليًا.)'
        : 'I can talk about 14 Libyan heritage sites (Leptis Magna, Cyrene, Ghadames…) and conservation materials like Paraloid B-72 and nano-lime. (Local reply: the AI model is unreachable right now.)';
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final suggestions = [
      s.t('حدثني عن لبدة الكبرى', 'Tell me about Leptis Magna'),
      s.t('ما هو Paraloid B-72؟', 'What is Paraloid B-72?'),
      s.t('كيف أعالج تزهر الأملاح؟', 'How do I treat salt efflorescence?'),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Icon(Icons.auto_awesome, color: p.accent),
            const SizedBox(width: 8),
            Text(s.t('المرشد الأثري الذكي', 'AI Heritage Guide'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: msgs.length + (sending ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == msgs.length) {
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: p.accent)),
                  ),
                );
              }
              final m = msgs[i];
              return Align(
                alignment: m.user
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: m.user ? p.primary : p.card,
                    borderRadius: BorderRadius.circular(18),
                    border: m.user ? null : Border.all(color: p.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SelectableText(m.text,
                        style: TextStyle(
                            height: 1.7, color: m.user ? Colors.white : p.text)),
                    if (m.local)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(s.t('رد محلي (غير متصل)', 'Local reply (offline)'),
                            style: TextStyle(fontSize: 11, color: p.text2)),
                      ),
                  ]),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final q in suggestions)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ActionChip(label: Text(q), onPressed: () => _send(q)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                    hintText: s.t('اكتب سؤالك...', 'Type your question...')),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: sending ? null : () => _send(_input.text),
              icon: const Icon(Icons.send),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────── Install (PWA) ──────────────────────────────

Future<void> installApp(BuildContext context, AppState s) async {
  if (pwaIsStandalone()) {
    _showInstallGuide(context, s, installed: true);
    return;
  }
  if (pwaCanInstall()) {
    final r = await pwaInstall();
    if (!context.mounted) return;
    if (r == 'accepted') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.t('جارٍ تثبيت التطبيق...', 'Installing the app...'))));
      return;
    }
    if (r == 'dismissed') return;
  }
  if (!context.mounted) return;
  _showInstallGuide(context, s);
}

void _showInstallGuide(BuildContext context, AppState s, {bool installed = false}) {
  final ios = pwaIsIOS();
  final steps = ios
      ? [
          (Icons.ios_share, s.t('اضغط زر المشاركة في أسفل Safari', 'Tap the Share button in Safari')),
          (Icons.add_box_outlined, s.t('اختر «إضافة إلى الشاشة الرئيسية»', 'Choose “Add to Home Screen”')),
          (Icons.check_circle_outline, s.t('اضغط «إضافة» وسيظهر إرث بين تطبيقاتك', 'Tap “Add” and ERTH appears with your apps')),
        ]
      : [
          (Icons.more_vert, s.t('افتح قائمة المتصفح (⋮)', 'Open the browser menu (⋮)')),
          (Icons.install_desktop, s.t('اختر «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية»', 'Choose “Install app” or “Add to Home screen”')),
          (Icons.check_circle_outline, s.t('أكّد التثبيت وافتح إرث من شاشتك الرئيسية', 'Confirm, then open ERTH from your home screen')),
        ];
  showDialog<void>(
    context: context,
    builder: (ctx) {
      final p = Pal.of(ctx);
      return AlertDialog(
        backgroundColor: p.card,
        title: Text(installed
            ? s.t('التطبيق مثبّت بالفعل', 'App already installed')
            : s.t('طريقة تثبيت إرث', 'How to install ERTH')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (installed)
              Text(s.t('أنت تستخدم إرث كتطبيق مثبّت على جهازك.',
                  'You are already running ERTH as an installed app.'))
            else
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(children: [
                    CircleAvatar(
                        radius: 16,
                        backgroundColor: p.primary,
                        child: Text('${i + 1}',
                            style: const TextStyle(color: Colors.white))),
                    const SizedBox(width: 12),
                    Icon(steps[i].$1, color: p.accent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(steps[i].$2)),
                  ]),
                ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.t('حسنًا', 'Got it'))),
        ],
      );
    },
  );
}

void showInstallSheet(BuildContext context, AppState s) {
  const red = Color(0xFF8B261D);
  const bronze = Color(0xFFC59B27);
  const beige = Color(0xFFF6F1E7);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: red,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF6E1C15),
                  shape: BoxShape.circle,
                  border: Border.all(color: bronze, width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: Transform.scale(
                  scale: 1.7,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => CustomPaint(
                        painter: _ArchPainter(beige, bronze)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(s.t('حمّل تطبيق إرث (ERTH) على جهازك', 'Install ERTH App'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: beige, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                  s.t(
                      'استمتع بتجربة أسرع، وصول فوري للمعالم الأثرية والماسح الضوئي، وتثبيت مباشر على الشاشة الرئيسية بدون متصفح.',
                      'Enjoy a faster experience, instant access to heritage sites and the scanner, and install straight to your home screen — no browser needed.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: beige.withValues(alpha: 0.85), height: 1.7)),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: bronze, foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    installApp(context, s);
                  },
                  icon: const Icon(Icons.download),
                  label: Text(s.t('تنزيل وتثبيت التطبيق الآن', 'Download & install now'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.t('تصفح عبر الويب حالياً', 'Continue on the web for now'),
                    style: const TextStyle(color: beige)),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}
