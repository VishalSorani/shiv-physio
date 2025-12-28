import 'package:get/get.dart';
import 'package:shiv_physio_app/data/modules/appointments_repository.dart';
import 'book_appointment_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(
        Get.find<AppointmentsRepository>(),
      ),
    );
  }
}

