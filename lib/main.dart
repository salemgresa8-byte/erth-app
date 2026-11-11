import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Bounded so a slow/unreachable backend can never delay the first frame.
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey)
        .timeout(const Duration(seconds: 6));
  } catch (e) {
    debugPrint('[ERTH] Supabase init failed, running offline: $e');
  }
  final state = AppState();
  await state.loadPrefs();
  runApp(ErthApp(state: state));
}

// ─────────────────────────────── Palette ────────────────────────────────────

// Premium dark-heritage tokens (from the "ERTH — Premium UI Redesign" spec).
const kWine = Color(0xFF1E0709);
const kObsidian = Color(0xFF100304);
const kMaroon = Color(0xFF240B0E);
const kGold = Color(0xFFC59B27);
const kGoldLight = Color(0xFFDFB85C);
const kGoldPale = Color(0xFFFAF2DC);
const kRed = Color(0xFF8B261D);
const kRedDeep = Color(0xFF6E1C15);
const kBeige = Color(0xFFE6D7C3);
const kMuted = Color(0xFFA89885);
const kMono = Color(0xFFE8C766);

class Pal {
  final Color bg, card, primary, accent, text, text2, line;
  const Pal(this.bg, this.card, this.primary, this.accent, this.text, this.text2,
      this.line);

  static const dark = Pal(kObsidian, kMaroon, kRed, kGold, kBeige, kMuted,
      Color(0x4DC59B27));
  static const light = dark;

  static Pal of(BuildContext c) => dark;
}

const kGoldGradient = LinearGradient(
  begin: AlignmentDirectional.topStart,
  end: AlignmentDirectional.bottomEnd,
  colors: [kGoldLight, kGold],
);
const kRedGradient = LinearGradient(
  begin: AlignmentDirectional.topStart,
  end: AlignmentDirectional.bottomEnd,
  colors: [kRed, kRedDeep],
);

/// Full-screen wine → obsidian backdrop with a soft radial glow at the top.
class HeritageBackdrop extends StatelessWidget {
  final Widget child;
  const HeritageBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kWine, kObsidian],
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.1),
            radius: 1.1,
            colors: [Color(0x553A0D12), Color(0x00100304)],
          ),
        ),
        child: child,
      ),
    );
  }
}

TextStyle titleStyle([double size = 22]) => GoogleFonts.tajawal(
    fontSize: size, fontWeight: FontWeight.w700, color: Colors.white);
TextStyle subStyle([double size = 15]) => GoogleFonts.tajawal(
    fontSize: size, fontWeight: FontWeight.w500, color: kBeige);
TextStyle captionStyle([double size = 12.5]) => GoogleFonts.tajawal(
    fontSize: size, fontWeight: FontWeight.w400, color: kMuted);
TextStyle monoStyle([double size = 11.5]) =>
    GoogleFonts.jetBrainsMono(fontSize: size, color: kMono);

ThemeData buildTheme(Brightness _) {
  const p = Pal.dark;
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  OutlineInputBorder ib(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w));
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: kRed, brightness: Brightness.dark)
        .copyWith(
      primary: kRed,
      onPrimary: kBeige,
      secondary: kGold,
      onSecondary: kWine,
      secondaryContainer: kRed,
      onSecondaryContainer: kBeige,
      surface: kMaroon,
      onSurface: kBeige,
      outline: p.line,
      outlineVariant: p.line,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: kMaroon,
    dividerColor: p.line,
    textTheme: GoogleFonts.tajawalTextTheme(base.textTheme)
        .apply(bodyColor: kBeige, displayColor: Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: kBeige,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: titleStyle(18),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF140406),
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 70,
      iconTheme: WidgetStateProperty.resolveWith((st) => IconThemeData(
          color: st.contains(WidgetState.selected) ? kGoldLight : kMuted,
          size: 24)),
      labelTextStyle: WidgetStateProperty.resolveWith((st) =>
          GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: st.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: st.contains(WidgetState.selected) ? kGoldLight : kMuted)),
    ),
    cardColor: kMaroon,
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: kMaroon,
      side: BorderSide(color: p.line),
      labelStyle: subStyle(13),
      shape: const StadiumBorder(),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: kWine),
    dialogTheme: const DialogThemeData(backgroundColor: kMaroon),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF170609),
      hintStyle: captionStyle(14),
      labelStyle: captionStyle(14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: ib(p.line),
      enabledBorder: ib(p.line),
      focusedBorder: ib(kGoldLight, 1.4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kRed,
        foregroundColor: kBeige,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kBeige,
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStatePropertyAll(BorderSide(color: p.line)),
        backgroundColor: WidgetStateProperty.resolveWith((st) =>
            st.contains(WidgetState.selected) ? kRed : const Color(0xFF170609)),
        foregroundColor: WidgetStateProperty.resolveWith((st) =>
            st.contains(WidgetState.selected) ? kBeige : kMuted),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

// ─────────────────────────── Premium primitives ─────────────────────────────

/// Metallic gold CTA (dark text) or terracotta red secondary button.
class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final bool red;
  final Widget? child;
  const GoldButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.height = 54,
      this.red = false,
      this.child});

  @override
  Widget build(BuildContext context) {
    final fg = red ? kBeige : kWine;
    return Opacity(
      opacity: onPressed == null ? 0.55 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: red ? kRedGradient : kGoldGradient,
          borderRadius: BorderRadius.circular(16),
          border: red ? Border.all(color: kGold.withValues(alpha: 0.6)) : null,
          boxShadow: [
            BoxShadow(
                color: (red ? kRed : kGold).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: child ??
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: GoogleFonts.tajawal(
                            fontSize: 16, fontWeight: FontWeight.w700, color: fg)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark glass button with a thin antique-gold outline.
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final bool pill;
  const GlassButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.height = 54,
      this.pill = false});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(pill ? 40 : 16);
    return Opacity(
      opacity: onPressed == null ? 0.55 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: r,
          border: Border.all(color: kGold.withValues(alpha: 0.4)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: r,
            onTap: onPressed,
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[
                  Icon(icon, size: 19, color: kGoldLight),
                  const SizedBox(width: 8),
                ],
                Text(label,
                    style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kGoldLight)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline pill badge. [mono] uses JetBrains Mono for chemical formulas.
class Pill extends StatelessWidget {
  final String text;
  final Color border, textColor;
  final Color? fill;
  final bool mono;
  final IconData? icon;
  const Pill(this.text,
      {super.key,
      this.border = kGold,
      this.textColor = kGoldLight,
      this.fill,
      this.mono = false,
      this.icon});

  const Pill.unesco(this.text, {super.key})
      : border = kGold,
        textColor = kGoldLight,
        fill = const Color(0xCC1E0709),
        mono = false,
        icon = null;

  const Pill.damage(this.text, {super.key})
      : border = const Color(0xFFD9574A),
        textColor = const Color(0xFFF08A7E),
        fill = const Color(0x332A0508),
        mono = false,
        icon = null;

  const Pill.formula(this.text, {super.key})
      : border = const Color(0x99B08D57),
        textColor = kMono,
        fill = null,
        mono = true,
        icon = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(text,
              style: mono
                  ? monoStyle(12).copyWith(color: textColor)
                  : GoogleFonts.tajawal(
                      fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        ),
      ]),
    );
  }
}

/// Statistic number in Cinzel with a pale-gold gradient fill.
class GoldNumber extends StatelessWidget {
  final String value;
  final double size;
  const GoldNumber(this.value, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kGoldPale, kGoldLight],
      ).createShader(r),
      child: Text(value,
          style: GoogleFonts.cinzel(
              fontSize: size, fontWeight: FontWeight.w700, height: 1.1)),
    );
  }
}

