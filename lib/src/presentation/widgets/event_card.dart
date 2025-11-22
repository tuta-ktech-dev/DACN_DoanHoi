import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/config/theme/app_colors.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;
  final VoidCallback? onUnregister;
  final VoidCallback? onAttend;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRegister,
    this.onUnregister,
    this.onAttend,
  });

  // Static date formatter to avoid recreating on every build
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    // Cache theme data to avoid multiple lookups
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;

    // Pre-calculate formatted date
    final formattedDate = event.startDate != null
        ? _dateFormatter.format(event.startDate!.toLocal())
        : '';

    // Pre-calculate status color
    final statusColor = _getStatusColor(event.status?.value);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image - Optimized
              _buildEventImage(),

              // Event details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges
                    _buildStatusRow(statusColor),
                    const SizedBox(height: 8),

                    // Event title
                    Text(
                      event.title ?? '',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Time and location
                    _buildInfoRow(
                      icon: Icons.access_time,
                      text: formattedDate,
                      textStyle: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      text: event.location ?? '',
                      textStyle: textTheme.bodyMedium,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),

                    // Organization and participants
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          event.currentParticipants?.toString() ?? '0',
                          style: textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            event.union?.name ?? '',
                            style: textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Rejection notes if available
                    if (event.registration?.status == RegistrationStatus.rejected &&
                        event.registration?.notes != null &&
                        event.registration!.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lý do từ chối:',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.registration!.notes!,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action buttons
                    const SizedBox(height: 16),
                    Center(child: _buildActionButton(textTheme)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extract image building to separate method for clarity
  Widget _buildEventImage() {
    if (event.imageUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: CachedNetworkImage(
          imageUrl: event.imageUrl!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          // Performance optimization: cache size limits
          memCacheHeight: 240,
          memCacheWidth: 600,
          maxHeightDiskCache: 240,
          maxWidthDiskCache: 600,
          // Static placeholder - no animation
          placeholder: (context, url) => const _ImagePlaceholder(),
          errorWidget: (context, url, error) => const _ImagePlaceholder(),
        ),
      );
    }
    return const _ImagePlaceholder();
  }

  // Build status row with badges
  Widget _buildStatusRow(Color statusColor) {
    // Check both registrationStatus (list) and registration.status (detail)
    final isApproved =
        event.registrationStatus == RegistrationStatus.approved ||
            event.registration?.status == RegistrationStatus.approved;

    return Row(
      children: [
        _StatusBadge(
          status: event.status?.value ?? '',
          color: statusColor,
        ),
        const Spacer(),
        if (isApproved) const _RegistrationBadge(),
      ],
    );
  }

  // Reusable info row widget
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    TextStyle? textStyle,
    int? maxLines,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  // Build action button based on registration status
  Widget _buildActionButton(TextTheme textTheme) {
    // Check both registrationStatus (list) and registration.status (detail)
    final status = event.registration?.status ?? event.registrationStatus;

    switch (status) {
      case null:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("Đăng ký"),
            ));
      case RegistrationStatus.pending:
      case RegistrationStatus.rejected:
      case RegistrationStatus.cancelled:
      case RegistrationStatus.approved:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUnregister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text("Hủy đăng ký",
                  style: TextStyle(color: Colors.white)),
            ));
    }
  }

  // Static method for status color - more efficient than switch in build
  static Color _getStatusColor(String? status) {
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

// Extracted to const widget for better performance
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Icon(Icons.event, size: 60, color: Colors.grey),
    );
  }
}

// Extracted status badge as separate widget with const constructor
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Extracted registration badge as const widget
class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Đã đăng ký',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
