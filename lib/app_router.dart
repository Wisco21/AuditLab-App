import 'package:auditlab/dof_ca_dashboard.dart';
import 'package:auditlab/forgot_password_screen.dart';
import 'package:auditlab/login_screen.dart';
import 'package:auditlab/profile_setup_screen.dart';
import 'package:auditlab/role_selection_screen.dart';
import 'package:auditlab/signup_screen.dart';
import 'package:auditlab/staff_dashboard.dart';
import 'package:flutter/material.dart';

/// Centralized app routing configuration
class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  static const String profileSetup = '/profile-setup';
  static const String dofCaDashboard = '/dof-ca-dashboard';
  static const String staffDashboard = '/staff-dashboard';

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
      case dofCaDashboard:
        return _buildRoute(const DOFCADashboard());
      case staffDashboard:
        return _buildRoute(const StaffDashboard());
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