/// Calligraphic red-gradient text with a warm glow (names, wordmark).
class Calligraphy extends StatelessWidget {
  final String text;
  final double size;
  const Calligraphy(this.text, {super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.arefRuqaa(
        fontSize: size, fontWeight: FontWeight.w700, height: 1.15);
    return Stack(children: [
      // Warm glow underneath.
      Text(text,
          style: style.copyWith(
              color: Colors.transparent,
              shadows: [
                Shadow(
                    color: const Color(0xFFE53935).withValues(alpha: 0.45),
                    blurRadius: size * 0.45),
              ])),
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE53935), kRed],
        ).createShader(r),
        child: Text(text, style: style),
      ),
    ]);
  }
}

/// Premium dark card surface with a thin antique-gold border.
BoxDecoration cardDeco({double radius = 22, double borderAlpha = 0.3}) =>
    BoxDecoration(
      color: kMaroon.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: kGold.withValues(alpha: borderAlpha)),
    );

// ─────────────────────────────── Logo ───────────────────────────────────────

/// Vector version of the golden arch emblem (no box, blends with dark bg).
class _ArchEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGoldPale, kGoldLight, kGold],
        stops: [0, 0.45, 1],
      ).createShader(Offset.zero & size);

    // Entablature (slightly flared slab).
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.06, h * 0.08)
          ..lineTo(w * 0.94, h * 0.08)
          ..lineTo(w * 0.88, h * 0.18)
          ..lineTo(w * 0.12, h * 0.18)
          ..close(),
        paint);
    // Two columns with flared capitals and bases.
    for (final dir in [1.0, -1.0]) {
      double x(double v) => dir > 0 ? w * v : w * (1 - v);
      canvas.drawPath(
          Path()
            ..moveTo(x(0.10), h * 0.25)
            ..quadraticBezierTo(x(0.16), h * 0.24, x(0.16), h * 0.32)
            ..lineTo(x(0.16), h * 0.84)
            ..quadraticBezierTo(x(0.16), h * 0.90, x(0.08), h * 0.92)
            ..lineTo(x(0.30), h * 0.92)
            ..quadraticBezierTo(x(0.24), h * 0.90, x(0.24), h * 0.84)
            ..lineTo(x(0.24), h * 0.32)
            ..quadraticBezierTo(x(0.24), h * 0.26, x(0.30), h * 0.25),
          paint);
    }
    // Double arch.
    for (final r in [0.22, 0.13]) {
      canvas.drawPath(
          Path()
            ..moveTo(w * (0.5 - r), h * 0.92)
            ..lineTo(w * (0.5 - r), h * 0.48)
            ..arcToPoint(Offset(w * (0.5 + r), h * 0.48),
                radius: Radius.circular(w * r))
            ..lineTo(w * (0.5 + r), h * 0.92),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArchEmblem extends StatelessWidget {
  final double size;
  const ArchEmblem({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ArchEmblemPainter()));
}

/// Unified brand: gold arch emblem + red calligraphic "إرث" + gold "ERTH"
/// (+ optional tagline). [horizontal] is the compact AppBar layout.
class ErthLogo extends StatelessWidget {
  final double size;
  final bool horizontal;
  final bool tagline;

  /// When set, the whole logo is tappable (used to jump back to Home).
  final VoidCallback? onTap;
  const ErthLogo(
      {super.key,
      this.size = 40,
      this.horizontal = true,
      this.tagline = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final ertH = Text('ERTH',
        textDirection: TextDirection.ltr,
        style: GoogleFonts.cinzel(
            fontSize: size * (horizontal ? 0.24 : 0.2),
            fontWeight: FontWeight.w600,
            letterSpacing: size * (horizontal ? 0.14 : 0.12),
            color: kGoldLight));
    final Widget content = horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            ArchEmblem(size: size * 0.95),
            SizedBox(width: size * 0.25),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Calligraphy('إرث', size: size * 0.78),
              ertH,
            ]),
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: [
            ArchEmblem(size: size),
            SizedBox(height: size * 0.12),
            Calligraphy('إرث', size: size * 0.8),
            ertH,
            if (tagline) ...[
              SizedBox(height: size * 0.12),
              Text('منصة التراث الليبي', style: captionStyle(14)),
            ],
          ]);
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'ERTH - الرئيسية',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: const EdgeInsets.all(2), child: content),
      ),
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

  /// Cover image first, then any extra gallery photos (deduplicated).
  List<String> get photos =>
      <String>{image, ...?kGallery[id]}.toList(growable: false);

  List<(String, String, String)> get videos =>
      kVideos[id] ??
      [
        (
          'جولة وثائقية: $nameAr',
          'Documentary: $nameEn',
          'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent('$nameEn Libya')}'
        ),
      ];
}

const kAll = 'الكل';
const kCategoryEn = {
  'الكل': 'All',
  'آثار رومانية': 'Roman ruins',
  'آثار إغريقية': 'Greek ruins',
  'نقوش صخرية': 'Rock art',
  'مدن قديمة': 'Ancient towns',
  'قلاع إسلامية': 'Islamic forts',
  'واحات طبيعية': 'Natural oases',
  'تحف فنية': 'Masterpieces',
  'شخصيات تاريخية': 'Historical figures',
  'تحف أثرية': 'Archaeological treasures',
  'مخطوطات نادرة': 'Rare manuscripts',
};
final kCategories = kCategoryEn.keys.toList();

class Persona {
  final String nameAr, titleAr;
  final List<String> ids;
  final IconData icon;
  const Persona(this.nameAr, this.titleAr, this.ids, this.icon);
}

const kPersonas = <String, Persona>{
  'A': Persona('عاشق الفنون والتحف', 'مواقع تناسب شغفك بالفنون والمنحوتات',
      ['redcastle', 'silin', 'apollo_cyrene', 'ptolemais'], Icons.palette),
  'B': Persona('مستكشف الألغاز وتاريخ الحضارات',
      'مواقع تناسب شغفك بالألغاز وعصور ما قبل التاريخ',
      ['acacus', 'garama', 'waw', 'gaberoun'], Icons.travel_explore),
  'C': Persona('عاشق الحياة اليومية والتراث', 'مواقع تروي لك كيف عاش الأجداد',
      ['ghadames', 'qasralhaj', 'marcus'], Icons.home_work),
  'D': Persona('مهندس العمارة والصوتيات', 'روائع الهندسة المعمارية والصوتيات القديمة',
      ['sabratha', 'leptis', 'ptolemais'], Icons.architecture),
};

const kQuiz = <(String, List<String>)>[
  ('ما الذي يلفت نظرك أولاً عند رؤية قطعة أثرية؟', [
    'تفاصيل نقوشها وجمال تصميمها ودقة صناعتها.',
    'السر التاريخي أو اللغز الذي تقف خلفه هذه القطعة.',
    'كيفية استخدامها في الحياة اليومية أو الممارسات الشعبية القديمة.',
    'التطور الهندسي أو التكنولوجي المبتكر في ابتكارها.',
  ]),
  ('لو كان بإمكانك قراءة كتاب واحد عن الآثار، ماذا تختار؟', [
    '«أجمل التحف الفنية والمنحوتات في العالم القديم».',
    '«أكبر الألغاز الأثرية والمقابر المفقودة عبر التاريخ».',
    '«يوميات إنسان قديم: كيف كانت تعيش الشعوب العادية؟».',
    '«عبقرية المعمار القديم: من بناء الأهرامات إلى السدود».',
  ]),
  ('ما نوع الموقع الأثري الذي تحلم بزيارته واستكشافه؟', [
    'معبد أو قصر ممتلئ بالتماثيل واللوحات والزخارف.',
    'مدينة مفقودة تحت الماء أو منطقة تنقيب مليئة بالغموض.',
    'قرية أثرية كاملة تظهر كيف كان يطهو ويلبس ويسكن الناس.',
    'قنوات ري قديمة، مسارح رومانية ذات صوتيات مذهلة، أو شبكات طرق.',
  ]),
  ('أيٌّ من هذه الأسئلة يثير فضولك أكثر؟', [
    'كيف استطاع الفنان القديم نحت هذه التفاصيل الدقيقة بدون أدوات حديثة؟',
    'ما الذي حدث لهذه الحضارة وأدى لاندثارها فجأة؟',
    'كيف كانت الأسر القديمة تحتفل وتتعالج وتتبادل البضائع؟',
    'كيف جُلبت هذه الأحجار الضخمة ورُفعت بدون آلات حديثة؟',
  ]),
];

