import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/providers/user_provider.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saved Addresses', style: AppTypography.titleLarge),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: user.addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final addr = user.addresses[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: addr.isDefault ? AppColors.primary : AppColors.border,
                width: addr.isDefault ? 1.5 : 1,
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          addr.name,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            addr.type.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (addr.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  addr.formattedAddress,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: ${addr.phone}',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!addr.isDefault)
                      TextButton(
                        onPressed: () {
                          ref.read(userProvider.notifier).setDefaultAddress(addr.id);
                          SnackBarUtils.showSuccess(context, 'Set as default address');
                        },
                        child: Text(
                          'Make Default',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        SnackBarUtils.showInfo(context, 'Address editing available in live profile');
                      },
                      child: Text('Edit', style: AppTypography.labelSmall),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.bottomNav,
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
            label: Text(
              'Add New Address',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
            onPressed: () {
              SnackBarUtils.showInfo(context, 'Add Address form enabled for frontend');
            },
          ),
        ),
      ),
    );
  }
}
