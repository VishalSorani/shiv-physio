import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'add_edit_patient_controller.dart';

class AddEditPatientScreen extends BaseScreenView<AddEditPatientController> {
  const AddEditPatientScreen({super.key});

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
        title: controller.isEditing ? 'Edit Patient' : 'Add Patient',
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
      ),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<AddEditPatientController>(
          id: AddEditPatientController.formId,
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacing4),
                  _buildTextField(
                    'Full Name *',
                    controller.fullNameController,
                    'Enter patient full name',
                    isDark,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _buildTextField(
                    'Email',
                    controller.emailController,
                    'Enter email address (optional)',
                    isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _buildTextField(
                    'Phone',
                    controller.phoneController,
                    'Enter phone number (optional)',
                    isDark,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Age',
                          controller.ageController,
                          'Age',
                          isDark,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Expanded(
                        child: _buildGenderDropdown(
                          controller,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _buildTextField(
                    'Address',
                    controller.addressController,
                    'Enter address (optional)',
                    isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              try {
                                await controller.savePatient();
                                if (context.mounted) {
                                  Get.back(result: true); // Return true to indicate success
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst('Exception: ', ''),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusLarge,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              controller.isEditing ? 'Update Patient' : 'Create Patient',
                              style: const TextStyle(
                                fontSize: AppConstants.body1Size,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                ],
              ),
            );
          },
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(
    AddEditPatientController controller,
    bool isDark,
  ) {
    final genders = ['male', 'female', 'other'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
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
            value: controller.selectedGender,
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
            hint: Text(
              'Select gender',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
            items: genders.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(
                  gender[0].toUpperCase() + gender.substring(1),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.setGender(value);
            },
          ),
        ),
      ],
    );
  }
}

