import 'package:auditlab/app_router.dart';
import 'package:auditlab/auth_service.dart';
import 'package:auditlab/firestore_service.dart';
import 'package:auditlab/widgets_role_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }

// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   String? _selectedRole;
//   String? _selectedDistrict;
//   bool _isLoading = false;
//   bool _checkingRoles = false;

//   // Malawian districts
//   final List<Map<String, String>> _malawianDistricts = [
//     {'code': 'BT', 'name': 'Blantyre'},
//     {'code': 'LL', 'name': 'Lilongwe'},
//     {'code': 'MZ', 'name': 'Mzuzu'},
//     {'code': 'ZW', 'name': 'Zomba'},
//     {'code': 'KR', 'name': 'Karonga'},
//     {'code': 'KS', 'name': 'Kasungu'},
//     {'code': 'MG', 'name': 'Mangochi'},
//     {'code': 'SM', 'name': 'Salima'},
//     {'code': 'NK', 'name': 'Nkhotakota'},
//     {'code': 'RU', 'name': 'Rumphi'},
//     {'code': 'MH', 'name': 'Mchinji'},
//     {'code': 'DC', 'name': 'Dedza'},
//     {'code': 'NT', 'name': 'Ntcheu'},
//     {'code': 'BA', 'name': 'Balaka'},
//     {'code': 'MN', 'name': 'Mulanje'},
//     {'code': 'TH', 'name': 'Thyolo'},
//     {'code': 'PH', 'name': 'Phalombe'},
//     {'code': 'CT', 'name': 'Chitipa'},
//     {'code': 'LK', 'name': 'Likoma'},
//     {'code': 'NZ', 'name': 'Nsanje'},
//     {'code': 'CH', 'name': 'Chikwawa'},
//   ];

//   List<Map<String, dynamic>> _availableRoles = [];
//   List<Map<String, dynamic>> _allRoles = [
//     {
//       'role': 'DOF',
//       'title': 'Director of Finance',
//       'description': 'District administrator with full access',
//       'icon': Icons.admin_panel_settings,
//       'color': Colors.blue,
//     },
//     {
//       'role': 'CA',
//       'title': 'Chief Accountant',
//       'description': 'Chief financial officer for the district',
//       'icon': Icons.manage_accounts,
//       'color': Colors.purple,
//     },
//     {
//       'role': 'Accountant',
//       'title': 'Accountant',
//       'description': 'Manage financial records and reports',
//       'icon': Icons.calculate,
//       'color': Colors.teal,
//     },
//     {
//       'role': 'Assistant Accountant',
//       'title': 'Assistant Accountant',
//       'description': 'Assist with financial record management',
//       'icon': Icons.account_balance_wallet,
//       'color': Colors.green,
//     },
//     {
//       'role': 'Accounts Assistant',
//       'title': 'Accounts Assistant',
//       'description': 'Support accounting operations',
//       'icon': Icons.assignment,
//       'color': Colors.orange,
//     },
//     {
//       'role': 'Intern',
//       'title': 'Intern',
//       'description': 'Limited access for learning purposes',
//       'icon': Icons.school,
//       'color': Colors.pink,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _availableRoles = List.from(_allRoles);
//   }

//   Future<void> _checkExistingRoles() async {
//     if (_selectedDistrict == null) return;

//     setState(() {
//       _checkingRoles = true;
//       _selectedRole = null;
//     });

//     try {
//       final firestoreService = Provider.of<FirestoreService>(
//         context,
//         listen: false,
//       );

//       // Check for existing DOF and CA in the selected district
//       final existingDOF = await firestoreService.checkExistingRoleInDistrict(
//         _selectedDistrict!,
//         'DOF',
//       );

//       final existingCA = await firestoreService.checkExistingRoleInDistrict(
//         _selectedDistrict!,
//         'CA',
//       );

//       setState(() {
//         _availableRoles = _allRoles.where((roleData) {
//           final role = roleData['role'];
//           if (role == 'DOF' && existingDOF) return false;
//           if (role == 'CA' && existingCA) return false;
//           return true;
//         }).toList();
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error checking district roles: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _checkingRoles = false);
//       }
//     }
//   }

