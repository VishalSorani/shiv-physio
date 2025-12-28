import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Reusable carousel card for clinic highlights
class AppCarouselCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? badge;
  final Color? badgeColor;
  final bool hasPlayButton;
  final VoidCallback? onTap;
  final double width;

  const AppCarouselCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.badge,
    this.badgeColor,
    this.hasPlayButton = false,
    this.onTap,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Calculate height based on 16:9 aspect ratio
    final cardHeight = width * 9 / 16;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: width,
        height: cardHeight,
        margin: const EdgeInsets.only(right: AppConstants.spacing4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with gradient overlay
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) => Container(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      child: Icon(
                        Icons.broken_image,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Play button overlay for videos
              if (hasPlayButton)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacing3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              // Content overlay with proper padding to prevent cutoff
              Positioned(
                left: AppConstants.spacing4,
                right: AppConstants.spacing4,
                bottom: AppConstants.spacing4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing2,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing2),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppConstants.h4Size,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

