part of 'main.dart';

// ─────────────────────────────── Legal & account deletion ──────────────────
// Privacy Policy / Terms of Use (App Store 5.1.1, Google Play User Data policy)
// and in-app account deletion (App Store 5.1.1(v), Google Play).

const kPolicyUpdated = '2026-11-13';

class LegalLinks extends StatelessWidget {
  final AppState state;
  const LegalLinks({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
            s.t('بالمتابعة فإنك توافق على ', 'By continuing you agree to the '),
            style: captionStyle(12)),
        TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 32)),
          onPressed: () => showLegalSheet(context, s, terms: true),
          child: Text(s.t('شروط الاستخدام', 'Terms of Use'),
              style: captionStyle(12).copyWith(
                  color: inkGold, decoration: TextDecoration.underline)),
        ),
        Text(s.t('و', '&'), style: captionStyle(12)),
        TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 32)),
          onPressed: () => showLegalSheet(context, s),
          child: Text(s.t('سياسة الخصوصية', 'Privacy Policy'),
              style: captionStyle(12).copyWith(
                  color: inkGold, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

void showLegalSheet(BuildContext context, AppState s, {bool terms = false}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Pal.of(context).bg,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.88,
      child: DefaultTabController(
        length: 2,
        initialIndex: terms ? 1 : 0,
        child: Column(children: [
          TabBar(
            indicatorColor: kGold,
            labelColor: inkGold,
            unselectedLabelColor: inkMuted,
            labelStyle:
                GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 15),
            tabs: [
              Tab(text: s.t('سياسة الخصوصية', 'Privacy Policy')),
              Tab(text: s.t('شروط الاستخدام', 'Terms of Use')),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              _LegalBody(s.ar ? _privacyAr : _privacyEn, s),
              _LegalBody(s.ar ? _termsAr : _termsEn, s),
            ]),
          ),
        ]),
      ),
    ),
  );
}

class _LegalBody extends StatelessWidget {
  final List<(String, String)> sections;
  final AppState s;
  const _LegalBody(this.sections, this.s);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          children: [
            Text(
                s.t('آخر تحديث: $kPolicyUpdated',
                    'Last updated: $kPolicyUpdated'),
                style: captionStyle(12)),
            for (final (h, body) in sections) ...[
              const SizedBox(height: 18),
              Text(h, style: titleStyle(17).copyWith(color: inkGold)),
              const SizedBox(height: 6),
              Text(body, style: subStyle(14.5).copyWith(height: 1.75)),
            ],
          ],
        ),
      ),
    );
  }
}

