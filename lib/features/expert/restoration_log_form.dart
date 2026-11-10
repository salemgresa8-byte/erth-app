import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

/// Form for an expert to log a restoration on a scanned artifact.
/// Pops with `true` when the log was saved.
class RestorationLogForm extends StatefulWidget {
  const RestorationLogForm({super.key, required this.artifact});

  final Map<String, dynamic> artifact;

  @override
  State<RestorationLogForm> createState() => _RestorationLogFormState();
}

class _RestorationLogFormState extends State<RestorationLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _materials = TextEditingController();
  final _report = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _materials.dispose();
    _report.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = SupabaseService.client.auth.currentUser;
    // TEMPORARY (no-auth testing): expert_id is null when nobody is signed in.

    setState(() => _saving = true);
    try {
      await SupabaseService.client.from('restoration_logs').insert({
        'artifact_id': widget.artifact['id'],
        'expert_id': user?.id,
        'chemical_materials': _materials.text.trim(),
        'technical_report': _report.text.trim(),
      });
      if (!mounted) return;
      _snack('Restoration log saved.');
      context.pop(true);
    } on PostgrestException catch (e) {
      if (mounted) _snack('Could not save log: ${e.message}');
    } catch (_) {
      if (mounted) _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColors.marble,
        labelStyle: const TextStyle(color: AppColors.burgundy),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.burgundyLight, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nameEn = widget.artifact['name_en'] as String? ?? '';
    final nameAr = widget.artifact['name_ar'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.burgundy,
      appBar: AppBar(title: const Text('New Restoration Log')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(nameEn,
                  style: text.headlineSmall
                      ?.copyWith(color: AppColors.marble)),
              if (nameAr.isNotEmpty)
                Text(nameAr,
                    style: text.titleLarge
                        ?.copyWith(color: AppColors.marble)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _materials,
                style: const TextStyle(color: AppColors.burgundy, fontSize: 18),
                decoration: _decoration('Chemical materials'),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the materials used'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _report,
                style: const TextStyle(color: AppColors.burgundy, fontSize: 18),
                decoration: _decoration('Technical report'),
                maxLines: 8,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the technical report'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.marble,
                    foregroundColor: AppColors.burgundy,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text('Save Log',
                          style: text.titleLarge
                              ?.copyWith(color: AppColors.burgundy)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
