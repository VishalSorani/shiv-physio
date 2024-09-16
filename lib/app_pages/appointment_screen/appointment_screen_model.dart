import '/compoments/bottom_navigation_component/bottom_navigation_component_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'appointment_screen_widget.dart' show AppointmentScreenWidget;
import 'package:flutter/material.dart';

class AppointmentScreenModel extends FlutterFlowModel<AppointmentScreenWidget> {
  ///  Local state fields for this page.

  List<String> timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM'
  ];
  void addToTimeSlots(String item) => timeSlots.add(item);
  void removeFromTimeSlots(String item) => timeSlots.remove(item);
  void removeAtIndexFromTimeSlots(int index) => timeSlots.removeAt(index);
  void insertAtIndexInTimeSlots(int index, String item) =>
      timeSlots.insert(index, item);
  void updateTimeSlotsAtIndex(int index, Function(String) updateFn) =>
      timeSlots[index] = updateFn(timeSlots[index]);

  List<String> appointmentDetails = [
    'Initial Consultation',
    'Follow-up',
    'Therapy Session',
    'Assessment'
  ];
  void addToAppointmentDetails(String item) => appointmentDetails.add(item);
  void removeFromAppointmentDetails(String item) =>
      appointmentDetails.remove(item);
  void removeAtIndexFromAppointmentDetails(int index) =>
      appointmentDetails.removeAt(index);
  void insertAtIndexInAppointmentDetails(int index, String item) =>
      appointmentDetails.insert(index, item);
  void updateAppointmentDetailsAtIndex(int index, Function(String) updateFn) =>
      appointmentDetails[index] = updateFn(appointmentDetails[index]);

  DateTime? selectedDate;

  int? selectedSlot;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;
  // State field(s) for AppointmentTypeDropDown widget.
  String? appointmentTypeDropDownValue;
  FormFieldController<String>? appointmentTypeDropDownValueController;
  // State field(s) for ReasonTextField widget.
  FocusNode? reasonTextFieldFocusNode;
  TextEditingController? reasonTextFieldTextController;
  String? Function(BuildContext, String?)?
      reasonTextFieldTextControllerValidator;
  String? _reasonTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Required Field';
    }

    return null;
  }

  // State field(s) for OtherTextField widget.
  FocusNode? otherTextFieldFocusNode;
  TextEditingController? otherTextFieldTextController;
  String? Function(BuildContext, String?)?
      otherTextFieldTextControllerValidator;
  // Model for BottomNavigationComponent component.
  late BottomNavigationComponentModel bottomNavigationComponentModel;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
    reasonTextFieldTextControllerValidator =
        _reasonTextFieldTextControllerValidator;
    bottomNavigationComponentModel =
        createModel(context, () => BottomNavigationComponentModel());
  }

  @override
  void dispose() {
    reasonTextFieldFocusNode?.dispose();
    reasonTextFieldTextController?.dispose();

    otherTextFieldFocusNode?.dispose();
    otherTextFieldTextController?.dispose();

    bottomNavigationComponentModel.dispose();
  }
}
