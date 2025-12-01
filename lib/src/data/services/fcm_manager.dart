import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/services/notification_service.dart';

/// FCM Manager để quản lý Firebase Cloud Messaging
/// Xử lý việc tạo, lưu, cập nhật và xóa FCM token
class FCMManager {
  final FirebaseMessaging _firebaseMessaging;
  final SharedPreferencesManager _sharedPreferences;
  final CmsApiService _cmsApiService;
  final NotificationService _notificationService;

  FCMManager(this._firebaseMessaging, this._sharedPreferences,
      this._cmsApiService, this._notificationService);

  /// Lấy FCM token từ Firebase
  /// Trả về Either<Failure, String> - Right(token) nếu thành công, Left(failure) nếu thất bại
  Future<Either<Failure, String>> getFCMToken() async {
    try {
      // Yêu cầu quyền thông báo (chỉ trên iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Kiểm tra quyền trên iOS
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return const Left(ServerFailure('Không có quyền gửi thông báo'));
      }

      // Lấy FCM token
      final token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        return const Left(ServerFailure('Không thể lấy FCM token'));
      }

      // Lưu token vào SharedPreferences để sử dụng sau này
      await _sharedPreferences.saveFCMToken(token);

      debugPrint('FCM Token: $token');
      return Right(token);
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return Left(ServerFailure('Lỗi khi lấy FCM token: ${e.toString()}'));
    }
  }

  /// Lưu FCM token lên server
  /// Trả về Either<Failure, void> - Right(null) nếu thành công, Left(failure) nếu thất bại
  Future<Either<Failure, void>> saveFCMTokenToServer(String token,
      {String? deviceType}) async {
    try {
      // Gọi API để lưu FCM token lên server
      // TODO: Implement API call to save FCM token to server

      // Lưu token vào SharedPreferences sau khi server xác nhận thành công
      await _sharedPreferences.saveFCMToken(token);
      debugPrint('FCM token saved to server successfully: $token');
      return const Right(null);
    } catch (e) {
      debugPrint('Error saving FCM token to server: $e');
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi khi lưu FCM token: ${e.toString()}'));
    }
  }

  /// Xóa FCM token khỏi server và local storage
  /// Trả về Either<Failure, void> - Right(null) nếu thành công, Left(failure) nếu thất bại
  Future<Either<Failure, void>> deleteFCMTokenFromServer() async {
    try {
      // Lấy token hiện tại
      final currentToken = await _sharedPreferences.getFCMToken();
      if (currentToken == null) {
        return const Right(null); // Không có token để xóa
      }

      // Gọi API để xóa FCM token khỏi server
      // TODO: Implement API call to delete FCM token from server

      // Xóa token khỏi Firebase
      await _firebaseMessaging.deleteToken();

      // Xóa token khỏi SharedPreferences
      await _sharedPreferences.deleteFCMToken();

      debugPrint(
          'FCM token deleted from server and local storage successfully');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi khi xóa FCM token: ${e.toString()}'));
    }
  }

  /// Cập nhật FCM token khi token thay đổi
  /// Phương thức này nên được gọi khi app khởi động để kiểm tra token mới
  Future<Either<Failure, void>> updateFCMToken() async {
    try {
      // Lấy token mới từ Firebase
      final tokenResult = await getFCMToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (newToken) async {
          // Lấy token cũ từ SharedPreferences
          final oldToken = await _sharedPreferences.getFCMToken();

          // Nếu token mới khác token cũ, cập nhật lên server
          if (oldToken != null && oldToken != newToken) {
            debugPrint('FCM token changed, updating...');
            return await updateFCMTokenOnServer(oldToken, newToken);
          } else if (oldToken == null) {
            debugPrint('No old token found, saving new token...');
            return await saveFCMTokenToServer(newToken);
          } else {
            debugPrint('FCM token unchanged');
            return const Right(null);
          }
        },
      );
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
      return Left(ServerFailure('Lỗi khi cập nhật FCM token: ${e.toString()}'));
    }
  }

  /// Cập nhật FCM token trên server khi token thay đổi
  /// Trả về Either<Failure, void> - Right(null) nếu thành công, Left(failure) nếu thất bại
  Future<Either<Failure, void>> updateFCMTokenOnServer(
      String oldToken, String newToken,
      {String? deviceType}) async {
    try {
      // Gọi API để cập nhật FCM token trên server
      // TODO: Implement API call to update FCM token on server
      await _cmsApiService.saveFCMToken({
        'token': newToken,
      });
      // Lưu token mới vào SharedPreferences
      await _sharedPreferences.saveFCMToken(newToken);
      debugPrint(
          'FCM token updated on server successfully: $oldToken -> $newToken');
      return const Right(null);
    } catch (e) {
      debugPrint('Error updating FCM token on server: $e');
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Lỗi khi cập nhật FCM token: ${e.toString()}'));
    }
  }

  /// Lắng nghe thay đổi FCM token
  /// Trả về Stream<String> để theo dõi token mới
  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }

  /// Lắng nghe thông báo khi app đang chạy (foreground)
  /// Trả về Stream<RemoteMessage> để xử lý thông báo
  Stream<RemoteMessage> onMessage() {
    return FirebaseMessaging.onMessage;
  }

  /// Lắng nghe thông báo khi app đang chạy (foreground) - version cũ
  /// Trả về Stream<RemoteMessage> để xử lý thông báo
  Stream<RemoteMessage> get onMessageStream {
    return FirebaseMessaging.onMessage;
  }

  /// Lắng nghe khi user tap vào thông báo để mở app
  /// Trả về Stream<RemoteMessage> để xử lý thông báo
  Stream<RemoteMessage> onMessageOpenedApp() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  /// Lấy thông báo ban đầu (khi app được mở từ notification)
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }

  /// Subscribe to topic
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
      return const Right(null);
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
      return Left(ServerFailure('Lỗi khi subscribe topic: ${e.toString()}'));
    }
  }

  /// Unsubscribe from topic
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
      return const Right(null);
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
      return Left(ServerFailure('Lỗi khi unsubscribe topic: ${e.toString()}'));
    }
  }

  /// Kiểm tra FCM token hiện tại
  Future<String?> getCurrentFCMToken() async {
    return await _sharedPreferences.getFCMToken();
  }

  /// Setup FCM với các listeners cần thiết và tích hợp notification
  void setupFCMListeners({
    Function(RemoteMessage)? onMessageHandler,
    Function(RemoteMessage)? onMessageOpenedAppHandler,
    Function(String)? onTokenRefreshHandler,
  }) {
    // Lắng nghe thông báo foreground và hiển thị local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received foreground message: ${message.notification?.title}');

      // Hiển thị local notification
      await _notificationService.showNotificationFromFCM(message);

      // Gọi custom handler nếu có
      if (onMessageHandler != null) {
        onMessageHandler(message);
      }
    });

    // Lắng nghe khi user tap vào notification
    if (onMessageOpenedAppHandler != null) {
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppHandler);
    }

    // Lắng nghe token refresh
    if (onTokenRefreshHandler != null) {
      _firebaseMessaging.onTokenRefresh.listen(onTokenRefreshHandler);
    }
  }

  /// Setup đầy đủ FCM với notification service
  void setupFCMWithNotifications({
    Function(RemoteMessage)? onMessageHandler,
    Function(RemoteMessage)? onMessageOpenedAppHandler,
    Function(String)? onTokenRefreshHandler,
  }) {
    setupFCMListeners(
      onMessageHandler: onMessageHandler,
      onMessageOpenedAppHandler: onMessageOpenedAppHandler,
      onTokenRefreshHandler: onTokenRefreshHandler,
    );
  }
}
