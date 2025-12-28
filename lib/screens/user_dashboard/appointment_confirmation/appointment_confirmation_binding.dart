import 'package:get/get.dart';
import 'package:shiv_physio_app/data/models/appointment.dart';
import 'package:shiv_physio_app/data/modules/appointments_repository.dart';
import 'package:shiv_physio_app/data/service/storage_service.dart';
import 'appointment_confirmation_controller.dart';

class AppointmentConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    final appointment = Get.arguments as Appointment?;
    if (appointment != null) {
      Get.lazyPut<AppointmentConfirmationController>(
        () => AppointmentConfirmationController(
          Get.find<StorageService>(),
          Get.find<AppointmentsRepository>(),
          appointment,
        ),
      );
    }
  }
}

