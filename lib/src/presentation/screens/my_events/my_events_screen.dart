import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/my_events/my_events_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/loading_shimmer.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyEventsCubit>()..fetchMyEvents(),
      child: const MyEventsView(),
    );
  }
}

class MyEventsView extends StatefulWidget {
  const MyEventsView({super.key});

  @override
  State<MyEventsView> createState() => _MyEventsViewState();
}

class _MyEventsViewState extends State<MyEventsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMyEvents() {
    context.read<MyEventsCubit>().fetchMyEvents();
  }

  Future<void> _onEventTap(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          eventId: event.id!,
          event: event,
        ),
      ),
    );

    // Refresh if event was modified
    if (result == true && mounted) {
      _loadMyEvents();
    }
  }

  Future<void> _onUnregisterEvent(int eventId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đăng ký'),
        content: const Text('Bạn có chắc chắn muốn hủy đăng ký sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hủy đăng ký',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await getIt<CmsApiService>().unregisterEvent(eventId);

      if (!mounted) return;

      if (result.success ?? false) {
        _loadMyEvents();
        Fluttertoast.showToast(
          msg: 'Hủy đăng ký sự kiện thành công',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: result.message ?? 'Hủy đăng ký sự kiện thất bại',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _onRefresh() async {
    _loadMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tab bar with improved styling
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Sắp diễn ra'),
              Tab(text: 'Đang diễn ra'),
              Tab(text: 'Đã tham gia'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: BlocBuilder<MyEventsCubit, MyEventsState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.upcomingEvents != current.upcomingEvents ||
                previous.ongoingEvents != current.ongoingEvents ||
                previous.pastEvents != current.pastEvents ||
                previous.errorMessage != current.errorMessage,
            builder: (context, state) {
              if (state.status == FetchingStatus.loading) {
                return _buildLoadingList();
              } else if (state.status == FetchingStatus.error) {
                return BaseError(
                  errorMessage: state.errorMessage ?? 'Có lỗi xảy ra',
                  onTryAgain: _loadMyEvents,
                );
              } else if (state.status == FetchingStatus.success) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsList(
                        state.upcomingEvents,
                        'Chưa có sự kiện sắp diễn ra',
                        Icons.schedule,
                      ),
                      _buildEventsList(
                        state.ongoingEvents,
                        'Chưa có sự kiện đang diễn ra',
                        Icons.play_circle,
                      ),
                      _buildEventsList(
                        state.pastEvents,
                        'Chưa có sự kiện đã tham gia',
                        Icons.check_circle,
                      ),
                    ],
                  ),
                );
              } else {
                return _buildEmptyState(
                  'Chưa có sự kiện nào',
                  Icons.event_available,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(
    List<Event> events,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    if (events.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyIcon);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      // Performance optimizations
      cacheExtent: 500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          key: ValueKey(event.id),
          onTap: () => _onEventTap(event),
          onUnregister:
              (event.registration?.status == RegistrationStatus.approved ||
                          event.registration?.status ==
                              RegistrationStatus.pending) &&
                      event.canRegister == true
                  ? () => _onUnregisterEvent(event.id!)
                  : null,
          onAttend: event.registration?.status == RegistrationStatus.pending
              ? () => _navigateToQRScanner(event.id.toString())
              : null,
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Hãy đăng ký tham gia các sự kiện để xem ở đây',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
