// lib/widgets/notification_list_item.dart
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: notification.isRead
            ? Colors.transparent
            : Theme.of(context).primaryColor.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notification.timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.supervisorAssignment:
        iconData = Icons.supervised_user_circle;
        iconColor = Colors.blue;
        break;
      case NotificationType.chequeAssignment:
        iconData = Icons.assignment_ind;
        iconColor = Colors.green;
        break;
      case NotificationType.issueReported:
        iconData = Icons.error_outline;
        iconColor = Colors.orange;
        break;
      case NotificationType.issueResolved:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case NotificationType.dueReminder:
        iconData = Icons.alarm;
        iconColor = Colors.purple;
        break;
      case NotificationType.statusUpdate:
        iconData = Icons.update;
        iconColor = Colors.teal;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}