const kSites = <HeritageSite>[
  HeritageSite(
    id: 'leptis', nameAr: 'لبدة الكبرى', nameEn: 'Leptis Magna',
    regionAr: 'الخمس', regionEn: 'Khoms', category: 'آثار رومانية',
    eraAr: 'القرن 7 ق.م – القرن 4 م', eraEn: '7th c. BC – 4th c. AD',
    unesco: true, lat: 32.6385, lon: 14.2910,
    status: Preservation.underTreatment, icon: Icons.account_balance,
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Leptis_Magna_Arch_of_Septimius_Severus.jpg/960px-Leptis_Magna_Arch_of_Septimius_Severus.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Temple_of_Zeus_in_Cyrene.jpg/960px-Temple_of_Zeus_in_Cyrene.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Theatre_of_Sabratha%2C_Libya.jpg/960px-Theatre_of_Sabratha%2C_Libya.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Libya_4985_Tadrart_Acacus_Luca_Galuzzi_2007.jpg/960px-Libya_4985_Tadrart_Acacus_Luca_Galuzzi_2007.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Libya_Ghadames_Old_Town_Rooftop_View.JPG/960px-Libya_Ghadames_Old_Town_Rooftop_View.JPG',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg/960px-Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Marcus_Aurelius_Arch_Tripoli_Libya.jpg/960px-Marcus_Aurelius_Arch_Tripoli_Libya.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Ptolemais_site.jpg/960px-Ptolemais_site.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Apollonia_portoriental.jpg/960px-Apollonia_portoriental.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/6/66/Qaser_el_haj.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_02.jpg/960px-Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_02.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Libya_5391_Ubari_Lakes_Luca_Galuzzi_2007.jpg/960px-Libya_5391_Ubari_Lakes_Luca_Galuzzi_2007.jpg',
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
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Waw_an-Namus-gr%C3%BCner_See.jpg/960px-Waw_an-Namus-gr%C3%BCner_See.jpg',
    storyAr: 'فوهة بركانية خامدة في قلب الصحراء، فيها بحيرات صغيرة ملونة محاطة برمال سوداء، وتُعرف بـ«واحة البعوض».',
    storyEn: 'An extinct volcanic caldera deep in the desert with small coloured lakes in black ash — nicknamed the “Mosquito Oasis”.',
    history: [
      ('عصور جيولوجية', 'تكوّن الفوهة البركانية', 'Caldera formed by volcanism'),
      ('العصر الحديث', 'توثيق الموقع علميًا', 'Scientific documentation'),
      ('اليوم', 'مقصد للمغامرين والباحثين', 'Destination for explorers and researchers'),
    ],
  ),
  HeritageSite(
    id: 'medusa', nameAr: 'رأس ميدوسا الرخامية', nameEn: 'Medusa of Leptis Magna',
    regionAr: 'متحف السراي الحمراء - طرابلس', regionEn: 'Red Castle Museum, Tripoli',
    category: 'تحف فنية',
    eraAr: 'العصر الروماني - القرن 2–3 م', eraEn: 'Roman era – 2nd–3rd c. AD',
    unesco: false, lat: 32.8987, lon: 13.1808,
    status: Preservation.good, icon: Icons.face_retouching_natural,
    image: 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Gorgone_libia_by_marcotambara.jpg',
    storyAr: 'رأس ميدوسا (الجورجون) من أشهر الزخارف الرخامية المرتبطة بلبدة الكبرى، حيث زُيّنت أروقة الميدان السيفيري بميداليات تحمل رؤوس ميدوسا لحماية المكان من الشر.',
    storyEn: 'The Gorgon Medusa head is among the most famous marble motifs tied to Leptis Magna, where the arcades of the Severan Forum were decorated with Medusa medallions believed to ward off evil.',
    history: [
      ('القرن 3 م', 'نحت الميداليات الرخامية للميدان السيفيري', 'Marble medallions carved for the Severan Forum'),
      ('القرن 20', 'أعمال التنقيب والتوثيق الأثري', 'Excavation and archaeological documentation'),
      ('اليوم', 'عرض وحفظ المقتنيات في متاحف طرابلس', 'Held and displayed in Tripoli museums'),
    ],
  ),
  HeritageSite(
    id: 'severus', nameAr: 'تمثال سيبتيموس سيفيروس', nameEn: 'Septimius Severus',
    regionAr: 'لبدة الكبرى', regionEn: 'Leptis Magna',
    category: 'شخصيات تاريخية',
    eraAr: '145 – 211 م', eraEn: '145 – 211 AD',
    unesco: true, lat: 32.6385, lon: 14.2910,
    status: Preservation.underTreatment, icon: Icons.military_tech,
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Bust_of_Septimius_Severus_%28GL_357%29.jpg/960px-Bust_of_Septimius_Severus_%28GL_357%29.jpg',
    storyAr: 'وُلد في لبدة الكبرى وأصبح عام 193 م أول إمبراطور روماني من أصل أفريقي. أغدق على مسقط رأسه بالأبنية الفخمة، ومنها القوس والميدان والبازيليكا السيفيرية.',
    storyEn: 'Born in Leptis Magna, he became in 193 AD the first Roman emperor of African origin. He lavished his hometown with grand buildings, including the arch, the forum and the Severan Basilica.',
    history: [
      ('145 م', 'ولادته في لبدة الكبرى', 'Born in Leptis Magna'),
      ('193 م', 'تولّيه عرش الإمبراطورية الرومانية', 'Becomes Roman emperor'),
      ('211 م', 'وفاته في يورك ببريطانيا', 'Dies at Eboracum (York), Britain'),
    ],
  ),
  HeritageSite(
    id: 'zliten', nameAr: 'لوحة فسيفساء الصيد (زليتن)', nameEn: 'Zliten Hunting Mosaic',
    regionAr: 'فيلا سيلين - الخمس', regionEn: 'Villa Silin, Khoms',
    category: 'تحف أثرية',
    eraAr: 'القرن 1–2 م', eraEn: '1st–2nd c. AD',
    unesco: false, lat: 32.5500, lon: 14.4500,
    status: Preservation.underTreatment, icon: Icons.grid_view,
    image: 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
    storyAr: 'فسيفساء رومانية نادرة تصور مشاهد الصيد ومصارعة الوحوش والمصارعين والموسيقيين، وهي من أبرز روائع الفن الروماني في شمال أفريقيا.',
    storyEn: 'A rare Roman mosaic depicting hunting, beast fights, gladiators and musicians — one of the finest works of Roman art in North Africa.',
    history: [
      ('القرن 1–2 م', 'تنفيذ اللوحة في فيلا ساحلية رومانية', 'Laid in a Roman coastal villa'),
      ('1913', 'الكشف عن اللوحة قرب زليتن', 'Uncovered near Zliten'),
      ('اليوم', 'أعمال تثبيت وتنظيف وحفظ', 'Stabilisation, cleaning and conservation'),
    ],
  ),
  HeritageSite(
    id: 'ghadames_ms', nameAr: 'مخطوطات غدامس التاريخية', nameEn: 'Ghadames Manuscripts',
    regionAr: 'مدينة غدامس القديمة', regionEn: 'Old Town of Ghadames',
    category: 'مخطوطات نادرة',
    eraAr: 'القرون الوسطى – العصر الحديث', eraEn: 'Medieval – modern era',
    unesco: true, lat: 30.1337, lon: 9.5000,
    status: Preservation.critical, icon: Icons.menu_book,
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Maghribi_script.jpg/960px-Maghribi_script.jpg',
    storyAr: 'مخطوطات في الفقه والتاريخ والتجارة والفلك حُفظت في بيوت غدامس ومكتباتها، شاهدة على دور المدينة كمحطة رئيسية على طرق القوافل الصحراوية.',
    storyEn: 'Manuscripts on law, history, trade and astronomy kept in Ghadames homes and libraries, witnesses to the town’s role as a key stop on Saharan caravan routes.',
    history: [
      ('القرون الوسطى', 'نسخ وتبادل المخطوطات عبر القوافل', 'Manuscripts copied and exchanged along caravan routes'),
      ('القرن 20', 'حفظها في المكتبات والبيوت الأسرية', 'Preserved in family homes and libraries'),
      ('اليوم', 'حاجة ماسة للرقمنة والترميم الوقائي', 'Urgent need for digitisation and preventive conservation'),
    ],
  ),
  HeritageSite(
    id: 'apollo_cyrene', nameAr: 'تماثيل أبولون وكاهنات قورينا', nameEn: 'Apollo & Priestesses of Cyrene',
    regionAr: 'شحات (قورينا)', regionEn: 'Shahhat (Cyrene)',
    category: 'آثار إغريقية',
    eraAr: 'القرن 2 م (نسخ رومانية عن أصول هلنستية)', eraEn: '2nd c. AD (Roman copies of Hellenistic originals)',
    unesco: true, lat: 32.8230, lon: 21.8600,
    status: Preservation.needsCare, icon: Icons.temple_hindu,
    image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Apollo_Kitharoidos_BM_1380.jpg/960px-Apollo_Kitharoidos_BM_1380.jpg',
    storyAr: 'من معبد أبولو في قورينا خرج تمثال أبولون حامل القيثارة، والمدينة كانت مركزًا لعبادة أبولو وكاهناتها. بعض هذه التماثيل محفوظ اليوم في متاحف عالمية.',
    storyEn: 'From the Temple of Apollo at Cyrene came the statue of Apollo holding a kithara; the city was a major centre of Apollo’s cult and priestesses. Some of these statues are now in museums abroad.',
    history: [
      ('القرن 7 ق.م', 'تأسيس عبادة أبولو في قورينا', 'Cult of Apollo established at Cyrene'),
      ('القرن 2 م', 'تماثيل رخامية رومانية لأبولون', 'Roman marble statues of Apollo'),
      ('القرن 19', 'نقل تماثيل من قورينا إلى المتحف البريطاني', 'Statues taken from Cyrene to the British Museum'),
    ],
  ),
];

