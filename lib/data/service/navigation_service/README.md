# Navigation Service

A centralized service for handling navigation in the Digilex mobile application.

## Overview

The Navigation Service provides a clean, type-safe way to handle navigation throughout the application. It encapsulates all navigation logic, making it easier to maintain and update navigation patterns.

## Key Features

- 🔒 **Encapsulated Navigation Logic**: All navigation is handled through the NavigationService
- 🏷️ **Type-Safe Navigation**: Specific methods for each route with proper parameters
- 📝 **Comprehensive Logging**: All navigation actions are logged for debugging
- 🔄 **Consistent Navigation Patterns**: Standardized approach to navigation

## Usage

### Basic Navigation

Instead of using direct Get navigation methods like `Get.toNamed()`, use the NavigationService:

```dart
// Before (not recommended)
Get.toNamed(kLoginRoute);

// After (recommended)
navigationService.navigateToLogin();
```

### Navigation with Parameters

For routes that require parameters:

```dart
// Before (not recommended)
Get.toNamed(kConsultantprofileRoute, arguments: user);

// After (recommended)
navigationService.navigateToConsultantProfile(user: user);
```

### Navigation with Callbacks

For routes that need to execute code after navigation:

```dart
// Before (not recommended)
await Get.toNamed(kProfileEditRoute);
someCallback();

// After (recommended)
navigationService.navigateToProfileEdit(() {
  // Callback code here
});
```

## Navigation Categories

The NavigationService organizes navigation methods into logical categories:

### Authentication Navigation
- `navigateToLogin()`
- `navigateToSignup()`
- `navigateToPhoneLogin()`
- `navigateToOtpVerification()`
- `navigateToForgotPassword()`
- `navigateToOnboarding()`

### Profile Navigation
- `navigateToProfileSetup()`
- `navigateToConsultantProfileSetup()`
- `navigateToClientProfileSetup()`
- `navigateToProfileSetupSelectPlan()`
- `navigateToProfilePreview()`
- `navigateToProfileEdit()`
- `navigateToMyProfile()`
- `navigateToConsultantProfile()`

### Appointment Navigation
- `navigateToConsultantBooking()`
- `navigateToBookingCompleted()`
- `navigateToAppointmentDetail()`

### Chat Navigation
- `navigateToChat()`
- `navigateToConversation()`

### Dashboard Navigation
- `navigateToDashboard()`
- `navigateToHome()`
- `navigateToSchedule()`
- `navigateToMyAppointments()`
- `navigateToAccount()`
- `navigateToNotification()`

### Media Navigation
- `navigateToViewImageOrDoc()`


## Best Practices

1. **Always use the NavigationService**: Never use direct Get navigation methods
2. **Use specific navigation methods**: Use the dedicated methods instead of generic ones
3. **Keep navigation logic in controllers**: Don't put navigation logic in views
4. **Log navigation actions**: Use the logger method for debugging
5. **Handle navigation errors**: Use try-catch blocks when navigating

## Implementation Details

The NavigationService uses private methods for the actual navigation:

- `_navigateTo()`: Navigate to a new screen
- `_navigateToAndRemove()`: Navigate to a new screen and remove the previous screen
- `_navigateToAndRemoveUntil()`: Navigate to a new screen and remove all previous screens

These methods are used by the public navigation methods to provide a clean API.

## Adding New Routes

When adding a new route to the application:

1. Define the route constant in the appropriate screen file
2. Add the screen import to `navigation_import.dart`
3. Create a new navigation method in the NavigationService
4. Update this README with the new method

## Example

```dart
// In a controller
class MyController extends GetxController {
  final NavigationService navigationService = Get.find<NavigationService>();
  
  void onButtonPressed() {
    navigationService.navigateToDashboard();
  }
}
``` 