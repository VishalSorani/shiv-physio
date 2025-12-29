import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_patient_card.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'patient_detail_screen.dart';
import 'patient_detail_binding.dart';
import 'add_edit_patient_screen.dart';
import 'add_edit_patient_binding.dart';
import 'patients_controller.dart';

class PatientManagementScreen
    extends BaseScreenView<PatientManagementController> {
  const PatientManagementScreen({super.key});

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
        title: 'My Patients',
        centerTitle: true,
        leading: Material(
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
        action: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => const AddEditPatientScreen(),
                binding: AddEditPatientBinding(),
              )?.then((result) {
                // Refresh patients list if patient was created/updated
                if (result == true) {
                  Get.find<PatientManagementController>().refreshPatients();
                }
              });
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing2),
              child: Icon(Icons.person_add, color: AppColors.primary),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search bar
            GetBuilder<PatientManagementController>(
              id: PatientManagementController.searchId,
              builder: (controller) =>
                  _buildSearchBar(context, controller, isDark),
            ),
            // Content
            Expanded(
              child: GetBuilder<PatientManagementController>(
                id: PatientManagementController.contentId,
                builder: (controller) {
                  if (controller.isLoading && controller.patients.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppConstants.spacing4),
                            Text(
                              'Loading patients...',
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

                  return GetBuilder<PatientManagementController>(
                    id: PatientManagementController.listId,
                    builder: (controller) {
                      if (controller.patients.isEmpty) {
                        return _buildEmptyState(context, isDark);
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.refreshPatients(),
                        color: AppColors.primary,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                  top: AppConstants.spacing4,
                                  left: AppConstants.spacing4,
                                  right: AppConstants.spacing4,
                                  bottom: AppConstants.spacing4,
                                ),
                                itemCount: controller.patients.length,
                                itemBuilder: (context, index) {
                                  final patient = controller.patients[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppConstants.spacing3,
                                    ),
                                    child: AppPatientCard(
                                      patient: patient,
                                      onTap: () {
                                        Get.to(
                                          () => const PatientDetailScreen(),
                                          binding: PatientDetailBinding(
                                            patient.patient.id,
                                          ),
                                        );
                                      },
                                      onMoreTap: () {
                                        // TODO: Show patient options menu
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Pagination
                            GetBuilder<PatientManagementController>(
                              id: PatientManagementController.paginationId,
                              builder: (controller) =>
                                  _buildPagination(context, controller, isDark),
                            ),
                          ],
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

  Widget _buildSearchBar(
    BuildContext context,
    PatientManagementController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
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
        child: TextField(
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by name, ID or condition...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: AppConstants.body1Size,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing4,
              vertical: AppConstants.spacing4,
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
            fontSize: AppConstants.body1Size,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    PatientManagementController controller,
    bool isDark,
  ) {
    if (controller.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final pageNumbers = controller.getPageNumbers();
    final startIndex = (controller.currentPage - 1) * 10 + 1;
    final endIndex = (startIndex + controller.patients.length - 1).clamp(
      0,
      controller.totalPatients,
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing6),
      child: Column(
        children: [
          // Page numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.currentPage > 1
                      ? () {
                          HapticFeedback.lightImpact();
                          controller.onPreviousPage();
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_left,
                      color: controller.currentPage > 1
                          ? (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing2),
              // Page number buttons
              ...pageNumbers.map((pageNum) {
                if (pageNum == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing1,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '...',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: AppConstants.body2Size,
                        ),
                      ),
                    ),
                  );
                }

                final isActive = pageNum == controller.currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing1,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.onPageTap(pageNum);
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSmall,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$pageNum',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600),
                            fontSize: AppConstants.body2Size,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: AppConstants.spacing2),
              // Next button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.hasMorePages
                      ? () {
                          HapticFeedback.lightImpact();
                          controller.onNextPage();
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_right,
                      color: controller.hasMorePages
                          ? (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Info text
          Text(
            'Showing $startIndex-${endIndex} of ${controller.totalPatients} patients',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              color: Colors.grey.shade400,
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
              Icons.people_outline,
              size: 64,
              color: isDark ? Colors.grey.shade600 : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'No Patients Found',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'Patients will appear here once they book appointments',
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
