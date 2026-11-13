import 'package:erth_project/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppState> fresh() async {
    final s = AppState();
    await s.loadPrefs();
    return s;
  }

  test('admin login requires correct credentials', () async {
    final s = await fresh();
    expect(s.loginAdmin('admin@erth.ly', 'wrong'), isNotNull);
    expect(s.isAdmin, isFalse);
    expect(s.loginAdmin(kAdminEmail, kAdminPasscode), isNull);
    expect(s.isAdmin, isTrue);
  });

  test('added site is live and survives reload', () async {
    final s = await fresh();
    final before = s.sites.length;
    final site = HeritageSite.fromJson({
      'id': 'custom_1',
      'nameAr': 'موقع جديد',
      'nameEn': 'New Site',
      'category': 'ما قبل التاريخ',
      'status': 'underTreatment',
      'unesco': true,
      'image': 'https://example.com/a.jpg',
      'gallery': ['https://example.com/b.jpg'],
      'custom': true,
    });
    s.saveSite(site);
    expect(s.sites.length, before + 1);
    expect(s.filteredSites.any((x) => x.id == 'custom_1'), isTrue);

    await Future<void>.delayed(Duration.zero);
    final r = await fresh();
    final back = r.siteById('custom_1')!;
    expect(back.nameEn, 'New Site');
    expect(back.status, Preservation.underTreatment);
    expect(back.photos, ['https://example.com/a.jpg', 'https://example.com/b.jpg']);
  });

  test('edit, hide and delete built-in site', () async {
    final s = await fresh();
    final leptis = s.siteById('leptis')!;
    s.saveSite(leptis.copyWith(nameEn: 'Leptis Edited'));
    expect(s.siteById('leptis')!.nameEn, 'Leptis Edited');
    expect(s.sites.length, kSites.length);

    s.setHidden('leptis', true);
    expect(s.siteById('leptis'), isNull);
    expect(s.allSites.any((x) => x.id == 'leptis'), isTrue);

    s.deleteSite('sabratha');
    expect(s.allSites.any((x) => x.id == 'sabratha'), isFalse);

    await Future<void>.delayed(Duration.zero);
    final r = await fresh();
    expect(r.siteById('leptis'), isNull);
    expect(r.allSites.firstWhere((x) => x.id == 'leptis').nameEn, 'Leptis Edited');
    expect(r.allSites.any((x) => x.id == 'sabratha'), isFalse);

    r.restoreBuiltInSites();
    expect(r.siteById('sabratha'), isNotNull);
    expect(r.siteById('leptis')!.nameEn, 'Leptis Magna');
  });

  test('report review persists', () async {
    final s = await fresh();
    final log = s.logs.last;
    s.setReview(log, ReviewStatus.archived, damage: 'مرتفع');
    await Future<void>.delayed(Duration.zero);
    final r = await fresh();
    expect(r.logs.last.review, ReviewStatus.archived);
    expect(r.logs.last.split.$2, 'الضرر: مرتفع');
  });

  test('quiz edits and completions persist', () async {
    final s = await fresh();
    s.setQuizItem(0, 'Q?', ['a', 'b', 'c', 'd']);
    s.completeQuiz(['B', 'B', 'A', 'C']);
    expect(s.persona, 'B');
    await Future<void>.delayed(Duration.zero);
    final r = await fresh();
    expect(r.quiz.first.$1, 'Q?');
    expect(r.quizCompletions, 1);
  });

  test('delete account wipes profile but keeps catalog', () async {
    final s = await fresh();
    s.quickDemo(UserRole.expert);
    s.setHidden('waw', true);
    await s.deleteAccount();
    expect(s.loggedIn, isFalse);
    expect(s.name, isEmpty);
    final r = await fresh();
    expect(r.loggedIn, isFalse);
    expect(r.email, isEmpty);
    expect(r.hiddenIds, contains('waw'));
  });
}
