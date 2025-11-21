part of 'fetch_event_cubit.dart';

enum FetchingStatus {
  initial,
  loading,
  loadingMore,
  success,
  error,
}

final class FetchEventState extends Equatable {
  const FetchEventState({
    this.status = FetchingStatus.initial,
    this.events,
    this.hasMore = true,
    this.page = 1,
    this.limit = 20,
    this.filter = const FetchEventFilter(status: null, unionId: null),
    this.errorMessage,
  });

  final FetchingStatus status;
  final List<Event>? events;
  final bool? hasMore;
  final int? page;
  final int? limit;
  final FetchEventFilter? filter;
  final String? errorMessage;

  FetchEventState copyWith({
    FetchingStatus? status,
    List<Event>? events,
    bool? hasMore,
    int? page,
    int? limit,
    FetchEventFilter? filter,
    String? errorMessage,
  }) =>
      FetchEventState(
        status: status ?? this.status,
        events: events ?? this.events,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        filter: filter ?? this.filter,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, events, hasMore, page, limit, filter];
}

final class FetchEventFilter extends Equatable {
  const FetchEventFilter({
    required this.status,
    required this.unionId,
  });

  final String? status;
  final int? unionId;

  @override
  List<Object?> get props => [status, unionId];
}
