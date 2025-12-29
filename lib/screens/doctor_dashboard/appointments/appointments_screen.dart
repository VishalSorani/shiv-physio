import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/enums.dart';
import '../../../widgets/app_appointment_request_card.dart';
import '../../../widgets/app_custom_app_bar.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notifications_binding.dart';
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
      appBar: AppCustomAppBar(
        title: 'Appointment Requests',
        centerTitle: true,
        action: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => const DoctorNotificationsScreen(),
                binding: DoctorNotificationsBinding(),
              );
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing2),
              child: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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

  Widget _buildFilters(
    BuildContext context,
    DoctorAppointmentsController controller,
    bool isDark,
  ) {
    final filters = [
      {'label': 'All', 'icon': Icons.filter_list},
      {'label': 'Accepted', 'icon': Icons.check_circle_outline},
      {'label': 'Rejected', 'icon': Icons.cancel_outlined},
      {'label': 'Date', 'icon': Icons.calendar_today},
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
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    if (index == 3) {
                      // Date filter - show date picker
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: isDark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                onSurface: isDark
                                    ? Colors.white
                                    : const Color(0xFF111518),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        controller.onDateSelected(selectedDate);
                        controller.onFilterChanged(index);
                      } else if (controller.selectedDate == null) {
                        // If no date selected and no previous date, don't change filter
                        return;
                      } else {
                        controller.onFilterChanged(index);
                      }
                    } else {
                      controller.onFilterChanged(index);
                    }
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
                          index == 3 && controller.selectedDate != null
                              ? DateFormat(
                                  'MMM d',
                                ).format(controller.selectedDate!)
                              : filter['label'] as String,
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
                        if (index == 3 &&
                            controller.selectedDate != null &&
                            isSelected)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppConstants.spacing2,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.clearDateFilter();
                                controller.onFilterChanged(0); // Switch to All
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
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
        final isAccepting = controller.acceptingIndex == index;
        final isConfirmingReject = controller.confirmingRejectIndex == index;

        // Only show actions for pending appointments
        final isPending =
            request.appointment.status == AppointmentStatus.pending;

        return AppAppointmentRequestCard(
          patientName: request.patient.fullName ?? 'Unknown Patient',
          patientAgeGender: request.patientAgeGender ?? 'Age not specified',
          patientAvatarUrl: request.patient.avatarUrl,
          status: request.requestStatus,
          appointmentStatus: request.appointment.status,
          date: request.formattedDate,
          time: request.formattedTime,
          reasonForVisit: request.reasonForVisit,
          isRejecting: isRejecting,
          rejectionReason: controller.rejectionReasons(index),
          isAccepting: isAccepting,
          isConfirmingReject: isConfirmingReject,
          showActions: isPending, // Only show actions for pending appointments
          onAccept: isPending ? () => controller.onAcceptRequest(index) : null,
          onReject: isPending ? () => controller.onRejectRequest(index) : null,
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