const _privacyAr = <(String, String)>[
  (
    'من نحن',
    'تطبيق «إرث» منصة تعليمية للتعريف بالتراث الليبي ودعم توثيق أعمال الترميم. توضح هذه السياسة البيانات التي نجمعها وكيف نستخدمها ونحميها.'
  ),
  (
    'البيانات التي نجمعها',
    '• بيانات الحساب: الاسم، البريد الإلكتروني، المدينة، ونوع الحساب (زائر أو مرمم). وللمرممين: التخصص ورقم العضوية.\n'
        '• التقارير الفنية التي يرفعها المرممون (اسم الموقع، المواد المستخدمة، وصف الضرر).\n'
        '• نتيجة استبيان الاهتمامات وتفضيلات التطبيق (اللغة والإشعارات) وتُحفظ على جهازك.\n'
        '• لا نجمع موقعك الجغرافي ولا جهات الاتصال ولا أي بيانات صحية أو مالية.'
  ),
  (
    'الكاميرا والصور (ماسح العتاد والآثار)',
    'يطلب الماسح إذن الكاميرا أو مكتبة الصور فقط عند ضغطك على زر الالتقاط أو الاختيار، لتصوير قطعة أثرية أو ملصق مادة ترميم. تُعالج الصورة على جهازك لعرض نتيجة توضيحية، ولا تُرفع إلى خوادمنا ولا تُشارك مع أي طرف. يمكنك سحب الإذن في أي وقت من إعدادات الجهاز دون أن يتأثر باقي التطبيق.'
  ),
  (
    'نتائج الماسح والمرشد الذكي',
    'نتائج الماسح في النسخة الحالية محاكاة تعليمية ولا تمثل تحليلًا مخبريًا أو كيميائيًا حقيقيًا، ولا تُقدم أي ادعاءات طبية أو تتعلق بالسلامة. إجابات المرشد الذكي مولّدة آليًا وقد تحتوي أخطاء؛ يُرسل نص محادثتك مع المرشد فقط إلى مزود الذكاء الاصطناعي (OpenRouter) لتوليد الإجابة، دون اسمك أو بريدك أو أي بيانات من حسابك.'
  ),
  (
    'كيف نستخدم البيانات',
    'لتشغيل حسابك، وعرض المحتوى المناسب لاهتماماتك، وتمكين الإدارة من مراجعة تقارير الترميم واعتمادها. لا نبيع بياناتك ولا نستخدمها للإعلانات ولا نتتبعك عبر التطبيقات الأخرى.'
  ),
  (
    'التخزين والحماية',
    'تُخزن بيانات الحساب والتقارير لدى مزود البنية السحابية (Supabase) عبر اتصال مشفر (HTTPS)، وتُحفظ التفضيلات محليًا على جهازك.'
  ),
  (
    'حذف الحساب وحقوقك',
    'يمكنك تعديل بياناتك من شاشة «الحساب»، وحذف حسابك وكل بياناتك نهائيًا عبر زر «حذف الحساب والبيانات» في الشاشة نفسها. يؤدي الحذف إلى إزالة بيانات الملف الشخصي من جهازك وطلب حذف الحساب من الخادم.'
  ),
  (
    'الأطفال',
    'التطبيق مناسب لجميع الأعمار، ومحتواه المرئي معماري وتعليمي خالٍ من العُري والعنف. لا نجمع عن قصد بيانات شخصية من الأطفال دون 13 عامًا.'
  ),
  (
    'التواصل',
    'لأي استفسار حول الخصوصية أو لطلب حذف بياناتك، تواصل مع فريق «إرث» عبر البريد: privacy@erth.ly'
  ),
];

const _privacyEn = <(String, String)>[
  (
    'Who we are',
    'ERTH is an educational platform that showcases Libyan heritage and supports documentation of conservation work. This policy explains what data we collect and how we use and protect it.'
  ),
  (
    'Data we collect',
    '• Account data: name, email, city and account type (visitor or conservator). For conservators: specialisation and membership number.\n'
        '• Technical reports submitted by conservators (site name, materials used, damage description).\n'
        '• Your interest-quiz result and app preferences (language, notifications), stored on your device.\n'
        '• We do not collect your location, contacts, or any health or financial data.'
  ),
  (
    'Camera & photos (Artifact Scanner)',
    'The scanner requests camera or photo-library access only when you tap capture or choose, to photograph an artifact or a conservation-material label. The image is processed on your device to show an illustrative result; it is not uploaded to our servers or shared with anyone. You can revoke the permission at any time in device settings without affecting the rest of the app.'
  ),
  (
    'Scanner & AI guide results',
    'Scanner results in this version are an educational simulation and are not a real laboratory or chemical analysis; they make no medical or safety claims. AI guide answers are machine-generated and may contain mistakes; only the text of your conversation with the guide is sent to the AI provider (OpenRouter) to generate answers, without your name, email or any account data.'
  ),
  (
    'How we use data',
    'To operate your account, tailor content to your interests, and let administrators review and approve restoration reports. We do not sell your data, use it for advertising, or track you across other apps.'
  ),
  (
    'Storage & security',
    'Account data and reports are stored with our cloud provider (Supabase) over encrypted HTTPS connections; preferences are stored locally on your device.'
  ),
  (
    'Account deletion & your rights',
    'You can edit your data on the Account screen and permanently delete your account and all of its data with the "Delete account & data" button on the same screen. Deletion removes your profile data from the device and requests deletion of the account on the server.'
  ),
  (
    'Children',
    'The app is suitable for all ages; its imagery is architectural and educational, free of nudity and violence. We do not knowingly collect personal data from children under 13.'
  ),
  (
    'Contact',
    'For privacy questions or data-deletion requests, contact the ERTH team at privacy@erth.ly'
  ),
];

