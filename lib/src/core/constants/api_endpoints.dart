class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.10:8000/api/';

  // Auth endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';
  static const String profile = 'auth/profile';

  // Event endpoints (CMS)
  static const String events = 'student/events';
  static const String eventDetail = 'student/events/{id}';
  static const String registerEvent = 'student/events/{id}/register';
  static const String unregisterEvent = 'student/events/{id}/unregister';
  static const String myEvents = 'student/registrations';
  static const String attendEvent = 'student/scan-qr';

  // Notification endpoints
  static const String notifications = 'notifications';
  static const String markNotificationAsRead = 'notifications/{id}/read';
  static const String clearNotifications = 'notifications/clear';

  // User endpoints
  static const String updateProfile = 'users/profile';
  static const String uploadAvatar = 'users/avatar';
  static const String userActivities = 'users/activities';

  // Organization endpoints
  static const String organizations = 'organizations';
}
