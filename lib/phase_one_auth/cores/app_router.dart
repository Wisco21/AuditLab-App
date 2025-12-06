import 'package:auditlab/phase_one_auth/auth/auth_pages/forgot_password_screen.dart';
import 'package:auditlab/phase_one_auth/auth/auth_pages/login_screen.dart';
import 'package:auditlab/phase_one_auth/auth/auth_pages/profile_setup_screen.dart';
import 'package:auditlab/phase_one_auth/auth/auth_pages/signup_screen.dart';
import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/phase_two_core_features/pages/analytics_dashboard.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_cheque_details.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_cheque_section.dart';
import 'package:auditlab/role_selection_screen.dart';
import 'package:flutter/material.dart';

/// Centralized app routing configuration
class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  static const String profileSetup = '/profile-setup';
  static const String home = '/'; // Changed to universal layout

  // New routes for deep navigation
  static const String periodDetails = '/period-details';
  static const String folderDetails = '/folder-details';
  static const String chequeDetails = '/cheque-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen());
      case signup:
        return _buildRoute(const SignupScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case roleSelection:
        return _buildRoute(const RoleSelectionScreen());
      case profileSetup:
        return _buildRoute(const ProfileSetupScreen());

      case home:
        return _buildRoute(const ImprovedDashboard()); // ← One layout for all
      // Deep navigation routes
      case chequeDetails:
        if (settings.arguments is ChequeDetailsArgs) {
          final args = settings.arguments as ChequeDetailsArgs;
          return _buildRoute(
            ChequeDetailsScreen(
              districtId: args.districtId,
              folder: args.folder,
              cheque: args.cheque,
            ),
          );
        }
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );

      case folderDetails:
        if (settings.arguments is FolderDetailsArgs) {
          final args = settings.arguments as FolderDetailsArgs;
          return _buildRoute(
            FolderDetailsScreen(
              districtId: args.districtId,
              folder: args.folder,
            ),
          );
        }
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// Arguments classes for navigation
class ChequeDetailsArgs {
  final String districtId;
  final Folder folder;
  final Cheque cheque;

  ChequeDetailsArgs({
    required this.districtId,
    required this.folder,
    required this.cheque,
  });
}

class FolderDetailsArgs {
  final String districtId;
  final Folder folder;

  FolderDetailsArgs({required this.districtId, required this.folder});
}

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type based on screen width
enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(double width) {
  if (width < Breakpoints.mobile) return DeviceType.mobile;
  if (width < Breakpoints.desktop) return DeviceType.tablet;
  return DeviceType.desktop;
}
