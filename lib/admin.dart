part of 'main.dart';

// ─────────────────────────────── Admin dashboard ────────────────────────────
// لوحة تحكم الإدارة: analytics, site CRUD, report review, content & quiz.
// Every change goes through AppState, which persists it and notifies the
// tourist / conservator views immediately.

class AdminShell extends StatelessWidget {
  final AppState state;
  const AdminShell({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final pages = <Widget>[
      AdminOverviewTab(state: s),
      AdminSitesTab(state: s),
      AdminReportsTab(state: s),
      AdminContentTab(state: s),
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
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                  key: ValueKey('admin$tabIndex'), child: pages[tabIndex]),
            ),
          ),
        ),
      ),
      floatingActionButton: tabIndex == 1
          ? SizedBox(
              width: 200,
              child: GoldButton(
                height: 50,
                label: s.t('إضافة أثر جديد', 'Add site'),
                icon: Icons.add,
                onPressed: () => showSiteEditor(context, s),
              ),
            )
          : null,
      bottomNavigationBar: GlossyNavFrame(
        child: NavigationBar(
          selectedIndex: tabIndex,
          onDestinationSelected: s.setTab,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                label: s.t('الإحصائيات', 'Overview')),
            NavigationDestination(
                icon: const Icon(Icons.account_balance_outlined),
                label: s.t('المواقع والآثار', 'Sites')),
            NavigationDestination(
                icon: Badge(
                  isLabelVisible: s.pendingReports > 0,
                  label: Text('${s.pendingReports}'),
                  child: const Icon(Icons.fact_check_outlined),
                ),
                label: s.t('التقارير', 'Reports')),
            NavigationDestination(
                icon: const Icon(Icons.tune), label: s.t('المحتوى', 'Content')),
            NavigationDestination(
                icon: const Icon(Icons.person_outline),
                label: s.t('الحساب', 'Account')),
          ],
        ),
      ),
    );
  }
}

Widget _adminHeader(String title, String sub) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: titleStyle(24)),
        const SizedBox(height: 4),
        Text(sub, style: captionStyle(13)),
      ]),
    );

Widget _adminSection(String t) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(t, style: titleStyle(17).copyWith(color: inkGold)),
    );

// ── 1. Overview & analytics ──────────────────────────────────────────────────

class AdminOverviewTab extends StatelessWidget {
  final AppState state;
  const AdminOverviewTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final sites = s.sites;
    final kpis = [
      (
        s.t('إجمالي المواقع الأثرية', 'Heritage sites'),
        '${sites.length}',
        Icons.account_balance
      ),
      (
        s.t('مواقع اليونسكو', 'UNESCO sites'),
        '${sites.where((x) => x.unesco).length}',
        Icons.public
      ),
      (
        s.t('تقارير المرممين النشطة', 'Active conservator reports'),
        '${s.activeReports}',
        Icons.science_outlined
      ),
      (
        s.t('مواقع قيد المعالجة', 'Sites under treatment'),
        '${s.underTreatment}',
        Icons.construction
      ),
      (
        s.t('إكمال استبيان الزوار', 'Tourist quiz completions'),
        '${s.quizCompletions}',
        Icons.quiz_outlined
      ),
      (
        s.t('تقارير بانتظار المراجعة', 'Reports pending review'),
        '${s.pendingReports}',
        Icons.hourglass_top
      ),
    ];
    final total = sites.isEmpty ? 1 : sites.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        _adminHeader(
            s.t('لوحة تحكم الإدارة • الإحصائيات العامة',
                'Admin dashboard • Overview'),
            s.t('مؤشرات حية تتحدث فور أي تعديل في المواقع أو التقارير',
                'Live indicators that update as sites and reports change')),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 760 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cols == 3 ? 1.9 : 1.35,
            children: [
              for (final (i, k) in kpis.indexed)
                StaggerIn(
                  index: i,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDeco(radius: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(k.$3, color: kGold, size: 22),
                        const SizedBox(height: 6),
                        GoldNumber(k.$2),
                        const SizedBox(height: 4),
                        Text(k.$1,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: captionStyle(12.5)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        _adminSection(s.t('توزيع حالة الحفظ', 'Conservation status breakdown')),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDeco(radius: 20),
          child: Column(children: [
            for (final st in Preservation.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(
                      width: 120,
                      child: Text(st.label(s.ar), style: subStyle(13.5))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value:
                            sites.where((x) => x.status == st).length / total,
                        minHeight: 10,
                        color: st.color,
                        backgroundColor: (gLight ? kGold : Colors.white).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${sites.where((x) => x.status == st).length}',
                      style: monoStyle(13)),
                ]),
              ),
          ]),
        ),
        _adminSection(s.t('إجراءات سريعة', 'Quick actions')),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: kGold, foregroundColor: kWine),
            onPressed: () => showSiteEditor(context, s),
            icon: const Icon(Icons.add),
            label: Text(s.t('إضافة أثر جديد', 'Add site')),
          ),
          OutlinedButton.icon(
            onPressed: () => s.setTab(2),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(s.t('مراجعة التقارير (${s.pendingReports})',
                'Review reports (${s.pendingReports})')),
          ),
          OutlinedButton.icon(
            onPressed: () => s.setTab(3),
            icon: const Icon(Icons.tune),
            label: Text(s.t('إدارة المحتوى', 'Manage content')),
          ),
        ]),
        if (s.hiddenIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
              s.t('${s.hiddenIds.length} موقع مخفي عن الزوار حاليًا',
                  '${s.hiddenIds.length} site(s) currently hidden from visitors'),
              style: captionStyle(13)),
        ],
      ],
    );
  }
}

