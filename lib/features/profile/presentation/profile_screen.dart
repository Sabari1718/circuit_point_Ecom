import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/providers/order_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/wishlist_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final orderCount = ref.watch(orderProvider).length;
    final wishlistCount = ref.watch(wishlistCountProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Account', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            // User Header Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        AssetConstants.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 36, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppTypography.titleMedium.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Counter Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    count: orderCount.toString(),
                    onTap: () => context.pushNamed(RouteNames.orders),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context: context,
                    icon: Icons.favorite_rounded,
                    label: 'Wishlist',
                    count: wishlistCount.toString(),
                    onTap: () => context.pushNamed(RouteNames.wishlist),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context: context,
                    icon: Icons.shopping_bag_rounded,
                    label: 'Cart',
                    count: cartCount.toString(),
                    onTap: () => context.pushNamed(RouteNames.cart),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Options Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'My Orders',
                    subtitle: 'Track past & active orders',
                    onTap: () => context.pushNamed(RouteNames.orders),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'My Wishlist',
                    subtitle: 'Saved electronic components',
                    onTap: () => context.pushNamed(RouteNames.wishlist),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage shipping destinations',
                    onTap: () => context.pushNamed(RouteNames.savedAddresses),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Circuit Point',
                    subtitle: 'Learn about our brand & catalog',
                    onTap: () => context.pushNamed(RouteNames.about),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact & warranty terms',
                    onTap: () => context.pushNamed(RouteNames.helpSupport),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Sign out from this session',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Circuit Point Ecom v1.0.0 (Build 1)',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                count,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(color: textColor ?? AppColors.textPrimary),
      ),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Circuit Point Ecom?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              SnackBarUtils.showInfo(context, 'Logged out successfully (Frontend Session)');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Order Notifications'),
              value: true,
              activeTrackColor: AppColors.primary,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Deal Alerts & Discounts'),
              value: true,
              activeTrackColor: AppColors.primary,
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
