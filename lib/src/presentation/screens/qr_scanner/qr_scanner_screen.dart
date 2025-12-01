import 'package:doan_hoi_app/src/data/models/attendance_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/attendance/attendance_cubit.dart';

import 'package:location/location.dart' hide PermissionStatus;
import 'package:location/location.dart' as location_package
    show PermissionStatus;

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late final AttendanceCubit _attendanceCubit;

  @override
  void initState() {
    super.initState();
    _attendanceCubit = getIt<AttendanceCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _attendanceCubit,
      child: const _QRScannerView(),
    );
  }
}

class _QRScannerView extends StatefulWidget {
  const _QRScannerView();

  @override
  State<_QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<_QRScannerView> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleQRCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _handleQRCode(String qrCode) async {
    // check quyền vị trí
    final permissionStatus = await Location().requestPermission();
    if (permissionStatus != location_package.PermissionStatus.granted) {
      _showErrorDialog('Vui lòng cấp quyền vị trí');
      return;
    }

    Location location = Location();
    final position = await location.getLocation();
    final latitude = position.latitude ?? 0;
    final longitude = position.longitude ?? 0;
    setState(() {
      _hasScanned = true;
    });

    // Stop scanner
    _scannerController.stop();

    // Process QR code through cubit
    context.read<AttendanceCubit>().scanQR(qrCode, latitude, longitude);
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
  }

  void _switchCamera() {
    _scannerController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          _showSuccessDialog(state.response);
        } else if (state is AttendanceError) {
          _showErrorDialog(state.message);
        }
      },
      child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final isProcessing = state is AttendanceProcessing;
          final hasScanned = _hasScanned || isProcessing;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                _buildScanner(),
                _buildScannerOverlay(hasScanned, isProcessing),
                _buildInstructions(),
                if (!hasScanned) _buildManualInputButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Quét mã QR'),
      actions: [
        IconButton(
          icon: const Icon(Icons.flash_on),
          onPressed: _toggleTorch,
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios),
          onPressed: _switchCamera,
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: _scannerController,
      onDetect: _onQRCodeDetected,
    );
  }

  Widget _buildScannerOverlay(bool hasScanned, bool isProcessing) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasScanned ? Colors.green : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasScanned ? Colors.green : Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isProcessing)
                const CircularProgressIndicator(color: Colors.white)
              else
                Icon(
                  hasScanned ? Icons.check_circle : Icons.qr_code_scanner,
                  size: 60,
                  color: hasScanned ? Colors.green : Colors.white,
                ),
              const SizedBox(height: 16),
              Text(
                isProcessing
                    ? 'Đang xử lý...'
                    : hasScanned
                        ? 'Đã quét thành công!'
                        : 'Hướng camera vào mã QR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Giữ camera ổn định để quét mã QR',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mã QR sẽ tự động được quét khi nằm trong khung',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputButton() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: TextButton(
          onPressed: _showManualInputDialog,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Nhập mã thủ công',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(AttendanceResponseModel response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Điểm danh thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sự kiện: ${response.data?.event?.title ?? 'N/A'}'),
            Text(
                'Điểm rèn luyện: +${response.data?.activityPointsEarned ?? 0}'),
            const SizedBox(height: 8),
            Text(response.message ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Lỗi điểm danh'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _hasScanned = false;
              });
              _scannerController.start();
            },
            child: const Text('Thử lại'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập mã điểm danh'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Nhập mã QR',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final code = textController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _handleQRCode(code);
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