// ── 2. Manage sites (CRUD) ───────────────────────────────────────────────────

class AdminSitesTab extends StatefulWidget {
  final AppState state;
  const AdminSitesTab({super.key, required this.state});

  @override
  State<AdminSitesTab> createState() => _AdminSitesTabState();
}

class _AdminSitesTabState extends State<AdminSitesTab> {
  String q = '';

  AppState get s => widget.state;

  Future<void> _delete(HeritageSite x) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('حذف الموقع؟', 'Delete site?')),
        content: Text(s.t(
            'سيُحذف «${x.nameAr}» من الدليل لدى جميع المستخدمين. يمكنك بدلًا من ذلك إخفاؤه مؤقتًا.',
            '"${x.nameEn}" will be removed from the catalog for all users. You can hide it temporarily instead.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.t('إلغاء', 'Cancel'))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.t('حذف', 'Delete'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    s.deleteSite(x.id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.t('تم حذف الموقع', 'Site deleted'))));
  }

  @override
  Widget build(BuildContext context) {
    final needle = q.trim().toLowerCase();
    final all = s.allSites
        .where((x) =>
            needle.isEmpty ||
            x.nameAr.contains(needle) ||
            x.nameEn.toLowerCase().contains(needle))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        _adminHeader(
            s.t('إدارة المواقع والآثار', 'Manage sites & antiquities'),
            s.t('${s.allSites.length} موقع • إضافة وتعديل وحذف وإخفاء',
                '${s.allSites.length} sites • add, edit, delete, hide')),
        TextField(
          onChanged: (v) => setState(() => q = v),
          decoration: InputDecoration(
            hintText: s.t('ابحث في المواقع...', 'Search sites...'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 14),
        for (final x in all) _row(x),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: s.restoreBuiltInSites,
            icon: const Icon(Icons.settings_backup_restore),
            label: Text(s.t('استعادة المواقع الأصلية المحذوفة/المعدلة',
                'Restore deleted/edited built-in sites')),
          ),
        ),
      ],
    );
  }

  Widget _row(HeritageSite x) {
    final hidden = s.hiddenIds.contains(x.id);
    return Opacity(
      opacity: hidden ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: cardDeco(radius: 18),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                SizedBox(width: 78, height: 78, child: _NetPhoto(x.image, x)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.name(s.ar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(16)),
              Text(
                  '${x.region(s.ar)} • ${s.ar ? x.category : kCategoryEn[x.category] ?? x.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle(12)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _StatusBadge(x.status, s.ar),
                if (x.unesco) Pill.unesco(s.t('يونسكو', 'UNESCO')),
                if (hidden)
                  Pill(s.t('مخفي', 'Hidden'),
                      border: inkMuted,
                      textColor: inkMuted,
                      fill: Colors.transparent),
                if (x.custom)
                  Pill(s.t('جديد', 'New'),
                      border: kGold,
                      textColor: inkGold,
                      fill: Colors.transparent),
              ]),
            ]),
          ),
          PopupMenuButton<String>(
            tooltip: s.t('إجراءات', 'Actions'),
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  showSiteEditor(context, s, site: x);
                case 'hide':
                  s.setHidden(x.id, !hidden);
                case 'delete':
                  _delete(x);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(s.t('تعديل', 'Edit')))),
              PopupMenuItem(
                  value: 'hide',
                  child: ListTile(
                      leading: Icon(hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      title: Text(hidden
                          ? s.t('إظهار للزوار', 'Show to visitors')
                          : s.t('إخفاء', 'Hide')))),
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                      leading: const Icon(Icons.delete_outline,
                          color: Color(0xFFD64535)),
                      title: Text(s.t('حذف', 'Delete'),
                          style: const TextStyle(color: Color(0xFFE0675A))))),
            ],
          ),
        ]),
      ),
    );
  }
}

