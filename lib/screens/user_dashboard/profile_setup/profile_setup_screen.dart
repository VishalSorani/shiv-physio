import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import 'profile_setup_controller.dart';

class ProfileSetupScreen extends BaseScreenView<ProfileSetupController> {
  const ProfileSetupScreen({super.key});

  static const String profileSetupScreen = '/profile-setup';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final surfaceColor = isDark ? Colors.grey.shade800 : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : const Color(0xFF111518);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            GetBuilder<ProfileSetupController>(
              id: ProfileSetupController.appBarId,
              builder: (controller) => _buildAppBar(context, isDark, controller),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.spacing4),
                    // Headline
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.headerId,
                      builder: (_) => _buildHeader(textColor, secondaryTextColor),
                    ),
                    const SizedBox(height: AppConstants.spacing6),
                    // Profile Photo
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.photoId,
                      builder: (controller) => _buildProfilePhoto(
                        context,
                        controller,
                        isDark,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing6),
                    // Form Fields
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.fullNameId,
                      builder: (controller) => _buildFullNameField(
                        controller,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                        isDark,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.phoneId,
                      builder: (controller) => _buildPhoneField(
                        controller,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.addressId,
                      builder: (controller) => _buildAddressField(
                        controller,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing6),
                    // Action Buttons
                    GetBuilder<ProfileSetupController>(
                      id: ProfileSetupController.buttonId,
                      builder: (controller) => _buildActionButtons(
                        controller,
                        isDark,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    // Security Note
                    _buildSecurityNote(secondaryTextColor),
                    const SizedBox(height: AppConstants.spacing6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    ProfileSetupController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing2,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
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
              'Profile Setup',
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

  Widget _buildHeader(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Text(
          'Complete Your Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
          child: Text(
            'Please provide a few more details for Dr. Pradip Chauhan\'s records.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.body1Size,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(
    BuildContext context,
    ProfileSetupController controller,
    bool isDark,
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
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                  child: controller.avatarUrl != null &&
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
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
          const SizedBox(height: AppConstants.spacing3),
          Text(
            'Upload Photo',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 64,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildFullNameField(
    ProfileSetupController controller,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacing3),
          child: Text(
            'Full Name',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppConstants.spacing4),
              Icon(
                Icons.person,
                color: secondaryTextColor,
                size: AppConstants.iconSizeMedium,
              ),
              const SizedBox(width: AppConstants.spacing3),
              Expanded(
                child: Text(
                  controller.fullName,
                  style: TextStyle(
                    fontSize: AppConstants.body1Size,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing4),
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(
    ProfileSetupController controller,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacing3),
          child: Text(
            'Phone Number',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppConstants.spacing4),
              Icon(
                Icons.call,
                color: AppColors.primary,
                size: AppConstants.iconSizeMedium,
              ),
              const SizedBox(width: AppConstants.spacing3),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: controller.phoneNumber)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.phoneNumber.length),
                    ),
                  onChanged: controller.updatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: AppConstants.body1Size,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: '+1 (555) 000-0000',
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(
    ProfileSetupController controller,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacing3),
          child: Text(
            'Home Address',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: AppConstants.spacing4),
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacing4),
                child: Icon(
                  Icons.home,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppConstants.spacing3),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: controller.address)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.address.length),
                    ),
                  onChanged: controller.updateAddress,
                  maxLines: 4,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: AppConstants.body1Size,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Street, City, Zip Code',
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ProfileSetupController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        // Save & Continue Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.isSaving ? null : controller.onSaveAndContinue,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              height: 56,
              decoration: BoxDecoration(
                color: controller.isSaving
                    ? AppColors.primary.withOpacity(0.6)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                boxShadow: controller.isSaving
                    ? null
                    : [
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
                  if (controller.isSaving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    Text(
                      'Save & Continue',
                      style: TextStyle(
                        fontSize: AppConstants.h4Size,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing2),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        // Skip Button
        TextButton(
          onPressed: controller.onSkip,
          child: Text(
            'Skip for now',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote(Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock,
          size: 16,
          color: AppColors.success,
        ),
        const SizedBox(width: AppConstants.spacing2),
        Text(
          'Your data is secure with Dr. Chauhan',
          style: TextStyle(
            fontSize: AppConstants.captionSize,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

