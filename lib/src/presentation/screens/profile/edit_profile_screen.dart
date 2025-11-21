import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/user/user_state.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_banner.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  String? _faculty;
  String? _course;
  static const List<String> _facultyOptions = [
    'Công nghệ Thông tin',
    'Kinh tế',
    'Kỹ thuật',
    'Ngoại ngữ',
    'Luật',
    'Môi trường',
    'Khoa học Đất',
    'Khí tượng - Thủy văn',
    'Quản lý Tài nguyên',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName;
    _emailController.text = widget.user.email;
    _classController.text = widget.user.className;
    _studentIdController.text = widget.user.studentId;
    _faculty = _normalizeFaculty(widget.user.faculty);
    _course = _normalizeCourse(widget.user.major);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _classController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      NotificationBanner.show(
        context: context,
        message: 'Thông tin chưa hợp lệ. Vui lòng kiểm tra các ô màu đỏ.',
        type: NotificationType.error,
      );
      return;
    }
    context.read<UserBloc>().add(UpdateProfileEvent({
          'studentId': _studentIdController.text.trim(),
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'className': _classController.text.trim(),
          'faculty': (_faculty ?? '').trim(),
          'major': (_course ?? '').trim(),
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserOperationSuccess) {
          NotificationBanner.show(
            context: context,
            message: state.message,
            type: NotificationType.success,
          );
          Navigator.pop(context);
        } else if (state is UserError) {
          NotificationBanner.show(
            context: context,
            message: state.message,
            type: NotificationType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa hồ sơ'),
          backgroundColor: const Color(0xFF0057B8),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _studentIdController,
                  label: 'Mã số sinh viên',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.text,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập mã số sinh viên'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập họ và tên'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration:
                      _inputDecoration('Email', Icons.email_outlined).copyWith(
                    suffixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF666666)),
                  ),
                  style:
                      const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _classController,
                  label: 'Lớp',
                  icon: Icons.school_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập lớp'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _faculty,
                  items: const [
                    DropdownMenuItem(
                        value: 'Công nghệ Thông tin',
                        child: Text('Công nghệ Thông tin')),
                    DropdownMenuItem(value: 'Kinh tế', child: Text('Kinh tế')),
                    DropdownMenuItem(
                        value: 'Kỹ thuật', child: Text('Kỹ thuật')),
                    DropdownMenuItem(
                        value: 'Ngoại ngữ', child: Text('Ngoại ngữ')),
                    DropdownMenuItem(value: 'Luật', child: Text('Luật')),
                    DropdownMenuItem(
                        value: 'Môi trường', child: Text('Môi trường')),
                    DropdownMenuItem(
                        value: 'Khoa học Đất', child: Text('Khoa học Đất')),
                    DropdownMenuItem(
                        value: 'Khí tượng - Thủy văn',
                        child: Text('Khí tượng - Thủy văn')),
                    DropdownMenuItem(
                        value: 'Quản lý Tài nguyên',
                        child: Text('Quản lý Tài nguyên')),
                  ],
                  onChanged: (v) => setState(() => _faculty = v),
                  decoration:
                      _inputDecoration('Khoa', Icons.account_balance_outlined),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Vui lòng chọn khoa' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _course,
                  items: List.generate(14, (i) {
                    final value = (i + 1).toString();
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('Khóa $value'),
                    );
                  }),
                  onChanged: (v) => setState(() => _course = v),
                  decoration: _inputDecoration('Khóa', Icons.timeline_outlined),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Vui lòng chọn khóa' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final loading = state is UserLoading;
                    return ElevatedButton(
                      onPressed: loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0057B8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Lưu thay đổi'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0057B8)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFF0057B8), width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFE53935), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
    );
  }

  String? _normalizeFaculty(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return null;
    for (final opt in _facultyOptions) {
      if (opt.toLowerCase() == v) return opt;
    }
    if (v.contains('cntt') || v.contains('cong nghe thong tin')) {
      return 'Công nghệ Thông tin';
    }
    if (v.contains('kinh te')) return 'Kinh tế';
    if (v.contains('ky thuat')) return 'Kỹ thuật';
    if (v.contains('ngoai ngu')) return 'Ngoại ngữ';
    if (v.contains('luat')) return 'Luật';
    if (v.contains('moi truong')) return 'Môi trường';
    if (v.contains('khoa hoc dat') || v.contains('khoa hoc đất'))
      return 'Khoa học Đất';
    if (v.contains('khi tuong') || v.contains('thuy van'))
      return 'Khí tượng - Thủy văn';
    if (v.contains('quan ly tai nguyen')) return 'Quản lý Tài nguyên';
    return null;
  }

  String? _normalizeCourse(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;
    final match = RegExp(r'(\d{1,2})').firstMatch(v);
    if (match != null) return match.group(1);
    return null;
  }
}
