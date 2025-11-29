import 'package:auditlab/app_router.dart';
import 'package:auditlab/auth_service.dart';
import 'package:auditlab/firestore_service.dart';
import 'package:auditlab/models_sector.dart';
import 'package:auditlab/widgets_auth_text_field.dart';
import 'package:auditlab/widgets_primary_button.dart';
import 'package:auditlab/widgets_sector_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class ProfileSetupScreen extends StatefulWidget {
//   const ProfileSetupScreen({super.key});

//   @override
//   State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
// }

// class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _districtNameController = TextEditingController();
//   final _joinCodeController = TextEditingController();

//   String? _userRole;
//   String? _userEmail;
//   bool _isLoading = true;
//   bool _isSaving = false;
//   bool _isAdminRole = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _districtNameController.dispose();
//     _joinCodeController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final firestoreService = Provider.of<FirestoreService>(
//       context,
//       listen: false,
//     );
//     final userId = authService.currentUser!.uid;

//     try {
//       final userData = await firestoreService.getUserProfile(userId);

//       setState(() {
//         if (userData != null) {
//           _userRole = userData['role'];
//           _userEmail = userData['email'] ?? authService.currentUser!.email;
//         } else {
//           // Fallback if user data not found
//           _userEmail = authService.currentUser!.email;
//         }
//         _isAdminRole = _userRole == 'DOF' || _userRole == 'CA';
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (mounted) {
//         // If there's an error, still show the screen with email
//         setState(() {
//           _userEmail = authService.currentUser!.email;
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Please complete your profile setup'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSaving = true);

//     try {
//       final authService = Provider.of<AuthService>(context, listen: false);
//       final firestoreService = Provider.of<FirestoreService>(
//         context,
//         listen: false,
//       );
//       final userId = authService.currentUser!.uid;

//       String districtId;

//       if (_isAdminRole) {
//         // DOF/CA: Create or join district
//         final districtName = _districtNameController.text.trim();

//         // Check if district exists
//         final existingDistrictId = await firestoreService.getDistrictIdByName(
//           districtName,
//         );

//         if (existingDistrictId != null) {
//           districtId = existingDistrictId;
//         } else {
//           // Create new district
//           districtId = await firestoreService.createDistrict(
//             districtName: districtName,
//             createdBy: userId,
//           );
//         }
//       } else {
//         // Other staff: Validate join code
//         final joinCode = _joinCodeController.text.trim().toUpperCase();

//         try {
//           final validatedDistrictId = await firestoreService.validateJoinCode(
//             joinCode,
//           );
//           if (validatedDistrictId == null) {
//             throw Exception('Invalid join code');
//           }
//           districtId = validatedDistrictId;
//         } catch (e) {
//           throw Exception(e.toString().replaceAll('Exception: ', ''));
//         }
//       }

//       // Create user profile
//       await firestoreService.createUserProfile(
//         userId: userId,
//         email: _userEmail!,
//         name: _nameController.text.trim(),
//         phone: _phoneController.text.trim(),
//         role: _userRole!,
//         districtId: districtId,
//         sectorCodes: [],
//       );

//       if (mounted) {
//         // Navigate to appropriate dashboard
//         if (_isAdminRole) {
//           Navigator.of(context).pushReplacementNamed(AppRouter.dofCaDashboard);
//         } else {
//           Navigator.of(context).pushReplacementNamed(AppRouter.staffDashboard);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Complete Your Profile'),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header
//                 Icon(
//                   Icons.account_circle,
//                   size: 80,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Profile Setup',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Please complete your profile to continue',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),

//                 // Name Field
//                 AuthTextField(
//                   controller: _nameController,
//                   label: 'Full Name',
//                   prefixIcon: Icons.person_outline,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your full name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Email Field (Read-only)
//                 AuthTextField(
//                   label: 'Email',
//                   initialValue: _userEmail,
//                   prefixIcon: Icons.email_outlined,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 16),

//                 // Phone Field
//                 AuthTextField(
//                   controller: _phoneController,
//                   label: 'Phone Number',
//                   keyboardType: TextInputType.phone,
//                   prefixIcon: Icons.phone_outlined,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your phone number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Role Field (Read-only)
//                 AuthTextField(
//                   label: 'Role',
//                   initialValue: _userRole,
//                   prefixIcon: Icons.badge_outlined,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 24),

//                 // District Section
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.shade200),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_city,
//                             color: Colors.blue.shade700,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'District Information',
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue.shade700,
//                                 ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       if (_isAdminRole) ...[
//                         // DOF/CA: District Name
//                         AuthTextField(
//                           controller: _districtNameController,
//                           label: 'District Name',
//                           prefixIcon: Icons.apartment,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter district name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Enter your district name. If it doesn\'t exist, a new district will be created.',
//                           style: Theme.of(context).textTheme.bodySmall
//                               ?.copyWith(color: Colors.grey[600]),
//                         ),
//                       ] else ...[
//                         // Other Staff: Join Code
//                         AuthTextField(
//                           controller: _joinCodeController,
//                           label: 'District Join Code',
//                           prefixIcon: Icons.vpn_key,
//                           textCapitalization: TextCapitalization.characters,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter the join code';
//                             }
//                             if (value.length < 6) {
//                               return 'Join code must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Enter the join code provided by your DOF or CA to join your district.',
//                           style: Theme.of(context).textTheme.bodySmall
//                               ?.copyWith(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Save Button
//                 PrimaryButton(
//                   onPressed: _saveProfile,
//                   isLoading: _isSaving,
//                   child: const Text('Complete Setup'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _userRole;
  String? _userEmail;
  String? _userDistrictCode;
  String? _userDistrictName;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAdminRole = false;
  List<Sector> _selectedSectors = [];
  List<String> _unavailableSectorCodes = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final userId = authService.currentUser!.uid;

    try {
      final userData = await firestoreService.getUserProfile(userId);

      setState(() {
        if (userData != null) {
          _userRole = userData['role'];
          _userEmail = userData['email'] ?? authService.currentUser!.email;
          _userDistrictCode = userData['districtCode'];
          _userDistrictName = userData['districtName'];
        } else {
          // Fallback if user data not found
          _userEmail = authService.currentUser!.email;
        }
        _isAdminRole = _userRole == 'DOF' || _userRole == 'CA';
        _isLoading = false;
      });

      // Load unavailable sectors if user is accountant
      if (_userRole == 'Accountant' && _userDistrictCode != null) {
        final unavailableSectors = await firestoreService
            .getUnavailableSectorCodes(_userDistrictCode!);
        setState(() {
          _unavailableSectorCodes = unavailableSectors;
        });
      }
    } catch (e) {
      if (mounted) {
        // If there's an error, still show the screen with email
        setState(() {
          _userEmail = authService.currentUser!.email;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete your profile setup'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Future<void> _saveProfile() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   // Validate sectors for non-admin roles
  //   if (!_isAdminRole && _selectedSectors.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please select at least one sector')),
  //     );
  //     return;
  //   }

  //   // Validate accountant sector assignment
  //   if (_userRole == 'Accountant' && _selectedSectors.length != 1) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Accountants must be assigned to exactly one sector')),
  //     );
  //     return;
  //   }

  //   setState(() => _isSaving = true);

  //   try {
  //     final authService = Provider.of<AuthService>(context, listen: false);
  //     final firestoreService = Provider.of<FirestoreService>(
  //       context,
  //       listen: false,
  //     );
  //     final userId = authService.currentUser!.uid;

  //     // Convert sectors to codes
  //     final sectorCodes = _selectedSectors.map((sector) => sector.code).toList();

  //     // Update user profile with sectors
  //     await firestoreService.createUserProfile(
  //       userId: userId,
  //       email: _userEmail!,
  //       name: _nameController.text.trim(),
  //       phone: _phoneController.text.trim(),
  //       role: _userRole!,
  //       districtId: _userDistrictCode!,
  //       districtCode: _userDistrictCode!,
  //       districtName: _userDistrictName!,
  //       sectorCodes: sectorCodes,
  //     );

  //     if (mounted) {
  //       // Navigate to appropriate dashboard
  //       if (_isAdminRole) {
  //         Navigator.of(context).pushReplacementNamed(AppRouter.dofCaDashboard);
  //       } else {
  //         Navigator.of(context).pushReplacementNamed(AppRouter.staffDashboard);
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate sectors for non-admin roles
    if (!_isAdminRole && _selectedSectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one sector')),
      );
      return;
    }

    // Validate accountant sector assignment
    if (_userRole == 'Accountant' && _selectedSectors.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accountants must be assigned to exactly one sector'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final userId = authService.currentUser!.uid;

      // Convert sectors to codes
      final sectorCodes = _selectedSectors
          .map((sector) => sector.code)
          .toList();

      // For now, use districtCode as districtId since we don't have the actual district document ID
      // In a real app, you might want to look up the district document ID
      final districtId = _userDistrictCode!;

      // Update user profile with sectors
      await firestoreService.createUserProfile(
        userId: userId,
        email: _userEmail!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _userRole!,
        districtId: districtId,
        districtCode: _userDistrictCode!,
        districtName: _userDistrictName!,
        sectorCodes: sectorCodes,
      );

      if (mounted) {
        // Navigate to appropriate dashboard
        if (_isAdminRole) {
          Navigator.of(context).pushReplacementNamed(AppRouter.dofCaDashboard);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRouter.staffDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile Setup',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please complete your profile to continue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Field
                AuthTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field (Read-only)
                AuthTextField(
                  label: 'Email',
                  initialValue: _userEmail,
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // Phone Field
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Field (Read-only)
                AuthTextField(
                  label: 'Role',
                  initialValue: _userRole,
                  prefixIcon: Icons.badge_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // District Field (Read-only)
                AuthTextField(
                  label: 'District',
                  initialValue: '$_userDistrictName ($_userDistrictCode)',
                  prefixIcon: Icons.location_on_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 24),

                // Sector Selection (for non-admin roles)
                if (!_isAdminRole) ...[
                  SectorSelector(
                    selectedSectors: _selectedSectors,
                    unavailableSectorCodes: _unavailableSectorCodes,
                    onChanged: (sectors) {
                      setState(() => _selectedSectors = sectors);
                    },
                    isAccountant: _userRole == 'Accountant',
                  ),
                  const SizedBox(height: 24),
                ],

                // Save Button
                PrimaryButton(
                  onPressed: _saveProfile,
                  isLoading: _isSaving,
                  child: const Text('Complete Setup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
