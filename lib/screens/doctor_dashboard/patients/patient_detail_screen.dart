import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/user.dart' as app_models;
import 'patient_detail_controller.dart';

class PatientDetailScreen
    extends BaseScreenView<PatientDetailController> {
  const PatientDetailScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<PatientDetailController>(
          id: PatientDetailController.contentId,
          builder: (controller) {
            if (controller.isLoading && controller.patient == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'Loading patient details...',
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header
                _buildHeader(context, controller, isDark),
                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.refreshPatientData(),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        // Profile Section
                        SliverToBoxAdapter(
                          child: GetBuilder<PatientDetailController>(
                            id: PatientDetailController.profileId,
                            builder: (controller) =>
                                _buildProfileSection(context, controller, isDark),
                          ),
                        ),
                        // Tabs
                        SliverToBoxAdapter(
                          child: GetBuilder<PatientDetailController>(
                            id: PatientDetailController.tabsId,
                            builder: (controller) =>
                                _buildTabs(context, controller, isDark),
                          ),
                        ),
                        // Appointments List
                        SliverToBoxAdapter(
                          child: GetBuilder<PatientDetailController>(
                            id: PatientDetailController.appointmentsId,
                            builder: (controller) =>
                                _buildAppointmentsList(context, controller, isDark),
                          ),
                        ),
                        // Bottom spacing for fixed button
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Fixed bottom button
      bottomNavigationBar: GetBuilder<PatientDetailController>(
        id: PatientDetailController.profileId,
        builder: (controller) => _buildBottomButton(context, controller, isDark),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    final headerBgColor = isDark ? const Color(0xFF1E2A34) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: headerBgColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing2),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              ),
            ),
            // Title
            Text(
              'Patient Details',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            // Edit button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to edit patient screen
                },
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing2),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    final patient = controller.patient;
    if (patient == null) {
      return const SizedBox.shrink();
    }

    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing8,
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 4,
                  ),
                ),
                child: patient.avatarUrl != null &&
                        patient.avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          patient.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialsAvatar(patient, isDark);
                          },
                        ),
                      )
                    : _buildInitialsAvatar(patient, isDark),
              ),
              // Status indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: surfaceColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Name
          Text(
            controller.patientName,
            style: TextStyle(
              fontSize: AppConstants.h2Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing1),
          // Info
          Text(
            controller.patientInfo,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF60778A),
            ),
          ),
          const SizedBox(height: AppConstants.spacing6),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context,
                Icons.call,
                'Call',
                isDark,
                () {
                  HapticFeedback.lightImpact();
                  // TODO: Handle call
                },
              ),
              const SizedBox(width: AppConstants.spacing8),
              _buildActionButton(
                context,
                Icons.mail,
                'Email',
                isDark,
                () {
                  HapticFeedback.lightImpact();
                  // TODO: Handle email
                },
              ),
              const SizedBox(width: AppConstants.spacing8),
              _buildActionButton(
                context,
                Icons.history,
                'History',
                isDark,
                () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to history
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(app_models.User patient, bool isDark) {
    final name = patient.fullName ?? '';
    final initials = name.isEmpty
        ? '?'
        : name.trim().split(' ').length >= 2
            ? '${name.trim().split(' ')[0][0]}${name.trim().split(' ')[1][0]}'
                .toUpperCase()
            : name[0].toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: AppConstants.h2Size,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    final tabs = ['All', 'Upcoming', 'Past'];
    final bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing4),
      padding: const EdgeInsets.all(AppConstants.spacing1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = controller.selectedTabIndex == index;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.onTabChanged(index);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing2,
                    horizontal: AppConstants.spacing3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? surfaceColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    final appointments = controller.appointments;

    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: isDark ? Colors.grey.shade600 : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'No Appointments',
                style: TextStyle(
                  fontSize: AppConstants.h3Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              const SizedBox(height: AppConstants.spacing2),
              Text(
                'No appointments found for this filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark
                      ? Colors.grey.shade400
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Column(
        children: appointments.map((appointment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing4),
            child: _buildAppointmentCard(context, appointment, isDark),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment appointment,
    bool isDark,
  ) {
    final now = DateTime.now();
    final isUpcoming = appointment.startAt.isAfter(now) &&
        (appointment.status == AppointmentStatus.pending ||
            appointment.status == AppointmentStatus.confirmed);
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    if (isUpcoming) {
      return _buildUpcomingAppointmentCard(context, appointment, isDark, surfaceColor);
    } else {
      return _buildPastAppointmentCard(
        context,
        appointment,
        isDark,
        surfaceColor,
        isCompleted,
        isCancelled,
      );
    }
  }

  Widget _buildUpcomingAppointmentCard(
    BuildContext context,
    Appointment appointment,
    bool isDark,
    Color surfaceColor,
  ) {
    final date = appointment.startAt;
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final isTomorrow = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day + 1;

    String dateLabel;
    if (isToday) {
      dateLabel = 'TODAY';
    } else if (isTomorrow) {
      dateLabel = 'TMRW';
    } else {
      final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      dateLabel = '${months[date.month - 1]} ${date.day}';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing5),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing3,
                        vertical: AppConstants.spacing1 / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                      ),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing3),
                    Text(
                      appointment.patientNote ?? 'Physiotherapy Session',
                      style: TextStyle(
                        fontSize: AppConstants.h4Size,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing1),
                    Text(
                      'Dr. Pradip Chauhan', // TODO: Get doctor name from controller
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF60778A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing1),
                    Text(
                      '$displayHour:$displayMinute',
                      style: TextStyle(
                        fontSize: AppConstants.h3Size,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF60778A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          Divider(
            height: 1,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                'Clinic Room 3', // TODO: Get from appointment or doctor profile
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppConstants.spacing6),
              Icon(
                Icons.timer,
                size: 18,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                '45 mins', // TODO: Calculate from start_at and end_at
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointmentCard(
    BuildContext context,
    Appointment appointment,
    bool isDark,
    Color surfaceColor,
    bool isCompleted,
    bool isCancelled,
  ) {
    final date = appointment.startAt;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateString = '${months[date.month - 1]} ${date.day}';

    final iconColor = isCancelled
        ? Colors.red.shade500
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);
    final iconBgColor = isCancelled
        ? (isDark ? Colors.red.shade500.withOpacity(0.1) : Colors.red.shade50)
        : (isDark ? Colors.grey.shade700 : Colors.grey.shade100);
    final statusText = isCancelled
        ? 'Cancelled by patient'
        : 'Completed • No issues';
    final statusColor = isCancelled
        ? Colors.red.shade500
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to appointment details
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCancelled ? Icons.close : Icons.check,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          appointment.patientNote ?? 'Consultation',
                          style: TextStyle(
                            fontSize: AppConstants.body1Size,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111518),
                          ),
                        ),
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing1 / 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacing2),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to chat screen
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing2),
                Text(
                  'Chat with ${controller.patientName}',
                  style: const TextStyle(
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
    );
  }
}

