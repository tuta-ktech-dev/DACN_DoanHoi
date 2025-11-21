import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_state.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_card_shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());
  }

  void _markAllAsRead() {
    context
        .read<NotificationBloc>()
        .add(const MarkAllNotificationsAsReadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with mark all as read button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông báo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 20),
                  label: const Text('Đọc tất cả'),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return _buildLoadingList();
                } else if (state is NotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildNotificationsList(state.notifications);
                } else if (state is NotificationError) {
                  return _buildErrorState(state.message);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => const NotificationCardShimmer(),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () => _onNotificationTap(notification),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn sẽ nhận được thông báo khi có sự kiện mới',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationEntity notification) {
    context
        .read<NotificationBloc>()
        .add(MarkNotificationAsReadEvent(notification.id));

    // Handle notification navigation based on type
    switch (notification.type) {
      case 'event_reminder':
      case 'event_update':
      case 'registration_confirmed':
        // Navigate to event detail
        if (notification.eventId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetailScreen(eventId: notification.eventId!),
            ),
          );
        }
        break;
      case 'training_points':
        // Navigate to profile or training points screen
        break;
      default:
        break;
    }
  }
}
