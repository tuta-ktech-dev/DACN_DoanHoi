import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/notification_card.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';
import 'package:doan_hoi_app/widgets/base_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NotificationCubit is provided by MainScreen via BlocProvider.value
    // Just return the view directly
    return const NotificationsView();
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      _isLoadingMore = true;
      context.read<NotificationCubit>().fetchMoreNotifications();
      Future.delayed(const Duration(seconds: 1), () {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        // Handle mark all as read result if needed
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.notifications != current.notifications ||
            previous.errorMessage != current.errorMessage,
        builder: (context, state) {
        if (state.status == FetchingStatus.error && state.notifications == null) {
          return BaseError(
            errorMessage: state.errorMessage ?? 'Có lỗi xảy ra',
            onTryAgain: () {
              context.read<NotificationCubit>().fetchNotifications();
            },
          );
        }

        final notifications = state.notifications ?? [];
        final isLoadingMore = state.status == FetchingStatus.loadingMore;
        final itemCount = notifications.length + (isLoadingMore ? 1 : 0);

        if (state.status == FetchingStatus.loading && notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<NotificationCubit>().fetchNotifications();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có thông báo nào',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Các thông báo sẽ xuất hiện ở đây',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<NotificationCubit>().fetchNotifications();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: itemCount,
            cacheExtent: 500,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              if (index >= notifications.length && isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: BaseIndicator()),
                );
              }

              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(context, notification),
                onMarkAsRead: notification.isRead
                    ? null
                    : () => _handleMarkAsRead(context, notification.id),
              );
            },
          ),
        );
        },
      ),
    );
  }


  Future<void> _handleNotificationTap(BuildContext context, notification) async {
    // Mark as read if not read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    // Navigate to event detail if has event_id
    if (notification.data?.eventId != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(
            eventId: notification.data!.eventId!,
          ),
        ),
      );

      // Refresh notifications if event was modified
      if (result == true && mounted) {
        context.read<NotificationCubit>().fetchNotifications();
      }
    }
  }

  void _handleMarkAsRead(BuildContext context, int notificationId) {
    context.read<NotificationCubit>().markAsRead(notificationId);
  }
}

