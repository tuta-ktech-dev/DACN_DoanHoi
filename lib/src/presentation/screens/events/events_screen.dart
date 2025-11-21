import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_bloc.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event/event_state.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/loading_shimmer.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedType = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  String _selectedOrganization = 'Tất cả';

  final List<String> _eventTypes = [
    'Tất cả',
    'Học thuật',
    'Văn hóa',
    'Thể thao',
    'Tình nguyện'
  ];
  final List<String> _eventStatuses = [
    'Tất cả',
    'Sắp diễn ra',
    'Đang diễn ra',
    'Đã kết thúc'
  ];
  final List<String> _organizations = [
    'Tất cả',
    'Đoàn trường',
    'Hội sinh viên',
    'Khoa',
    'Lớp'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _loadMoreEvents();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadEvents() {
    context.read<EventBloc>().add(LoadEventsEvent(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          type: _selectedType == 'Tất cả' ? null : _selectedType,
          status: _selectedStatus == 'Tất cả'
              ? null
              : _getStatusValue(_selectedStatus),
          unionId: _selectedOrganization == 'Tất cả'
              ? null
              : int.tryParse(_selectedOrganization),
          page: 1,
          limit: 20,
        ));
  }

  void _loadMoreEvents() {
    final currentState = context.read<EventBloc>().state;
    if (currentState is EventsLoaded && !currentState.hasReachedMax) {
      context.read<EventBloc>().add(LoadEventsEvent(
            search:
                _searchController.text.isEmpty ? null : _searchController.text,
            type: _selectedType == 'Tất cả' ? null : _selectedType,
            status: _selectedStatus == 'Tất cả'
                ? null
                : _getStatusValue(_selectedStatus),
            unionId: _selectedOrganization == 'Tất cả'
                ? null
                : int.tryParse(_selectedOrganization),
            page: currentState.currentPage + 1,
            limit: 20,
          ));
    }
  }

  String _getStatusValue(String status) {
    switch (status) {
      case 'Sắp diễn ra':
        return 'upcoming';
      case 'Đang diễn ra':
        return 'ongoing';
      case 'Đã kết thúc':
        return 'completed';
      default:
        return 'upcoming';
    }
  }

  void _onEventTap(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }

  void _onRegisterEvent(String eventId) {
    context.read<EventBloc>().add(RegisterEvent(eventId));
  }

  void _onUnregisterEvent(String eventId) {
    context.read<EventBloc>().add(UnregisterEvent(eventId));
  }

  Future<void> _onRefresh() async {
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sự kiện...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _loadEvents(),
                ),
                const SizedBox(height: 16),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: ScrollController(),
                  child: Row(
                    children: [
                      _buildFilterChip('Loại', _selectedType, _eventTypes,
                          (value) {
                        setState(() {
                          _selectedType = value;
                          _loadEvents();
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Trạng thái', _selectedStatus, _eventStatuses,
                          (value) {
                        setState(() {
                          _selectedStatus = value;
                          _loadEvents();
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Tổ chức', _selectedOrganization, _organizations,
                          (value) {
                        setState(() {
                          _selectedOrganization = value;
                          _loadEvents();
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoading) {
                  return _buildLoadingList();
                } else if (state is EventsLoaded) {
                  if (state.events.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildEventsList(state.events, state.hasReachedMax);
                } else if (state is EventError) {
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

  Widget _buildFilterChip(String label, String selectedValue,
      List<String> options, Function(String) onSelected) {
    return ChoiceChip(
      label: Text('$label: $selectedValue'),
      selected: false,
      onSelected: (_) => _showFilterDialog(label, options, onSelected),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: Colors.grey[800]),
    );
  }

  void _showFilterDialog(
      String title, List<String> options, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                title: Text(option),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(option);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => const EventCardShimmer(),
    );
  }

  Widget _buildEventsList(List<Event> events, bool hasReachedMax) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length + (hasReachedMax ? 0 : 1),
      // Performance optimization: cache items above and below viewport
      cacheExtent: 500, // Cache 500px ahead for smooth scrolling
      itemBuilder: (context, index) {
        if (index >= events.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final event = events[index];
        return EventCard(
          key: Key(event.id.toString()),
          event: event,
          onTap: () => _onEventTap(event),
          onRegister: event.registrationStatus == 'open'
              ? () => _onRegisterEvent(event.id.toString())
              : null,
          onUnregister: event.canRegister == true
              ? () => _onUnregisterEvent(event.id.toString())
              : null,
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
            Icons.event_note,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có sự kiện nào',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử điều chỉnh bộ lọc của bạn',
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
            onPressed: _loadEvents,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
