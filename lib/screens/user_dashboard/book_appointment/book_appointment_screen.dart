import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import 'book_appointment_controller.dart';

class BookAppointmentScreen extends BaseScreenView<BookAppointmentController> {
  const BookAppointmentScreen({super.key});

  static const String bookAppointmentScreen = '/book-appointment';

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
        ? Colors.grey.shade400
        : const Color(0xFF60778a);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, isDark, controller, surfaceColor),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Profile Header
                    GetBuilder<BookAppointmentController>(
                      id: BookAppointmentController.doctorInfoId,
                      builder: (controller) => _buildDoctorProfile(
                        controller,
                        isDark,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                      ),
                    ),
                    // Calendar Picker
                    GetBuilder<BookAppointmentController>(
                      id: BookAppointmentController.calendarId,
                      builder: (controller) => _buildCalendar(
                        controller,
                        isDark,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                      ),
                    ),
                    // Time Slots
                    GetBuilder<BookAppointmentController>(
                      id: BookAppointmentController.timeSlotsId,
                      builder: (controller) => _buildTimeSlots(
                        controller,
                        isDark,
                        textColor,
                        secondaryTextColor,
                      ),
                    ),
                    // Booking Form
                    GetBuilder<BookAppointmentController>(
                      id: BookAppointmentController.bookingFormId,
                      builder: (controller) => _buildBookingForm(
                        controller,
                        isDark,
                        surfaceColor,
                        textColor,
                        secondaryTextColor,
                        borderColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
                    ),
                    // Bottom spacing for fixed footer
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Book Button
      bottomNavigationBar: GetBuilder<BookAppointmentController>(
        id: BookAppointmentController.buttonId,
        builder: (controller) =>
            _buildBookButton(controller, isDark, surfaceColor),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    BookAppointmentController controller,
    Color surfaceColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing3,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.onBack,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Container(
                width: 40,
                height: 40,
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
              'Book Appointment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildDoctorProfile(
    BookAppointmentController controller,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing4),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
            // Avatar
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.grey.shade600 : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        controller.doctorAvatarUrl != null &&
                            controller.doctorAvatarUrl!.isNotEmpty
                        ? Image.network(
                            controller.doctorAvatarUrl!,
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
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? surfaceColor : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppConstants.spacing4),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.doctorName,
                    style: TextStyle(
                      fontSize: AppConstants.h4Size,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    controller.doctorSpecialization,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing1),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(120 Reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
      child: Icon(
        Icons.person,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        size: 32,
      ),
    );
  }

  Widget _buildCalendar(
    BookAppointmentController controller,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing4,
        0,
        AppConstants.spacing4,
        AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: AppConstants.h4Size,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing3,
                  vertical: AppConstants.spacing2,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusCircular,
                  ),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppConstants.spacing2),
                    Text(
                      controller.currentMonthShort,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing2),
          // Calendar
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
                // Month Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.onPreviousMonth,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      controller.currentMonthDisplay,
                      style: TextStyle(
                        fontSize: AppConstants.body1Size,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.onNextMonth,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing4),
                // Calendar Grid
                _buildCalendarGrid(
                  controller,
                  isDark,
                  textColor,
                  secondaryTextColor,
                ),
                const SizedBox(height: AppConstants.spacing4),
                // Legend
                _buildCalendarLegend(isDark, secondaryTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BookAppointmentController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final firstDayOfMonth = DateTime(
      controller.currentMonth.year,
      controller.currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      controller.currentMonth.year,
      controller.currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    // Weekday headers
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Weekday headers
        Row(
          children: weekdays.map((day) {
            return Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spacing2),
        // Days grid
        ...List.generate((firstWeekday + daysInMonth + 6) ~/ 7, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(
                controller.currentMonth.year,
                controller.currentMonth.month,
                dayNumber,
              );
              final isSelected = controller.isDateSelected(date);
              final isDisabled = controller.isDateDisabled(date);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isDisabled
                          ? null
                          : () => controller.onDateSelected(date),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isDisabled
                                ? secondaryTextColor.withOpacity(0.5)
                                : isSelected
                                ? Colors.white
                                : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarLegend(bool isDark, Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primary, 'Selected', secondaryTextColor),
        const SizedBox(width: AppConstants.spacing6),
        _buildLegendItem(
          isDark ? Colors.white : const Color(0xFF111518),
          'Available',
          secondaryTextColor,
        ),
        const SizedBox(width: AppConstants.spacing6),
        _buildLegendItem(
          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          'Disabled',
          secondaryTextColor,
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppConstants.spacing2),
        Text(label, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }

  Widget _buildTimeSlots(
    BookAppointmentController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    if (controller.isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.all(AppConstants.spacing4),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final timeSlots = controller.getTimeSlotsForDate();
    if (timeSlots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacing4),
        child: Center(
          child: Text(
            'No available time slots for this date',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: AppConstants.body2Size,
            ),
          ),
        ),
      );
    }

    // Group slots by time of day
    final morningSlots = <DateTime>[];
    final afternoonSlots = <DateTime>[];
    final eveningSlots = <DateTime>[];

    for (final slot in timeSlots) {
      if (slot.hour < 12) {
        morningSlots.add(slot);
      } else if (slot.hour < 17) {
        afternoonSlots.add(slot);
      } else {
        eveningSlots.add(slot);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Time',
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          // Morning slots
          if (morningSlots.isNotEmpty) ...[
            _buildTimeSlotSection(
              'Morning',
              Icons.wb_sunny,
              morningSlots,
              controller,
              isDark,
              textColor,
              secondaryTextColor,
            ),
            const SizedBox(height: AppConstants.spacing4),
          ],
          // Afternoon slots
          if (afternoonSlots.isNotEmpty) ...[
            _buildTimeSlotSection(
              'Afternoon',
              Icons.wb_twilight,
              afternoonSlots,
              controller,
              isDark,
              textColor,
              secondaryTextColor,
            ),
            const SizedBox(height: AppConstants.spacing4),
          ],
          // Evening slots
          if (eveningSlots.isNotEmpty)
            _buildTimeSlotSection(
              'Evening',
              Icons.nightlight,
              eveningSlots,
              controller,
              isDark,
              textColor,
              secondaryTextColor,
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection(
    String title,
    IconData icon,
    List<DateTime> slots,
    BookAppointmentController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: secondaryTextColor),
            const SizedBox(width: AppConstants.spacing2),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing3),
        Wrap(
          spacing: AppConstants.spacing3,
          runSpacing: AppConstants.spacing3,
          children: slots.map((slot) {
            final isSelected = controller.isTimeSlotSelected(slot);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.onTimeSlotSelected(slot),
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular,
                ),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200),
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: isSelected ? Colors.white : secondaryTextColor,
                      ),
                      const SizedBox(width: AppConstants.spacing2),
                      Text(
                        controller.formatTime(slot),
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingForm(
    BookAppointmentController controller,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor, {
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking For Section
          Text(
            'Booking For',
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing3),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBookingOption(
                    'For Myself',
                    'self',
                    controller.bookedFor == 'self',
                    controller,
                    isDark,
                    textColor,
                    secondaryTextColor,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing3),
                Expanded(
                  child: _buildBookingOption(
                    'For Someone Else',
                    'other',
                    controller.bookedFor == 'other',
                    controller,
                    isDark,
                    textColor,
                    secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          // Other Person Details (if booking for other)
          if (controller.isBookingForOther) ...[
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'Person Details',
              style: TextStyle(
                fontSize: AppConstants.h4Size,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacing3),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildFormTextField(
                    label: 'Full Name',
                    controller: controller.otherPersonNameController,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    borderColor: borderColor,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _buildFormTextField(
                    label: 'Phone Number',
                    controller: controller.otherPersonPhoneController,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    borderColor: borderColor,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  _buildFormTextField(
                    label: 'Age (Optional)',
                    controller: controller.otherPersonAgeController,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    borderColor: borderColor,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
          // Reason Section
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Reason for Appointment',
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller.reasonController,
              maxLines: 3,
              minLines: 2,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: AppConstants.body1Size,
                color: textColor,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: 'e.g., Back Pain Therapy, Initial Assessment',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOption(
    String label,
    String value,
    bool isSelected,
    BookAppointmentController controller,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.onBookedForChanged(value),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacing3,
            horizontal: AppConstants.spacing4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTextField({
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
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton(
    BookAppointmentController controller,
    bool isDark,
    Color surfaceColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.canBook ? controller.onBookAppointment : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            height: 48,
            decoration: BoxDecoration(
              color: controller.canBook
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              boxShadow: controller.canBook
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: controller.isBooking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: AppConstants.body1Size,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing2),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
