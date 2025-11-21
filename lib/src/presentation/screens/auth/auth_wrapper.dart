import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_state.dart';
import 'package:doan_hoi_app/src/presentation/screens/main/main_screen.dart';
import 'package:doan_hoi_app/src/presentation/screens/auth/login_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_banner.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          NotificationBanner.show(
            context: context,
            message: state.message,
            type: NotificationType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainScreen();
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
