import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:doan_hoi_app/src/core/constants/api_endpoints.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/models/auth_response.dart';
import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
import 'package:doan_hoi_app/src/data/models/user_model.dart';

class ApiService {
  final Dio _dio;
  String? _accessToken;

  ApiService(this._dio) {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout
          }
          return handler.next(error);
        },
      ),
    );

    // Pretty Dio Logger - hiển thị log đẹp hơn trong console
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  // Auth endpoints
  Future<AuthResponse> login(String studentId, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': studentId,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String faculty,
    required String className,
    required String course,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'student_id': studentId,
          'class': className,
          'faculty': faculty,
          'course': course,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'phone': phone,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      final data = response.data['data'] ?? {};
      final user = data['user'] ?? {};
      final student = data['student'] ?? {};
      final merged = {
        'id': user['id'] ?? '',
        'student_id': student['student_id'] ?? '',
        'full_name': user['full_name'] ?? '',
        'email': user['email'] ?? '',
        'avatar_url': null,
        'class_name': student['class'] ?? '',
        'faculty': student['faculty'] ?? '',
        'major': student['course'] ?? '',
        'training_points': 0,
        'created_at': user['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': user['created_at'] ?? DateTime.now().toIso8601String(),
      };
      return UserModel.fromJson(merged);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Event endpoints
  Future<List<EventDataModel>> getEvents({
    String? search,
    String? type,
    String? status,
    String? organization,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (organization != null) {
        final unionId = int.tryParse(organization);
        if (unionId != null) {
          queryParams['union_id'] = unionId;
        }
      }
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['per_page'] = limit;

      final response = await _dio.get(
        ApiEndpoints.events,
        queryParameters: queryParams,
      );
      final data = response.data;
      List items = const [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        final inner = (data['data'] is Map) ? data['data'] : data;
        final events = inner?['events'];
        if (events is List) {
          items = events;
        } else if (events is Map && events['data'] is List) {
          items = List.from(events['data'] as List);
        } else if (inner?['data'] is List) {
          items = List.from(inner['data'] as List);
        } else {
          items = const [];
        }
      }
      return items
          .map((json) =>
              EventDataModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<EventDataModel> getEventDetail(String eventId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.eventDetail.replaceAll('{id}', eventId),
      );
      return EventDataModel.fromJson(
          Map<String, dynamic>.from(response.data['data'] ?? {}));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> registerEvent(String eventId) async {
    try {
      await _dio.post(
        ApiEndpoints.registerEvent.replaceAll('{id}', eventId),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> unregisterEvent(String eventId) async {
    try {
      await _dio.delete(
        ApiEndpoints.unregisterEvent.replaceAll('{id}', eventId),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> attendEvent(String eventId, String qrToken) async {
    try {
      await _dio.post(
        ApiEndpoints.attendEvent,
        data: {'qr_token': qrToken},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
          'Kết nối mạng quá thời gian. Vui lòng thử lại.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Đã xảy ra lỗi';

      dynamic errors = (data is Map) ? data['errors'] : null;
      if (errors == null && data is Map && data['data'] is Map) {
        errors = (data['data'] as Map)['errors'];
      }
      if (errors == null && data is Map && data['error'] is Map) {
        errors = (data['error'] as Map)['errors'];
      }

      if (errors is Map) {
        final collected = <String>[];
        for (final entry in errors.entries) {
          final key = entry.key.toString();
          final val = entry.value;
          if (val is List) {
            for (final v in val) {
              collected.add(_localizeFieldMessage(key, v.toString()));
            }
          } else if (val != null) {
            collected.add(_localizeFieldMessage(key, val.toString()));
          }
        }
        if (collected.isNotEmpty) {
          message = collected.join('\n');
        }
      } else if (errors is List) {
        final collected =
            errors.map((e) => _localizeText(e.toString())).toList();
        if (collected.isNotEmpty) {
          message = collected.join('\n');
        }
      } else if (errors is String && errors.isNotEmpty) {
        message = _localizeText(errors);
      }
      message = _localizeText(message);

      switch (statusCode) {
        case 400:
          return BadRequestFailure(message);
        case 401:
          return AuthenticationFailure(message);
        case 404:
          return NotFoundFailure(message);
        case 422:
          return ValidationFailure(message);
        case 500:
        case 502:
        case 503:
          return ServerFailure(message, statusCode);
        default:
          return ServerFailure(message, statusCode);
      }
    }

    return const ServerFailure('Đã xảy ra lỗi không xác định');
  }

  String _localizeText(String text) {
    final t = {
      'Validation failed': 'Dữ liệu không hợp lệ',
      'validation.unique': 'Giá trị đã tồn tại',
      'validation.required': 'Thiếu thông tin bắt buộc',
      'validation.email': 'Email không hợp lệ',
      'validation.date_format': 'Sai định dạng ngày',
      'validation.confirmed': 'Xác nhận không khớp',
      'auth.failed': 'Thông tin đăng nhập không chính xác',
    };
    for (final entry in t.entries) {
      if (text.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    final lower = text.toLowerCase();
    if (lower.contains('has already been taken') || lower.contains('unique')) {
      return 'Giá trị đã tồn tại';
    }
    if (lower.contains('required')) {
      return 'Thiếu thông tin bắt buộc';
    }
    if (lower.contains('must be a valid email') ||
        lower.contains('invalid email')) {
      return 'Email không hợp lệ';
    }
    if (lower.contains('date format') ||
        lower.contains('format y-m-d') ||
        lower.contains('validation.date_format')) {
      return 'Sai định dạng ngày';
    }
    if (lower.contains('confirmed') || lower.contains('does not match')) {
      return 'Xác nhận không khớp';
    }
    return text;
  }

  String _localizeFieldMessage(String field, String message) {
    final fieldMap = {
      'email': 'Email',
      'username': 'Tên đăng nhập',
      'student_id': 'Mã số sinh viên',
      'phone': 'Số điện thoại',
      'password': 'Mật khẩu',
      'password_confirmation': 'Xác nhận mật khẩu',
      'date_of_birth': 'Ngày sinh',
      'class': 'Lớp',
      'faculty': 'Khoa',
      'course': 'Khóa học',
      'gender': 'Giới tính',
      'full_name': 'Họ và tên',
    };
    final label = fieldMap[field] ?? field;
    final lower = message.toLowerCase();

    if (lower.contains('has already been taken') || lower.contains('unique')) {
      return '$label: $label đã tồn tại';
    }
    if (lower.contains('required')) {
      return '$label: Vui lòng nhập $label';
    }
    if (field == 'email' &&
        (lower.contains('validation.email') ||
            lower.contains('must be a valid email') ||
            lower.contains('invalid email'))) {
      return 'Email: Email không hợp lệ';
    }
    if (field == 'date_of_birth' &&
        (lower.contains('date format') ||
            lower.contains('format y-m-d') ||
            lower.contains('validation.date_format'))) {
      return 'Ngày sinh: Sai định dạng ngày';
    }
    if ((field == 'password' || field == 'password_confirmation') &&
        (lower.contains('confirmed') || lower.contains('does not match'))) {
      return 'Xác nhận mật khẩu: Xác nhận không khớp';
    }

    final translated = _localizeText(message);
    if (translated == message) {
      return '$label: $message';
    }
    return '$label: $translated';
  }
}
