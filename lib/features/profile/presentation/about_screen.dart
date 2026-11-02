import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('About Circuit Point', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Brand Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  Image.asset(
                    AssetConstants.logo,
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CIRCUIT ',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'POINT',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your trusted partner for electronic components, IoT microcontrollers, sensors, robotics accessories, and enterprise networking hardware.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Key Highlights
            _buildFeatureCard(
              icon: Icons.verified_rounded,
              title: '100% Genuine Components',
              description: 'We source directly from licensed chip fabricators, Arduino, Espressif, and TI authorized distributors.',
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              icon: Icons.speed_rounded,
              title: 'Express Dispatch & Safe Packaging',
              description: 'Anti-static ESD packaging ensures delicate semiconductors and boards arrive in pristine condition.',
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              icon: Icons.support_agent_rounded,
              title: 'Engineering Technical Support',
              description: 'Our in-house electrical engineers provide datasheet verification, pinout guides, and schematic assistance.',
            ),

            const SizedBox(height: 24),
            Text(
              'Circuit Point Ecom • All Rights Reserved © 2026',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

