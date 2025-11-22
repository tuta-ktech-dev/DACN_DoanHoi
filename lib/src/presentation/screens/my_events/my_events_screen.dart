import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/models/attendance_history_response_model.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/attendance_history/attendance_history_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/my_events/my_events_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/loading_shimmer.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: 'Đã đăng ký'),
              Tab(text: 'Đã điểm danh'),
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
                      _buildRegistrationTab(state),
                      _buildAttendanceHistoryTab(),
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

  Widget _buildRegistrationTab(MyEventsState state) {
    // Combine all registered events
    final allEvents = [
      ...state.upcomingEvents,
      ...state.ongoingEvents,
      ...state.pastEvents,
    ];

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: allEvents.isEmpty
          ? _buildEmptyState(
              'Chưa có sự kiện đã đăng ký',
              Icons.event_note,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allEvents.length,
              // Performance optimizations
              cacheExtent: 500,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              itemBuilder: (context, index) {
                final event = allEvents[index];
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
            ),
    );
  }

  Widget _buildAttendanceHistoryTab() {
    return BlocProvider(
      create: (context) => getIt<AttendanceHistoryCubit>()..fetchAttendanceHistory(),
      child: BlocBuilder<AttendanceHistoryCubit, AttendanceHistoryState>(
        builder: (context, state) {
          if (state is AttendanceHistoryLoading) {
            return _buildLoadingList();
          } else if (state is AttendanceHistoryError) {
            return BaseError(
              errorMessage: state.message,
              onTryAgain: () => context.read<AttendanceHistoryCubit>().fetchAttendanceHistory(),
            );
          } else if (state is AttendanceHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<AttendanceHistoryCubit>().fetchAttendanceHistory(),
              child: state.attendanceHistory.isEmpty
                  ? _buildEmptyState(
                      'Chưa có lịch sử điểm danh',
                      Icons.check_circle_outline,
                    )
                  : _buildAttendanceHistoryList(state.attendanceHistory),
            );
          }
          return _buildEmptyState('Chưa có lịch sử điểm danh', Icons.check_circle_outline);
        },
      ),
    );
  }

  Widget _buildAttendanceHistoryList(List<AttendanceHistoryItemModel> attendanceHistory) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: attendanceHistory.length,
      itemBuilder: (context, index) {
        final item = attendanceHistory[index];
        return _buildAttendanceHistoryCard(item);
      },
    );
  }

  Widget _buildAttendanceHistoryCard(AttendanceHistoryItemModel item) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAttendanceStatusColor(item.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.statusLabel ?? item.status ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Event title
            Text(
              item.event?.title ?? 'Unknown Event',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Event details
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.event?.union?.name ?? 'Unknown Organization',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            if (item.activityPointsEarned != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '+${item.activityPointsEarned} điểm rèn luyện',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Attendance time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatAttendanceDate(item.attendedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Notes if available
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAttendanceStatusColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatAttendanceDate(String? dateStr) {
    if (dateStr == null) return 'Unknown time';

    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date, locale: 'vi', allowFromNow: true);
    } catch (e) {
      return dateStr;
    }
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
