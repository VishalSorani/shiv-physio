import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import 'appointment_confirmation_controller.dart';

class AppointmentConfirmationScreen
    extends BaseScreenView<AppointmentConfirmationController> {
  const AppointmentConfirmationScreen({super.key});

  static const String appointmentConfirmationScreen =
      '/appointment-confirmation';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final cardColor = isDark ? const Color(0xFF1c2932) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111518);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF60778a);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildAppBar(context, isDark, controller),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Success Hero Section
                    _buildSuccessHero(controller, isDark, textColor, secondaryTextColor),
                    // Appointment Details Card
                    _buildAppointmentDetailsCard(
                      controller,
                      isDark,
                      cardColor,
                      textColor,
                      secondaryTextColor,
                    ),
                    // Location & Payment Card
                    _buildLocationPaymentCard(
                      controller,
                      isDark,
                      cardColor,
                      textColor,
                      secondaryTextColor,
                    ),
                    // Bottom spacing
                    const SizedBox(height: AppConstants.spacing6),
                  ],
                ),
              ),
            ),
            // Action Buttons
            _buildActionButtons(controller, isDark, surfaceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    AppointmentConfirmationController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing3,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.onBack,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Confirmation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSuccessHero(
    AppointmentConfirmationController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing4,
                vertical: AppConstants.spacing6,
              ),
              child: Column(
                children: [
                  // Success Indicator
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),
                  // Text Content
                  Text(
                    'Booking Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing2),
                  Text(
                    'Your appointment with ${controller.doctorName} is successfully scheduled.',
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentDetailsCard(
    AppointmentConfirmationController controller,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
                    // Doctor Header
                    GetBuilder<AppointmentConfirmationController>(
                      id: AppointmentConfirmationController.doctorInfoId,
                      builder: (controller) => Container(
                        padding: const EdgeInsets.all(AppConstants.spacing4),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: controller.doctorAvatarUrl != null &&
                                        controller.doctorAvatarUrl!.isNotEmpty
                                    ? Image.network(
                                        controller.doctorAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildDefaultAvatar(isDark),
                                      )
                                    : _buildDefaultAvatar(isDark),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing4),
                            // Doctor Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.doctorSpecialization.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primary
                                          : secondaryTextColor,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    controller.doctorName,
                                    style: TextStyle(
                                      fontSize: AppConstants.h4Size,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            // Details
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              child: Column(
                children: [
                  // Date & Time
                  _buildDetailRow(
                    Icons.calendar_month,
                    controller.appointmentDate,
                    controller.appointmentTime,
                    isDark,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  // Reason
                  _buildDetailRow(
                    Icons.medical_services,
                    controller.mainReason,
                    controller.reasonDetail.isNotEmpty
                        ? controller.reasonDetail
                        : null,
                    isDark,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
      child: Icon(
        Icons.person,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        size: 28,
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String? subtitle,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.body1Size,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppConstants.body2Size,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPaymentCard(
    AppointmentConfirmationController controller,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GetBuilder<AppointmentConfirmationController>(
          id: AppointmentConfirmationController.doctorInfoId,
          builder: (controller) => Column(
            children: [
              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CLINIC LOCATION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing1),
                        Text(
                          controller.clinicAddress,
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing1),
                        Text(
                          'Get Directions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing6),
              // Payment
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAYMENT STATUS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.amber.shade900.withOpacity(0.3)
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pending at Clinic',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    AppointmentConfirmationController controller,
    bool isDark,
    Color surfaceColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Add to Calendar Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.onAddToCalendar,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AppConstants.spacing2),
                    Text(
                      'Add to Calendar',
                      style: TextStyle(
                        fontSize: AppConstants.body1Size,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          // View Appointments Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.onViewAppointments,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'View My Appointments',
                    style: TextStyle(
                      fontSize: AppConstants.body1Size,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111518),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // iOS Home Indicator Spacer
          const SizedBox(height: AppConstants.spacing2),
        ],
      ),
    );
  }
}

