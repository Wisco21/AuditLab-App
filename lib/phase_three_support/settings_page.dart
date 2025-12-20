// File: settings_screen.dart

import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:auditlab/phase_two_core_features/provider/district_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final userRole = ref.watch(userRoleProvider);
    final districtId = ref.watch(userDistrictIdProvider);
    final districtDataAsync = ref.watch(userDistrictDataProvider); // Change this

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 2),
      body: userDataAsync.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('User data not available'));
          }

          final isSupervisor =
              userRole.value == 'DOF' || userRole.value == 'CA';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section (All Users)
                _buildSectionHeader(context, 'Profile'),
                const SizedBox(height: 12),
                _ProfileSection(userData: userData),
                const SizedBox(height: 24),

                // District Management (DOF/CA Only)
                if (isSupervisor && districtId.value != null) ...[
                  _buildSectionHeader(context, 'District Management'),
                  const SizedBox(height: 12),
                  _DistrictManagementSection(
                    // districtId: districtId.value!,
                    userData: userData,
                  ),
                  const SizedBox(height: 24),
                ],

                // User Management (DOF/CA Only)
                if (isSupervisor && districtId.value != null) ...[
                  _buildSectionHeader(context, 'User Management'),
                  const SizedBox(height: 12),
                  _UserManagementSection(districtId: districtId.value!,),
                  const SizedBox(height: 24),
                ],

                // Sector Configuration (DOF/CA Only)
                if (isSupervisor) ...[
                  _buildSectionHeader(context, 'Sector Configuration'),
                  const SizedBox(height: 12),
                  _SectorConfigurationSection(),
                  const SizedBox(height: 24),
                ],

                // Issue Types (DOF/CA Only)
                if (isSupervisor) ...[
                  _buildSectionHeader(context, 'Issue Types'),
                  const SizedBox(height: 12),
                  _IssueTypesSection(),
                  const SizedBox(height: 24),
                ],

                // App Settings (All Users)
                _buildSectionHeader(context, 'App Settings'),
                const SizedBox(height: 12),
                _AppSettingsSection(),
                const SizedBox(height: 24),

                // Danger Zone
                _buildSectionHeader(context, 'Account', color: Colors.red),
                const SizedBox(height: 12),
                _DangerZoneSection(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    Color? color,
  }) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

// Profile Section
class _ProfileSection extends ConsumerWidget {
  final Map<String, dynamic> userData;

