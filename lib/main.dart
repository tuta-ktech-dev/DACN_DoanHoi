import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:doan_hoi_app/src/presentation/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:doan_hoi_app/src/data/services/notification_service.dart';
import 'package:doan_hoi_app/src/data/services/fcm_manager.dart';

/// Background message handler for FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
  // Background messages are handled here
  // Local notifications for background messages will be handled by the system
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup dependencies
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    // Setup FCM listeners
    final fcmManager = getIt<FCMManager>();

    // Setup FCM with notification handling
    fcmManager.setupFCMWithNotifications(
      onMessageHandler: (RemoteMessage message) {
        debugPrint(
            'Received foreground message: ${message.notification?.title}');
        // Additional custom handling can be added here
      },
      onMessageOpenedAppHandler: (RemoteMessage message) {
        debugPrint('Message opened app: ${message.notification?.title}');
        // Handle navigation based on message data
        _handleMessageNavigation(message);
      },
      onTokenRefreshHandler: (String token) async {
        debugPrint('FCM Token refreshed: $token');
        // Update token on server
        await fcmManager.updateFCMToken();
      },
    );

    // Update FCM token on app start
    await fcmManager.updateFCMToken();
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('route')) {
      final route = data['route'];
      // Navigate to specific screen based on route
      switch (route) {
        case 'events':
          // Navigate to events screen
          break;
        case 'notifications':
          // Navigate to notifications screen
          break;
        default:
          // Default navigation
          break;
      }
    }
  }

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
          '/qr-scanner': (context) => const QRScannerScreen(),
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