void showSiteEditor(BuildContext context, AppState state,
    {HeritageSite? site}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => SiteEditor(state: state, site: site),
  ));
}

class SiteEditor extends StatefulWidget {
  final AppState state;
  final HeritageSite? site;
  const SiteEditor({super.key, required this.state, this.site});

  @override
  State<SiteEditor> createState() => _SiteEditorState();
}

class _SiteEditorState extends State<SiteEditor> {
  final _form = GlobalKey<FormState>();
  late final HeritageSite? e = widget.site;
  late final _nameAr = TextEditingController(text: e?.nameAr);
  late final _nameEn = TextEditingController(text: e?.nameEn);
  late final _eraAr = TextEditingController(text: e?.eraAr);
  late final _eraEn = TextEditingController(text: e?.eraEn);
  late final _regionAr = TextEditingController(text: e?.regionAr);
  late final _regionEn = TextEditingController(text: e?.regionEn);
  late final _lat = TextEditingController(text: e == null ? '' : '${e!.lat}');
  late final _lon = TextEditingController(text: e == null ? '' : '${e!.lon}');
  late final _storyAr = TextEditingController(text: e?.storyAr);
  late final _storyEn = TextEditingController(text: e?.storyEn);
  late final _cover = TextEditingController(text: e?.image);
  final _newPhoto = TextEditingController();
  late String category = e?.category ?? 'آثار رومانية';
  late bool unesco = e?.unesco ?? false;
  late Preservation status = e?.status ?? Preservation.good;
  late final List<String> gallery = [...?e?.extraPhotos];

  AppState get s => widget.state;