const _termsAr = <(String, String)>[
  (
    'قبول الشروط',
    'باستخدامك تطبيق «إرث» فإنك توافق على هذه الشروط. إذا لم توافق عليها فيُرجى عدم استخدام التطبيق.'
  ),
  (
    'الحسابات',
    'أنت مسؤول عن صحة بياناتك وسرية كلمة المرور. حسابات «المرمم المعتمد» مخصصة للمختصين، ويحق للإدارة مراجعة التقارير أو أرشفتها أو تعليق الحسابات المخالفة.'
  ),
  (
    'المحتوى الذي ترفعه',
    'تتعهد بأن تكون التقارير والصور التي ترفعها دقيقة ومهنية وخالية من أي محتوى مسيء أو مخالف للآداب العامة أو منتهك لحقوق الغير. تخضع التقارير لمراجعة الإدارة قبل اعتمادها.'
  ),
  (
    'الطابع التعليمي والتجريبي',
    'المعلومات التاريخية للتثقيف العام. نتائج الماسح محاكاة توضيحية ولا تُغني عن الفحص المخبري المتخصص، ولا يجوز الاعتماد عليها في قرارات ترميم أو سلامة. إجابات المرشد الذكي قد تكون غير دقيقة.'
  ),
  (
    'حماية التراث',
    'يُمنع استخدام التطبيق للإضرار بالمواقع الأثرية أو الاتجار غير المشروع بالقطع الأثرية أو نشر مواقع حساسة بهدف العبث بها.'
  ),
  (
    'الصور وحقوق النشر',
    'الصور المعروضة مصدرها ويكيميديا كومنز وفق تراخيصها المفتوحة، وتبقى الحقوق لأصحابها.'
  ),
  ('حذف الحساب', 'يمكنك إنهاء استخدامك وحذف حسابك في أي وقت من شاشة «الحساب».'),
  (
    'التعديلات',
    'قد نُحدّث هذه الشروط، وسيُشار إلى تاريخ آخر تحديث أعلى الصفحة.'
  ),
];

const _termsEn = <(String, String)>[
  (
    'Acceptance',
    'By using ERTH you agree to these terms. If you do not agree, please do not use the app.'
  ),
  (
    'Accounts',
    'You are responsible for the accuracy of your data and the secrecy of your password. Certified-conservator accounts are intended for professionals; administrators may review or archive reports and suspend accounts that break these terms.'
  ),
  (
    'Content you submit',
    'Reports and images you submit must be accurate, professional, and free of offensive, indecent or infringing content. Reports are reviewed by administrators before approval.'
  ),
  (
    'Educational & demo nature',
    'Historical information is for general education. Scanner results are an illustrative simulation, do not replace specialised laboratory testing, and must not be relied on for conservation or safety decisions. AI guide answers may be inaccurate.'
  ),
  (
    'Heritage protection',
    'Using the app to damage heritage sites, traffic antiquities, or expose sensitive locations for looting is prohibited.'
  ),
  (
    'Images & copyright',
    'Images are sourced from Wikimedia Commons under their open licences; rights remain with their owners.'
  ),
  (
    'Account deletion',
    'You may stop using the app and delete your account at any time from the Account screen.'
  ),
  (
    'Changes',
    'We may update these terms; the last-updated date is shown at the top.'
  ),
];

Future<void> confirmDeleteAccount(BuildContext context, AppState s) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded,
          color: Color(0xFFE0675A), size: 36),
      title: Text(s.t('حذف الحساب نهائيًا؟', 'Delete account permanently?')),
      content: Text(s.t(
          'سيتم حذف حسابك وملفك الشخصي ونتيجة الاستبيان وتفضيلاتك من هذا الجهاز وطلب حذفها من الخادم. لا يمكن التراجع عن هذا الإجراء.',
          'Your account, profile, quiz result and preferences will be deleted from this device and deletion will be requested on the server. This cannot be undone.')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('إلغاء', 'Cancel'))),
        FilledButton.icon(
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB8463A),
              foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.delete_forever),
          label: Text(s.t('حذف نهائي', 'Delete permanently')),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  await s.deleteAccount();
  messenger.showSnackBar(SnackBar(
      content:
          Text(s.t('تم حذف الحساب وبياناته', 'Account and data deleted'))));
}
