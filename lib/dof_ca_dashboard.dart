import 'package:auditlab/phase_one_auth/auth/auth_service/auth_service.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:auditlab/phase_one_auth/widgets/dashboard_card.dart';
import 'package:auditlab/phase_one_auth/widgets/join_code_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DOFCADashboard extends StatefulWidget {
  const DOFCADashboard({super.key});

  @override
  State<DOFCADashboard> createState() => _DOFCADashboardState();
}

class _DOFCADashboardState extends State<DOFCADashboard> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _districtData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final userId = authService.currentUser!.uid;

      print('Loading dashboard data for user: $userId');

      final userData = await firestoreService.getUserProfile(userId);
      print('User data loaded: ${userData != null}');

      if (userData != null) {
        print('User district ID: ${userData['districtId']}');
        print('User district code: ${userData['districtCode']}');

        // Try to get district by ID first, then by code as fallback
        Map<String, dynamic>? districtData;

        if (userData['districtId'] != null) {
          districtData = await firestoreService.getDistrict(
            userData['districtId'],
          );
          print('District data by ID: ${districtData != null}');
        }

        // If district not found by ID, try by code
        if (districtData == null && userData['districtCode'] != null) {
          districtData = await firestoreService.getDistrictByCode(
            userData['districtCode'],
          );
          print('District data by code: ${districtData != null}');
        }

        if (mounted) {
          setState(() {
            _userData = userData;
            _districtData = districtData;
            _isLoading = false;
            _errorMessage = districtData == null
                ? 'District data not found'
                : null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User data not found';
          });
        }
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // Safe method to get district ID
  String? get _safeDistrictId {
    if (_districtData == null) return null;
    return _districtData!['districtId'] ?? _districtData!['id'];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Failed to load dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final isDOF = _userData?['role'] == 'DOF';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _districtData?['districtName'] ??
                  _userData?['districtName'] ??
                  'Dashboard',
            ),
            Text(
              _userData?['role'] ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              // Join Code Section
              if (_districtData != null) ...[
                Text(
                  'District Join Code',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                JoinCodeDisplay(
                  joinCode: _districtData!['joinCode'] ?? 'N/A',
                  expiresAt: _getExpiresAt(),
                  onCopy: _copyJoinCode,
                  onGenerate: _generateNewJoinCode,
                ),
                const SizedBox(height: 24),
              ],

              // CA Assignment Section (DOF only)
              if (isDOF && _districtData != null) ...[
                Text(
                  'Assign Chief Accountant (CA)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCAAssignmentSection(),
                const SizedBox(height: 24),
              ],

              // Quick Stats
              if (_districtData != null) ...[
                Text(
                  'Quick Stats',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStatsSection(),
              ],

              // District Data Missing Warning
              if (_districtData == null) ...[
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.warning, size: 48, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text(
                          'District Data Not Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The district information for ${_userData?['districtName'] ?? 'your district'} could not be loaded. '
                          'This might be a temporary issue or the district document might have been deleted.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Reload Data'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _userData?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _userData?['name'] ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, _userData?['email']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, _userData?['phone']),
            if (_userData?['districtName'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, _userData?['districtName']),
            ],
            if (_userData?['districtCode'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.code, _userData?['districtCode']),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _getExpiresAt() {
    if (_districtData?['joinCodeExpiresAt'] == null) return null;
    try {
      if (_districtData!['joinCodeExpiresAt'] is Timestamp) {
        return (_districtData!['joinCodeExpiresAt'] as Timestamp).toDate();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _generateNewJoinCode() async {
    if (_districtData == null || _safeDistrictId == null) return;

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final newCode = await firestoreService.generateNewJoinCode(
        _safeDistrictId!,
      );

      if (mounted) {
        setState(() {
          _districtData!['joinCode'] = newCode;
          _districtData!['joinCodeExpiresAt'] = DateTime.now().add(
            const Duration(hours: 24),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New join code generated!'),
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
    }
  }

  void _copyJoinCode() {
    if (_districtData == null) return;

    final joinCode = _districtData!['joinCode'];
    if (joinCode != null) {
      Clipboard.setData(ClipboardData(text: joinCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join code copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCAAssignmentSection() {
    if (_safeDistrictId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'District data not available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder(
      stream: firestoreService.streamDistrictMembers(_safeDistrictId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('Error loading members: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No staff members yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        // ... rest of the CA assignment section code remains the same
        // Filter eligible users: Accountants with "Other" (000) sector
        final eligibleUsers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final role = data['role'];
          final sectorCodes = List<String>.from(data['sectorCodes'] ?? []);
          return role == 'Accountant' && sectorCodes.contains('000');
        }).toList();

        // Find current CA
        final currentCA = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'CA';
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentCA.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Chief Accountant',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                (currentCA.first.data()
                                        as Map<String, dynamic>)['name'] ??
                                    '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _removeCA(currentCA.first.id),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Eligible Accountants (with "Other" sector):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (eligibleUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No eligible accountants. Only accountants with "Other" sector can be assigned as CA.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...eligibleUsers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            (data['name'] as String?)
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(data['name'] ?? 'Unknown'),
                        subtitle: Text(data['email'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () => _assignCA(doc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Assign as CA'),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    if (_safeDistrictId == null) {
      return Row(
        children: [
          Expanded(
            child: DashboardCard(
              title: 'Total Members',
              value: '0',
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardCard(
              title: 'Staff',
              value: '0',
              icon: Icons.badge,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder(
      stream: firestoreService.streamDistrictMembers(_safeDistrictId!),
      builder: (context, snapshot) {
        int totalMembers = 0;
        int dofCount = 0;
        int caCount = 0;
        int staffCount = 0;

        if (snapshot.hasData) {
          totalMembers = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final role = (doc.data() as Map<String, dynamic>)['role'];
            if (role == 'DOF')
              dofCount++;
            else if (role == 'CA')
              caCount++;
            else
              staffCount++;
          }
        }

        return Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Total Members',
                value: totalMembers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardCard(
                title: 'Staff',
                value: staffCount.toString(),
                icon: Icons.badge,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text ?? 'Not provided',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _assignCA(String userId) async {
    if (_safeDistrictId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign CA Role'),
        content: const Text(
          'Are you sure you want to assign this user as Chief Accountant? '
          'They will have the same authorities as DOF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.assignCARole(
        districtId: _safeDistrictId!,
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CA role assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeCA(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove CA Role'),
        content: const Text(
          'Are you sure you want to remove CA role from this user? '
          'They will be reverted to Accountant role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.removeCARole(userId: userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CA role removed successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _signOut() async {
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
