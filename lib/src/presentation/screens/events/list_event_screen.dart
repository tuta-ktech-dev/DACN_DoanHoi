import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/models/union_response_model.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/src/presentation/widgets/filter_chip_widget.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';
import 'package:doan_hoi_app/widgets/base_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ListEventScreen extends StatelessWidget {
  const ListEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FetchEventCubit>()..fetchEvents(),
      child: const ListEventView(),
    );
  }
}

class ListEventView extends StatefulWidget {
  const ListEventView({super.key});

  @override
  State<ListEventView> createState() => _ListEventViewState();
}

class _ListEventViewState extends State<ListEventView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  // Filter state
  String? _selectedStatus;
  int? _selectedUnionId;
  List<UnionDataModel> _unions = [];
  bool _isLoadingUnions = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUnions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Optimized scroll listener with threshold
  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger load more when user is 200px away from bottom
    if (currentScroll >= maxScroll - 200) {
      _isLoadingMore = true;
      context.read<FetchEventCubit>().fetchMoreEvents();
      // Reset flag after a short delay to allow next load
      Future.delayed(const Duration(seconds: 1), () {
        _isLoadingMore = false;
      });
    }
  }

  // Load unions from API
  Future<void> _loadUnions() async {
    try {
      final response = await getIt<CmsApiService>().getUnions();
      if (mounted && (response.success ?? false)) {
        setState(() {
          _unions = response.data ?? [];
          _isLoadingUnions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUnions = false);
      }
    }
  }

  // Apply filter
  void _applyFilter() {
    context.read<FetchEventCubit>().setFilter(
          status: _selectedStatus,
          unionId: _selectedUnionId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Filter section
        FilterSection(
          children: [
            // Status filter
            FilterChipWidget(
              label: _selectedStatus == null
                  ? 'Trạng thái'
                  : _getStatusLabel(_selectedStatus!),
              isSelected: _selectedStatus != null,
              onTap: () => _showStatusFilter(),
              icon: Icons.event,
            ),
            const SizedBox(width: 12),

            // Union filter
            FilterChipWidget(
              label: _selectedUnionId == null
                  ? 'Đoàn hội'
                  : _getUnionName(_selectedUnionId!),
              isSelected: _selectedUnionId != null,
              onTap: _isLoadingUnions ? null : () => _showUnionFilter(),
              icon: Icons.business,
            ),

            // Clear filter button
            if (_selectedStatus != null || _selectedUnionId != null) ...[
              const SizedBox(width: 12),
              ClearFilterButton(
                onTap: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedUnionId = null;
                  });
                  _applyFilter();
                },
              ),
            ],
          ],
        ),

        // Events list
        Expanded(
          child: BlocBuilder<FetchEventCubit, FetchEventState>(
            // Only rebuild when events or error changes, not on every state change
            buildWhen: (previous, current) =>
                previous.events != current.events ||
                previous.errorMessage != current.errorMessage ||
                previous.status != current.status,
            builder: (context, state) {
              if (state.errorMessage != null) {
                return BaseError(
                  errorMessage: state.errorMessage!,
                  onTryAgain: () {
                    context.read<FetchEventCubit>().fetchEvents();
                  },
                );
              }

              final events = state.events ?? [];
              final isLoadingMore = state.status == FetchingStatus.loadingMore;
              final itemCount = events.length + (isLoadingMore ? 1 : 0);

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Không có sự kiện nào',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<FetchEventCubit>().fetchEvents(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: itemCount,
                  // Performance optimizations
                  cacheExtent: 500, // Pre-render items within 500px
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index >= events.length && isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: BaseIndicator()),
                      );
                    }

                    final event = events[index];
                    return EventCard(
                      event: event,
                      key: ValueKey(event.id),
                      onTap: () => _navigateToDetail(context, event.id!, event),
                      onRegister: () => _handleRegister(context, event.id!),
                      onUnregister: () => _handleUnregister(context, event.id!),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Show status filter dialog
  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet<String?>(
        title: 'Chọn trạng thái',
        selectedValue: _selectedStatus,
        options: const [
          FilterOption<String?>(
              value: null, label: 'Tất cả', icon: Icons.all_inclusive),
          FilterOption<String?>(
            value: 'upcoming',
            label: 'Sắp diễn ra',
            icon: Icons.schedule,
          ),
          FilterOption<String?>(
            value: 'ongoing',
            label: 'Đang diễn ra',
            icon: Icons.play_circle,
          ),
          FilterOption<String?>(
            value: 'completed',
            label: 'Đã kết thúc',
            icon: Icons.check_circle,
          ),
        ],
        onSelected: (value) {
          setState(() => _selectedStatus = value);
          _applyFilter();
        },
      ),
    );
  }

  // Show union filter dialog
  void _showUnionFilter() {
    final unionOptions = [
      const FilterOption<int?>(
          value: null, label: 'Tất cả', icon: Icons.all_inclusive),
      ..._unions.map(
        (union) => FilterOption<int?>(
          value: union.id,
          label: union.name ?? 'Unknown',
          icon: Icons.business,
        ),
      ),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet<int?>(
        title: 'Chọn đoàn hội',
        selectedValue: _selectedUnionId,
        options: unionOptions,
        onSelected: (value) {
          setState(() => _selectedUnionId = value);
          _applyFilter();
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }

  String _getUnionName(int unionId) {
    final union = _unions.firstWhere(
      (u) => u.id == unionId,
      orElse: () => const UnionDataModel(
        id: null,
        name: 'Unknown',
        description: null,
        logoUrl: null,
        status: null,
      ),
    );
    return union.name ?? 'Unknown';
  }

  // Navigate to event detail screen
  Future<void> _navigateToDetail(
      BuildContext context, int eventId, Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: eventId, event: event),
      ),
    );

    // Refresh list if event was modified
    if (result == true && context.mounted) {
      context.read<FetchEventCubit>().fetchEvents();
    }
  }

  // Extract registration logic for cleaner code
  Future<void> _handleRegister(BuildContext context, int eventId) async {
    try {
      final result = await getIt<CmsApiService>().registerEvent(eventId);

      if (!context.mounted) return;

      if (result.success ?? false) {
        context.read<FetchEventCubit>().fetchEvents();
        Fluttertoast.showToast(
          msg: 'Đăng ký sự kiện thành công',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Đăng ký sự kiện thất bại',
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

  Future<void> _handleUnregister(BuildContext context, int eventId) async {
    try {
      final result = await getIt<CmsApiService>().unregisterEvent(eventId);

      if (!context.mounted) return;

      if (result.success ?? false) {
        context.read<FetchEventCubit>().fetchEvents();
        Fluttertoast.showToast(
          msg: 'Hủy đăng ký sự kiện thành công',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Hủy đăng ký sự kiện thất bại',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
