import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:doan_hoi_app/src/presentation/screens/main/main_screen.dart';
import 'package:doan_hoi_app/src/presentation/screens/auth/login_screen.dart'
    as auth_login;
import 'package:doan_hoi_app/src/presentation/screens/auth/register_screen.dart'
    as auth;
import 'package:doan_hoi_app/src/presentation/screens/auth/auth_wrapper.dart'
    as auth_wrapper;
import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_bloc.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0057B8),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
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
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const auth_wrapper.AuthWrapper(),
          '/login': (context) => const auth_login.LoginScreen(),
          '/register': (context) => const auth.RegisterScreen(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}

// Simple home screen for testing
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: const Color(0xFF0057B8),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng đến với hệ thống Đoàn - Hội!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0057B8),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0057B8),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
