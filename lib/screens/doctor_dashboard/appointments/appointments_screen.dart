import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_appointment_request_card.dart';
import 'appointments_controller.dart';

class DoctorAppointmentsScreen
    extends BaseScreenView<DoctorAppointmentsController> {
  const DoctorAppointmentsScreen({super.key});

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
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Filter Chips
            GetBuilder<DoctorAppointmentsController>(
              id: DoctorAppointmentsController.filtersId,
              builder: (controller) =>
                  _buildFilters(context, controller, isDark),
            ),
            // Content
            Expanded(
              child: GetBuilder<DoctorAppointmentsController>(
                id: DoctorAppointmentsController.contentId,
                builder: (controller) {
                  if (controller.isLoading &&
                      controller.appointmentRequests.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppConstants.spacing4),
                            Text(
                              'Loading appointments...',
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

                  return GetBuilder<DoctorAppointmentsController>(
                    id: DoctorAppointmentsController.listId,
                    builder: (controller) {
                      if (controller.appointmentRequests.isEmpty) {
                        return _buildEmptyState(context, isDark);
                      }
                      return RefreshIndicator(
                        onRefresh: () =>
                            controller.refreshAppointmentRequests(),
                        color: AppColors.primary,
                        child: _buildAppointmentsList(
                          context,
                          controller,
                          isDark,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final headerBgColor = isDark ? const Color(0xFF1A2632) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: headerBgColor,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Requests',
                    style: TextStyle(
                      fontSize: AppConstants.h3Size,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111518),
                      letterSpacing: -0.015,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing1),
                  Text(
                    'Welcome back, Dr. Chauhan',
                    style: TextStyle(
                      fontSize: AppConstants.captionSize,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF60778A),
                    ),
                  ),
                ],
              ),
            ),
            // Notification Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Handle notification tap
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.notifications,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                  ),
                ),
                // Notification Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: headerBgColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    DoctorAppointmentsController controller,
    bool isDark,
  ) {
    final filters = [
      {'label': 'All', 'icon': Icons.filter_list},
      {'label': 'Urgency', 'icon': Icons.priority_high},
      {'label': 'Date', 'icon': Icons.calendar_today},
      {'label': 'Newest', 'icon': Icons.schedule},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing3,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = controller.selectedFilterIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing3),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.onFilterChanged(index);
                  },
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusCircular,
                  ),
                  child: AnimatedContainer(
                    duration: AppConstants.shortAnimation,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing4,
                      vertical: AppConstants.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.primary
                                : const Color(0xFF111518))
                          : (isDark ? const Color(0xFF2A3844) : Colors.white),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey.shade300
                                    : const Color(0xFF111518)),
                        ),
                        const SizedBox(width: AppConstants.spacing2),
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade300
                                      : const Color(0xFF111518)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    DoctorAppointmentsController controller,
    bool isDark,
  ) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: AppConstants.spacing4,
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing8 + 64, // Space for bottom nav
      ),
      itemCount: controller.appointmentRequests.length,
      itemBuilder: (context, index) {
        final request = controller.appointmentRequests[index];
        final isRejecting = controller.rejectingIndex == index;

        return AppAppointmentRequestCard(
          patientName: request.patient.fullName ?? 'Unknown Patient',
          patientAgeGender: request.patientAgeGender ?? 'Age not specified',
          patientAvatarUrl: request.patient.avatarUrl,
          status: request.requestStatus,
          date: request.formattedDate,
          time: request.formattedTime,
          reasonForVisit: request.reasonForVisit,
          isRejecting: isRejecting,
          rejectionReason: controller.rejectionReasons(index),
          onAccept: () => controller.onAcceptRequest(index),
          onReject: () => controller.onRejectRequest(index),
          onCancelReject: () => controller.onCancelReject(index),
          onRejectionReasonChanged: (reason) =>
              controller.onRejectionReasonChanged(index, reason),
          onConfirmReject: () => controller.onConfirmReject(index),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade600 : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'No Appointment Requests',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'New appointment requests will appear here',
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
}
