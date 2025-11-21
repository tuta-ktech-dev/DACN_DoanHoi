import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/event_detail/event_detail_cubit.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/config/theme/app_colors.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';

class EventDetailScreen extends StatelessWidget {
  final int eventId;
  final Event? event; // Optional for hero animation

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EventDetailCubit>()..fetchEventDetail(eventId),
      child: EventDetailView(initialEvent: event),
    );
  }
}

class EventDetailView extends StatefulWidget {
  final Event? initialEvent;

  const EventDetailView({super.key, this.initialEvent});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<EventDetailCubit, EventDetailState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.event != current.event,
        builder: (context, state) {
          // Show error state
          if (state.status == FetchingStatus.error) {
            return _buildErrorState(state.errorMessage ?? 'Có lỗi xảy ra');
          }

          // Show loading state on initial load
          if (state.status == FetchingStatus.loading && state.event == null) {
            return _buildLoadingState();
          }

          // Use initial event if available, otherwise use state event
          final event = state.event ?? widget.initialEvent;

          if (event == null) {
            return _buildErrorState('Không tìm thấy sự kiện');
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<EventDetailCubit>().fetchEventDetail(event.id!),
            child: CustomScrollView(
              slivers: [
                // App bar with hero image
                _buildSliverAppBar(event, theme),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and organization
                      _buildTitleSection(event, theme),

                      // Info cards
                      _buildInfoCards(event, theme),

                      // Registration details
                      if (event.registration != null)
                        _buildRegistrationDetails(event, theme),

                      // Description
                      _buildDescription(event, theme),

                      // Bottom padding for action buttons
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Action buttons
      bottomNavigationBar: BlocBuilder<EventDetailCubit, EventDetailState>(
        builder: (context, state) {
          final event = state.event ?? widget.initialEvent;
          if (event == null) return const SizedBox.shrink();

          return _buildActionButtons(event, theme);
        },
      ),
    );
  }

  // Build sliver app bar with image
  Widget _buildSliverAppBar(Event event, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: theme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context, true), // Return true if changed
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            if (event.imageUrl != null)
              CachedNetworkImage(
                imageUrl: event.imageUrl!,
                fit: BoxFit.cover,
                memCacheHeight: 450,
                memCacheWidth: 800,
                maxHeightDiskCache: 450,
                maxWidthDiskCache: 800,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, size: 80, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.event, size: 80, color: Colors.grey),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build title section
  Widget _buildTitleSection(Event event, ThemeData theme) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                _StatusBadge(
                  status: event.status?.value ?? '',
                  color: _getStatusColor(event.status?.value),
                ),
                const Spacer(),
                if (event.registration?.status == RegistrationStatus.approved)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Đã đăng ký',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              event.title ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Organization
            if (event.union != null)
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổ chức bởi',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          event.union!.name ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Build info cards
  Widget _buildInfoCards(Event event, ThemeData theme) {
    final startDate = event.startDate != null
        ? _dateFormatter.format(event.startDate!.toLocal())
        : 'N/A';
    final endDate = event.endDate != null
        ? _dateFormatter.format(event.endDate!.toLocal())
        : 'N/A';

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _InfoCard(
              icon: Icons.access_time,
              title: 'Thời gian',
              content: 'Bắt đầu: $startDate\nKết thúc: $endDate',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.location_on,
              title: 'Địa điểm',
              content: event.location ?? 'Chưa xác định',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.group,
                    title: 'Số lượng',
                    content:
                        '${event.currentParticipants ?? 0}/${event.maxParticipants ?? 0}',
                    color: Colors.green,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.star,
                    title: 'Điểm rèn luyện',
                    content: event.activityPoints ?? '0',
                    color: Colors.orange,
                    compact: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build registration details
  Widget _buildRegistrationDetails(Event event, ThemeData theme) {
    final registration = event.registration;
    if (registration == null) return const SizedBox.shrink();

    final status = registration.status;
    Color bgColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case RegistrationStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'Đang chờ xét duyệt';
        statusIcon = Icons.schedule;
        break;
      case RegistrationStatus.approved:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = 'Đã đăng ký thành công';
        statusIcon = Icons.check_circle;
        break;
      case RegistrationStatus.rejected:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = 'Đã bị từ chối';
        statusIcon = Icons.cancel;
        break;
      case RegistrationStatus.cancelled:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        statusText = 'Đã bị hủy';
        statusIcon = Icons.block;
        break;
      default:
        return const SizedBox.shrink();
    }

    // Format registered date
    final registeredDate = registration.registeredAt != null
        ? _dateFormatter.format(registration.registeredAt!.toLocal())
        : 'N/A';

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: textColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trạng thái đăng ký',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Registration details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Registration ID
                  if (registration.id != null)
                    _RegistrationInfoRow(
                      icon: Icons.tag,
                      label: 'Mã đăng ký',
                      value: '#${registration.id}',
                      color: textColor,
                    ),

                  // Registered date
                  if (registration.registeredAt != null) ...[
                    if (registration.id != null) const SizedBox(height: 12),
                    _RegistrationInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Ngày đăng ký',
                      value: registeredDate,
                      color: textColor,
                    ),
                  ],

                  // Notes
                  if (registration.notes != null &&
                      registration.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: textColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note, size: 20, color: textColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ghi chú',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  registration.notes!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build description
  Widget _buildDescription(Event event, ThemeData theme) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mô tả',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.description ?? 'Không có mô tả',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build action buttons
  Widget _buildActionButtons(Event event, ThemeData theme) {
    final isCompleted = event.status == EventStatus.completed;
    final isFull =
        (event.currentParticipants ?? 0) >= (event.maxParticipants ?? 0);

    // Determine if user has active registration (approved or pending)
    final hasActiveRegistration = event.registration != null &&
        (event.registration!.status == RegistrationStatus.approved ||
            event.registration!.status == RegistrationStatus.pending);

    // Can register if: not completed, not full, no active registration, and not processing
    final canRegister =
        !isCompleted && !isFull && !hasActiveRegistration && !_isProcessing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : !hasActiveRegistration
                ? SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          canRegister ? () => _handleRegister(event.id!) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isCompleted
                            ? 'Sự kiện đã kết thúc'
                            : isFull
                                ? 'Đã hết chỗ'
                                : 'Đăng ký tham gia',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: !_isProcessing
                          ? () => _handleUnregister(event.id!)
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy đăng ký',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // Handle register
  Future<void> _handleRegister(int eventId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: const Text('Bạn có chắc chắn muốn đăng ký sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final result = await getIt<CmsApiService>().registerEvent(eventId);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (result.success ?? false) {
        // Refresh event detail
        if (mounted) {
          context.read<EventDetailCubit>().fetchEventDetail(eventId);
        }

        Fluttertoast.showToast(
          msg: 'Đăng ký sự kiện thành công!',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: result.message ?? 'Đăng ký sự kiện thất bại',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  // Handle unregister
  Future<void> _handleUnregister(int eventId) async {
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

    setState(() => _isProcessing = true);

    try {
      final result = await getIt<CmsApiService>().unregisterEvent(eventId);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (result.success ?? false) {
        // Refresh event detail
        if (mounted) {
          context.read<EventDetailCubit>().fetchEventDetail(eventId);
        }

        Fluttertoast.showToast(
          msg: 'Hủy đăng ký sự kiện thành công!',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: result.message ?? 'Hủy đăng ký sự kiện thất bại',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      Fluttertoast.showToast(
        msg: 'Có lỗi xảy ra: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  // Build loading state
  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Build error state
  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Chi tiết sự kiện',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BaseError(
        errorMessage: message,
        onTryAgain: () {
          // Get eventId from context or widget
          final eventId = widget.initialEvent?.id;
          if (eventId != null) {
            context.read<EventDetailCubit>().fetchEventDetail(eventId);
          }
        },
      ),
    );
  }

  // Get status color
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  String get _statusText {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final bool compact;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: compact ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Registration Info Row Widget
class _RegistrationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RegistrationInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
