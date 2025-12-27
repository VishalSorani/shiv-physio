abstract class DeviceInfoProvider {
  Future<String> getDeviceId();
  Future<String> getDeviceModel();
  Future<String> getDeviceOsVersion();
  Future<Map<String, dynamic>> getAllDeviceInfo();
  Future<String> getAppVersion();
  Future<bool> isPhysicalDevice();
  Future<String> getDevicePlatform();
}