  @override
  void dispose() {
    for (final c in [
      _nameAr,
      _nameEn,
      _eraAr,
      _eraEn,
      _regionAr,
      _regionEn,
      _lat,
      _lon,
      _storyAr,
      _storyEn,
      _cover,
      _newPhoto,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validUrl(String v) {
    final u = Uri.tryParse(v.trim());
    return u != null &&
        (u.scheme == 'https' || u.scheme == 'http') &&
        u.host.isNotEmpty;
  }

  void _addPhoto() {
    final v = _newPhoto.text.trim();
    if (!_validUrl(v)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.t('أدخل رابط صورة صالحًا (https://...)',
              'Enter a valid image URL (https://...)'))));
      return;
    }
    setState(() {
      if (!gallery.contains(v)) gallery.add(v);
      _newPhoto.clear();
    });
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final base = e ??
        HeritageSite(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          nameAr: '',
          nameEn: '',
          regionAr: '',
          regionEn: '',
          category: category,
          eraAr: '',
          eraEn: '',
          unesco: false,
          lat: 0,
          lon: 0,
          status: Preservation.good,
          image: '',
          icon: categoryIcon(category),
          storyAr: '',
          storyEn: '',
          history: const [],
          custom: true,
        );
    final site = base.copyWith(
      nameAr: _nameAr.text.trim(),
      nameEn: _nameEn.text.trim(),
      eraAr: _eraAr.text.trim(),
      eraEn:
          _eraEn.text.trim().isEmpty ? _eraAr.text.trim() : _eraEn.text.trim(),
      regionAr: _regionAr.text.trim(),
      regionEn: _regionEn.text.trim().isEmpty
          ? _regionAr.text.trim()
          : _regionEn.text.trim(),
      lat: double.tryParse(_lat.text.trim()) ?? 0,
      lon: double.tryParse(_lon.text.trim()) ?? 0,
      category: category,
      unesco: unesco,
      status: status,
      image: _cover.text.trim(),
      storyAr: _storyAr.text.trim(),
      storyEn: _storyEn.text.trim().isEmpty
          ? _storyAr.text.trim()
          : _storyEn.text.trim(),
      gallery: [...gallery],
    );
    s.saveSite(site);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e == null
            ? s.t('تمت إضافة الموقع وظهر فورًا للزوار والمرممين',
                'Site added — now live for visitors and conservators')
            : s.t('تم حفظ التعديلات', 'Changes saved'))));
  }

  @override
  Widget build(BuildContext context) {
    String? req(String? v) => (v == null || v.trim().isEmpty)
        ? s.t('هذا الحقل مطلوب', 'Required')
        : null;
    String? coord(String? v, double limit) {
      if (v == null || v.trim().isEmpty) return null;
      final d = double.tryParse(v.trim());
      return (d == null || d.abs() > limit)
          ? s.t('قيمة غير صالحة', 'Invalid value')
          : null;
    }

    Widget field(TextEditingController c, String label,
            {String? Function(String?)? validator,
            int lines = 1,
            TextInputType? kb,
            TextDirection? dir}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: c,
            validator: validator,
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 3,
            keyboardType: kb,
            textDirection: dir,
            decoration:
                InputDecoration(labelText: label, alignLabelWithHint: true),
          ),
        );
    Widget pair(Widget a, Widget b) => LayoutBuilder(
        builder: (context, c) => c.maxWidth > 560
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: a),
                const SizedBox(width: 12),
                Expanded(child: b),
              ])
            : Column(children: [a, b]));

    final cats = kCategories.where((c) => c != kAll).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(e == null
            ? s.t('إضافة أثر أو معلم جديد', 'Add new site / artifact')
            : s.t('تعديل: ${e!.nameAr}', 'Edit: ${e!.nameEn}')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: kGold, foregroundColor: kWine),
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(s.t('حفظ', 'Save')),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
              children: [
                _adminSection(s.t('البيانات الأساسية', 'Basic details')),
                pair(
                    field(_nameAr, s.t('الاسم بالعربية', 'Arabic name'),
                        validator: req),
                    field(_nameEn, s.t('الاسم بالإنجليزية', 'English name'),
                        validator: req, dir: TextDirection.ltr)),
                pair(
                    field(_eraAr,
                        s.t('الحقبة التاريخية (عربي)', 'Historical era (AR)'),
                        validator: req),
                    field(
                        _eraEn,
                        s.t('الحقبة التاريخية (إنجليزي)',
                            'Historical era (EN)'),
                        dir: TextDirection.ltr)),
                pair(
                    field(_regionAr,
                        s.t('المدينة / المنطقة (عربي)', 'City / region (AR)'),
                        validator: req),
                    field(
                        _regionEn,
                        s.t('المدينة / المنطقة (إنجليزي)',
                            'City / region (EN)'),
                        dir: TextDirection.ltr)),
                pair(
                    field(_lat, s.t('خط العرض', 'Latitude'),
                        validator: (v) => coord(v, 90),
                        kb: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        dir: TextDirection.ltr),
                    field(_lon, s.t('خط الطول', 'Longitude'),
                        validator: (v) => coord(v, 180),
                        kb: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        dir: TextDirection.ltr)),
                DropdownButtonFormField<String>(
                  initialValue: cats.contains(category) ? category : cats.first,
                  decoration:
                      InputDecoration(labelText: s.t('التصنيف', 'Category')),
                  items: [
                    for (final c in cats)
                      DropdownMenuItem(
                          value: c, child: Text(s.ar ? c : kCategoryEn[c]!)),
                  ],
                  onChanged: (v) => setState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Preservation>(
                  initialValue: status,
                  decoration: InputDecoration(
                      labelText: s.t('حالة الحفظ', 'Conservation status')),
                  items: [
                    for (final p in Preservation.values)
                      DropdownMenuItem(
                        value: p,
                        child: Row(children: [
                          Icon(Icons.circle, size: 12, color: p.color),
                          const SizedBox(width: 8),
                          Text(p.label(s.ar)),
                        ]),
                      ),
                  ],
                  onChanged: (v) => setState(() => status = v ?? status),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: unesco,
                  onChanged: (v) => setState(() => unesco = v),
                  secondary: const Icon(Icons.public, color: kGold),
                  title: Text(
                      s.t('مُدرج في قائمة اليونسكو', 'UNESCO World Heritage')),
                ),
                _adminSection(s.t('الصور', 'Images')),
                Text(
                    s.t('استخدم صورًا معمارية محتشمة ومناسبة لجميع الأعمار (بدون عُري أو مشاهد عنف أو فوضى شوارع حديثة).',
                        'Use modest, family-friendly architectural images (no nudity, violence or modern street clutter).'),
                    style: captionStyle(12.5)),
                const SizedBox(height: 10),
                field(_cover, s.t('رابط صورة الغلاف', 'Cover image URL'),
                    validator: (v) => (v == null || !_validUrl(v))
                        ? s.t('رابط غير صالح', 'Invalid URL')
                        : null,
                    dir: TextDirection.ltr),
                ValueListenableBuilder(
                  valueListenable: _cover,
                  builder: (_, v, __) => _validUrl(v.text)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 200,
                            child: Image.network(v.text.trim(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                                errorBuilder: (_, __, ___) => _previewError()),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _newPhoto,
                      textDirection: TextDirection.ltr,
                      onSubmitted: (_) => _addPhoto(),
                      decoration: InputDecoration(
                          labelText: s.t('إضافة صورة لمعرض الصور',
                              'Add gallery photo URL')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                        backgroundColor: kGold, foregroundColor: kWine),
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                ]),
                const SizedBox(height: 10),
                if (gallery.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      buildDefaultDragHandles: true,
                      onReorderItem: (a, b) => setState(
                          () => gallery.insert(b, gallery.removeAt(a))),
                      children: [
                        for (final url in gallery)
                          Padding(
                            key: ValueKey(url),
                            padding: const EdgeInsetsDirectional.only(end: 10),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 140,
                                  height: 110,
                                  child: Image.network(url,
                                      fit: BoxFit.cover,
                                      webHtmlElementStrategy:
                                          WebHtmlElementStrategy.prefer,
                                      errorBuilder: (_, __, ___) =>
                                          _previewError()),
                                ),
                              ),
                              PositionedDirectional(
                                top: 4,
                                end: 4,
                                child: IconButton.filled(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54),
                                  tooltip: s.t('إزالة', 'Remove'),
                                  onPressed: () =>
                                      setState(() => gallery.remove(url)),
                                  icon: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ]),
                          ),
                      ],
                    ),
                  ),
                _adminSection(s.t('الوصف', 'Description')),
                field(_storyAr, s.t('الوصف بالعربية', 'Arabic description'),
                    validator: req, lines: 3),
                field(_storyEn, s.t('الوصف بالإنجليزية', 'English description'),
                    lines: 3, dir: TextDirection.ltr),
                const SizedBox(height: 10),
                GoldButton(
                  label: s.t('حفظ ونشر', 'Save & publish'),
                  icon: Icons.publish,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewError() => Container(
        color: surfaceColor,
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.broken_image_outlined, color: inkMuted),
          Text(s.t('تعذر تحميل المعاينة', 'Preview unavailable'),
              style: captionStyle(12)),
        ]),
      );
}