// Extra high-resolution photos (Wikimedia Commons) per site id.
const kGallery = <String, List<String>>{
  'leptis': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Leptis_libya.jpg/960px-Leptis_libya.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Forum_Leptis_Magna_04.JPG/960px-Forum_Leptis_Magna_04.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Leptis_Magna_Theatre.jpg/960px-Leptis_Magna_Theatre.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Leptis_Magna_-_Severan_Basilika.jpg/960px-Leptis_Magna_-_Severan_Basilika.jpg',
  ],
  'cyrene': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Archaeological_Site_of_Cyrene-109023.jpg/960px-Archaeological_Site_of_Cyrene-109023.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Archaeological_Site_of_Cyrene-109025.jpg/960px-Archaeological_Site_of_Cyrene-109025.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Exedra_of_Apollo_Karneios%2C_Cyrene_%2850144977036%29.jpg/960px-Exedra_of_Apollo_Karneios%2C_Cyrene_%2850144977036%29.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Cyrene_Historical_Site.jpg/960px-Cyrene_Historical_Site.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Cyrene_Apollo_temple.jpg/960px-Cyrene_Apollo_temple.jpg',
  ],
  'sabratha': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Theatre_of_Sabratha%2C_Libya.jpg/960px-Theatre_of_Sabratha%2C_Libya.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Sabratha_-_B%C3%BChnenhaus_des_Theaters_2._Jh..jpg/960px-Sabratha_-_B%C3%BChnenhaus_des_Theaters_2._Jh..jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Via_del_Teatro%2C_Sabratha_%2819416%29.jpg/960px-Via_del_Teatro%2C_Sabratha_%2819416%29.jpg',
  ],
  'ghadames': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Ghadames%2C_2006.jpg/960px-Ghadames%2C_2006.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Ghadames_Old_city_from_the_air.jpg/960px-Ghadames_Old_city_from_the_air.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Covered_Street_in_Ghadames_%285282815853%29.jpg/960px-Covered_Street_in_Ghadames_%285282815853%29.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Ghadames_street_at_moring.jpg/960px-Ghadames_street_at_moring.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Libya_Ghadames_Old_Town_Wall_Entrance.JPG/960px-Libya_Ghadames_Old_Town_Wall_Entrance.JPG',
  ],
  'redcastle': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg/960px-Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Red_Castle_Museum.jpg/960px-Red_Castle_Museum.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Roman_mosaic%2C_Tripoli_Museum%2C_Libya.jpg/960px-Roman_mosaic%2C_Tripoli_Museum%2C_Libya.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Three_Graces%2C_Tripoli_Museum%2C_Libya_%283042179766%29.jpg/960px-Three_Graces%2C_Tripoli_Museum%2C_Libya_%283042179766%29.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/The_Red_Castle.jpg/960px-The_Red_Castle.jpg',
  ],
  'silin': [
    'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Gladiators_from_the_Zliten_mosaic_4.JPG/960px-Gladiators_from_the_Zliten_mosaic_4.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Musicians_from_Zliten_mosaic.JPG/960px-Musicians_from_Zliten_mosaic.JPG',
  ],
  'zliten': [
    'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/f/f3/Gladiators_from_the_Zliten_mosaic_2.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Gladiators_from_the_Zliten_mosaic_4.JPG/960px-Gladiators_from_the_Zliten_mosaic_4.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Musicians_from_Zliten_mosaic.JPG/960px-Musicians_from_Zliten_mosaic.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/5/51/Beasts_and_criminals_from_the_Zliten_mosaic.jpg',
  ],
  'medusa': [
    'https://upload.wikimedia.org/wikipedia/commons/7/7c/Gorgone_libia_by_marcotambara.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Forum_Leptis_Magna_04.JPG/960px-Forum_Leptis_Magna_04.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Leptis_Magna_-_Fragment_Kopf.jpg/960px-Leptis_Magna_-_Fragment_Kopf.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Red_Castle_Museum.jpg/960px-Red_Castle_Museum.jpg',
  ],
  'severus': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Bust_of_Septimius_Severus_%28GL_357%29.jpg/960px-Bust_of_Septimius_Severus_%28GL_357%29.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/b/bf/Septimius_Severus_bust_Thessalonike_Greece_01.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Leptis_Magna_Arch_of_Septimius_Severus.jpg/960px-Leptis_Magna_Arch_of_Septimius_Severus.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Severan_Basilica.JPG/960px-Severan_Basilica.JPG',
  ],
  'ghadames_ms': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Maghribi_script.jpg/960px-Maghribi_script.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Quran_19th_century_Nigeria%2C_Maghribi_style%2C_Boston_Museum_of_Fine_Arts.jpg/960px-Quran_19th_century_Nigeria%2C_Maghribi_style%2C_Boston_Museum_of_Fine_Arts.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Libya_Ghadames_Old_Town_Spring_Water_Pool.JPG/960px-Libya_Ghadames_Old_Town_Spring_Water_Pool.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Ghadames_-_Altstadt%2C_Thermalquelle.jpg/960px-Ghadames_-_Altstadt%2C_Thermalquelle.jpg',
  ],
  'apollo_cyrene': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Apollo_Kitharoidos_BM_1380.jpg/960px-Apollo_Kitharoidos_BM_1380.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Marble_statue_of_Apollo_holding_a_kithara%2C_British_Museum.jpg/960px-Marble_statue_of_Apollo_holding_a_kithara%2C_British_Museum.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Cyrene_Apollo_temple.jpg/960px-Cyrene_Apollo_temple.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Exedra_of_Apollo_Karneios%2C_Cyrene_%2850144977036%29.jpg/960px-Exedra_of_Apollo_Karneios%2C_Cyrene_%2850144977036%29.jpg',
  ],
};