//   Future<void> _confirmRole() async {
//     if (_selectedDistrict == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please select a district')));
//       return;
//     }

//     if (_selectedRole == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please select a role')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final authService = Provider.of<AuthService>(context, listen: false);
//       final firestoreService = Provider.of<FirestoreService>(
//         context,
//         listen: false,
//       );
//       final userId = authService.currentUser!.uid;
//       final userEmail = authService.currentUser!.email!;

//       // Check if we need to create district document
//       final isDOF = _selectedRole == 'DOF';
//       final isCA = _selectedRole == 'CA';
//       final districtName = _getDistrictName(_selectedDistrict!);

//       if (isDOF || isCA) {
//         final otherRole = isDOF ? 'CA' : 'DOF';
//         final otherRoleExists = await firestoreService
//             .checkExistingRoleInDistrict(_selectedDistrict!, otherRole);

//         if (!otherRoleExists) {
//           // Create district document
//           await firestoreService.createDistrict(
//             districtName: districtName,
//             districtCode: _selectedDistrict!,
//             createdBy: userId,
//           );
//         }
//       }

//       // Save role selection and district
//       await firestoreService.updateUserRoleAndDistrict(
//         userId,
//         _selectedRole!,
//         userEmail,
//         _selectedDistrict!,
//         districtName,
//       );

//       // Wait for the user doc to exist and role field to be present
//       final userDocRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId);
//       final sw = Stopwatch()..start();
//       while (sw.elapsed.inSeconds < 5) {
//         final snap = await userDocRef.get();
//         if (snap.exists && snap.data()?['role'] == _selectedRole) {
//           break;
//         }
//         await Future.delayed(const Duration(milliseconds: 250));
//       }

//       if (!mounted) return;

//       // Navigate to profile setup
//       Navigator.of(context).pushReplacementNamed(AppRouter.profileSetup);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   String _getDistrictName(String districtCode) {
//     return _malawianDistricts.firstWhere(
//       (district) => district['code'] == districtCode,
//       orElse: () => {'name': 'Unknown District'},
//     )['name']!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.person_outline,
//                     size: 64,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Select Your District & Role',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Choose your district and position to continue',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),

//             // District Selection
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Select District',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _selectedDistrict,
//                         isExpanded: true,
//                         hint: const Text('Choose your district'),
//                         items: _malawianDistricts.map((district) {
//                           return DropdownMenuItem<String>(
//                             value: district['code'],
//                             child: Text(
//                               '${district['name']} (${district['code']})',
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             _selectedDistrict = newValue;
//                             _selectedRole = null;
//                           });
//                           _checkExistingRoles();
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),

