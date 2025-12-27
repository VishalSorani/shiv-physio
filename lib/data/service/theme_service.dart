import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/data/clients/storage/storage_provider.dart';

/// Service responsible for managing and persisting the app theme.
/// Uses [StorageProvider] for persistence and [Get] to apply the theme at runtime.
class ThemeService {
  ThemeService(this._storageProvider);

  final StorageProvider _storageProvider;

  static const String _themeModeKey = '@theme_mode';

  /// Returns the current [ThemeMode] from storage. Defaults to light.
  ThemeMode get themeMode {
    final stored = _storageProvider.read<String>(_themeModeKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  /// Returns true if current theme is dark.
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Toggle theme and persist the choice.
  Future<void> toggleTheme() async {
    final nextIsDark = !isDarkMode;
    await setDarkMode(nextIsDark);
  }

  /// Set dark mode on/off, persist and apply immediately.
  Future<void> setDarkMode(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storageProvider.write<String>(
      _themeModeKey,
      isDark ? 'dark' : 'light',
    );
    Get.changeThemeMode(mode);
  }
}
