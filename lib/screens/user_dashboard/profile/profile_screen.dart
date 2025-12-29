import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'profile_controller.dart';

class ProfileScreen extends BaseScreenView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111518);
    final secondaryTextColor = isDark
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, isDark, controller, surfaceColor),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.spacing4),
              // Profile Photo
              GetBuilder<ProfileController>(
                id: ProfileController.photoId,
                builder: (controller) => _buildProfilePhoto(
                  context,
                  controller,
                  isDark,
                  surfaceColor,
                ),
              ),
              const SizedBox(height: AppConstants.spacing6),
              // Form Fields
              GetBuilder<ProfileController>(
                id: ProfileController.formId,
                builder: (controller) => _buildFormFields(
                  controller,
                  isDark,
                  surfaceColor,
                  textColor,
                  secondaryTextColor,
                  borderColor,
                ),
              ),
              // Bottom spacing for save button
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Save Button (Fixed at bottom)
      bottomNavigationBar: GetBuilder<ProfileController>(
        id: ProfileController.saveButtonId,
        builder: (controller) =>
            _buildSaveButton(controller, isDark, surfaceColor),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    ProfileController controller,
    Color surfaceColor,
  ) {
    return AppCustomAppBar(
      title: 'Basic Info',
      backgroundColor: surfaceColor,
      centerTitle: true,
      action: GetBuilder<ProfileController>(
        id: ProfileController.saveButtonId,
        builder: (controller) => TextButton(
          onPressed: controller.isSaving ? null : controller.onSave,
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: AppConstants.body1Size,
              fontWeight: FontWeight.bold,
              color: controller.isSaving
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(
    BuildContext context,
    ProfileController controller,
    bool isDark,
    Color surfaceColor,
  ) {
    return GestureDetector(
      onTap: controller.onPhotoTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: surfaceColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                              _buildAvatarPlaceholder(controller, isDark),
                        )
                      : _buildAvatarPlaceholder(controller, isDark),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Change Photo',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(ProfileController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey.shade700, Colors.grey.shade600]
              : [Colors.blue.shade100, Colors.blue.shade300],
        ),
      ),
      child: Center(
        child: Text(
          controller.getInitials(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(
    ProfileController controller,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
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
          // Full Name
          _buildTextField(
            label: 'Full Name',
            controller: controller.fullNameController,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            borderColor: borderColor,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Age
          _buildTextField(
            label: 'Age',
            controller: controller.ageController,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            borderColor: borderColor,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Gender Dropdown
          _buildGenderDropdown(
            controller,
            isDark,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Mobile Number
          _buildPhoneField(
            controller,
            isDark,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Address
          _buildAddressField(
            controller,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required Color secondaryTextColor,
    required Color borderColor,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: AppConstants.body1Size, color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing4,
              vertical: AppConstants.spacing3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(
    ProfileController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: DropdownButtonFormField<Gender>(
            value: controller.selectedGender,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing4,
                vertical: AppConstants.spacing3,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: AppConstants.body1Size,
              color: textColor,
            ),
            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
            items: [
              DropdownMenuItem<Gender>(value: Gender.male, child: Text('Male')),
              DropdownMenuItem<Gender>(
                value: Gender.female,
                child: Text('Female'),
              ),
              DropdownMenuItem<Gender>(
                value: Gender.other,
                child: Text('Other'),
              ),
            ],
            onChanged: controller.updateGender,
            hint: Text(
              'Select Gender',
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(
    ProfileController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Stack(
          children: [
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: AppConstants.body1Size,
                color: textColor,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.only(
                  left: AppConstants.spacing4,
                  right: controller.isPhoneVerified
                      ? 80
                      : AppConstants.spacing4,
                  top: AppConstants.spacing3,
                  bottom: AppConstants.spacing3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
              ),
            ),
            if (controller.isPhoneVerified)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.green.shade900.withValues(alpha: 0.3)
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressField(
    ProfileController controller,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        TextField(
          controller: controller.addressController,
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          style: TextStyle(fontSize: AppConstants.body1Size, color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(AppConstants.spacing4),
            hintText: 'Street, City, Pin Code',
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    ProfileController controller,
    bool isDark,
    Color surfaceColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isSaving ? null : controller.onSave,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            height: 56,
            decoration: BoxDecoration(
              color: controller.isSaving
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: controller.isSaving
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: controller.isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: AppConstants.body1Size,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