//             // Role Cards
//             if (_checkingRoles) ...[
//               const Padding(
//                 padding: EdgeInsets.all(24),
//                 child: CircularProgressIndicator(),
//               ),
//               Text(
//                 'Checking available roles...',
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ] else if (_selectedDistrict != null) ...[
//               Expanded(
//                 child: _availableRoles.isEmpty
//                     ? Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.warning, size: 64, color: Colors.orange),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No Available Roles',
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'All administrative roles (DOF and CA) are already filled in this district.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         itemCount: _availableRoles.length,
//                         itemBuilder: (context, index) {
//                           final roleData = _availableRoles[index];
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 12),
//                             child: RoleCard(
//                               role: roleData['role'],
//                               title: roleData['title'],
//                               description: roleData['description'],
//                               icon: roleData['icon'],
//                               color: roleData['color'],
//                               isSelected: _selectedRole == roleData['role'],
//                               onTap: () {
//                                 setState(
//                                   () => _selectedRole = roleData['role'],
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ] else ...[
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         size: 64,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Select a District',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Please select your district to see available roles',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             // Continue Button
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed:
//                       (_selectedDistrict != null &&
//                           _selectedRole != null &&
//                           !_isLoading)
//                       ? _confirmRole
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                       : const Text('Continue', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String? _selectedDistrict;
  bool _isLoading = false;
  bool _checkingRoles = false;
  TextEditingController _districtCodeController = TextEditingController();
  bool _showDistrictCodeInput = false;
  String? _currentDistrictJoinCode;

  // Malawian districts
  final List<Map<String, String>> _malawianDistricts = [
    {'code': 'BT', 'name': 'Blantyre'},
    {'code': 'LL', 'name': 'Lilongwe'},
    {'code': 'MZ', 'name': 'Mzuzu'},
    {'code': 'ZW', 'name': 'Zomba'},
    {'code': 'KR', 'name': 'Karonga'},
    {'code': 'KS', 'name': 'Kasungu'},
    {'code': 'MG', 'name': 'Mangochi'},
    {'code': 'SM', 'name': 'Salima'},
    {'code': 'NK', 'name': 'Nkhotakota'},
    {'code': 'RU', 'name': 'Rumphi'},
    {'code': 'MH', 'name': 'Mchinji'},
    {'code': 'DC', 'name': 'Dedza'},
    {'code': 'NT', 'name': 'Ntcheu'},
    {'code': 'BA', 'name': 'Balaka'},
    {'code': 'MN', 'name': 'Mulanje'},
    {'code': 'TH', 'name': 'Thyolo'},
    {'code': 'PH', 'name': 'Phalombe'},
    {'code': 'CT', 'name': 'Chitipa'},
    {'code': 'LK', 'name': 'Likoma'},
    {'code': 'NZ', 'name': 'Nsanje'},
    {'code': 'CH', 'name': 'Chikwawa'},
  ];

  List<Map<String, dynamic>> _availableRoles = [];
  List<Map<String, dynamic>> _allRoles = [
    {
      'role': 'DOF',
      'title': 'Director of Finance',
      'description': 'District administrator with full access',
      'icon': Icons.admin_panel_settings,
      'color': Colors.blue,
    },
    {
      'role': 'CA',
      'title': 'Chief Accountant',
      'description': 'Chief financial officer for the district',
      'icon': Icons.manage_accounts,
      'color': Colors.purple,
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

  @override
  void initState() {
    super.initState();
    _availableRoles = List.from(_allRoles);
  }

  Future<void> _checkExistingRoles() async {
    if (_selectedDistrict == null) return;

    setState(() {
      _checkingRoles = true;
      _selectedRole = null;
      _showDistrictCodeInput = false;
      _currentDistrictJoinCode = null;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );

      // Check for existing DOF and CA in the selected district
      final existingDOF = await firestoreService.checkExistingRoleInDistrict(
        _selectedDistrict!,
        'DOF',
      );

      final existingCA = await firestoreService.checkExistingRoleInDistrict(
        _selectedDistrict!,
        'CA',
      );

      // Get current district join code if district exists
      final districtData = await firestoreService.getDistrictByCode(
        _selectedDistrict!,
      );
      if (districtData != null) {
        setState(() {
          _currentDistrictJoinCode = districtData['joinCode'];
        });
      }

      setState(() {
        _availableRoles = _allRoles.where((roleData) {
          final role = roleData['role'];
          if (role == 'DOF' && existingDOF) return false;
          if (role == 'CA' && existingCA) return false;
          return true;
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking district: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingRoles = false);
      }
    }
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
      // Show district code input for non-DOF/CA roles
      _showDistrictCodeInput = (role != 'DOF' && role != 'CA');
      if (!_showDistrictCodeInput) {
        _districtCodeController.clear();
      }
    });
  }

  Future<void> _confirmRole() async {
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a district')));
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    // For non-DOF/CA roles, require district code
    if (_showDistrictCodeInput && _districtCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter district join code')),
      );
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

      final districtName = _getDistrictName(_selectedDistrict!);
      final isDOF = _selectedRole == 'DOF';
      final isCA = _selectedRole == 'CA';

      String districtId;
      String districtCodeToUse = _selectedDistrict!;

      // For DOF/CA: Create district document if needed
      if (isDOF || isCA) {
        final otherRole = isDOF ? 'CA' : 'DOF';
        final otherRoleExists = await firestoreService
            .checkExistingRoleInDistrict(_selectedDistrict!, otherRole);

        // Check if district already exists
        final existingDistrict = await firestoreService.getDistrictByCode(
          _selectedDistrict!,
        );

        if (existingDistrict == null) {
          // Create new district with generated join code
          districtId = await firestoreService.createDistrict(
            districtName: districtName,
            districtCode: _selectedDistrict!,
            createdBy: userId,
          );
        } else {
          districtId = existingDistrict['districtId'];
          // Update district if current user is the first admin
          if (!otherRoleExists) {
            await firestoreService.updateDistrictAdmin(
              districtId: districtId,
              adminUserId: userId,
              adminRole: _selectedRole!,
            );
          }
        }
      } else {
        // For other roles: Validate district join code
        final enteredCode = _districtCodeController.text.trim().toUpperCase();

        final districtData = await firestoreService.validateDistrictJoinCode(
          districtCode: _selectedDistrict!,
          joinCode: enteredCode,
        );

        if (districtData == null) {
          throw Exception(
            'Invalid join code. Please check with your district administrator.',
          );
        }

        districtId = districtData['districtId'];
      }

      // Save role selection and district
      await firestoreService.updateUserRoleAndDistrict(
        userId,
        _selectedRole!,
        userEmail,
        districtCodeToUse,
        districtName,
        districtId,
      );

      // Wait for the user doc to exist and role field to be present
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
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

  String _getDistrictName(String districtCode) {
    return _malawianDistricts.firstWhere(
      (district) => district['code'] == districtCode,
      orElse: () => {'name': 'Unknown District'},
    )['name']!;
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
                    'Select Your District & Role',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your district and position to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // District Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select District',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDistrict,
                        isExpanded: true,
                        hint: const Text('Choose your district'),
                        items: _malawianDistricts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district['code'],
                            child: Text(
                              '${district['name']} (${district['code']})',
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                            _selectedRole = null;
                            _showDistrictCodeInput = false;
                            _districtCodeController.clear();
                          });
                          _checkExistingRoles();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Current District Info
            if (_selectedDistrict != null &&
                _currentDistrictJoinCode != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'District exists. Current join code: ${_currentDistrictJoinCode}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // District Code Input (for non-DOF/CA roles)
            if (_showDistrictCodeInput) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter District Join Code',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _districtCodeController,
                      decoration: InputDecoration(
                        hintText:
                            'Enter current join code for ${_getDistrictName(_selectedDistrict!)}',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vpn_key),
                        suffixIcon: _currentDistrictJoinCode != null
                            ? Tooltip(
                                message:
                                    'Current code: $_currentDistrictJoinCode',
                                child: Icon(
                                  Icons.help_outline,
                                  color: Colors.blue,
                                ),
                              )
                            : null,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ask your DOF/CA for the current join code. Codes expire every 24 hours.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],

            // Role Cards
            if (_checkingRoles) ...[
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
              Text(
                'Checking district information...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else if (_selectedDistrict != null) ...[
              Expanded(
                child: _availableRoles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, size: 64, color: Colors.orange),
                            const SizedBox(height: 16),
                            Text(
                              'No Available Roles',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All administrative roles (DOF and CA) are already filled in this district.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _availableRoles.length,
                        itemBuilder: (context, index) {
                          final roleData = _availableRoles[index];
                          final isAdminRole =
                              roleData['role'] == 'DOF' ||
                              roleData['role'] == 'CA';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RoleCard(
                              role: roleData['role'],
                              title: roleData['title'],
                              description: roleData['description'],
                              icon: roleData['icon'],
                              color: roleData['color'],
                              isSelected: _selectedRole == roleData['role'],
                              onTap: () => _onRoleSelected(roleData['role']),
                              showAdminBadge: isAdminRole,
                            ),
                          );
                        },
                      ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a District',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please select your district to see available roles',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedDistrict != null &&
                          _selectedRole != null &&
                          (!_showDistrictCodeInput ||
                              _districtCodeController.text.isNotEmpty) &&
                          !_isLoading)
                      ? _confirmRole
                      : null,
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
