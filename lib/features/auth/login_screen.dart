import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/app_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text('Welcome to ERTH',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('مرحباً بكم في إرث',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                        fontSize: 24, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 40),
                _RoleCard(
                  icon: Icons.science_outlined,
                  titleEn: 'Expert / Conservator',
                  titleAr: 'خبير / مرمم',
                  onTap: () => context.go(AppRoutes.expert),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  icon: Icons.museum_outlined,
                  titleEn: 'Tourist / Visitor',
                  titleAr: 'سائح / زائر',
                  onTap: () => context.go(AppRoutes.tourist),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.titleEn,
    required this.titleAr,
    required this.onTap,
  });

  final IconData icon;
  final String titleEn;
  final String titleAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titleEn, style: theme.textTheme.titleLarge),
                    Text(titleAr,
                        style: GoogleFonts.amiri(
                            fontSize: 20, color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
