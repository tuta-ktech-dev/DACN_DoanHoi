import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_state.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/loading_shimmer.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMyEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMyEvents() {
    context.read<EventBloc>().add(const LoadMyEventsEvent());
  }

  void _onEventTap(event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }

  void _onUnregisterEvent(String eventId) {
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
              context.read<EventBloc>().add(UnregisterEvent(eventId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Có, hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    _loadMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Sắp diễn ra'),
              Tab(text: 'Đang diễn ra'),
              Tab(text: 'Đã tham gia'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              if (state is EventLoading) {
                return _buildLoadingList();
              } else if (state is MyEventsLoaded) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsList(state.upcomingEvents, 'Chưa có sự kiện sắp diễn ra'),
                      _buildEventsList(state.ongoingEvents, 'Chưa có sự kiện đang diễn ra'),
                      _buildEventsList(state.pastEvents, 'Chưa có sự kiện đã tham gia'),
                    ],
                  ),
                );
              } else if (state is EventError) {
                return _buildErrorState(state.message);
              } else {
                return _buildEmptyState('Chưa có sự kiện nào');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(List events, String emptyMessage) {
    if (events.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => _onEventTap(event),
          onUnregister: event.canCancelRegistration ? () => _onUnregisterEvent(event.id) : null,
          onAttend: event.canAttend ? () => _navigateToQRScanner(event.id) : null,
        );
      },
    );
  }

  void _navigateToQRScanner(String eventId) {
    Navigator.pushNamed(context, '/qr-scanner', arguments: eventId);
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => const EventCardShimmer(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy đăng ký tham gia các sự kiện',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
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
            onPressed: _loadMyEvents,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}