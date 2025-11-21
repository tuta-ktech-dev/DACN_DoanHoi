import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/screens/events/event_detail_screen.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchEventCubit, FetchEventState>(
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

        return ListView.builder(
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
        );
      },
    );
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
