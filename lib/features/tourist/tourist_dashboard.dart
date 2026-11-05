import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/routes/app_router.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class _Site {
  const _Site(this.nameEn, this.nameAr, this.blurb, this.icon);
  final String nameEn;
  final String nameAr;
  final String blurb;
  final IconData icon;
}

const _sites = [
  _Site('Leptis Magna', 'لبدة الكبرى',
      'A grand Roman port city and birthplace of Emperor Septimius Severus.',
      Icons.account_balance),
  _Site('Cyrene', 'قوريني',
      'An ancient Greek colony, once a renowned centre of learning.',
      Icons.temple_hindu_outlined),
  _Site('Sabratha', 'صبراتة',
      'A Phoenician trading post with a magnificent Roman theatre.',
      Icons.theater_comedy_outlined),
  _Site('Tadrart Acacus', 'تادرارت أكاكوس',
      'Saharan mountains sheltering thousands of prehistoric rock paintings.',
      Icons.landscape_outlined),
];

class TouristDashboard extends StatefulWidget {
  const TouristDashboard({super.key});

  @override
  State<TouristDashboard> createState() => _TouristDashboardState();
}

class _TouristDashboardState extends State<TouristDashboard> {
  bool _loading = false;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _scan() async {
    final code = await context.push<String>(AppRoutes.scanner);
    if (code == null || !mounted) return;

    setState(() => _loading = true);
    try {
      final artifact = await SupabaseService.client
          .from('artifacts')
          .select('name_ar, name_en, story_ar, video_url')
          .eq('qr_code_ref', code)
          .maybeSingle();
      if (!mounted) return;
      if (artifact == null) {
        _snack('No artifact found for this QR code.');
      } else {
        context.push(AppRoutes.story, extra: artifact);
      }
    } on PostgrestException catch (e) {
      if (mounted) _snack('Could not load artifact: ${e.message}');
    } catch (_) {
      if (mounted) _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.burgundy,
      appBar: AppBar(title: const Text('ERTH')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _scan,
        backgroundColor: AppColors.marble,
        foregroundColor: AppColors.burgundy,
        icon: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5))
            : const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          children: [
            Text('Discover Libya’s Heritage',
                style:
                    text.headlineMedium?.copyWith(color: AppColors.marble)),
            const SizedBox(height: 4),
            Text('اكتشف تراث ليبيا',
                style: GoogleFonts.amiri(
                    fontSize: 22,
                    color: AppColors.marble.withValues(alpha: 0.85))),
            const SizedBox(height: 20),
            for (final site in _sites) ...[
              _SiteCard(site: site),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site});
  final _Site site;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: AppColors.marble,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(site.icon, size: 40, color: AppColors.burgundy),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site.nameEn,
                      style: text.titleLarge
                          ?.copyWith(color: AppColors.burgundy)),
                  Text(site.nameAr,
                      style: GoogleFonts.amiri(
                          fontSize: 20, color: AppColors.burgundy)),
                  const SizedBox(height: 6),
                  Text(site.blurb,
                      style: text.bodyMedium?.copyWith(
                          color: AppColors.burgundy, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
