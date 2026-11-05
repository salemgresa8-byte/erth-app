import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Shows an artifact's historical tale (story_ar) and a video placeholder.
class ArtifactStoryScreen extends StatelessWidget {
  const ArtifactStoryScreen({super.key, required this.artifact});

  final Map<String, dynamic> artifact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nameEn = artifact['name_en'] as String? ?? '';
    final nameAr = artifact['name_ar'] as String? ?? '';
    final story = artifact['story_ar'] as String?;
    final videoUrl = artifact['video_url'] as String?;

    return Scaffold(
      backgroundColor: AppColors.burgundy,
      appBar: AppBar(title: Text(nameEn)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(nameAr,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.marble)),
            const SizedBox(height: 4),
            Text(nameEn,
                style:
                    text.titleLarge?.copyWith(color: AppColors.marble)),
            const SizedBox(height: 20),
            Card(
              color: AppColors.marble,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  (story == null || story.trim().isEmpty)
                      ? 'لا توجد قصة لهذه القطعة بعد.'
                      : story,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                      fontSize: 22, height: 1.9, color: AppColors.burgundy),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _VideoPlaceholder(videoUrl: videoUrl),
          ],
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({this.videoUrl});
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.marble.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline,
                size: 64, color: AppColors.marble),
            const SizedBox(height: 8),
            Text(hasVideo ? 'Video player coming soon' : 'No video available',
                style: text.titleMedium?.copyWith(color: AppColors.marble)),
            if (hasVideo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(videoUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.marble.withValues(alpha: 0.7))),
              ),
          ],
        ),
      ),
    );
  }
}
