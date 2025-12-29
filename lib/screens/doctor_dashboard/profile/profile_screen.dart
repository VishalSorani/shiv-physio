import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'profile_controller.dart';

class DoctorProfileScreen extends BaseScreenView<DoctorProfileController> {
  const DoctorProfileScreen({super.key});

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
        title: 'Manage Profile',
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
        action: GetBuilder<DoctorProfileController>(
          id: DoctorProfileController.contentId,
          builder: (controller) => TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (controller.currentTabIndex == 0) {
                controller.onSaveProfile();
              } else {
                controller.onSaveAvailability();
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: AppConstants.body1Size,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Tabs
            GetBuilder<DoctorProfileController>(
              id: DoctorProfileController.tabsId,
              builder: (controller) => _buildTabs(context, controller, isDark),
            ),
            // Content
            Expanded(
              child: GetBuilder<DoctorProfileController>(
                id: DoctorProfileController.contentId,
                builder: (controller) {
                  if (controller.currentTabIndex == 0) {
                    return GetBuilder<DoctorProfileController>(
                      id: DoctorProfileController.profileDetailsId,
                      builder: (_) =>
                          _buildProfileDetails(context, controller, isDark),
                    );
                  } else {
                    return GetBuilder<DoctorProfileController>(
                      id: DoctorProfileController.availabilityId,
                      builder: (_) =>
                          _buildAvailability(context, controller, isDark),
                    );
                  }
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
    DoctorProfileController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.onTabChanged(0);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing3,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: controller.currentTabIndex == 0
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    'Profile Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: controller.currentTabIndex == 0
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: controller.currentTabIndex == 0
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.onTabChanged(1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing3,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: controller.currentTabIndex == 1
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    'Availability',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: controller.currentTabIndex == 1
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: controller.currentTabIndex == 1
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppConstants.spacing6,
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing8 + 64, // Space for bottom nav
      ),
      child: Column(
        children: [
          // Profile Picture Section
          _buildProfilePicture(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing6),
          // Professional Info
          _buildProfessionalInfo(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing5),
          // Clinic & Contact
          _buildClinicContact(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing5),
          // Consultation Fees
          _buildConsultationFees(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing5),
          // Last Updated
          Text(
            'Last updated: Oct 24, 2023.\nChanges will be reflected in patient app immediately.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    controller.avatarUrl != null &&
                        controller.avatarUrl!.isNotEmpty
                    ? Image.network(
                        controller.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(isDark),
                      )
                    : _buildDefaultAvatar(isDark),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular,
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.onEditAvatar();
                  },
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusCircular,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacing2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          controller.doctorName,
          style: TextStyle(
            fontSize: AppConstants.h3Size,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
        ),
        const SizedBox(height: AppConstants.spacing1),
        Text(
          controller.title,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 56,
        color: isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildProfessionalInfo(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return _buildSectionCard(
      context,
      'Professional Info',
      Icons.school,
      isDark,
      [
        _buildTextField(
          context,
          'Qualifications',
          controller.qualifications,
          (value) => controller.qualifications = value,
          isDark,
          hintText: 'e.g. MBBS, MD',
        ),
        const SizedBox(height: AppConstants.spacing4),
        _buildTextField(
          context,
          'Specializations',
          controller.specializations,
          (value) => controller.specializations = value,
          isDark,
          hintText: 'e.g. Cardiology, Neurology',
          helperText: 'Separate multiple with commas',
        ),
        const SizedBox(height: AppConstants.spacing4),
        _buildNumberField(
          context,
          'Years of Experience',
          controller.yearsOfExperience.toString(),
          (value) {
            final intValue = int.tryParse(value) ?? 0;
            controller.yearsOfExperience = intValue;
          },
          isDark,
          suffix: 'Years',
        ),
      ],
    );
  }

  Widget _buildClinicContact(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return _buildSectionCard(
      context,
      'Clinic & Contact',
      Icons.location_on,
      isDark,
      [
        _buildTextField(
          context,
          'Clinic Name',
          controller.clinicName,
          (value) => controller.clinicName = value,
          isDark,
        ),
        const SizedBox(height: AppConstants.spacing4),
        _buildTextArea(
          context,
          'Clinic Address',
          controller.clinicAddress,
          (value) => controller.clinicAddress = value,
          isDark,
        ),
        const SizedBox(height: AppConstants.spacing4),
        _buildTextField(
          context,
          'Phone Number',
          controller.phoneNumber,
          (value) => controller.phoneNumber = value,
          isDark,
          prefixIcon: Icons.call,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppConstants.spacing4),
        _buildTextField(
          context,
          'Email Address',
          controller.email,
          (value) => controller.email = value,
          isDark,
          prefixIcon: Icons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildConsultationFees(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return _buildSectionCard(
      context,
      'Consultation Fees',
      Icons.payments,
      isDark,
      [
        _buildNumberField(
          context,
          'Standard Consultation',
          controller.consultationFee.toString(),
          (value) {
            final intValue = int.tryParse(value) ?? 0;
            controller.consultationFee = intValue;
          },
          isDark,
          prefix: '₹',
          suffix: 'per session',
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
            children: [
              Icon(
                icon,
                size: AppConstants.iconSizeMedium,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.body1Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String> onChanged,
    bool isDark, {
    String? hintText,
    String? helperText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
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
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: AppConstants.iconSizeMedium,
                    color: Colors.grey.shade400,
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppConstants.spacing3),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppConstants.spacing1),
          Text(
            helperText,
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextArea(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String> onChanged,
    bool isDark,
  ) {
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
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          maxLines: 3,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppConstants.spacing3),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String> onChanged,
    bool isDark, {
    String? prefix,
    String? suffix,
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
        Stack(
          children: [
            TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: EdgeInsets.only(
                  left: prefix != null
                      ? AppConstants.spacing8
                      : AppConstants.spacing3,
                  right: suffix != null
                      ? AppConstants.spacing8
                      : AppConstants.spacing3,
                  top: AppConstants.spacing3,
                  bottom: AppConstants.spacing3,
                ),
              ),
            ),
            if (prefix != null)
              Positioned(
                left: AppConstants.spacing4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    prefix,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            if (suffix != null)
              Positioned(
                right: AppConstants.spacing4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    suffix,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailability(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    if (controller.isLoadingAvailability) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'Loading availability...',
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

    if (!controller.hasAvailability && !controller.hasTimeOff) {
      return _buildEmptyAvailabilityState(context, controller, isDark);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppConstants.spacing6,
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing8 + 64, // Space for bottom nav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Schedule
          _buildWeeklySchedule(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing6),
          // All Available Days
          ..._buildAllDayAvailability(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing6),
          // Time Off
          _buildTimeOff(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing5),
          // Pro Tip
          _buildProTip(context, isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyAvailabilityState(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
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
              'No Availability Set',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'Set your weekly schedule and time slots to start accepting appointments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark
                    ? Colors.grey.shade400
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacing6),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Set default availability (Mon-Fri, 9 AM - 5 PM)
                controller.onDayTapped(0); // Monday
                controller.onDayTapped(1); // Tuesday
                controller.onDayTapped(2); // Wednesday
                controller.onDayTapped(3); // Thursday
                controller.onDayTapped(4); // Friday
              },
              icon: const Icon(Icons.add),
              label: const Text('Set Up Availability'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing5,
                  vertical: AppConstants.spacing3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySchedule(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final isSunday = [false, false, false, false, false, false, true];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            Text(
              'Tap day to edit',
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing4),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
              // Day labels
              Row(
                children: days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.captionSize,
                        fontWeight: FontWeight.w600,
                        color: isSunday[index]
                            ? Colors.red.shade400
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing2),
              // Day buttons
              Row(
                children: List.generate(7, (index) {
                  final isAvailable = controller.weeklyAvailability[index];
                  final isOff = index == 6; // Sunday is off

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.onDayTapped(index);
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isOff
                                    ? (isDark
                                          ? Colors.red.shade900.withOpacity(0.1)
                                          : Colors.red.shade50)
                                    : (isAvailable
                                          ? AppColors.primary.withOpacity(0.1)
                                          : (isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade100)),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),
                                border: Border.all(
                                  color: isOff
                                      ? (isDark
                                            ? Colors.red.shade900.withOpacity(
                                                0.3,
                                              )
                                            : Colors.red.shade100)
                                      : (isAvailable
                                            ? (index == 0
                                                  ? AppColors.primary
                                                  : AppColors.primary
                                                        .withOpacity(0.3))
                                            : Colors.transparent),
                                  width: isAvailable && index == 0 ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isOff ? Icons.close : Icons.check,
                                  size: AppConstants.iconSizeMedium,
                                  color: isOff
                                      ? Colors.red.shade400
                                      : (isAvailable
                                            ? AppColors.primary
                                            : Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ),
                          if (isAvailable && !isOff)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Divider(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              ),
              const SizedBox(height: AppConstants.spacing3),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendItem(
                    context,
                    AppColors.primary,
                    'Available',
                    isDark,
                  ),
                  _buildLegendItem(
                    context,
                    isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    'Unavailable',
                    isDark,
                  ),
                  _buildLegendItem(
                    context,
                    isDark
                        ? Colors.red.shade900.withOpacity(0.3)
                        : Colors.red.shade100,
                    'Time Off',
                    isDark,
                    isBordered: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Color color,
    String label,
    bool isDark, {
    bool isBordered = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isBordered
                ? Border.all(
                    color: isDark ? Colors.red.shade800 : Colors.red.shade200,
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppConstants.spacing2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAllDayAvailability(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    final availableDays = <int>[];

    // Find all days that are available
    for (int day = 0; day < 7; day++) {
      if (controller.isDayAvailable(day)) {
        availableDays.add(day);
      }
    }

    if (availableDays.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: AppConstants.spacing3),
              Text(
                'No days selected',
                style: TextStyle(
                  fontSize: AppConstants.body1Size,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: AppConstants.spacing2),
              Text(
                'Tap days in the weekly schedule above to set availability',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Build availability sections for each available day
    return availableDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return Column(
        children: [
          if (index > 0) const SizedBox(height: AppConstants.spacing6),
          _buildDayAvailability(context, controller, isDark, day),
        ],
      );
    }).toList();
  }

  Widget _buildDayAvailability(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
    int dayOfWeek,
  ) {
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final isAvailable = controller.isDayAvailable(dayOfWeek);
    final timeSlots = controller.getTimeSlotsForDay(dayOfWeek);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${dayNames[dayOfWeek]} Availability',
          style: TextStyle(
            fontSize: AppConstants.h4Size,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111518),
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: AppConstants.body1Size,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF111518),
                    ),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      controller.onDayTapped(dayOfWeek);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              if (isAvailable) ...[
                Divider(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                ),
                const SizedBox(height: AppConstants.spacing3),
                // Time Slots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Slots',
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await _showTimeSlotDialog(
                            context,
                            controller,
                            isDark,
                            dayOfWeek,
                          );
                        },
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing2,
                            vertical: AppConstants.spacing1,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: AppConstants.iconSizeSmall,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppConstants.spacing1),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: AppConstants.body2Size,
                                  fontWeight: FontWeight.w500,
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
                const SizedBox(height: AppConstants.spacing3),
                if (timeSlots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing4,
                    ),
                    child: Text(
                      'No time slots set. Add a slot to define your availability.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  )
                else
                  ...timeSlots.asMap().entries.map((entry) {
                    final index = entry.key;
                    final slot = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spacing3,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  await _showTimeSlotDialog(
                                    context,
                                    controller,
                                    isDark,
                                    dayOfWeek,
                                    slotIndex: index,
                                    initialStartTime: slot['start']!,
                                    initialEndTime: slot['end']!,
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
                                    color: isDark
                                        ? AppColors.backgroundDark
                                        : AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      slot['start']!,
                                      style: TextStyle(
                                        fontSize: AppConstants.body1Size,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF111518),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing2,
                            ),
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: AppConstants.body1Size,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  await _showTimeSlotDialog(
                                    context,
                                    controller,
                                    isDark,
                                    dayOfWeek,
                                    slotIndex: index,
                                    initialStartTime: slot['start']!,
                                    initialEndTime: slot['end']!,
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
                                    color: isDark
                                        ? AppColors.backgroundDark
                                        : AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      slot['end']!,
                                      style: TextStyle(
                                        fontSize: AppConstants.body1Size,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF111518),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.onDeleteTimeSlot(dayOfWeek, index);
                              },
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppConstants.spacing1,
                                ),
                                child: Icon(
                                  Icons.delete,
                                  size: AppConstants.iconSizeMedium,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOff(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Time Off',
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await _showTimeOffDialog(context, controller, isDark);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing2,
                    vertical: AppConstants.spacing1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle,
                        size: AppConstants.iconSizeSmall,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.spacing1),
                      Text(
                        'New',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.bold,
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
        if (!controller.hasTimeOff)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 48,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(height: AppConstants.spacing3),
                Text(
                  'No upcoming time off',
                  style: TextStyle(
                    fontSize: AppConstants.body1Size,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  'Add time off periods when you\'ll be unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.body2Size,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          )
        else
          ...controller.timeOffListFormatted.asMap().entries.map((entry) {
            final index = entry.key;
            final timeOff = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing3),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Color indicator bar
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: timeOff.color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppConstants.radiusLarge),
                            bottomLeft: Radius.circular(
                              AppConstants.radiusLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: AppConstants.spacing4),
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacing3),
                          decoration: BoxDecoration(
                            color: timeOff.color.withOpacity(
                              isDark ? 0.2 : 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            timeOff.icon,
                            color: timeOff.color,
                            size: AppConstants.iconSizeMedium,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing4),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeOff.dateRange,
                                style: TextStyle(
                                  fontSize: AppConstants.body1Size,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111518),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacing1),
                              Text(
                                timeOff.reason,
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
                        // Edit button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              await _showTimeOffDialog(
                                context,
                                controller,
                                isDark,
                                timeOffIndex: index,
                              );
                            },
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusCircular,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.spacing2,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: AppConstants.iconSizeMedium,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing1),
                        // Delete button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller.onDeleteTimeOff(index);
                            },
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusCircular,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.spacing2,
                              ),
                              child: Icon(
                                Icons.delete,
                                size: AppConstants.iconSizeMedium,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProTip(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: AppColors.primary,
            size: AppConstants.iconSizeMedium,
          ),
          const SizedBox(width: AppConstants.spacing3),
          Expanded(
            child: Text(
              'Pro Tip: Long press on any day in the weekly view to quickly mark it as a recurring day off.',
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark
                    ? AppColors.primary.withOpacity(0.9)
                    : AppColors.primaryDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimeSlotDialog(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark,
    int dayOfWeek, {
    int? slotIndex,
    String? initialStartTime,
    String? initialEndTime,
  }) async {
    // Parse initial times or use defaults
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);

    if (initialStartTime != null) {
      // Parse "HH:MM AM/PM" format
      try {
        final parts = initialStartTime.split(' ');
        if (parts.length == 2) {
          final timePart = parts[0].split(':');
          var hour = int.parse(timePart[0]);
          final minute = int.parse(timePart[1]);
          final period = parts[1].toUpperCase();

          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
          startTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        // Use default
      }
    }

    if (initialEndTime != null) {
      try {
        final parts = initialEndTime.split(' ');
        if (parts.length == 2) {
          final timePart = parts[0].split(':');
          var hour = int.parse(timePart[0]);
          final minute = int.parse(timePart[1]);
          final period = parts[1].toUpperCase();

          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
          endTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        // Use default
      }
    }

    // Show dialog to pick start time
    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedStartTime == null) return;

    // Show dialog to pick end time
    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: endTime.isAfter(pickedStartTime) ? endTime : pickedStartTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedEndTime == null) return;

    // Validate end time is after start time
    if (pickedEndTime.hour < pickedStartTime.hour ||
        (pickedEndTime.hour == pickedStartTime.hour &&
            pickedEndTime.minute <= pickedStartTime.minute)) {
      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('End time must be after start time'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return;
    }

    // Format times for display
    final startTimeStr = _formatTimeOfDay(pickedStartTime);
    final endTimeStr = _formatTimeOfDay(pickedEndTime);

    // Update or add time slot
    if (slotIndex != null) {
      // Editing existing slot
      controller.onEditTimeSlot(dayOfWeek, slotIndex, startTimeStr, endTimeStr);
    } else {
      // Adding new slot
      final startTimeDb = _formatTimeOfDayForDb(pickedStartTime);
      final endTimeDb = _formatTimeOfDayForDb(pickedEndTime);
      controller.onAddTimeSlot(
        dayOfWeek,
        startTime: startTimeDb,
        endTime: endTimeDb,
      );
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String _formatTimeOfDayForDb(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _showTimeOffDialog(
    BuildContext context,
    DoctorProfileController controller,
    bool isDark, {
    int? timeOffIndex,
  }) async {
    DateTime? startDate;
    DateTime? endDate;
    String? reason;

    // If editing, get existing values
    if (timeOffIndex != null) {
      final existingTimeOff = controller.getTimeOff(timeOffIndex);
      if (existingTimeOff != null) {
        startDate = existingTimeOff.startAt;
        endDate = existingTimeOff.endAt;
        reason = existingTimeOff.reason;
      }
    }

    // Default to today and tomorrow if adding new
    final now = DateTime.now();
    startDate ??= DateTime(now.year, now.month, now.day);
    endDate ??= DateTime(now.year, now.month, now.day + 1);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TimeOffDialog(
        isDark: isDark,
        initialStartDate: startDate!,
        initialEndDate: endDate!,
        initialReason: reason,
        isEdit: timeOffIndex != null,
      ),
    );

    if (result != null && context.mounted) {
      final pickedStartDate = result['startDate'] as DateTime;
      final pickedEndDate = result['endDate'] as DateTime;
      final pickedReason = result['reason'] as String?;

      // Validate end date is after start date
      if (pickedEndDate.isBefore(pickedStartDate) ||
          (pickedEndDate.year == pickedStartDate.year &&
              pickedEndDate.month == pickedStartDate.month &&
              pickedEndDate.day == pickedStartDate.day &&
              pickedEndDate.isBefore(pickedStartDate))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('End date must be after start date'),
            backgroundColor: Colors.red.shade400,
          ),
        );
        return;
      }

      if (timeOffIndex != null) {
        // Editing existing time off
        controller.onEditTimeOff(
          timeOffIndex,
          pickedStartDate,
          pickedEndDate,
          pickedReason,
        );
      } else {
        // Adding new time off
        controller.onAddTimeOff(pickedStartDate, pickedEndDate, pickedReason);
      }
    }
  }
}

class _TimeOffDialog extends StatefulWidget {
  final bool isDark;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final String? initialReason;
  final bool isEdit;

  const _TimeOffDialog({
    required this.isDark,
    required this.initialStartDate,
    required this.initialEndDate,
    this.initialReason,
    this.isEdit = false,
  });

  @override
  State<_TimeOffDialog> createState() => _TimeOffDialogState();
}

class _TimeOffDialogState extends State<_TimeOffDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _reasonController = TextEditingController(text: widget.initialReason ?? '');
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: widget.isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: widget.isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit ? 'Edit Time Off' : 'Add Time Off',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing5),
            // Start Date
            Text(
              'Start Date',
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectStartDate,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing3),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: widget.isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppConstants.iconSizeSmall,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.spacing3),
                      Text(
                        _formatDate(_startDate),
                        style: TextStyle(
                          fontSize: AppConstants.body1Size,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF111518),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            // End Date
            Text(
              'End Date',
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectEndDate,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing3),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: widget.isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppConstants.iconSizeSmall,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.spacing3),
                      Text(
                        _formatDate(_endDate),
                        style: TextStyle(
                          fontSize: AppConstants.body1Size,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF111518),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            // Reason
            Text(
              'Reason (Optional)',
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g., Vacation, Conference, Holiday',
                hintStyle: TextStyle(
                  color: widget.isDark
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: widget.isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: widget.isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: widget.isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : const Color(0xFF111518),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppConstants.spacing6),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing3),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'startDate': _startDate,
                      'endDate': _endDate,
                      'reason': _reasonController.text.trim().isEmpty
                          ? null
                          : _reasonController.text.trim(),
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing5,
                      vertical: AppConstants.spacing3,
                    ),
                  ),
                  child: Text(widget.isEdit ? 'Update' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
