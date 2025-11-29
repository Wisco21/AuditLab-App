import 'package:auditlab/auth_service.dart';
import 'package:auditlab/firestore_service.dart';
import 'package:auditlab/widgets_ca_request_card.dart';
import 'package:auditlab/widgets_dashboard_card.dart';
import 'package:auditlab/widgets_join_code_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DOFCADashboard extends StatefulWidget {
  const DOFCADashboard({super.key});

  @override
  State<DOFCADashboard> createState() => _DOFCADashboardState();
}

class _DOFCADashboardState extends State<DOFCADashboard> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _districtData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final userId = authService.currentUser!.uid;

    try {
      final userData = await firestoreService.getUserProfile(userId);
      if (userData != null) {
        final districtData = await firestoreService.getDistrict(
          userData['districtId'],
        );
        setState(() {
          _userData = userData;
          _districtData = districtData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _generateNewJoinCode() async {
    if (_districtData == null) return;

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final newCode = await firestoreService.generateNewJoinCode(
        _districtData!['districtId'],
      );

      setState(() {
        _districtData!['joinCode'] = newCode;
        _districtData!['joinCodeExpiresAt'] = DateTime.now().add(
          const Duration(hours: 24),
        );
      });

      if (mounted) {
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

    Clipboard.setData(ClipboardData(text: _districtData!['joinCode']));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join code copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleCARequest(
    String requestId,
    String userId,
    bool approve,
  ) async {
    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.updateCARequestStatus(
        districtId: _districtData!['districtId'],
        requestId: requestId,
        status: approve ? 'approved' : 'rejected',
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'CA request approved!' : 'CA request rejected',
            ),
            backgroundColor: approve ? Colors.green : Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDOF = _userData?['role'] == 'DOF';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_districtData?['districtName'] ?? 'Dashboard'),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              _userData?['name']
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
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
                                  _userData?['name'] ?? '',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Join Code Section
              Text(
                'District Join Code',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              JoinCodeDisplay(
                joinCode: _districtData?['joinCode'] ?? '',
                expiresAt: (_districtData?['joinCodeExpiresAt'] as dynamic)
                    ?.toDate(),
                onCopy: _copyJoinCode,
                onGenerate: _generateNewJoinCode,
              ),
              const SizedBox(height: 24),

              // CA Requests Section (DOF only)
              if (isDOF) ...[
                Text(
                  'CA Role Requests',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCARequestsSection(),
                const SizedBox(height: 24),
              ],

              // Quick Stats
              Text(
                'Quick Stats',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildCARequestsSection() {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder(
      stream: firestoreService.streamPendingCARequests(
        _districtData!['districtId'],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No pending CA requests',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CARequestCard(
              requestId: doc.id,
              userId: data['userId'],
              requestedAt: (data['requestedAt'] as dynamic)?.toDate(),
              onApprove: () => _handleCARequest(doc.id, data['userId'], true),
              onReject: () => _handleCARequest(doc.id, data['userId'], false),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder(
      stream: firestoreService.streamDistrictMembers(
        _districtData!['districtId'],
      ),
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
}
