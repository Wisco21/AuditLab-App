import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/phase_three_support/notification_list_item.dart';
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_cheque_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final NotificationRepository _notificationRepo = NotificationRepository();
  String? _districtId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'mark_all_read') {
                await _notificationRepo.markAllAsRead(user.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                    ),
                  );
                }
              } else if (value == 'clear_all') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications'),
                    content: const Text(
                      'Are you sure you want to clear all notifications?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _notificationRepo.clearAllNotifications(user.uid);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications cleared'),
                      ),
                    );
                  }
                }
              } else if (value == 'settings') {
                _showNotificationSettings(user.uid);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Notification settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildNotificationsList(user.uid),
    );
  }

  Widget _buildNotificationsList(String userId) {
    return StreamBuilder<List<AppNotification>>(
      stream: _notificationRepo.getUserNotifications(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                SelectableText('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notifications about assignments and issues will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationListItem(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () =>
                    _notificationRepo.deleteNotification(notification.id),
              );
            },
          ),
        );
      },
    );
  }

  void _handleNotificationTap(AppNotification notification) async {
    // Mark as read
    if (!notification.isRead) {
      await _notificationRepo.markAsRead(notification.id);
    }

    // Navigate based on notification type
    final chequeNumber = notification.data['chequeNumber'];
    final districtId = notification.data['districtId'];
    
    if (chequeNumber != null && districtId != null) {
      // Find the cheque and navigate
      await _navigateToChequeFromNotification(districtId, chequeNumber);
    }
  }

  Future<void> _navigateToChequeFromNotification(
    String districtId,
    String chequeNumber,
  ) async {
    try {
      // Query for the cheque
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('cheques')
          .where('chequeNumber', isEqualTo: chequeNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cheque not found')),
          );
        }
        return;
      }

      final chequeDoc = querySnapshot.docs.first;
      final cheque = Cheque.fromJson(chequeDoc.data());

      // Get folder data
      final folderDoc = await FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(cheque.periodId)
          .collection('folders')
          .doc(cheque.folderId)
          .get();

      if (!folderDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder not found')),
          );
        }
        return;
      }

      final folder = Folder.fromJson(folderDoc.data()!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChequeDetailsScreen(
              districtId: districtId,
              folder: folder,
              cheque: cheque,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showNotificationSettings(String userId) async {
    final preferences = await _notificationRepo.getPreferences(userId);

    if (!mounted) return;

    final result = await showDialog<NotificationPreferences>(
      context: context,
      builder: (context) => _NotificationSettingsDialog(preferences: preferences),
    );

    if (result != null) {
      await _notificationRepo.updatePreferences(userId, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated')),
        );
      }
    }
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  final NotificationPreferences preferences;

  const _NotificationSettingsDialog({required this.preferences});

  @override
  State<_NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notification Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Supervisor Assignments'),
              subtitle: const Text('When you are assigned as supervisor'),
              value: _preferences.supervisorAssignments,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    supervisorAssignments: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Cheque Assignments'),
              subtitle: const Text('When you are assigned to a cheque'),
              value: _preferences.chequeAssignments,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    chequeAssignments: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Issue Alerts'),
              subtitle: const Text('When issues are reported or resolved'),
              value: _preferences.issueAlerts,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(issueAlerts: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Due Date Reminders'),
              subtitle: const Text('Reminders for upcoming due dates'),
              value: _preferences.dueReminders,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(dueReminders: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Status Updates'),
              subtitle: const Text('When cheque status changes'),
              value: _preferences.statusUpdates,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(statusUpdates: value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _preferences),
          child: const Text('Save'),
        ),
      ],
    );
  }
}