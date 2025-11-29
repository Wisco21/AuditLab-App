import 'package:auditlab/app_router.dart';
import 'package:auditlab/auth_service.dart';
import 'package:auditlab/firestore_service.dart';
import 'package:auditlab/widgets_role_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': 'DOF',
      'title': 'Director of Finance',
      'description': 'District administrator with full access',
      'icon': Icons.admin_panel_settings,
      'color': Colors.blue,
    },
    {
      'role': 'Accountant',
      'title': 'Accountant',
      'description': 'Manage financial records and reports',
      'icon': Icons.calculate,
      'color': Colors.teal,
    },
    {
      'role': 'Assistant Accountant',
      'title': 'Assistant Accountant',
      'description': 'Assist with financial record management',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'role': 'Accounts Assistant',
      'title': 'Accounts Assistant',
      'description': 'Support accounting operations',
      'icon': Icons.assignment,
      'color': Colors.orange,
    },
    {
      'role': 'Intern',
      'title': 'Intern',
      'description': 'Limited access for learning purposes',
      'icon': Icons.school,
      'color': Colors.pink,
    },
  ];

  // Future<void> _confirmRole() async {
  //   if (_selectedRole == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please select a role')));
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final authService = Provider.of<AuthService>(context, listen: false);
  //     final firestoreService = Provider.of<FirestoreService>(
  //       context,
  //       listen: false,
  //     );
  //     final userId = authService.currentUser!.uid;
  //     final userEmail = authService.currentUser!.email!;

  //     // Save role selection to Firestore (creates document if not exists)
  //     await firestoreService.updateUserRole(userId, _selectedRole!, userEmail);

  //     if (mounted) {
  //       // Navigate to profile setup
  //       Navigator.of(context).pushReplacementNamed(AppRouter.profileSetup);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _confirmRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final userId = authService.currentUser!.uid;
      final userEmail = authService.currentUser!.email!;

      await firestoreService.updateUserRole(userId, _selectedRole!, userEmail);

      // Wait for the user doc to exist and role field to be present
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      // Wait up to ~5 seconds for the doc to appear
      final sw = Stopwatch()..start();
      while (sw.elapsed.inSeconds < 5) {
        final snap = await userDocRef.get();
        if (snap.exists && snap.data()?['role'] == _selectedRole) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }

      if (!mounted) return;

      // Navigate to profile setup
      Navigator.of(context).pushReplacementNamed(AppRouter.profileSetup);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Your Role',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the role that best describes your position',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Role Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final roleData = _roles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoleCard(
                      role: roleData['role'],
                      title: roleData['title'],
                      description: roleData['description'],
                      icon: roleData['icon'],
                      color: roleData['color'],
                      isSelected: _selectedRole == roleData['role'],
                      onTap: () {
                        setState(() => _selectedRole = roleData['role']);
                      },
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
