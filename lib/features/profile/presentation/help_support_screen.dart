import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_utils.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Channels
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Direct Assistance', style: AppTypography.titleMedium),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    detail: AppConstants.supportEmail,
                    onTap: () => SnackBarUtils.showInfo(context, 'Support Email: ${AppConstants.supportEmail}'),
                  ),
                  const Divider(height: 16),
                  _buildContactRow(
                    icon: Icons.phone_outlined,
                    title: 'Call Support',
                    detail: AppConstants.supportPhone,
                    onTap: () => SnackBarUtils.showInfo(context, 'Toll Free: ${AppConstants.supportPhone}'),
                  ),
                  const Divider(height: 16),
                  _buildContactRow(
                    icon: Icons.chat_outlined,
                    title: 'WhatsApp Help Desk',
                    detail: 'Chat with engineering team (9 AM - 7 PM)',
                    onTap: () => SnackBarUtils.showInfo(context, 'WhatsApp Chat initiated'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FAQs
            Text('Frequently Asked Questions', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _buildFaqTile(
              question: 'Are all sensors and dev boards original?',
              answer: 'Yes! All items in Circuit Point Ecom catalog are 100% genuine and bench-tested before shipping.',
            ),
            _buildFaqTile(
              question: 'How long does shipping take?',
              answer: 'Orders are dispatched within 24 hours. Standard transit time is 2 to 4 business days across India.',
            ),
            _buildFaqTile(
              question: 'What is the return/replacement policy?',
              answer: 'We offer a 7-day hassle-free replacement on defective items or components damaged in transit.',
            ),
            _buildFaqTile(
              question: 'Do you offer GST invoices for businesses/colleges?',
              answer: 'Yes, full B2B GST tax invoices are automatically generated with your registered GSTIN.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall.copyWith(fontSize: 13)),
                Text(detail, style: AppTypography.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTypography.titleSmall.copyWith(fontSize: 13.5),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

