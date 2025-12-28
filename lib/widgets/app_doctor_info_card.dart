import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Reusable doctor info card with primary blue styling
class AppDoctorInfoCard extends StatelessWidget {
  final String doctorName;
  final String? doctorSpecialization;
  final String? doctorTitle;
  final String? doctorAvatarUrl;
  final String? clinicName;
  final String? clinicAddress;
  final VoidCallback? onTap;

  const AppDoctorInfoCard({
    super.key,
    required this.doctorName,
    this.doctorSpecialization,
    this.doctorTitle,
    this.doctorAvatarUrl,
    this.clinicName,
    this.clinicAddress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(AppConstants.spacing5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background elements
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -32,
                    left: -32,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Doctor',
                                  style: TextStyle(
                                    fontSize: AppConstants.body2Size,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing1),
                                Text(
                                  doctorName,
                                  style: const TextStyle(
                                    fontSize: AppConstants.h3Size,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                if (doctorTitle != null || doctorSpecialization != null) ...[
                                  const SizedBox(height: AppConstants.spacing1),
                                  Text(
                                    doctorTitle ?? doctorSpecialization ?? '',
                                    style: TextStyle(
                                      fontSize: AppConstants.body2Size,
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacing2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall,
                              ),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      // Doctor info
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacing3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSmall,
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: doctorAvatarUrl != null &&
                                        doctorAvatarUrl!.isNotEmpty
                                    ? Image.network(
                                        doctorAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildDefaultAvatar(),
                                      )
                                    : _buildDefaultAvatar(),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctorSpecialization ?? 'Physiotherapist',
                                    style: const TextStyle(
                                      fontSize: AppConstants.body2Size,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (clinicName != null) ...[
                                    const SizedBox(height: AppConstants.spacing1),
                                    Text(
                                      clinicName!,
                                      style: TextStyle(
                                        fontSize: AppConstants.captionSize,
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (clinicAddress != null) ...[
                        const SizedBox(height: AppConstants.spacing3),
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacing3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSmall,
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.blue.shade100,
                              ),
                              const SizedBox(width: AppConstants.spacing2),
                              Expanded(
                                child: Text(
                                  clinicAddress!,
                                  style: TextStyle(
                                    fontSize: AppConstants.captionSize,
                                    color: Colors.blue.shade100,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}

