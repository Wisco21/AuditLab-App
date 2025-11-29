import 'package:auditlab/app_router.dart';
import 'package:auditlab/auth_service.dart';
import 'package:auditlab/dof_ca_dashboard.dart';
import 'package:auditlab/firebase_options.dart';
import 'package:auditlab/firestore_service.dart';
import 'package:auditlab/login_screen.dart';
import 'package:auditlab/profile_setup_screen.dart';
import 'package:auditlab/role_selection_screen.dart';
import 'package:auditlab/staff_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'AuditLab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

/// Wrapper to determine which screen to show based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in, check onboarding status
          return const OnboardingCheckScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

/// Check if user has completed onboarding steps
class OnboardingCheckScreen extends StatelessWidget {
  const OnboardingCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder(
      future: firestoreService.getUserProfile(authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // No profile yet, go to role selection
          return const RoleSelectionScreen();
        }

        final userData = snapshot.data!;

        // Check if profile is complete
        if (!_isProfileComplete(userData)) {
          return const ProfileSetupScreen();
        }

        // Profile complete, go to appropriate dashboard
        final role = userData['role'] as String?;
        if (role == 'DOF' || role == 'CA') {
          return const DOFCADashboard();
        } else {
          return const StaffDashboard();
        }
      },
    );
  }

  bool _isProfileComplete(Map<String, dynamic> userData) {
    return userData['name'] != null &&
        userData['phone'] != null &&
        userData['role'] != null &&
        userData['districtId'] != null;
  }
}
