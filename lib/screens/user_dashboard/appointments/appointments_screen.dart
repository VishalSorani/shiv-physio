import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_appointment_list_card.dart';
import 'appointments_controller.dart';

class AppointmentsScreen extends BaseScreenView<AppointmentsController> {
  const AppointmentsScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Tabs
            GetBuilder<AppointmentsController>(
              id: AppointmentsController.tabsId,
              builder: (controller) => _buildTabs(context, controller, isDark),
            ),
            // Content
            Expanded(
              child: GetBuilder<AppointmentsController>(
                id: AppointmentsController.listId,
                builder: (controller) {
                  if (controller.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }
                  return _buildAppointmentsList(context, controller, isDark);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : Colors.white)
            .withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
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
                borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing2),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              ),
            ),
            // Title
            Text(
              'My Appointments',
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            // Add button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.find<AppointmentsController>().onAddAppointmentTap();
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing2),
                  child: Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
    BuildContext context,
    AppointmentsController controller,
    bool isDark,
  ) {
    final tabs = [
      'Upcoming',
      'Completed',
      'Cancelled',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = controller.currentTabIndex == index;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.onTabChanged(index);
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.spacing3,
                    top: AppConstants.spacing2,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
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
                              : AppColors.onSurfaceVariant),
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
    AppointmentsController controller,
    bool isDark,
  ) {
    final appointments = controller.appointments;

    // Check if we need a divider for completed section
    final hasCompletedSection = controller.currentTabIndex ==
            AppointmentsController.completedTabIndex &&
        appointments.isNotEmpty;

    return ListView.builder(
      padding: EdgeInsets.only(
        top: AppConstants.spacing6,
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing8 + 64, // Space for FAB + bottom nav
      ),
      itemCount: appointments.length + (hasCompletedSection ? 1 : 0),
      itemBuilder: (context, index) {
        // Add divider before completed section
        if (hasCompletedSection && index == 0) {
          return _buildSectionDivider(context, isDark, 'Recent Completed');
        }

        final appointmentIndex =
            hasCompletedSection ? index - 1 : index;
        final appointment = appointments[appointmentIndex];

        return AppAppointmentListCard(
          doctorName: appointment.doctorName,
          specialization: appointment.specialization,
          month: appointment.month,
          day: appointment.day,
          time: appointment.time,
          status: appointment.status,
          type: appointment.type,
          location: appointment.location,
          onReschedule: () => controller.onRescheduleTap(appointment),
          onCancel: () => controller.onCancelTap(appointment),
          onViewPrescription: () =>
              controller.onViewPrescriptionTap(appointment),
          onViewTreatmentPlan: () =>
              controller.onViewTreatmentPlanTap(appointment),
          onTap: () => controller.onAppointmentTap(appointment),
        );
      },
    );
  }

  Widget _buildSectionDivider(
    BuildContext context,
    bool isDark,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing2),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.captionSize,
                color: isDark
                    ? Colors.grey.shade500
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
        ],
      ),
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
              'Your ${_getTabLabel()} appointments will appear here',
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

  String _getTabLabel() {
    final controller = Get.find<AppointmentsController>();
    switch (controller.currentTabIndex) {
      case AppointmentsController.upcomingTabIndex:
        return 'upcoming';
      case AppointmentsController.completedTabIndex:
        return 'completed';
      case AppointmentsController.cancelledTabIndex:
        return 'cancelled';
      default:
        return '';
    }
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Get.find<AppointmentsController>().onBookAppointmentTap();
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