  const _ProfileSection({required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                (userData['name'] as String?)?.substring(0, 1).toUpperCase() ??
                    'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              userData['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(userData['role'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProfileDialog(context, ref, userData),
            ),
          ),
          const Divider(height: 1),
          _ProfileInfoTile(
            icon: Icons.email,
            label: 'Email',
            value: userData['email'] ?? 'N/A',
          ),
          _ProfileInfoTile(
            icon: Icons.phone,
            label: 'Phone',
            value: userData['phone'] ?? 'N/A',
          ),
          _ProfileInfoTile(
            icon: Icons.location_city,
            label: 'District',
            value: userData['districtName'] ?? 'N/A',
          ),
          if (userData['sectorCodes'] != null)
            _ProfileInfoTile(
              icon: Icons.business,
              label: 'Sectors',
              value: (userData['sectorCodes'] as List)
                  .map((code) => Sector.getByCode(code)?.displayName ?? code)
                  .join(', '),
            ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> userData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EditProfileSheet(userData: userData),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600], size: 20),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Edit Profile Sheet
class _EditProfileSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const _EditProfileSheet({required this.userData});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(currentUserDataProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// District Management Section - UPDATED VERSION
class _DistrictManagementSection extends ConsumerWidget {
  final Map<String, dynamic> userData;

  const _DistrictManagementSection({
    required this.userData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtDataAsync = ref.watch(userDistrictDataProvider);

    return districtDataAsync.when(
      data: (districtData) {
        if (districtData == null) {
          return _buildDistrictNotAvailableCard();
        }

        final joinCode = districtData['joinCode'] as String?;
        final expiresAt = districtData['joinCodeExpiresAt'] as Timestamp?;
        final districtId = districtData['districtId'] as String?;
        final districtName = districtData['districtName'] as String?;

        if (districtId == null) {
          return _buildDistrictNotAvailableCard();
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_city, color: Colors.blue),
                ),
                title: Text(
                  districtName ?? 'District',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ID: ${districtData['districtCode'] ?? 'N/A'}'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.vpn_key, color: Colors.green),
                ),
                title: const Text(
                  'District Join Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(joinCode ?? 'N/A'),
                    if (expiresAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Expires: ${DateFormat('MMM d, y h:mm a').format(expiresAt.toDate())}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (joinCode != null)
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyJoinCode(context, joinCode),
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _generateNewJoinCode(
                        context,
                        districtId,
                        ref,
                      ),
                    ),
                  ],
                ),
              ),
              // Add more district info if needed
              if (districtData['createdBy'] != null)
                ListTile(
                  leading: const Icon(Icons.person, size: 20),
                  title: const Text('Created By'),
                  subtitle: Text(districtData['createdBy']),
                ),
              if (districtData['createdAt'] != null)
                ListTile(
                  leading: const Icon(Icons.calendar_today, size: 20),
                  title: const Text('Created On'),
                  subtitle: Text(
                    DateFormat('MMM d, y').format(
                      (districtData['createdAt'] as Timestamp).toDate(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Error loading district data',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictNotAvailableCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              'District Data Not Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The district information could not be loaded. This might be a temporary issue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _copyJoinCode(BuildContext context, String joinCode) {
    Clipboard.setData(ClipboardData(text: joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _generateNewJoinCode(
    BuildContext context,
    String districtId,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Join Code?'),
        content: const Text(
          'This will invalidate the current join code and create a new one valid for 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestoreService = FirestoreService();
      await firestoreService.generateNewJoinCode(districtId);

      // Refresh district data
      ref.invalidate(userDistrictDataProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New join code generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// Continue in next part...
class _UserManagementSection extends ConsumerWidget {
  final String districtId;
  

  const _UserManagementSection({required this.districtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('districtId', isEqualTo: districtId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final users = snapshot.data!.docs;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: Colors.purple),
                ),
                title: const Text(
                  'District Members',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${users.length} members'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUserListDialog(context, users),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserListDialog(
    BuildContext context,
    List<QueryDocumentSnapshot> users,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'District Members (${users.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData =
                          users[index].data() as Map<String, dynamic>;
                      return _UserListTile(
                        userData: userData,
                        userId: users[index].id,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

// // User Management Section - UPDATED
// class _UserManagementSection extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final districtDataAsync = ref.watch(userDistrictDataProvider);

//     return districtDataAsync.when(
//       data: (districtData) {
//         if (districtData == null) {
//           return _buildDistrictNotAvailableCard();
//         }

//         final districtId = districtData['districtId'] as String?;
//         if (districtId == null) {
//           return _buildDistrictNotAvailableCard();
//         }

//         return StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('users')
//               .where('districtId', isEqualTo: districtId)
//               .snapshots(),
//           builder: (context, snapshot) {
//             // ... rest of your user management code remains the same
//             if (!snapshot.hasData) {
//               return const Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               );
//             }

//             final users = snapshot.data!.docs;

//             return Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(Icons.people, color: Colors.purple),
//                     ),
//                     title: const Text(
//                       'District Members',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text('${users.length} members'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () => _showUserListDialog(context, users),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       loading: () => const Card(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       ),
//       error: (error, stack) => Card(
//         color: Colors.red.shade50,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Icon(Icons.error, color: Colors.red),
//               const SizedBox(height: 8),
//               Text(
//                 'Error loading district data',
//                 style: TextStyle(color: Colors.red[700]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDistrictNotAvailableCard() {
//     return Card(
//       color: Colors.orange.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Icon(Icons.warning, size: 48, color: Colors.orange),
//             const SizedBox(height: 12),
//             Text(
//               'District Not Available',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange.shade700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Cannot load user management without district data',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // ... rest of your _UserManagementSection code
  
//   void _showUserListDialog(
//     BuildContext context,
//     List<QueryDocumentSnapshot> users,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) {
//           return Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'District Members (${users.length})',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: scrollController,
//                     itemCount: users.length,
//                     itemBuilder: (context, index) {
//                       final userData =
//                           users[index].data() as Map<String, dynamic>;
//                       return _UserListTile(
//                         userData: userData,
//                         userId: users[index].id,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

// }

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const _UserListTile({required this.userData, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(userData['role']),
          child: Text(
            (userData['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          userData['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userData['email'] ?? ''),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(userData['role']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userData['role'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getRoleColor(userData['role']),
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (userData['role'] != 'DOF')
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Deactivate', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              _showUserDetails(context, userData);
            } else if (value == 'deactivate') {
              _deactivateUser(context, userId, userData['name']);
            }
          },
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
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userData['name'] ?? 'User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Role', userData['role']),
              _DetailRow('Email', userData['email']),
              _DetailRow('Phone', userData['phone']),
              _DetailRow('District', userData['districtName']),
              if (userData['sectorCodes'] != null)
                _DetailRow(
                  'Sectors',
                  (userData['sectorCodes'] as List).join(', '),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deactivateUser(BuildContext context, String userId, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text(
          'Are you sure you want to deactivate ${name ?? 'this user'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement user deactivation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deactivation feature coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}

// Sector Configuration Section
class _SectorConfigurationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.category, color: Colors.teal),
            ),
            title: const Text(
              'Manage Sectors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${Sector.allSectors.length} sectors configured'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSectorManagementDialog(context),
          ),
        ],
      ),
    );
  }

  void _showSectorManagementDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SectorManagementSheet(),
    );
  }
}

class _SectorManagementSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sector Configuration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'View and manage district sectors',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: Sector.allSectors.length,
                  itemBuilder: (context, index) {
                    final sector = Sector.allSectors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: Text(
                            sector.code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        title: Text(
                          sector.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Code: ${sector.code}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showSectorInfo(context, sector),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sector codes are configured at the system level. Contact support to add or modify sectors.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSectorInfo(BuildContext context, Sector sector) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sector.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Sector Code', sector.code),
            _DetailRow('Display Name', sector.displayName),
            const SizedBox(height: 16),
            Text(
              'This sector is used for categorizing cheques and financial records.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Issue Types Section
class _IssueTypesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final issueTypes = [
      ('Missing Signatories', Icons.person_off, Colors.red),
      ('Missing Voucher', Icons.receipt_long, Colors.orange),
      ('Missing Loose Minute', Icons.description, Colors.purple),
      ('Missing Requisition', Icons.request_page, Colors.blue),
      ('Missing Signing Sheet', Icons.assignment, Colors.teal),
      ('No Invoice', Icons.receipt, Colors.pink),
      ('Improper Support', Icons.support, Colors.amber),
      ('Other', Icons.error_outline, Colors.grey),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            title: const Text(
              'Issue Types',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${issueTypes.length} types configured'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showIssueTypesDialog(context, issueTypes),
          ),
        ],
      ),
    );
  }

  void _showIssueTypesDialog(
    BuildContext context,
    List<(String, IconData, Color)> issueTypes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Issue Types',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Available issue types for cheque auditing',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: issueTypes.length,
                    itemBuilder: (context, index) {
                      final issue = issueTypes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: issue.$3.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(issue.$2, color: issue.$3),
                          ),
                          title: Text(
                            issue.$1,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Used for categorizing cheque issues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// App Settings & Danger Zone in next part...

class _AppSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for new assignments'),
            value: true, // TODO: Connect to actual setting
            onChanged: (value) {
              // TODO: Implement notification toggle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: false, // TODO: Connect to actual theme setting
            onChanged: (value) {
              // TODO: Implement theme toggle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme settings coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English (Default)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AuditLab',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A comprehensive audit management system for district financial operations.',
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 AuditLab. All rights reserved.',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

// Danger Zone Section
class _DangerZoneSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.red),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Sign out of your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _signOut(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            subtitle: const Text('Permanently delete your account'),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_open),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_open),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser!;
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );

                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPasswordController.text);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. Your account and all associated data will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will delete:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _BulletPoint('Your profile and personal information'),
                  _BulletPoint('All your assignments'),
                  _BulletPoint('Your activity history'),
                  _BulletPoint('Access to your district'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser!;
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text,
                );

                await user.reauthenticateWithCredential(credential);

                // Delete user document
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .delete();

                // Delete auth account
                await user.delete();

                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
