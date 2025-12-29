import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/appointment.dart';
import '../../../widgets/app_appointment_list_card.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'appointments_controller.dart';

class AppointmentsScreen extends BaseScreenView<AppointmentsController> {
  const AppointmentsScreen({super.key});

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
        title: 'My Appointments',
        centerTitle: true,

        action: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.find<AppointmentsController>().onBookAppointmentTap();
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing2),
              child: Icon(Icons.add_circle, color: AppColors.primary),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                    return RefreshIndicator(
                      onRefresh: controller.refreshAppointments,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(context, isDark),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refreshAppointments,
                    child: _buildAppointmentsList(context, controller, isDark),
                  );
                },
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
    final tabs = ['Upcoming', 'Completed', 'Cancelled'];

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
    final hasCompletedSection =
        controller.currentTabIndex ==
            AppointmentsController.completedTabIndex &&
        appointments.isNotEmpty;

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when list is short
      padding: EdgeInsets.only(
        top: AppConstants.spacing6,
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing8 + 64, // Space for bottom nav
      ),
      itemCount: appointments.length + (hasCompletedSection ? 1 : 0),
      itemBuilder: (context, index) {
        // Add divider before completed section
        if (hasCompletedSection && index == 0) {
          return _buildSectionDivider(context, isDark, 'Recent Completed');
        }

        final appointmentIndex = hasCompletedSection ? index - 1 : index;
        final appointment = appointments[appointmentIndex];

        return AppAppointmentListCard(
          doctorName: controller.doctorName,
          specialization: controller.doctorSpecialization,
          month: controller.getMonth(appointment),
          day: controller.getDay(appointment),
          time: controller.getTime(appointment),
          status: controller.getCardStatus(appointment),
          type: controller.getAppointmentType(appointment),
          location: controller.clinicAddress,
          onReschedule: () => controller.onRescheduleTap(appointment),
          onCancel: () =>
              _showCancelDialog(context, controller, appointment, isDark),
          onViewPrescription: () =>
              controller.onViewPrescriptionTap(appointment),
          onViewTreatmentPlan: () =>
              controller.onViewTreatmentPlanTap(appointment),
          onTap: () => controller.onAppointmentTap(appointment),
        );
      },
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    AppointmentsController controller,
    Appointment appointment,
    bool isDark,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Cancel Appointment?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(
                color: isDark
                    ? Colors.grey.shade400
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      await controller.onCancelTap(appointment);
    }
  }

  Widget _buildSectionDivider(BuildContext context, bool isDark, String label) {
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing2,
            ),
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
}
