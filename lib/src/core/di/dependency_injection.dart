import 'package:dio/dio.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/repositories/auth_repository_impl.dart';
import 'package:doan_hoi_app/src/data/repositories/event_repository_impl.dart';
import 'package:doan_hoi_app/src/data/repositories/notification_repository_impl.dart';
import 'package:doan_hoi_app/src/data/repositories/user_repository_impl.dart';
import 'package:doan_hoi_app/src/domain/repositories/auth_repository.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';
import 'package:doan_hoi_app/src/domain/repositories/notification_repository.dart';
import 'package:doan_hoi_app/src/domain/repositories/user_repository.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<CmsApiService>(
      () => CmsApiService(getIt<Dio>(), baseUrl: 'http://localhost:8000/api/'));
  getIt.registerLazySingleton<SharedPreferencesManager>(
      () => SharedPreferencesManager());

  // API Service
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      getIt<ApiService>(), getIt<SharedPreferencesManager>()));
  getIt.registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(getIt<ApiService>(), getIt<CmsApiService>()));
  getIt.registerLazySingleton<NotificationRepository>(() =>
      NotificationRepositoryImpl(
          getIt<ApiService>(), getIt<SharedPreferencesManager>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
      getIt<ApiService>(), getIt<SharedPreferencesManager>()));

  // Blocs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<EventBloc>(() => EventBloc(getIt<EventRepository>()));
  getIt.registerFactory<NotificationBloc>(
      () => NotificationBloc(getIt<NotificationRepository>()));
  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));

  getIt.registerFactory<FetchEventCubit>(
      () => FetchEventCubit(getIt<EventRepository>()));
}
