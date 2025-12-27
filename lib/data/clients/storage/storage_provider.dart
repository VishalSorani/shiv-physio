/// Abstract class defining the storage interface for the application.
/// This interface provides a contract for implementing different storage solutions
/// while maintaining a consistent API across the application.
abstract class StorageProvider {
  /// Writes a value to storage with the specified key.
  /// 
  /// [key] - The unique identifier for the stored value
  /// [value] - The value to store, can be of any type T
  /// Returns a Future that completes when the write operation is finished
  Future<void> write<T>(String key, T value);

  /// Reads a value from storage using the specified key.
  /// 
  /// [key] - The unique identifier for the stored value
  /// Returns the stored value of type T, or null if not found
  T? read<T>(String key);

  /// Deletes a value from storage using the specified key.
  /// 
  /// [key] - The unique identifier for the value to delete
  /// Returns a Future that completes when the delete operation is finished
  Future<void> delete(String key);

  /// Clears all stored values from storage.
  /// 
  /// Returns a Future that completes when all values have been cleared
  Future<void> clear();
}