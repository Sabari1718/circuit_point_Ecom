// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'app_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(appId: AppConfig.appId)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.travel_explore_rounded, color: Color(0xFF38BDF8), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              AppConfig.appName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings (Profile, Locks & Version)',
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF38BDF8), size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout Session',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
