import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/config/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (event.posterUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: event.posterUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.event, size: 60, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.event, size: 60, color: Colors.grey),
              ),
            
            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Row(
                    children: [
                      _buildStatusChip(event.status),
                      const Spacer(),
                      if (event.isRegistered)
                        const Chip(
                          label: Text('Đã đăng ký'),
                          backgroundColor: AppColors.success,
                          labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Event title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Time and location
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDateTime(event.startTime),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Organization and participants
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} người',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        event.organization,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Training points
                  if (event.trainingPoints > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${event.trainingPoints} điểm rèn luyện',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Action buttons
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (event.canAttend && onAttend != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAttend,
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Quét QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        )
                      else if (event.isRegistrationOpen && onRegister != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Đăng ký'),
                          ),
                        )
                      else if (event.isRegistered && event.canCancelRegistration && onUnregister != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onUnregister,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text(
                              'Hủy đăng ký',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
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
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'upcoming':
        color = Colors.blue;
        text = 'Sắp diễn ra';
        break;
      case 'ongoing':
        color = Colors.green;
        text = 'Đang diễn ra';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Đã kết thúc';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }
    
    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    if (event.hasAttended) {
      return 'Đã điểm danh';
    } else if (event.isRegistered && !event.isRegistrationOpen) {
      return 'Đã đăng ký';
    } else if (event.status == 'completed') {
      return 'Đã kết thúc';
    } else if (event.currentParticipants >= event.maxParticipants) {
      return 'Đã đủ người';
    } else {
      return 'Không thể đăng ký';
    }
  }
}