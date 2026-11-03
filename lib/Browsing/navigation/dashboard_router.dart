import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../../features/home/presentation/home_screen.dart';

/// Centralized Destination Router for the Application Dashboard.
///
/// Connects the Browsing authentication & validation flow directly to
/// Circuit Point Ecom's main store dashboard (/home).
class DashboardRouter {
  /// Defines fallback widget if accessed without GoRouter
  static Widget getDashboardWidget() {
    return const HomeScreen();
  }

  /// Transitions to Circuit Point Ecom's Store Dashboard (/home)
  static void navigateToDashboard(BuildContext context, {bool clearStack = false}) {
    try {
      context.goNamed(RouteNames.home);
    } catch (_) {
      try {
        GoRouter.of(context).go('/home');
      } catch (_) {
        if (clearStack) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => getDashboardWidget()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => getDashboardWidget()),
          );
        }
      }
    }
  }
}
