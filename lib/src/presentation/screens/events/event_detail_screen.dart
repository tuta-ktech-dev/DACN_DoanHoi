import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_state.dart';
import 'package:doan_hoi_app/src/config/theme/app_colors.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_banner.dart';

class EventDetailScreen extends StatefulWidget {
  final Event? event;
  final String? eventId;

  const EventDetailScreen({
    super.key,
    this.event,
    this.eventId,
  }) : assert(event != null || eventId != null);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  @override
  void initState() {
    super.initState();
    final idToLoad = widget.event?.id ?? widget.eventId!;
    context.read<EventBloc>().add(LoadEventDetailEvent(idToLoad));
    _event = widget.event;
  }

  void _registerEvent() {
    final id = _event?.id ?? widget.eventId!;
    context.read<EventBloc>().add(RegisterEvent(id));
  }

  void _unregisterEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn hủy đăng ký sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final id = _event?.id ?? widget.eventId!;
              context.read<EventBloc>().add(UnregisterEvent(id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Có, hủy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
            NotificationBanner.show(
              context: context,
              message: state.message,
              type: NotificationType.success,
            );
            Navigator.pop(context);
          } else if (state is EventError) {
            NotificationBanner.show(
              context: context,
              message: state.message,
              type: NotificationType.error,
            );
          } else if (state is EventDetailLoaded) {
            setState(() {
              _event = state.event;
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: (_event?.posterUrl) != null
                    ? CachedNetworkImage(
                        imageUrl: _event!.posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.event, size: 80, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.event, size: 80, color: Colors.grey),
                      ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildStatusChip(_event?.status ?? 'upcoming'),
                            const Spacer(),
                            if ((_event?.isRegistered ?? false))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Đã đăng ký',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _event?.title ?? 'Đang tải...',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _event?.organization ?? '',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event details
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          icon: Icons.access_time,
                          title: 'Thời gian',
                          content: _formatDateTimeRange(),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.location_on,
                          title: 'Địa điểm',
                          content: _event?.location ?? '',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.group,
                          title: 'Số lượng',
                          content: (_event != null)
                              ? '${_event!.currentParticipants}/${_event!.maxParticipants} người'
                              : '',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.star,
                          title: 'Điểm rèn luyện',
                          content: (_event != null) ? '${_event!.trainingPoints} điểm' : '',
                        ),
                        if ((_event?.registrationDeadline ?? DateTime(0)).isAfter(DateTime.now())) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            title: 'Hạn đăng ký',
                            content: _event != null ? _formatDateTime(_event!.registrationDeadline) : '',
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mô tả',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _event?.description ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              if (_event?.canAttend ?? false)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to QR scanner
                      Navigator.pushNamed(context, '/qr-scanner', arguments: _event!.id);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Quét QR điểm danh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              else if (_event?.isRegistrationOpen ?? false)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _registerEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Đăng ký tham gia'),
                  ),
                )
              else if ((_event?.isRegistered ?? false) && (_event?.canCancelRegistration ?? false))
                Expanded(
                  child: OutlinedButton(
                    onPressed: _unregisterEvent,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'Hủy đăng ký',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'upcoming':
        color = Colors.blue;
        text = 'Sắp diễn ra';
        break;
      case 'ongoing':
        color = Colors.green;
        text = 'Đang diễn ra';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Đã kết thúc';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTimeRange() {
    final start = _event != null ? _formatDateTime(_event!.startTime) : '';
    final end = _event != null ? _formatDateTime(_event!.endTime) : '';
    return '$start - $end';
  }

  String _getStatusText() {
    if ((_event?.hasAttended ?? false)) {
      return 'Đã điểm danh';
    } else if ((_event?.isRegistered ?? false) && !(_event?.isRegistrationOpen ?? false)) {
      return 'Đã đăng ký';
    } else if ((_event?.status ?? '') == 'completed') {
      return 'Đã kết thúc';
    } else if (_event != null && _event!.currentParticipants >= _event!.maxParticipants) {
      return 'Đã đủ người';
    } else {
      return 'Không thể đăng ký';
    }
  }
}
