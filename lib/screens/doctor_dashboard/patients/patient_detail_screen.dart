import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/treatment_plan.dart';
import '../../../data/models/user.dart' as app_models;
import '../../../widgets/app_custom_app_bar.dart';
import 'add_edit_patient_screen.dart';
import 'add_edit_patient_binding.dart';
import 'patient_detail_controller.dart';

class PatientDetailScreen extends BaseScreenView<PatientDetailController> {
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
      appBar: AppCustomAppBar(
        title: 'Patient Details',
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
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
        action: GetBuilder<PatientDetailController>(
          id: PatientDetailController.profileId,
          builder: (controller) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.patient == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      Get.to(
                        () => const AddEditPatientScreen(),
                        binding: AddEditPatientBinding(
                          patient: controller.patient,
                        ),
                      )?.then((result) {
                        // Refresh patient data if patient was updated
                        if (result == true) {
                          controller.refreshPatientData();
                        }
                      });
                    },
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing2),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: controller.patient == null
                      ? Colors.grey
                      : (isDark ? Colors.white : const Color(0xFF111518)),
                ),
              ),
            ),
          ),
        ),
      ),
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
                            builder: (controller) => _buildProfileSection(
                              context,
                              controller,
                              isDark,
                            ),
                          ),
                        ),
                        // Treatment Plan Section
                        SliverToBoxAdapter(
                          child: GetBuilder<PatientDetailController>(
                            id: PatientDetailController.treatmentPlansId,
                            builder: (controller) => _buildTreatmentPlanSection(
                              context,
                              controller,
                              isDark,
                            ),
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
                            builder: (controller) => _buildAppointmentsList(
                              context,
                              controller,
                              isDark,
                            ),
                          ),
                        ),
                        // Bottom spacing for fixed button
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
        builder: (controller) =>
            _buildBottomButton(context, controller, isDark),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
                child:
                    patient.avatarUrl != null && patient.avatarUrl!.isNotEmpty
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
                    border: Border.all(color: surfaceColor, width: 2),
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
              _buildActionButton(context, Icons.call, 'Call', isDark, () {
                HapticFeedback.lightImpact();
                // TODO: Handle call
              }),
              const SizedBox(width: AppConstants.spacing8),
              _buildActionButton(context, Icons.mail, 'Email', isDark, () {
                HapticFeedback.lightImpact();
                // TODO: Handle email
              }),
              const SizedBox(width: AppConstants.spacing8),
              _buildActionButton(context, Icons.history, 'History', isDark, () {
                HapticFeedback.lightImpact();
                // TODO: Navigate to history
              }),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
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
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500),
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
                color: isDark
                    ? Colors.grey.shade600
                    : AppColors.onSurfaceVariant,
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
    final isUpcoming =
        appointment.startAt.isAfter(now) &&
        (appointment.status == AppointmentStatus.pending ||
            appointment.status == AppointmentStatus.confirmed);
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    if (isUpcoming) {
      return _buildUpcomingAppointmentCard(
        context,
        appointment,
        isDark,
        surfaceColor,
      );
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

    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final isTomorrow =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day + 1;

    String dateLabel;
    if (isToday) {
      dateLabel = 'TODAY';
    } else if (isTomorrow) {
      dateLabel = 'TMRW';
    } else {
      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      dateLabel = '${months[date.month - 1]} ${date.day}';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing5),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                        color: AppColors.primary.withValues(alpha: 0.1),
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
                        color: isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF60778A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
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
                        color: isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF60778A),
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
              Icon(Icons.location_on, size: 18, color: Colors.grey.shade400),
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
              Icon(Icons.timer, size: 18, color: Colors.grey.shade400),
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
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateString = '${months[date.month - 1]} ${date.day}';

    final iconColor = isCancelled
        ? Colors.red.shade500
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);
    final iconBgColor = isCancelled
        ? (isDark
              ? Colors.red.shade500.withValues(alpha: 0.1)
              : Colors.red.shade50)
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
            border: Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          appointment.patientNote ?? 'Consultation',
                          style: TextStyle(
                            fontSize: AppConstants.body1Size,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111518),
                          ),
                        ),
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade400,
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
        color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(
          alpha: 0.8,
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: GetBuilder<PatientDetailController>(
        id: PatientDetailController.chatButtonId,
        builder: (controller) {
          final isStartingChat = controller.isStartingChat;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isStartingChat
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      controller.startChatWithPatient();
                    },
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: isStartingChat
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isStartingChat)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                    const SizedBox(width: AppConstants.spacing2),
                    Text(
                      isStartingChat
                          ? 'Starting chat...'
                          : 'Chat with ${controller.patientName}',
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
          );
        },
      ),
    );
  }

  Widget _buildTreatmentPlanSection(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
  ) {
    final treatmentPlans = controller.treatmentPlans;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Treatment Plans',
                style: TextStyle(
                  fontSize: AppConstants.h4Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showTreatmentPlanDialog(context, controller, isDark, null);
                  },
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing3,
                      vertical: AppConstants.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppConstants.spacing1),
                        Text(
                          'Create Plan',
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (treatmentPlans.isEmpty)
            _buildEmptyTreatmentPlan(context, isDark, surfaceColor)
          else
            ...treatmentPlans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing4),
                child: _buildTreatmentPlanCard(
                  context,
                  plan,
                  isDark,
                  surfaceColor,
                  controller,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanCard(
    BuildContext context,
    TreatmentPlan plan,
    bool isDark,
    Color surfaceColor,
    PatientDetailController controller,
  ) {
    final isExpanded = controller.isPlanExpanded(plan.id);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.togglePlanExpansion(plan.id);
              },
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing2,
                            vertical: AppConstants.spacing1 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: plan.isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSmall,
                            ),
                          ),
                          child: Text(
                            plan.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: plan.isActive
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.diagnosis ?? 'Treatment Plan',
                                style: TextStyle(
                                  fontSize: AppConstants.body1Size,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111518),
                                ),
                                maxLines: isExpanded ? null : 1,
                                overflow: isExpanded
                                    ? null
                                    : TextOverflow.ellipsis,
                              ),
                              if (!isExpanded) ...[
                                const SizedBox(
                                  height: AppConstants.spacing1 / 2,
                                ),
                                Text(
                                  'Created ${_formatDate(plan.createdAt)}',
                                  style: TextStyle(
                                    fontSize: AppConstants.captionSize,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing2),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppConstants.shortAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (isExpanded) ...[
            const SizedBox(height: AppConstants.spacing3),
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            const SizedBox(height: AppConstants.spacing3),
            // Date when expanded
            Text(
              'Created ${_formatDate(plan.createdAt)}',
              style: TextStyle(
                fontSize: AppConstants.captionSize,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            if (plan.diagnosis != null && plan.diagnosis!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacing3),
              _buildInfoRow(
                Icons.medical_information,
                'Diagnosis',
                plan.diagnosis!,
                isDark,
              ),
            ],
            if (plan.medicalConditions != null &&
                plan.medicalConditions!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacing2),
              _buildInfoRow(
                Icons.health_and_safety,
                'Conditions',
                plan.medicalConditions!.join(', '),
                isDark,
              ),
            ],
            if (plan.treatmentGoals != null &&
                plan.treatmentGoals!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacing2),
              _buildInfoRow(Icons.flag, 'Goals', plan.treatmentGoals!, isDark),
            ],
            const SizedBox(height: AppConstants.spacing3),
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            const SizedBox(height: AppConstants.spacing3),
            Text(
              'Treatment Plan',
              style: TextStyle(
                fontSize: AppConstants.body1Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              plan.treatmentPlan,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            if (plan.durationWeeks != null ||
                plan.frequencyPerWeek != null) ...[
              const SizedBox(height: AppConstants.spacing3),
              Row(
                children: [
                  if (plan.durationWeeks != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: AppConstants.spacing1),
                    Text(
                      '${plan.durationWeeks} weeks',
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (plan.durationWeeks != null &&
                      plan.frequencyPerWeek != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing2,
                      ),
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  if (plan.frequencyPerWeek != null) ...[
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: AppConstants.spacing1),
                    Text(
                      '${plan.frequencyPerWeek}x/week',
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (plan.notes != null && plan.notes!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacing3),
              Divider(
                height: 1,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              const SizedBox(height: AppConstants.spacing3),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: AppConstants.body1Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              const SizedBox(height: AppConstants.spacing2),
              Text(
                plan.notes!,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
            // Action buttons
            const SizedBox(height: AppConstants.spacing4),
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            const SizedBox(height: AppConstants.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showTreatmentPlanDialog(
                        context,
                        controller,
                        isDark,
                        plan,
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing3,
                        vertical: AppConstants.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 16, color: AppColors.primary),
                          const SizedBox(width: AppConstants.spacing1),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: AppConstants.body2Size,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing3),
                // Delete button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showDeleteConfirmationDialog(
                        context,
                        controller,
                        isDark,
                        plan,
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing3,
                        vertical: AppConstants.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: AppConstants.spacing1),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: AppConstants.body2Size,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyTreatmentPlan(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: isDark ? Colors.grey.shade600 : AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.spacing3),
          Text(
            'No Treatment Plan',
            style: TextStyle(
              fontSize: AppConstants.body1Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing1),
          Text(
            'Create a treatment plan to track patient progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              color: isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppConstants.spacing2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.captionSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing1 / 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _showTreatmentPlanDialog(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
    TreatmentPlan? existingPlan,
  ) {
    final isEditing = existingPlan != null;
    final diagnosisController = TextEditingController(
      text: existingPlan?.diagnosis ?? '',
    );
    final treatmentGoalsController = TextEditingController(
      text: existingPlan?.treatmentGoals ?? '',
    );
    final treatmentPlanController = TextEditingController(
      text: existingPlan?.treatmentPlan ?? '',
    );
    final notesController = TextEditingController(
      text: existingPlan?.notes ?? '',
    );
    final durationController = TextEditingController(
      text: existingPlan?.durationWeeks?.toString() ?? '',
    );
    final frequencyController = TextEditingController(
      text: existingPlan?.frequencyPerWeek?.toString() ?? '',
    );
    final conditionsController = TextEditingController(
      text: existingPlan?.medicalConditions?.join(', ') ?? '',
    );
    String selectedStatus = existingPlan?.status ?? 'active';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          padding: const EdgeInsets.all(AppConstants.spacing5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Treatment Plan' : 'Create Treatment Plan',
                    style: TextStyle(
                      fontSize: AppConstants.h3Size,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111518),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'Diagnosis',
                        diagnosisController,
                        'e.g., Lower back pain, ACL injury',
                        isDark,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      _buildTextField(
                        'Medical Conditions (comma-separated)',
                        conditionsController,
                        'e.g., Hypertension, Diabetes',
                        isDark,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      _buildTextField(
                        'Treatment Goals',
                        treatmentGoalsController,
                        'e.g., Reduce pain, Improve mobility',
                        isDark,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      _buildTextField(
                        'Treatment Plan *',
                        treatmentPlanController,
                        'Detailed treatment plan including exercises, therapies, etc.',
                        isDark,
                        maxLines: 6,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Duration (weeks)',
                              durationController,
                              'e.g., 8',
                              isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacing4),
                          Expanded(
                            child: _buildTextField(
                              'Frequency/week',
                              frequencyController,
                              'e.g., 3',
                              isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      _buildTextField(
                        'Notes',
                        notesController,
                        'Additional notes and observations',
                        isDark,
                        maxLines: 4,
                      ),
                      if (isEditing) ...[
                        const SizedBox(height: AppConstants.spacing4),
                        _buildStatusDropdown(selectedStatus, isDark, (
                          newStatus,
                        ) {
                          selectedStatus = newStatus;
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing2),
                  ElevatedButton(
                    onPressed: () async {
                      if (treatmentPlanController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Treatment plan is required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final conditions = conditionsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      if (isEditing) {
                        await controller.updateTreatmentPlan(
                          treatmentPlanId: existingPlan.id,
                          diagnosis: diagnosisController.text.trim().isEmpty
                              ? null
                              : diagnosisController.text.trim(),
                          medicalConditions: conditions.isEmpty
                              ? null
                              : conditions,
                          treatmentGoals:
                              treatmentGoalsController.text.trim().isEmpty
                              ? null
                              : treatmentGoalsController.text.trim(),
                          treatmentPlan: treatmentPlanController.text.trim(),
                          durationWeeks: durationController.text.trim().isEmpty
                              ? null
                              : int.tryParse(durationController.text.trim()),
                          frequencyPerWeek:
                              frequencyController.text.trim().isEmpty
                              ? null
                              : int.tryParse(frequencyController.text.trim()),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                          status: selectedStatus,
                        );
                      } else {
                        await controller.createTreatmentPlan(
                          diagnosis: diagnosisController.text.trim().isEmpty
                              ? null
                              : diagnosisController.text.trim(),
                          medicalConditions: conditions.isEmpty
                              ? null
                              : conditions,
                          treatmentGoals:
                              treatmentGoalsController.text.trim().isEmpty
                              ? null
                              : treatmentGoalsController.text.trim(),
                          treatmentPlan: treatmentPlanController.text.trim(),
                          durationWeeks: durationController.text.trim().isEmpty
                              ? null
                              : int.tryParse(durationController.text.trim()),
                          frequencyPerWeek:
                              frequencyController.text.trim().isEmpty
                              ? null
                              : int.tryParse(frequencyController.text.trim()),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(
    String currentStatus,
    bool isDark,
    ValueChanged<String> onChanged,
  ) {
    final statuses = ['active', 'completed', 'paused', 'cancelled'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: currentStatus,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing3,
                vertical: AppConstants.spacing2,
              ),
              border: InputBorder.none,
            ),
            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    PatientDetailController controller,
    bool isDark,
    TreatmentPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Delete Treatment Plan',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this treatment plan? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteTreatmentPlan(plan.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
