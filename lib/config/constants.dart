class Constants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://brftthatozftxdybxxtd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJyZnR0aGF0b3pmdHhkeWJ4eHRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODEyNTEsImV4cCI6MjA2NDI1NzI1MX0.Ysqjez-e8M8iQHauS5ivNIAMhxk0rYC2C5rkwgp0ld0';

  // API Endpoints
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';

  // App Settings
  static const String appName = 'SafeNest';
  static const String appVersion = '1.0.0';
  
  // Location Settings
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  static const int locationUpdateInterval = 30; // seconds
  
  // SOS Settings
  static const int sosTimeout = 300; // 5 minutes in seconds
  static const int maxEmergencyContacts = 5;
  
  // Map Settings
  static const double defaultMapZoom = 15.0;
  static const int dangerZoneRadius = 100; // meters
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userProfileKey = 'user_profile';
  static const String emergencyContactsKey = 'emergency_contacts';
  static const String lastLocationKey = 'last_location';
  static const String isFirstRunKey = 'is_first_run';
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String locationError = 'Unable to access location. Please enable location services.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success Messages
  static const String sosSent = 'SOS alert sent successfully!';
  static const String locationShared = 'Location shared successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  
  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordMismatch = 'Passwords do not match';
  static const String passwordLength = 'Password must be at least 8 characters';
} 