import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/data/clients/network/network_info.dart';

import '../clients/network/backend/error_handling/network_error_constants.dart';
import '../clients/network/backend/exceptions/network_exception.dart';

class NetworkService extends GetxService {
  final NetworkInfo networkInfo;
  bool _isDialogOpen = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final _isConnected = true.obs;
  final List<Function(bool)> _connectivityCallbacks = [];

  bool get isConnectedValue => _isConnected.value;
  Stream<bool> get onConnectionChanged => _isConnected.stream;

  /// Register a callback to be called when internet connectivity changes
  /// [callback] will be called immediately with the current connectivity state
  /// and whenever the connectivity state changes
  void addConnectivityListener(Function(bool isConnected) callback) async {
    if (!_connectivityCallbacks.contains(callback)) {
      _connectivityCallbacks.add(callback);
      // Perform a double-check to avoid false negatives during app start
      bool isConnected = await checkInternetConnectionPing();
      if (!isConnected) {
        await Future.delayed(const Duration(milliseconds: 1200));
        isConnected = await checkInternetConnectionPing();
      }
      // Only call the callback if it hasn't been removed in the meantime
      if (_connectivityCallbacks.contains(callback)) {
        callback(isConnected);
      }
    }
  }

  /// Remove a previously registered callback
  void removeConnectivityListener(Function(bool) callback) {
    _connectivityCallbacks.remove(callback);
  }

  NetworkService({required this.networkInfo});

  @override
  void onInit() {
    super.onInit();
    initialize();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<bool> get isConnected => networkInfo.isConnected;

  Stream<ConnectivityResult> get onConnectivityChanged =>
      networkInfo.onConnectivityChanged;

  Future<void> initialize() => networkInfo.initialize();

  Future<void> checkInternetConnection() async {
    bool hasConnection = await networkInfo.isConnected;
    if (!hasConnection) {
      // Allow radios/DNS to warm up, then double-check before erroring out
      await Future.delayed(const Duration(milliseconds: 600));
      hasConnection = await checkInternetConnectionPing();
    } else {
      // Verify actual internet reachability to avoid stale states
      hasConnection = await checkInternetConnectionPing();
    }

    if (!hasConnection) {
      throw NetworkException.fromNetworkException(
        NetworkException(
          code: NetworkErrorCode.noInternet,
          message: NetworkErrorMessage.noInternet,
        ),
      );
    }
  }

  // Check internet connection ping to google
  Future<bool> checkInternetConnectionPing() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw SocketException('Connection timeout'),
      );
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _isConnected.value = isConnected;
      return isConnected;
    } catch (e) {
      _isConnected.value = false;
      return false;
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      result,
    ) async {
      if (result == ConnectivityResult.none) {
        // Double-check with a short delay to avoid false negatives on app start
        await Future.delayed(const Duration(milliseconds: 800));
        final hasInternet = await checkInternetConnectionPing();
        _isConnected.value = hasInternet;
      } else {
        // Brief delay to allow radios/DNS to warm up, then verify via ping
        await Future.delayed(const Duration(milliseconds: 300));
        await checkInternetConnectionPing();
      }
      // Notify all registered callbacks
      _notifyConnectivityChange(_isConnected.value);
    });
  }

  void _notifyConnectivityChange(bool isConnected) {
    for (final callback in List<Function(bool)>.from(_connectivityCallbacks)) {
      try {
        callback(isConnected);
      } catch (e) {
        // Handle any errors in callbacks to prevent breaking the notification chain
        log('Error in connectivity callback: $e');
      }
    }
  }

  Future<void> _showOrDismissDialog() async {
    if (!_isConnected.value && !_isDialogOpen) {
      await _showNoInternetDialog();
    } else if (_isConnected.value && _isDialogOpen) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _isDialogOpen = false;
    }
  }

  Future<void> _showNoInternetDialog() async {
    if (_isDialogOpen) return;

    _isDialogOpen = true;

    await Get.dialog(
      // ignore: deprecated_member_use
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text(
            'No Internet Connection',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Please check your internet connection and try again. Make sure you are connected to the internet and try again.',
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                _isDialogOpen = false;
                Get.back();
                // Small delay to allow dialog to close before showing again if needed
                await Future.delayed(const Duration(milliseconds: 300));
                final hasConnection = await checkInternetConnectionPing();
                if (!hasConnection) {
                  _isDialogOpen =
                      false; // Reset the flag to allow showing dialog again
                  _showOrDismissDialog();
                }
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    _isDialogOpen = false;
  }
}
