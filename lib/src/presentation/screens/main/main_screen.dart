import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/notification/notification_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/list_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/presentation/screens/my_events/my_events_screen.dart';
import 'package:doan_hoi_app/src/presentation/screens/notifications/notifications_screen.dart';
import 'package:doan_hoi_app/src/presentation/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final NotificationCubit _notificationCubit;

  @override
  void initState() {
    super.initState();
    _notificationCubit = getIt<NotificationCubit>();
    // Fetch notifications when app starts
    _notificationCubit.fetchNotifications();
  }

  @override
  void dispose() {
    _notificationCubit.close();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      const ListEventScreen(),
      const MyEventsScreen(),
      BlocProvider.value(
        value: _notificationCubit,
        child: const NotificationsScreen(),
      ),
      const ProfileScreen(),
    ];
  }

  final List<String> _titles = [
    'Sự kiện',
    'Sự kiện của tôi',
    'Thông báo',
    'Cá nhân',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleMarkAllAsRead(
    BuildContext context,
    NotificationCubit cubit,
    int unreadCount,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh dấu tất cả đã đọc'),
        content: Text('Bạn có chắc chắn muốn đánh dấu $unreadCount thông báo là đã đọc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đánh dấu tất cả thông báo là đã đọc')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          backgroundColor: const Color(0xFF0057B8),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (_currentIndex == 2)
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  final unreadCount = state.unreadCount ?? 0;
                  
                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.done_all),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: unreadCount > 0
                        ? () => _handleMarkAllAsRead(context, _notificationCubit, unreadCount)
                        : null,
                    tooltip: unreadCount > 0
                        ? 'Đánh dấu $unreadCount thông báo đã đọc'
                        : 'Không có thông báo chưa đọc',
                  );
                },
              ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _buildScreens(),
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0057B8),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            activeIcon: Icon(Icons.event_available),
            label: 'Sự kiện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
      ),
    );
  }
}
