import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/patients_repository.dart';
import '../../../data/models/patient_display.dart';

class PatientManagementController extends BaseController {
  static const String contentId = 'patients_content';
  static const String searchId = 'patients_search';
  static const String listId = 'patients_list';
  static const String paginationId = 'patients_pagination';

  final PatientsRepository _patientsRepository;

  PatientManagementController(this._patientsRepository);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Search state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Pagination state
  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _totalPatients = 0;
  int get totalPatients => _totalPatients;
  static const int _pageSize = 10;
  int get totalPages => (_totalPatients / _pageSize).ceil();
  bool get hasMorePages => _currentPage < totalPages;

  // Patients list
  List<PatientDisplay> _patients = [];
  List<PatientDisplay> get patients => _patients;

  /// Load patients from Supabase
  Future<void> loadPatients({bool showLoading = true}) async {
    await handleAsyncOperation(() async {
      if (showLoading) {
        _isLoading = true;
        update([contentId]);
      }

      try {
        // Get total count
        _totalPatients = await _patientsRepository.getPatientsCount(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );

        // Get patients for current page
        final fetchedPatients = await _patientsRepository.getPatients(
          page: _currentPage,
          limit: _pageSize,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );

        _patients = fetchedPatients;
        update([listId, paginationId]);
      } finally {
        if (showLoading) {
          _isLoading = false;
          update([contentId]);
        }
      }
    }, showLoadingIndicator: false);
    update([listId, paginationId]);
  }

  /// Refresh patients (for pull-to-refresh)
  Future<void> refreshPatients() async {
    await loadPatients(showLoading: false);
  }

  /// Update search query and reload
  void onSearchChanged(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _currentPage = 1; // Reset to first page on search
      update([searchId]);
      loadPatients();
    }
  }

  /// Navigate to next page
  Future<void> onNextPage() async {
    if (hasMorePages) {
      _currentPage++;
      await loadPatients();
    }
  }

  /// Navigate to previous page
  Future<void> onPreviousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await loadPatients();
    }
  }

  /// Navigate to specific page
  Future<void> onPageTap(int page) async {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      await loadPatients();
    }
  }

  /// Get page numbers to display in pagination
  List<int?> getPageNumbers() {
    final pages = <int?>[];
    final total = totalPages;

    if (total <= 7) {
      // Show all pages if 7 or fewer
      for (int i = 1; i <= total; i++) {
        pages.add(i);
      }
    } else {
      // Show first page
      pages.add(1);

      if (_currentPage <= 3) {
        // Near the start
        for (int i = 2; i <= 4; i++) {
          pages.add(i);
        }
        pages.add(null); // Ellipsis
        pages.add(total);
      } else if (_currentPage >= total - 2) {
        // Near the end
        pages.add(null); // Ellipsis
        for (int i = total - 3; i <= total; i++) {
          pages.add(i);
        }
      } else {
        // In the middle
        pages.add(null); // Ellipsis
        for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
          pages.add(i);
        }
        pages.add(null); // Ellipsis
        pages.add(total);
      }
    }

    return pages;
  }

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadPatients();
    }
  }
}
