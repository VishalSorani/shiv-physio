/// Supabase configuration.
///
/// Fill these values from your Supabase Project Settings:
/// - Project URL
/// - Project API Key (anon/public)
///
/// For production, you may want to load these via `--dart-define` or a secure
/// remote config instead of hardcoding.
class SupabaseConfig {
  SupabaseConfig._();

  /// Example: `https://xxxxxxxxxxxxxxxxxxxx.supabase.co`
  static const String url = 'https://ygzzqzuajrgpvrjcmqmf.supabase.co';

  /// Supabase anon key (public).
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlnenpxenVhanJncHZyamNtcW1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4MTI0MjIsImV4cCI6MjA4MjM4ODQyMn0.qR3pHOU9cyaHnxnSqRunq7SpsXy5Gx-NDW_sQEmCbB4';

  /// Deep-link callback hostname used by `supabase_flutter` OAuth flow.
  /// We recommend keeping this stable.
  static const String authCallbackUrlHostname = 'login-callback';

  /// Redirect URL used for OAuth on mobile. With Android package `com.shivphysio.app`,
  /// a good default is:
  /// `com.shivphysio.app://login-callback`
  ///
  /// If you change your app id, update this too.
  static const String redirectUrl = 'com.shivphysio.app://login-callback';
}
