import 'package:erth_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // The test font (Ahem) renders every glyph as a wide square, so text-driven
  // RenderFlex overflows and missing Google Fonts are expected here; any other
  // error fails the test.
  void ignoreTestFontNoise() {
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      final e = '${d.exception}';
      if (e.contains('GoogleFonts') ||
          e.contains('allowRuntimeFetching') ||
          e.contains('overflowed')) {
        return;
      }
      prev?.call(d);
    };
  }

  testWidgets('every admin tab and the site editor render', (t) async {
    ignoreTestFontNoise();
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.loadPrefs();
    s.quickDemo(UserRole.admin);
    await t.binding.setSurfaceSize(const Size(420, 900));
    await t.pumpWidget(ErthApp(state: s));
    await t.pump(const Duration(seconds: 2));

    expect(find.byType(AdminShell), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      s.setTab(i);
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull, reason: 'tab $i');
    }
    s.setTab(1);
    await t.pump(const Duration(seconds: 1));
    showSiteEditor(t.element(find.byType(AdminSitesTab)), s,
        site: s.siteById('leptis'));
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(SiteEditor), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pump(const Duration(seconds: 3));
  });
}