// ── 3. Conservator & scanner reports approval ────────────────────────────────

class AdminReportsTab extends StatefulWidget {
  final AppState state;
  const AdminReportsTab({super.key, required this.state});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  ReviewStatus? filter = ReviewStatus.pending;

  AppState get s => widget.state;

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  Future<void> _editStatus(RestorationLog l) async {
    var review = l.review;
    var damage = l.damageLevel;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(s.t('تعديل حالة التقرير', 'Edit report status')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<ReviewStatus>(
              initialValue: review,
              decoration: InputDecoration(
                  labelText: s.t('حالة المراجعة', 'Review status')),
              items: [
                for (final r in ReviewStatus.values)
                  DropdownMenuItem(value: r, child: Text(r.label(s.ar))),
              ],
              onChanged: (v) => setD(() => review = v ?? review),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: damage.isEmpty ? null : damage,
              decoration: InputDecoration(
                  labelText: s.t('مستوى الضرر', 'Damage level')),
              items: [
                for (var i = 0; i < kDamageLevels.length; i++)
                  DropdownMenuItem(
                      value: kDamageLevels[i],
                      child:
                          Text(s.ar ? kDamageLevels[i] : kDamageLevelsEn[i])),
              ],
              onChanged: (v) => setD(() => damage = v ?? damage),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(s.t('إلغاء', 'Cancel'))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(s.t('حفظ', 'Save'))),
          ],
        ),
      ),
    );
    if (ok == true) s.setReview(l, review, damage: damage);
  }

  @override
  Widget build(BuildContext context) {
    final logs =
        s.logs.where((l) => filter == null || l.review == filter).toList();
    return RefreshIndicator(
      onRefresh: s.loadLogs,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          _adminHeader(
              s.t('مراجعة تقارير الترميم والماسح',
                  'Restoration & scanner reports'),
              s.t('اعتماد أو تعديل أو أرشفة التقارير الفنية المرفوعة من المرممين',
                  'Approve, edit or archive technical logs from conservators')),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final f in <ReviewStatus?>[null, ...ReviewStatus.values])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(
                        '${f == null ? s.t('الكل', 'All') : f.label(s.ar)} (${s.logs.where((l) => f == null || l.review == f).length})'),
                    selected: filter == f,
                    showCheckmark: false,
                    selectedColor: kRed,
                    onSelected: (_) => setState(() => filter = f),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          if (s.loadingLogs) const LinearProgressIndicator(color: kGold),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                  child: Text(
                      s.t('لا توجد تقارير في هذا التصنيف', 'No reports here'),
                      style: captionStyle(14))),
            ),
          for (final l in logs) _card(l),
        ],
      ),
    );
  }

  Widget _card(RestorationLog l) {
    final (action, damage) = l.split;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: cardDeco(radius: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.siteName, style: titleStyle(18))),
          ReviewChip(l.review, s.ar),
        ]),
        const SizedBox(height: 4),
        Text(
            '${_fmt(l.createdAt)} • ${l.synced ? s.t('متزامن مع الخادم', 'Synced') : s.t('محلي', 'Local')}',
            style: captionStyle(12)),
        const SizedBox(height: 10),
        Text(action, style: subStyle(14.5).copyWith(height: 1.7)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (l.materials.trim().isNotEmpty) Pill.formula(l.materials),
          if (damage != null) Pill.damage(damage),
        ]),
        const Divider(height: 24),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (l.review != ReviewStatus.approved)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4E9A5C),
                  foregroundColor: Colors.white),
              onPressed: () => s.setReview(l, ReviewStatus.approved),
              icon: const Icon(Icons.verified, size: 18),
              label: Text(s.t('اعتماد', 'Approve')),
            ),
          OutlinedButton.icon(
            onPressed: () => _editStatus(l),
            icon: const Icon(Icons.edit_note, size: 18),
            label: Text(s.t('تعديل الحالة', 'Edit status')),
          ),
          if (l.review != ReviewStatus.archived)
            OutlinedButton.icon(
              onPressed: () => s.setReview(l, ReviewStatus.archived),
              icon: const Icon(Icons.archive_outlined, size: 18),
              label: Text(s.t('أرشفة', 'Archive')),
            )
          else
            OutlinedButton.icon(
              onPressed: () => s.setReview(l, ReviewStatus.pending),
              icon: const Icon(Icons.unarchive_outlined, size: 18),
              label: Text(s.t('إلغاء الأرشفة', 'Unarchive')),
            ),
        ]),
      ]),
    );
  }
}

