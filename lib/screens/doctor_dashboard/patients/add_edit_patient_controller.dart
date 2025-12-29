import 'package:flutter/material.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/patients_repository.dart';
import '../../../data/models/user.dart' as app_models;

class AddEditPatientController extends BaseController {
  static const String formId = 'patient_form';

  final PatientsRepository _patientsRepository;
  final app_models.User? existingPatient;

  AddEditPatientController(this._patientsRepository, {this.existingPatient});

  // Form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;

  // Getters
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get ageController => _ageController;
  TextEditingController get addressController => _addressController;
  String? get selectedGender => _selectedGender;

  bool get isEditing => existingPatient != null;

  @override
  void onInit() {
    super.onInit();
    if (existingPatient != null) {
      _fullNameController.text = existingPatient!.fullName ?? '';
      _emailController.text = existingPatient!.email ?? '';
      _phoneController.text = existingPatient!.phone ?? '';
      _ageController.text = existingPatient!.age?.toString() ?? '';
      _addressController.text = existingPatient!.address ?? '';
      _selectedGender = existingPatient!.gender;
      update([formId]);
    }
  }

  @override
  void onClose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.onClose();
  }

  void setGender(String? gender) {
    _selectedGender = gender;
    update([formId]);
  }

  Future<void> savePatient() async {
    if (_fullNameController.text.trim().isEmpty) {
      throw Exception('Full name is required');
    }

    await handleAsyncOperation(() async {
      if (isEditing) {
        await _patientsRepository.updatePatient(
          patientId: existingPatient!.id,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          age: _ageController.text.trim().isEmpty
              ? null
              : int.tryParse(_ageController.text.trim()),
          gender: _selectedGender,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        );
      } else {
        await _patientsRepository.createPatient(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          age: _ageController.text.trim().isEmpty
              ? null
              : int.tryParse(_ageController.text.trim()),
          gender: _selectedGender,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        );
      }
    });
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
