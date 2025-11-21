class AppConstants {
  static const String appName = 'Đoàn - Hội App';
  static const String appVersion = '1.0.0';
  
  // Cache keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyEventsCache = 'events_cache';
  static const String keyNotificationsCache = 'notifications_cache';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxCacheAge = 3600; // 1 hour in seconds
  
  // Event status
  static const String eventUpcoming = 'upcoming';
  static const String eventOngoing = 'ongoing';
  static const String eventCompleted = 'completed';
  
  // Notification types
  static const String notifEventRegistration = 'event_registration';
  static const String notifEventCancellation = 'event_cancellation';
  static const String notifEventReminder = 'event_reminder';
  static const String notifEventStarted = 'event_started';
  static const String notifAttendanceSuccess = 'attendance_success';
  static const String notifProfileUpdate = 'profile_update';
  
  // QR Code
  static const String qrEventPrefix = 'EVENT_';
  static const int qrCodeTimeout = 300; // 5 minutes
}