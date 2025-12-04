// lib/screens/my_assignments_screen.dart
import 'package:auditlab/phase2/models/cheque.dart';
import 'package:auditlab/phase2/provider/cheque_provider.dart';
import 'package:auditlab/phase2/provider/user_provider.dart';
import 'package:auditlab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyAssignmentsScreen extends ConsumerWidget {
  const MyAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final districtIdAsync = ref.watch(userDistrictIdProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          final chequesAsync = ref.watch(
            userChequesProvider((districtId: districtId, userId: user.uid)),
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                userChequesProvider((districtId: districtId, userId: user.uid)),
              );
            },
            child: chequesAsync.when(
              data: (cheques) {
                if (cheques.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No assignments yet'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cheques.length,
                  itemBuilder: (context, index) {
                    final cheque = cheques[index];
                    return _AssignmentCard(cheque: cheque);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Cheque cheque;

  const _AssignmentCard({required this.cheque});

  @override
  Widget build(BuildContext context) {
    final hasIssues = cheque.issues.isNotEmpty;
    final openIssues = cheque.issues.where((i) => i.status == 'Open').length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(cheque.status).withOpacity(0.2),
          child: Icon(
            _getStatusIcon(cheque.status),
            color: _getStatusColor(cheque.status),
          ),
        ),
        title: Text('Cheque #${cheque.chequeNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cheque.payee != null) Text(cheque.payee!),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, y').format(cheque.updatedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (hasIssues) ...[
              const SizedBox(height: 4),
              Text(
                '$openIssues open issue(s)',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: _StatusChip(status: cheque.status),
        onTap: () {
          // Navigate to cheque details
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Cleared':
        return Colors.green;
      case 'Has Issues':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Cleared':
        return Icons.check_circle;
      case 'Has Issues':
        return Icons.warning;
      default:
        return Icons.pending;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor()),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'Cleared':
        return Colors.green;
      case 'Has Issues':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// // lib/screens/team_members_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/user_provider.dart';
// import '../services/firestore_service.dart';

class TeamMembersScreen extends ConsumerWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtIdAsync = ref.watch(userDistrictIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Team Members')),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          final firestoreService = FirestoreService();

          return StreamBuilder(
            stream: firestoreService.streamDistrictMembers(districtId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No team members yet'),
                    ],
                  ),
                );
              }

              final members = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final data = members[index].data() as Map<String, dynamic>;
                  return _MemberCard(data: data);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MemberCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(data['role']),
          child: Text(
            (data['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(data['name'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['email'] ?? ''),
            const SizedBox(height: 4),
            _buildRoleBadge(data['role']),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String? role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role ?? 'Unknown',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getRoleColor(role),
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'DOF':
        return Colors.blue;
      case 'CA':
        return Colors.green;
      case 'Accountant':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
