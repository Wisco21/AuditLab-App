// lib/screens/my_assignments_screen.dart
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