// Documentary / tour video links. These are YouTube search pages (always valid);
// the viewer picks the video. Sites without an entry fall back to a search.
const kVideos = <String, List<(String, String, String)>>{
  'leptis': [
    ('جولة في لبدة الكبرى', 'Leptis Magna tour', 'https://www.youtube.com/results?search_query=Leptis+Magna+Libya+documentary'),
    ('وثائقي: لبدة الكبرى', 'Leptis Magna (Arabic)', 'https://www.youtube.com/results?search_query=%D9%84%D8%A8%D8%AF%D8%A9+%D8%A7%D9%84%D9%83%D8%A8%D8%B1%D9%89+%D9%88%D8%AB%D8%A7%D8%A6%D9%82%D9%8A'),
  ],
  'cyrene': [
    ('جولة في قورينا (شحات)', 'Cyrene tour', 'https://www.youtube.com/results?search_query=Cyrene+Libya+ancient+city+documentary'),
    ('وثائقي: شحات وقورينا', 'Shahhat & Cyrene (Arabic)', 'https://www.youtube.com/results?search_query=%D9%82%D9%88%D8%B1%D9%8A%D9%86%D8%A7+%D8%B4%D8%AD%D8%A7%D8%AA+%D9%88%D8%AB%D8%A7%D8%A6%D9%82%D9%8A'),
  ],
  'ghadames': [
    ('جولة في غدامس القديمة', 'Ghadames old town tour', 'https://www.youtube.com/results?search_query=Ghadames+Libya+old+town+documentary'),
    ('وثائقي: لؤلؤة الصحراء غدامس', 'Ghadames (Arabic)', 'https://www.youtube.com/results?search_query=%D8%BA%D8%AF%D8%A7%D9%85%D8%B3+%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D8%A9+%D8%A7%D9%84%D9%82%D8%AF%D9%8A%D9%85%D8%A9+%D9%88%D8%AB%D8%A7%D8%A6%D9%82%D9%8A'),
  ],
  'redcastle': [
    ('جولة في متحف السراي الحمراء', 'Red Castle Museum tour', 'https://www.youtube.com/results?search_query=Red+Castle+Museum+Tripoli+Libya'),
    ('وثائقي: السرايا الحمراء', 'Assaraya Alhamra (Arabic)', 'https://www.youtube.com/results?search_query=%D8%A7%D9%84%D8%B3%D8%B1%D8%A7%D9%8A%D8%A7+%D8%A7%D9%84%D8%AD%D9%85%D8%B1%D8%A7%D8%A1+%D8%B7%D8%B1%D8%A7%D8%A8%D9%84%D8%B3+%D9%88%D8%AB%D8%A7%D8%A6%D9%82%D9%8A'),
  ],
  'medusa': [
    ('ميدوسا ولبدة الكبرى', 'Medusa of Leptis Magna', 'https://www.youtube.com/results?search_query=Medusa+Leptis+Magna+Severan+Forum'),
    ('جولة في متحف السراي الحمراء', 'Red Castle Museum tour', 'https://www.youtube.com/results?search_query=Red+Castle+Museum+Tripoli+Libya'),
  ],
  'severus': [
    ('سيبتيموس سيفيروس: الإمبراطور الليبي', 'Septimius Severus documentary', 'https://www.youtube.com/results?search_query=Septimius+Severus+emperor+documentary'),
    ('جولة في لبدة الكبرى', 'Leptis Magna tour', 'https://www.youtube.com/results?search_query=Leptis+Magna+Libya+documentary'),
  ],
  'zliten': [
    ('فسيفساء زليتن', 'Zliten mosaic', 'https://www.youtube.com/results?search_query=Zliten+mosaic+Libya'),
    ('فيلا سيلين', 'Villa Silin', 'https://www.youtube.com/results?search_query=Villa+Silin+Libya+mosaics'),
  ],
  'silin': [
    ('فيلا سيلين', 'Villa Silin', 'https://www.youtube.com/results?search_query=Villa+Silin+Libya+mosaics'),
  ],
  'ghadames_ms': [
    ('مخطوطات غدامس', 'Ghadames manuscripts', 'https://www.youtube.com/results?search_query=%D9%85%D8%AE%D8%B7%D9%88%D8%B7%D8%A7%D8%AA+%D8%BA%D8%AF%D8%A7%D9%85%D8%B3'),
    ('جولة في غدامس القديمة', 'Ghadames old town tour', 'https://www.youtube.com/results?search_query=Ghadames+Libya+old+town+documentary'),
  ],
  'apollo_cyrene': [
    ('معبد أبولو في قورينا', 'Temple of Apollo at Cyrene', 'https://www.youtube.com/results?search_query=Temple+of+Apollo+Cyrene+Libya'),
    ('جولة في قورينا (شحات)', 'Cyrene tour', 'https://www.youtube.com/results?search_query=Cyrene+Libya+ancient+city+documentary'),
  ],
};

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

  // Visitor heritage-interest quiz + itinerary
  String persona = ''; // '', 'A', 'B', 'C', 'D'
  bool retakingQuiz = false;

  SharedPreferences? _prefs;

  bool get isExpertRole => role == UserRole.expert;
  bool get quizDone => persona.isNotEmpty;
  bool get showQuiz => !isExpertRole && (!quizDone || retakingQuiz);

  void completeQuiz(List<String> answers) {
    final counts = <String, int>{};
    for (final a in answers) {
      counts[a] = (counts[a] ?? 0) + 1;
    }
    var best = 'A';
    var max = -1;
    // Ties resolve in favour of the earliest answer given.
    for (final a in answers) {
      if (counts[a]! > max) {
        max = counts[a]!;
        best = a;
      }
    }
    persona = best;
    retakingQuiz = false;
    notifyListeners();
    _save();
  }

  void resetQuiz() {
    persona = '';
    retakingQuiz = true;
    tab = 0;
    notifyListeners();
    _save();
  }

  void cancelQuiz() {
    retakingQuiz = false;
    notifyListeners();
  }

  List<String> touristTags(HeritageSite x) {
    final tags = <String>[];
    if (persona.isNotEmpty && (kPersonas[persona]?.ids.contains(x.id) ?? false)) {
      tags.add('موصى به لزيارتك');
    }
    if (x.unesco) tags.add('موقع يونسكو');
    if (const {'تحف فنية', 'تحف أثرية', 'شخصيات تاريخية', 'مخطوطات نادرة'}
        .contains(x.category)) {
      tags.add('تحفة فنية');
    }
    if (const {'واحات طبيعية', 'نقوش صخرية'}.contains(x.category)) {
      tags.add('مناظر طبيعية');
    }
    if (tags.isEmpty) tags.add('موصى به لزيارتك');
    return tags;
  }

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
      persona = p.getString('quizPersona') ?? '';
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
      await p.setString('quizPersona', persona);
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
    tab = 0;
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
        theme: buildTheme(Brightness.dark),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        builder: (context, child) => Directionality(
          textDirection: state.ar ? TextDirection.rtl : TextDirection.ltr,
          child: HeritageBackdrop(child: child!),
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: BorderSide(color: kGold.withValues(alpha: 0.5)),
            minimumSize: const Size(52, 34),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          onPressed: s.toggleLang,
          child: Text(s.ar ? 'EN' : 'AR',
              style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700, color: kBeige)),
        ),
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
                      ErthLogo(
                        size: 96,
                        horizontal: false,
                        tagline: true,
                        onTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: cardDeco(radius: 24).copyWith(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 12)),
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
                              GoldButton(
                                  label: '',
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
                                          style: GoogleFonts.tajawal(
                                              color: kWine,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16)),
                              ),
                              const SizedBox(height: 10),
                              GlassButton(
                                onPressed: () => s.quickDemo(role),
                                icon: Icons.bolt,
                                label: s.t('دخول سريع (تجريبي)', 'Quick demo access'),
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
    final isExpert = s.role == UserRole.expert;
    final pages = isExpert
        ? <Widget>[
            HomeTab(state: s),
            SitesTab(state: s),
            ScannerTab(state: s),
            LogsTab(state: s),
            AccountTab(state: s),
          ]
        : <Widget>[
            HomeTab(state: s),
            SitesTab(state: s),
            ChatSheet(state: s),
            AccountTab(state: s),
          ];
    final tabIndex = s.tab.clamp(0, pages.length - 1);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        toolbarHeight: 68,
        title: ErthLogo(
          size: 40,
          onTap: () {
            // Close any open sheet/dialog and go back to the Home feed.
            Navigator.of(context).popUntil((r) => r.isFirst);
            s.setTab(0);
          },
        ),
        actions: topControls(context, s, account: true),
      ),
      body: SizedBox.expand(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                  key: ValueKey('${s.role.name}$tabIndex'), child: pages[tabIndex]),
            ),
          ),
        ),
      ),
      floatingActionButton: (!isExpert && tabIndex == 2)
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isExpert && tabIndex == 3) ...[
                  SizedBox(
                    width: 250,
                    child: GoldButton(
                      height: 50,
                      label: s.t('إضافة تقرير ترميم فني', 'Add restoration report'),
                      icon: Icons.add,
                      onPressed: () => showAddLogSheet(context, s),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _GuidePill(
                  label: s.t('المرشد الأثري الذكي', 'AI Heritage Guide'),
                  onTap: () => showChatSheet(context, s),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: kGold.withValues(alpha: 0.25)))),
        child: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: s.setTab,
        destinations: isExpert
            ? [
                NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_outlined),
                    label: s.t('الرئيسية', 'Home')),
                NavigationDestination(
                    icon: const Icon(Icons.account_balance_outlined),
                    selectedIcon: const Icon(Icons.account_balance_outlined),
                    label: s.t('المواقع', 'Sites')),
                NavigationDestination(
                    icon: const Icon(Icons.crop_free),
                    selectedIcon: const Icon(Icons.crop_free),
                    label: s.t('الماسح', 'Scanner')),
                NavigationDestination(
                    icon: const Icon(Icons.science_outlined),
                    selectedIcon: const Icon(Icons.science_outlined),
                    label: s.t('سجل الترميم', 'Logs')),
                NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person_outline),
                    label: s.t('الحساب', 'Account')),
              ]
            : [
                NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_outlined),
                    label: s.t('الرئيسية', 'Home')),
                NavigationDestination(
                    icon: const Icon(Icons.account_balance_outlined),
                    selectedIcon: const Icon(Icons.account_balance_outlined),
                    label: s.t('المواقع', 'Explore')),
                NavigationDestination(
                    icon: const Icon(Icons.auto_awesome_outlined),
                    selectedIcon: const Icon(Icons.auto_awesome_outlined),
                    label: s.t('المرشد الذكي', 'AI guide')),
                NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person_outline),
                    label: s.t('الحساب', 'Account')),
              ],
      ),
      ),
    );
  }
}

