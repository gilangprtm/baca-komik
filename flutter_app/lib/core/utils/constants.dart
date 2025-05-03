class Constants {
  // App info
  static const String appName = 'BacaKomik';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String readingDirectionKey = 'reading_direction';
  
  // Default values
  static const int defaultPageSize = 20;
  static const String defaultAvatarUrl = 'https://ui-avatars.com/api/?name=User&background=random';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection and try again.';
  static const String generalErrorMessage = 'Something went wrong. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
}
