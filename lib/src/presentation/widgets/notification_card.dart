import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:doan_hoi_app/src/domain/entities/notification.dart' as domain;

class NotificationCard extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey[200]! : Colors.blue[200]!,
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon based on type
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and unread indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight:
                                    isRead ? FontWeight.w500 : FontWeight.bold,
                                color:
                                    isRead ? Colors.grey[800] : Colors.black87,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Event info if available
                      if (notification.data != null) ...[
                        _buildEventInfo(notification.data!, theme),
                        const SizedBox(height: 8),
                      ],

                      // Time and action
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(notification.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          if (!isRead && onMarkAsRead != null)
                            TextButton(
                              onPressed: onMarkAsRead,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Đánh dấu đã đọc',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(domain.NotificationData data, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.eventTitle != null) ...[
            Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data.eventTitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (data.eventStartDate != null)
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatEventDate(data.eventStartDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          if (data.eventLocation != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data.eventLocation!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (data.activityPoints != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${data.activityPoints} điểm hoạt động',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTypeIcon(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.registrationSuccess:
        return Icons.check_circle;
      case domain.NotificationType.unregistrationSuccess:
        return Icons.cancel;
      case domain.NotificationType.attendanceSuccess:
        return Icons.verified;
    }
  }

  Color _getTypeColor(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.registrationSuccess:
        return Colors.green;
      case domain.NotificationType.unregistrationSuccess:
        return Colors.red;
      case domain.NotificationType.attendanceSuccess:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    // Use timeago for relative time formatting
    return timeago.format(date, locale: 'vi', allowFromNow: true);
  }

  String _formatEventDate(String eventDateStr) {
    try {
      final eventDate = DateTime.parse(eventDateStr);
      final now = DateTime.now();

      // If event is in the future, show time format
      if (eventDate.isAfter(now)) {
        return 'Bắt đầu lúc ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
      }

      // If event is in the past, show relative time
      return timeago.format(eventDate, locale: 'vi', allowFromNow: true);
    } catch (e) {
      // Fallback to original string if parsing fails
      return eventDateStr;
    }
  }
}