// ── 4. App content & quiz manager ────────────────────────────────────────────

class AdminContentTab extends StatefulWidget {
  final AppState state;
  const AdminContentTab({super.key, required this.state});

  @override
  State<AdminContentTab> createState() => _AdminContentTabState();
}

class _AdminContentTabState extends State<AdminContentTab> {
  AppState get s => widget.state;
  late final _bannerAr = TextEditingController(text: s.bannerAr);
  late final _bannerEn = TextEditingController(text: s.bannerEn);

  @override
  void dispose() {
    _bannerAr.dispose();
    _bannerEn.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _editQuestion(int i) async {
    final item = s.quiz[i];
    final q = TextEditingController(text: item.$1);
    final opts = [for (final o in item.$2) TextEditingController(text: o)];
    final key = GlobalKey<FormState>();
    const marks = ['أ', 'ب', 'ج', 'د'];
    String? req(String? v) => (v == null || v.trim().isEmpty)
        ? s.t('هذا الحقل مطلوب', 'Required')
        : null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('تعديل السؤال ${i + 1}', 'Edit question ${i + 1}')),
        content: SizedBox(
          width: 520,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: q,
                  validator: req,
                  maxLines: 3,
                  minLines: 1,
                  decoration:
                      InputDecoration(labelText: s.t('نص السؤال', 'Question')),
                ),
                for (var k = 0; k < opts.length; k++) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: opts[k],
                    validator: req,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                        labelText:
                            '${s.t('الخيار', 'Option')} ${marks[k]} → ${kPersonas[[
                      'A',
                      'B',
                      'C',
                      'D'
                    ][k]]!.nameAr}'),
                  ),
                ],
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.t('إلغاء', 'Cancel'))),
          FilledButton(
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: Text(s.t('حفظ', 'Save'))),
        ],
      ),
    );
    if (ok == true) {
      s.setQuizItem(i, q.text.trim(), [for (final o in opts) o.text.trim()]);
      _snack(s.t('تم تحديث السؤال', 'Question updated'));
    }
    q.dispose();
    for (final o in opts) {
      o.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        _adminHeader(
            s.t('إدارة محتوى التطبيق والاستبيان', 'App content & quiz'),
            s.t('تظهر التعديلات فورًا في واجهة الزائر',
                'Changes appear instantly for visitors')),
        _adminSection(s.t('نص البانر الرئيسي', 'Home banner text')),
        TextField(
          controller: _bannerAr,
          decoration:
              InputDecoration(labelText: s.t('النص بالعربية', 'Arabic text')),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _bannerEn,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
              labelText: s.t('النص بالإنجليزية', 'English text')),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: kGold, foregroundColor: kWine),
            onPressed: () {
              if (_bannerAr.text.trim().isEmpty) return;
              s.setContent(
                  newBannerAr: _bannerAr.text.trim(),
                  newBannerEn: _bannerEn.text.trim().isEmpty
                      ? _bannerAr.text.trim()
                      : _bannerEn.text.trim());
              _snack(s.t('تم تحديث البانر', 'Banner updated'));
            },
            icon: const Icon(Icons.check),
            label: Text(s.t('حفظ البانر', 'Save banner')),
          ),
        ),
        _adminSection(s.t('التنبيهات العامة', 'Global notices')),
        Container(
          decoration: cardDeco(radius: 18),
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: [
              SwitchListTile(
                value: s.maintenanceNotice,
                onChanged: (v) => s.setContent(maintenance: v),
                secondary: const Icon(Icons.construction),
                title: Text(s.t('إشعار وضع الصيانة', 'Maintenance notice')),
                subtitle: Text(s.t('يظهر شريط تنبيه للزوار والمرممين',
                    'Shows a banner to visitors and conservators')),
              ),
              SwitchListTile(
                value: s.demoNotice,
                onChanged: (v) => s.setContent(demo: v),
                secondary: const Icon(Icons.info_outline),
                title: Text(
                    s.t('إشعار النسخة التجريبية', 'Demo / evaluation notice')),
                subtitle: Text(s.t('يوضح أن بعض البيانات للعرض فقط',
                    'Clarifies some data is for demonstration only')),
              ),
            ]),
          ),
        ),
        _adminSection(s.t('أسئلة استبيان الزوار', 'Tourist quiz questions')),
        for (var i = 0; i < s.quiz.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: cardDeco(radius: 18),
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: kGold.withValues(alpha: 0.15),
                    child: Text('${i + 1}',
                        style: TextStyle(color: inkGold))),
                title: Text(s.quiz[i].$1,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(s.quiz[i].$2.join(' • '),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  tooltip: s.t('تعديل', 'Edit'),
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editQuestion(i),
                ),
              ),
            ),
          ),
        _adminSection(s.t('توصيات كل شخصية', 'Recommendations per persona')),
        for (final e in kPersonas.entries)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: cardDeco(radius: 18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(e.value.icon, color: p.accent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e.value.nameAr,
                        style: const TextStyle(fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final x in s.sites)
                  FilterChip(
                    label: Text(x.name(s.ar)),
                    selected: s.personaSites[e.key]?.contains(x.id) ?? false,
                    selectedColor: kRed,
                    onSelected: (on) {
                      final ids = [...?s.personaSites[e.key]];
                      on ? ids.add(x.id) : ids.remove(x.id);
                      s.setPersonaSites(e.key, ids);
                    },
                  ),
              ]),
            ]),
          ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () {
              s.resetContent();
              _bannerAr.text = s.bannerAr;
              _bannerEn.text = s.bannerEn;
              _snack(s.t(
                  'تمت استعادة المحتوى الافتراضي', 'Default content restored'));
            },
            icon: const Icon(Icons.settings_backup_restore),
            label: Text(
                s.t('استعادة المحتوى الافتراضي', 'Restore default content')),
          ),
        ),
      ],
    );
  }
}
