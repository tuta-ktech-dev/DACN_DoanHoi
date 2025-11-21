import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/auth/auth_state.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _didSubmitLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _didSubmitLogin = true;
      context.read<AuthBloc>().add(LoginEvent(
            studentId: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated && _didSubmitLogin) {
              _didSubmitLogin = false;
              NotificationBanner.show(
                context: context,
                message: 'Đăng nhập thành công!',
                type: NotificationType.success,
              );
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthError) {
              NotificationBanner.show(
                context: context,
                message: state.message,
                type: NotificationType.error,
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Đăng nhập',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0057B8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 100,
                            child: Image.asset(
                              'assets/images/logo_truong.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Đoàn-Hội Trường Đại Học Tài Nguyên và Môi Trường TP. Hồ Chí Minh',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0057B8),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Email sinh viên',
                                    hintText: 'Nhập gmail của bạn',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF0057B8),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      borderSide: BorderSide(
                                        color: Color(0xFF0057B8),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE53935),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'Email không đúng định dạng';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    hintText: 'Nhập mật khẩu',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF0057B8),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF666666),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      borderSide: BorderSide(
                                        color: Color(0xFF0057B8),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE53935),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    if (value.length < 6) {
                                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _login(),
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      onPressed:
                                          state is AuthLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0057B8),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: state is AuthLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Đăng nhập',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản?',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Đăng ký ngay',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
