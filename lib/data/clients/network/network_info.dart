import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/widgets/app_snackbar.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectivityResult> get onConnectivityChanged;
  Future<void> initialize();
}

class NetworkInfoImpl extends GetxService implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  Future<void> initialize() async {
    // Register connectivity changed listener
    _connectivity.onConnectivityChanged.listen((result) {
      if (result.first == ConnectivityResult.none) {
        AppSnackBar.warning(
          message: 'No Internet Connection',
          title: 'Please check your connection and try again.',
        );
      }
    });
  }

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return (connectivityResult).first != ConnectivityResult.none;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.expand((list) => list);
}
