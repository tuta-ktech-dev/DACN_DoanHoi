import 'package:doan_hoi_app/src/presentation/screens/events/list_event_screen.dart';
import 'package:flutter/material.dart';
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

  final List<Widget> _screens = [
    const ListEventScreen(),
    const MyEventsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color(0xFF0057B8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {},
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
    );
  }
}