class _GuidePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GuidePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: kRedGradient,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: kGoldLight.withValues(alpha: 0.85), width: 1.3),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome, size: 19, color: kGoldLight),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.tajawal(
                  fontSize: 15, fontWeight: FontWeight.w700, color: kBeige)),
        ]),
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
    final good = status == Preservation.good;
    return Pill(status.label(ar),
        border: good ? const Color(0xFF6FAF7A) : const Color(0xFFB8463A),
        textColor: good ? const Color(0xFFBFE3C4) : const Color(0xFFF2B3A9),
        fill: const Color(0xD91E0709));
  }
}

class _TouristTag extends StatelessWidget {
  final String text;
  const _TouristTag(this.text);

  @override
  Widget build(BuildContext context) => Pill.unesco(text);
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
          colors: [const Color(0xFF4A1218), p.bg],
        ),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.8, child: ArchEmblem(size: 96)),
        ],
      ),
    );
  }
}

/// Scale-down physics on press, for immediate tactile feedback.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const TapScale({super.key, required this.child, this.onTap, this.scale = 0.96});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => down = true),
      onPointerUp: (_) => setState(() => down = false),
      onPointerCancel: (_) => setState(() => down = false),
      child: AnimatedScale(
        scale: down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: widget.child),
      ),
    );
  }
}

/// Fade + slide-up entrance, delayed by [index] for a staggered cascade.
class StaggerIn extends StatefulWidget {
  final int index;
  final Widget child;
  const StaggerIn({super.key, required this.index, required this.child});

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(Duration(milliseconds: 70 * math.min(widget.index, 10)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(a),
        child: widget.child,
      ),
    );
  }
}

class SiteImage extends StatelessWidget {
  final HeritageSite site;

  /// Hero scope: must be unique per visible list so tags never collide.
  final String scope;
  const SiteImage(this.site, {super.key, this.scope = ''});

  @override
  Widget build(BuildContext context) {
    return Hero(tag: 'site-$scope${site.id}', child: _img());
  }

  Widget _img() {
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
  final String scope;
  const SiteCard(
      {super.key, required this.site, required this.state, this.scope = ''});

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
        child: TapScale(
          scale: 0.97,
          onTap: () => showSiteSheet(context, widget.state, s, scope: widget.scope),
          child: Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: kGold.withValues(alpha: hover ? 0.55 : 0.3)),
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
                    SiteImage(s, scope: widget.scope),
                    PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: widget.state.isExpertRole
                            ? _StatusBadge(s.status, ar)
                            : _TouristTag(widget.state.touristTags(s).first)),
                    if (s.unesco && widget.state.isExpertRole)
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: Pill.unesco(ar ? 'اليونسكو' : 'UNESCO'),
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
                              style: TextStyle(fontSize: 11, color: kGoldLight)),
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

