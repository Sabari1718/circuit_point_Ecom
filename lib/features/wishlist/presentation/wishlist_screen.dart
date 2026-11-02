import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/cart_badge.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistCount = ref.watch(wishlistCountProvider);
    final wishlistProductsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Wishlist ($wishlistCount)', style: AppTypography.titleLarge),
        actions: [
          if (wishlistCount > 0)
            TextButton(
              onPressed: () {
                ref.read(wishlistProvider.notifier).clear();
                SnackBarUtils.showInfo(context, 'Wishlist cleared');
              },
              child: Text(
                'Clear',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
          const CartBadgeButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistCount == 0
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              description: 'Save items that you like by tapping the heart icon on any electronic component.',
              actionLabel: 'Discover Products',
              onAction: () {
                context.goNamed(RouteNames.products);
              },
            )
          : wishlistProductsAsync.when(
              data: (products) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _WishlistItemCard(product: product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
    );
  }
}

class _WishlistItemCard extends ConsumerWidget {
  final ProductModel product;

  const _WishlistItemCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Delete from wishlist button
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => context.pushNamed(
                    RouteNames.productDetails,
                    pathParameters: {'id': product.id},
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: Image.asset(
                        product.images.first,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.memory_rounded, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ref.read(wishlistProvider.notifier).remove(product.id);
                        SnackBarUtils.showInfo(context, 'Removed from wishlist');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 36,
                  child: Text(
                    product.name,
                    style: AppTypography.titleSmall.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: AppTypography.priceMedium.copyWith(fontSize: 15),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      CurrencyFormatter.format(product.mrp),
                      style: AppTypography.priceOriginal.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Move to Cart Button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(product);
                ref.read(wishlistProvider.notifier).remove(product.id);
                SnackBarUtils.showSuccess(
                  context,
                  'Moved "${product.name}" to Cart',
                  actionLabel: 'VIEW CART',
                  onAction: () => context.pushNamed(RouteNames.cart),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'Move to Cart',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
