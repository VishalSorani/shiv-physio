# Storage Module

This module provides a storage abstraction layer for the Digilex mobile application. It implements a flexible storage solution using the GetStorage package.

## Overview

The storage module consists of two main components:

1. `StorageProvider` - An abstract class defining the storage interface
2. `GetxStorage` - A concrete implementation using GetStorage

## Features

- Type-safe storage operations
- Key-value based storage
- Support for different data types
- Asynchronous operations
- Clear and delete functionality

## Usage

```dart
// Initialize storage
final storage = GetxStorage();

// Write data
await storage.write('user_id', '12345');
await storage.write('settings', {'theme': 'dark'});

// Read data
final userId = storage.read<String>('user_id');
final settings = storage.read<Map<String, dynamic>>('settings');

// Delete specific key
await storage.delete('user_id');

// Clear all data
await storage.clear();
```

## Implementation Details

The storage module uses GetStorage as the underlying storage mechanism, which provides:
- Persistent storage across app restarts
- Efficient key-value storage
- Type safety through generics
- Asynchronous operations for better performance

## Error Handling

The implementation includes basic error handling and logging capabilities. Failed operations are logged for debugging purposes. 