void showSiteSheet(BuildContext context, AppState state, HeritageSite s,
    {String scope = ''}) {
  final p = Pal.of(context);
  final ar = state.ar;
  Navigator.of(context).push(PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (sheetCtx, _, __) => Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        title: Text(s.name(ar),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(height: 260, child: SiteImage(s, scope: scope)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Text(s.name(ar),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ),
            if (state.isExpertRole) _StatusBadge(s.status, ar),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (!state.isExpertRole)
              for (final tg in state.touristTags(s))
                Chip(
                    avatar: Icon(Icons.verified, size: 16, color: p.accent),
                    label: Text(tg)),
            Chip(
                avatar: Icon(Icons.place, size: 16, color: p.accent),
                label: Text(s.region(ar))),
            Chip(label: Text(ar ? s.category : kCategoryEn[s.category]!)),
            Chip(
                avatar: Icon(Icons.schedule, size: 16, color: p.accent),
                label: Text(s.era(ar))),
            if (s.unesco && state.isExpertRole)
              Chip(
                  avatar: Icon(Icons.public, size: 16, color: p.accent),
                  label: Text(ar ? 'تراث عالمي - اليونسكو' : 'UNESCO World Heritage')),
            Chip(
                avatar: Icon(Icons.my_location, size: 16, color: p.accent),
                label: Text(
                    '${s.lat.toStringAsFixed(4)}°N, ${s.lon.toStringAsFixed(4)}°E')),
          ]),
          const SizedBox(height: 16),
          _GalleryStrip(site: s, ar: ar),
          const SizedBox(height: 16),
          Text(ar ? 'القصة والتراث' : 'Story & heritage',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: kGoldLight)),
          const SizedBox(height: 8),
          Text(s.story(ar), style: const TextStyle(height: 1.8, fontSize: 15)),
          const SizedBox(height: 20),
          Text(
              state.isExpertRole
                  ? (ar ? 'تاريخ الموقع والترميم' : 'Site & restoration history')
                  : (ar ? 'تاريخ الموقع' : 'Site timeline'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: kGoldLight)),
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
          _VideoSection(site: s, ar: ar),
          const SizedBox(height: 16),
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
      ),
    ),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  ));
}

// ───────────────────── Gallery & videos (site sheet) ────────────────────────

class _GalleryStrip extends StatelessWidget {
  final HeritageSite site;
  final bool ar;
  const _GalleryStrip({required this.site, required this.ar});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final photos = site.photos;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.photo_library_outlined, size: 20, color: kGoldLight),
        const SizedBox(width: 8),
        Text(ar ? 'معرض الصور' : 'Photo gallery',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kGoldLight)),
        const SizedBox(width: 8),
        Text('${photos.length}', style: TextStyle(color: p.text2)),
      ]),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) => InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openViewer(ctx, photos, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 210,
                child: _NetPhoto(photos[i], site),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  void _openViewer(BuildContext context, List<String> photos, int start) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(children: [
          PageView.builder(
            controller: PageController(initialPage: start),
            itemCount: photos.length,
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  photos[i],
                  fit: BoxFit.contain,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NetPhoto extends StatelessWidget {
  final String url;
  final HeritageSite site;
  const _NetPhoto(this.url, this.site);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
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

class _VideoSection extends StatelessWidget {
  final HeritageSite site;
  final bool ar;
  const _VideoSection({required this.site, required this.ar});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ar ? 'تعذر فتح الرابط' : 'Could not open the link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.smart_display_outlined, size: 20, color: kGoldLight),
        const SizedBox(width: 8),
        Text(ar ? 'فيديوهات وثائقية' : 'Documentary videos',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kGoldLight)),
      ]),
      const SizedBox(height: 10),
      for (final v in site.videos)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _open(context, v.$3),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: p.line),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: p.accent, size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ar ? v.$1 : v.$2,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('YouTube',
                              style: TextStyle(color: p.text2, fontSize: 12)),
                        ]),
                  ),
                  Icon(Icons.open_in_new, size: 18, color: p.text2),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
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
            border: Border.all(color: kGold.withValues(alpha: 0.35)),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [Color(0xFF4A1218), kMaroon],
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.t('مرحبًا', 'Welcome'), style: captionStyle(14)),
                Calligraphy(
                    s.name.isEmpty ? s.t('زائر', 'Guest') : s.name, size: 34),
                const SizedBox(height: 6),
                Text(
                    isExpert
                        ? s.t('لوحة متابعة أعمال الترميم والعتاد',
                            'Restoration and equipment dashboard')
                        : s.t('رحلة عبر آلاف السنين من الحضارات',
                            'A journey through thousands of years of civilisation'),
                    style: subStyle(14)),
              ]),
            ),
            const SizedBox(width: 12),
            const ArchEmblem(size: 70),
          ]),
        ),
        const SizedBox(height: 18),
        if (s.offline) _OfflineBanner(s),
        if (!isExpert)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: s.showQuiz
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: HeritageQuizCard(state: s))
                : s.quizDone
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _Recommendations(state: s))
                    : const SizedBox.shrink(),
          ),
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
            style: titleStyle(21)),
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
                    child: SiteCard(site: x, state: s, scope: 'f'),
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

class HeritageQuizCard extends StatefulWidget {
  final AppState state;
  const HeritageQuizCard({super.key, required this.state});

  @override
  State<HeritageQuizCard> createState() => _HeritageQuizCardState();
}

class _HeritageQuizCardState extends State<HeritageQuizCard> {
  int q = 0;
  final List<String> answers = [];

