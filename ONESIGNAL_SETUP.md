# OneSignal Configuration Setup

This app uses environment variables to securely store OneSignal credentials.

## Required Environment Variables

- `ONESIGNAL_APP_ID`: Your OneSignal App ID
- `ONESIGNAL_REST_API_KEY`: Your OneSignal REST API Key

## How to Set Environment Variables

### Option 1: Using --dart-define flags (Recommended)

When running the app:
```bash
flutter run --dart-define=ONESIGNAL_APP_ID=your_app_id --dart-define=ONESIGNAL_REST_API_KEY=your_api_key
```

When building for production:
```bash
# Android
flutter build apk --dart-define=ONESIGNAL_APP_ID=your_app_id --dart-define=ONESIGNAL_REST_API_KEY=your_api_key

# iOS
flutter build ios --dart-define=ONESIGNAL_APP_ID=your_app_id --dart-define=ONESIGNAL_REST_API_KEY=your_api_key
```

### Option 2: Using VS Code Launch Configuration

Add to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "dart-define": {
        "ONESIGNAL_APP_ID": "your_app_id",
        "ONESIGNAL_REST_API_KEY": "your_api_key"
      }
    }
  ]
}
```

### Option 3: Using Android Studio Run Configuration

1. Go to Run > Edit Configurations
2. Add to "Additional run args":
```
--dart-define=ONESIGNAL_APP_ID=your_app_id --dart-define=ONESIGNAL_REST_API_KEY=your_api_key
```

## Getting Your OneSignal Credentials

1. **App ID**: 
   - Go to OneSignal Dashboard
   - Settings > Keys & IDs
   - Copy the "App ID"

2. **REST API Key**:
   - Go to OneSignal Dashboard
   - Settings > Keys & IDs
   - Copy the "REST API Key"

## Security Notes

- Never commit these values to version control
- Use different keys for development and production
- Consider using a CI/CD pipeline to inject these values during build
