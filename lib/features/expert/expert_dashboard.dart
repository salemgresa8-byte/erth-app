import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/routes/app_router.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  late Future<List<Map<String, dynamic>>> _logs;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _logs = _fetchLogs();
  }

  Future<List<Map<String, dynamic>>> _fetchLogs() async {
    final rows = await SupabaseService.client
        .from('restoration_logs')
        .select(
            'id, chemical_materials, technical_report, created_at, artifacts(name_en, name_ar)')
        .order('created_at', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(rows);
  }

  void _refresh() => setState(() => _logs = _fetchLogs());

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _scan() async {
    final code = await context.push<String>(AppRoutes.scanner);
    if (code == null || !mounted) return;

    setState(() => _scanning = true);
    try {
      final artifact = await SupabaseService.client
          .from('artifacts')
          .select('id, name_ar, name_en, qr_code_ref')
          .eq('qr_code_ref', code)
          .maybeSingle();
      if (!mounted) return;
      if (artifact == null) {
        _snack('No artifact found for this QR code.');
        return;
      }
      final saved =
          await context.push<bool>(AppRoutes.restorationForm, extra: artifact);
      if (saved == true && mounted) _refresh();
    } on PostgrestException catch (e) {
      if (mounted) _snack('Could not load artifact: ${e.message}');
    } catch (_) {
      if (mounted) _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.burgundy,
      appBar: AppBar(
        title: const Text('Restoration Logs'),
        actions: [
          IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _scan,
        backgroundColor: AppColors.marble,
        foregroundColor: AppColors.burgundy,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _logs,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.marble));
          }
          if (snap.hasError) {
            final err = snap.error;
            final msg = err is PostgrestException ? err.message : '$err';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load logs:\n$msg',
                    textAlign: TextAlign.center,
                    style: text.titleMedium
                        ?.copyWith(color: AppColors.marble)),
              ),
            );
          }
          final logs = snap.data!;
          if (logs.isEmpty) {
            return Center(
              child: Text('No restoration logs yet.\nScan an artifact to add one.',
                  textAlign: TextAlign.center,
                  style:
                      text.titleMedium?.copyWith(color: AppColors.marble)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _LogCard(log: logs[i]),
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});
  final Map<String, dynamic> log;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final artifact = log['artifacts'] as Map<String, dynamic>?;
    final nameEn = artifact?['name_en'] as String? ?? 'Unknown artifact';
    final nameAr = artifact?['name_ar'] as String? ?? '';
    final created = (log['created_at'] as String? ?? '');
    final date = created.length >= 10 ? created.substring(0, 10) : created;
    final materials = log['chemical_materials'] as String? ?? '—';
    final report = log['technical_report'] as String? ?? '—';

    return Card(
      color: AppColors.marble,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(nameEn,
                      style: text.titleLarge
                          ?.copyWith(color: AppColors.burgundy)),
                ),
                Text(date,
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.burgundy)),
              ],
            ),
            if (nameAr.isNotEmpty)
              Text(nameAr,
                  style: GoogleFonts.amiri(
                      fontSize: 18, color: AppColors.burgundy)),
            const Divider(color: AppColors.burgundy, height: 20, thickness: 0.3),
            Text('Materials: $materials',
                style: text.bodyLarge?.copyWith(color: AppColors.burgundy)),
            const SizedBox(height: 4),
            Text(report,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(color: AppColors.burgundy)),
          ],
        ),
      ),
    );
  }
}