  void _pick(String letter) {
    if (q + 1 < kQuiz.length) {
      setState(() {
        answers.add(letter);
        q++;
      });
    } else {
      widget.state.completeQuiz([...answers, letter]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final item = kQuiz[q];
    const letters = ['A', 'B', 'C', 'D'];
    const marks = ['أ', 'ب', 'ج', 'د'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.accent.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.quiz, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text('استبيان الاهتمامات الأثرية',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kGoldLight)),
          ),
          if (widget.state.retakingQuiz)
            TextButton(
                onPressed: widget.state.cancelQuiz, child: const Text('إلغاء')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text('السؤال ${q + 1} من ${kQuiz.length}',
              style: TextStyle(color: p.text2, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (q + 1) / kQuiz.length),
                duration: const Duration(milliseconds: 350),
                builder: (_, v, __) => LinearProgressIndicator(
                    value: v, minHeight: 7, color: p.accent, backgroundColor: p.line),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                  position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
                      .animate(a),
                  child: c)),
          child: Column(
            key: ValueKey(q),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('س${q + 1}: ${item.$1}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, height: 1.5)),
              const SizedBox(height: 12),
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TapScale(
                    scale: 0.97,
                    onTap: () => _pick(letters[i]),
                    child: Material(
                      color: p.bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: p.line)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _pick(letters[i]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          child: Row(children: [
                      CircleAvatar(
                          radius: 13,
                          backgroundColor: p.primary.withValues(alpha: 0.12),
                          child: Text(marks[i],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: kGoldLight,
                                  fontWeight: FontWeight.w800))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(item.$2[i],
                              style: TextStyle(color: p.text, height: 1.4))),
                    ]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Recommendations extends StatelessWidget {
  final AppState state;
  const _Recommendations({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final per = kPersonas[state.persona]!;
    final sites = [
      for (final id in per.ids) kSites.firstWhere((x) => x.id == id)
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Icon(per.icon, color: p.primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('شخصيتك الأثرية: ${per.nameAr}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              TextButton.icon(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                onPressed: state.resetQuiz,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('إعادة تحديد اهتماماتي'),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Text('موصى به لك',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: p.accent)),
      const SizedBox(height: 2),
      Text(per.titleAr,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      SizedBox(
        height: 300,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final x in sites)
              SizedBox(
                width: 270,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 14),
                  child: SiteCard(site: x, state: state, scope: 'r'),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: cardDeco(),
        child: Column(children: [
          GoldNumber(value),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: captionStyle(13)),
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
                  itemBuilder: (_, i) => StaggerIn(
                      key: ValueKey('${s.category}-${sites[i].id}'),
                      index: i,
                      child: SiteCard(site: sites[i], state: s, scope: 'e')),
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
    Widget seg(int v, String label) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              mode = v;
              mat = null;
              finding = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: mode == v ? kRedGradient : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(label,
                  style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: mode == v ? FontWeight.w700 : FontWeight.w500,
                      color: mode == v ? kBeige : kMuted)),
            ),
          ),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Text(s.t('ماسح العتاد والآثار', 'Equipment & Artifact Scanner'),
                style: titleStyle(24)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kGold.withValues(alpha: 0.35)),
            ),
            child: Text(s.t('4 من 6', '4 of 6'), style: subStyle(14)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
            s.t('نسخة تجريبية: النتائج محاكاة ولا تمثل تحليلاً حقيقياً للصورة.',
                'Demo: results are simulated and are not a real image analysis.'),
            style: captionStyle(13)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF170609),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            seg(0, s.t('فحص العتاد والمواد', 'Equipment & materials')),
            const SizedBox(width: 6),
            seg(1, s.t('تشخيص حالة الأثر', 'Artifact diagnosis')),
          ]),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C0203),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kGold.withValues(alpha: 0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              if (image != null)
                Image.memory(image!, fit: BoxFit.cover)
              else
                Center(
                  child: Icon(Icons.crop_free,
                      size: 84, color: kMuted.withValues(alpha: 0.25)),
                ),
              CustomPaint(painter: _BracketPainter(kGoldLight)),
              AnimatedBuilder(
                animation: _laser,
                builder: (_, __) => Align(
                  alignment: Alignment(0, _laser.value * 1.6 - 0.8),
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 34),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(colors: [
                        Color(0x00DFB85C),
                        kGoldLight,
                        kGoldPale,
                        kGoldLight,
                        Color(0x00DFB85C),
                      ]),
                      boxShadow: [
                        BoxShadow(
                            color: kGoldLight.withValues(alpha: 0.8),
                            blurRadius: scanning ? 18 : 10,
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
                      style: subStyle(14)),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: GoldButton(
              label: s.t('التقاط صورة', 'Take photo'),
              onPressed: scanning ? null : () => _pick(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassButton(
              label: s.t('رفع صورة', 'Upload photo'),
              onPressed: scanning ? null : () => _pick(ImageSource.gallery),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        GlassButton(
          pill: true,
          label: s.t('مسح مباشر (محاكاة)', 'Live scan (simulated)'),
          onPressed: scanning ? null : () => _scan(),
        ),
        const SizedBox(height: 18),
        if (mat != null) _equipmentResult(p, isExpert),
        if (finding != null) _diagnosisResult(p, isExpert),
      ],
    );
  }

  Widget _card(Pal p, List<Widget> children) => Container(
        padding: const EdgeInsets.all(18),
        decoration: cardDeco(),
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
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(
              width: 110,
              child: Text(s.t('الصيغة', 'Formula'), style: captionStyle(13))),
          Flexible(child: Pill.formula(m.formula)),
        ]),
      ),
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
          style: TextStyle(fontWeight: FontWeight.w800, color: kGoldLight)),
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
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const m = 22.0, l = 44.0;
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

  Widget _logCard(RestorationLog l) {
    // Split "… الضرر: تآكل متوسط." into the action text and a damage pill.
    var action = l.report.trim();
    String? damage;
    final k = action.indexOf('الضرر:');
    if (k >= 0) {
      damage = action.substring(k).replaceAll(RegExp(r'[.。]+$'), '').trim();
      action = action.substring(0, k).trim();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: cardDeco(radius: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.siteName, style: titleStyle(19))),
          if (!l.synced)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Icon(Icons.cloud_off, size: 14, color: kMuted),
            ),
          Text(_fmt(l.createdAt),
              textDirection: TextDirection.ltr, style: captionStyle(13)),
        ]),
        const SizedBox(height: 10),
        Text(action, style: subStyle(15).copyWith(height: 1.7)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 10, children: [
          if (l.materials.trim().isNotEmpty) Pill.formula(l.materials),
          if (damage != null) Pill.damage(damage),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final p = Pal.of(context);
    return RefreshIndicator(
      onRefresh: s.loadLogs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
        children: [
          Text(s.t('سجل الترميم', 'Restoration log'), style: titleStyle(24)),
          const SizedBox(height: 4),
          Text(s.t('${s.logs.length} تقرير فني', '${s.logs.length} technical reports'),
              style: captionStyle(13)),
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
          for (final l in s.logs) _logCard(l),
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
          child: Text(t, style: titleStyle(17).copyWith(color: kGoldLight)),
        );
    Widget field(String label, TextEditingController c,
            {String? Function(String?)? validator, int lines = 1}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: captionStyle(13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: c,
              validator: validator,
              minLines: lines,
              maxLines: lines == 1 ? 1 : lines + 2,
              style: subStyle(16).copyWith(color: Colors.white),
              decoration: InputDecoration(hintText: label),
            ),
          ]),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Row(children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: kRedGradient,
              shape: BoxShape.circle,
              border: Border.all(color: kGoldLight, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: kRed.withValues(alpha: 0.45), blurRadius: 24),
              ],
            ),
            child: Icon(isExpert ? Icons.verified_user_outlined : Icons.person_outline,
                size: 46, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Calligraphy(
                  s.name.isEmpty ? s.t('زائر', 'Guest') : s.name, size: 32),
              Text(s.email,
                  textDirection: TextDirection.ltr, style: captionStyle(14)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            field(s.t('الاسم', 'Name'), _name,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? s.t('هذا الحقل مطلوب', 'Required')
                    : null),
            field(s.t('البريد الإلكتروني', 'Email'), _email,
                validator: (v) => (v == null || !v.contains('@'))
                    ? s.t('بريد إلكتروني غير صالح', 'Invalid email')
                    : null),
            field(s.t('المسمى / التخصص', 'Title / specialty'), _title),
            field(s.t('المدينة / الهاتف', 'City / phone'), _city),
            if (isExpert) ...[
              field(s.t('التخصص الدقيق', 'Academic specialization'), _spec),
              field(s.t('رقم العضوية / التصريح', 'Membership / license no.'), _lic),
              field(s.t('نبذة', 'Bio'), _bio, lines: 3),
            ],
            const SizedBox(height: 4),
            GoldButton(
              label: s.t('حفظ التغييرات', 'Save changes'),
              onPressed: _save,
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
        if (!isExpert) ...[
          section(s.t('اهتماماتي الأثرية', 'My heritage interests')),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(
                  s.quizDone ? kPersonas[s.persona]!.icon : Icons.quiz_outlined,
                  color: p.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    s.quizDone
                        ? kPersonas[s.persona]!.nameAr
                        : 'لم تُجرِ الاستبيان بعد',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              OutlinedButton(
                onPressed: s.resetQuiz,
                child: Text(s.quizDone ? 'إعادة تحديد اهتماماتي' : 'ابدأ الاستبيان'),
              ),
            ]),
          ),
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
            s.isExpertRole
                ? 'مرحبًا! أنا المرشد الأثري الذكي لـ «إرث». اسألني عن المواقع الأثرية الليبية أو عن كيمياء الترميم والمواد.'
                : 'مرحبًا! أنا المرشد الأثري الذكي لـ «إرث». اسألني عن المواقع الأثرية الليبية وتاريخها وكيف تخطط لزيارتها.',
            s.isExpertRole
                ? 'Hello! I am ERTH’s AI heritage guide. Ask me about Libyan archaeological sites or conservation chemistry.'
                : 'Hello! I am ERTH’s AI heritage guide. Ask me about Libyan sites, their history and how to plan your visit.')));
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
  const bronze = Color(0xFFC59B27);
  const beige = Color(0xFFF5F1E6);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: kWine,
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
              const ErthLogo(size: 64),
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
