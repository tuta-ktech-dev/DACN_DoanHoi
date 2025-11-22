import 'package:doan_hoi_app/src/config/theme/app_theme.dart';
import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_bloc.dart';
import 'package:doan_hoi_app/src/presentation/screens/auth/auth_wrapper.dart';
import 'package:doan_hoi_app/src/presentation/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:doan_hoi_app/src/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DoanHoiApp extends StatefulWidget {
  const DoanHoiApp({super.key});

  @override
  State<DoanHoiApp> createState() => _DoanHoiAppState();
}

class _DoanHoiAppState extends State<DoanHoiApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<EventBloc>()),
        BlocProvider(create: (_) => getIt<UserBloc>()),
      ],
      child: MaterialApp(
        title: 'Đoàn - Hội App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en', 'US'),
        ],
        locale: const Locale('vi', 'VN'),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          if (settings.name == '/qr-scanner') {
            return MaterialPageRoute(
              builder: (_) => const QRScannerScreen(),
            );
          } else if (settings.name == '/register') {
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
            );
          }
          return null;
        },
      ),
    );
  }
}
