import '../../../core/constants/app_colors.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/service/storage_service.dart';

class HomeController extends BaseController {
  static const String contentId = 'home_content';

  final StorageService _storageService;

  HomeController(this._storageService);

  // User info
  String? get userName => _storageService.getUser()?.fullName;
  String? get avatarUrl => _storageService.getUser()?.avatarUrl;

  // Upcoming appointment data (placeholder - will be fetched from repository)
  String get upcomingAppointmentTitle => 'Physiotherapy Session';
  String get upcomingDoctorName => 'Dr. Pradip Chauhan';
  String get upcomingDoctorSpecialization => 'Senior Physiotherapist';
  String? get upcomingDoctorAvatarUrl =>
      null; // TODO: Fetch from appointment data
  String get upcomingTime => '10:00 AM';
  String get upcomingDate => 'Today, 24 Oct';

  // Clinic highlights (placeholder - will be fetched from repository)
  List<Map<String, dynamic>> get clinicHighlights => [
    {
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCcWGpQsqJ90H8dqQVjiUSiw5TeGSdxvHpSne1U-pm39eine9V0u2u8OUxl3nHali973FTU_FACeBgvOtxu_lsInm2bpl5iWjJqun5XHTSXQw_IxYSRALgmmAlY7nSbeopTkM2GG1mm3MBdbCwr99GiCTHCByZYbRvO8ci0RPxUiNTD-eOD99OzMgZcCoCFDHmbW9xUn1bPQuTgq7ZOlTBGPc2-XigN96DoPC42j2e4t2fmgK8noySMDcdcrpFvDC4G5lE_qOJ_0Cc',
      'title': 'Advanced Laser Therapy Now Available',
      'badge': 'New',
      'badgeColor': null, // Uses primary color
    },
    {
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAhE_-Mk4HUHU_FlbfjDMbKp5qs70-IGUpzU9aNubr0LZg0j7hY5HhzmjlhrGNWLTo4z2wqr80uvhq38Rv3NaZJ8svMeizaSR5d7xassofh6awkieF4CyKmaw4Lw5zRViCXLWPXgUn0DWee7dy64N4Ew0edwXH0wsPZNHVK-0j_Z7M_20GhfXj2mHcDP9AUV5XpluQY9n1xPm-32jcptVA3p9yjiiF0nqp5YDePrGDxmK8yoVy_Rb3jN1DADBTwHxOXBuxwB6ze0_s',
      'title': 'Free Workshop: Posture Correction',
      'badge': 'Event',
      'badgeColor': AppColors.warning, // Orange
    },
  ];

  // Recovery items (placeholder - will be fetched from repository)
  List<Map<String, dynamic>> get recoveryItems => [
    {
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDAxPsY4_WljidglTCfeOMhyYFghHsbWb6llX833QBD9Aco09ZqcUhKs6HRHjsb0zYJhiyelCNzTAZME3Qr_9F0H32F0frGwh2lVbMMUzy5c4rVDU_t-DNPQXCMB0bL9IvR_yv_eIpmnJ1GZR1QfFDAi96Ps7abB-SNDUXAAuB7pvqspjmER-eYsfU6EyUTGZ_VG0ZeiZ1GXq4Ui2ogLhNoLG9opX7g7jI5Op4ajSBeMdaqD8AUGbq-XLLX7yn4w7k82PL7q8c7ar0',
      'title': 'Lower Back Stretches',
      'type': 'Video',
      'duration': '5 min',
      'hasPlayButton': true,
    },
    {
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWbx_xFkJgZoPvV3ODXzeUrDsVhYkfLWCjr9nUt1C8pRoQ0s2pnqk6qiXo85lCaOvovQ17X0k2fRGbhfju6f0k2voNLk9pyLoblOEvOvp21DibTkTQH99_r5RtOpAt0PxVmy7A_efX0uH_ZEICpQARqsjqnqAhLmvRZYiOlnLI6dC7CCbY8txNB1kmcsjMTFC7H2TMakvUKpy1mVYZXDsBVOKrIhEVbqfzKwcRUY8LrRcONpzzgq5l5QUud8k39XU6s8J7BLgx_V0',
      'title': 'Post-Session Ice Pack Guide',
      'type': 'Article',
      'duration': '3 min read',
      'hasPlayButton': false,
    },
  ];

  void onNotificationTap() {
    // TODO: Navigate to notifications
  }

  void onProfileTap() {
    // TODO: Navigate to profile
  }

  void onAppointmentTap() {
    // TODO: Navigate to appointment details
  }

  void onRescheduleTap() {
    // TODO: Navigate to reschedule
  }

  void onBookTap() {
    // TODO: Navigate to booking
  }

  void onHistoryTap() {
    // TODO: Navigate to appointment history
  }

  void onChatTap() {
    // TODO: Navigate to chat
  }

  void onSeeAllHighlightsTap() {
    // TODO: Navigate to all highlights
  }

  void onHighlightTap(int index) {
    // TODO: Navigate to highlight details
  }

  void onRecoveryItemTap(int index) {
    // TODO: Navigate to recovery item details
  }

  @override
  void onInit() {
    super.onInit();
    // TODO: Load user data and appointments
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
