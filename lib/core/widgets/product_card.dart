import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../shared/models/product_model.dart';
import '../../shared/providers/cart_provider.dart';
import 'discount_badge.dart';
import 'rating_widget.dart';
import 'wishlist_button.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCart = ref.watch(cartProvider).isInCart(product.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.pushNamed(RouteNames.productDetails, pathParameters: {'id': product.id}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area with Badges
            Expanded(
              child: Stack(
                children: [
                  // Image
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: Hero(
                        tag: 'product-img-${product.id}',
                        child: Image.asset(
                          product.images.first,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.memory_rounded,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DiscountBadge(
                        discountPercentage: product.discountPercentage,
                        isSmall: true,
                      ),
                    ),

                  // Wishlist Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: WishlistButton(
                      productId: product.id,
                      productName: product.name,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand
                  Text(
                    product.brand.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Product Title
                  SizedBox(
                    height: 36,
                    child: Text(
                      product.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Subcategory
                  Text(
                    product.subCategory,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  RatingWidget(
                    rating: product.rating,
                    compact: true,
                  ),
                  const SizedBox(height: 4),

                  // Offer Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.radiusXs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            'OFFER ${product.discountPercentage}% OFF',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price & MRP
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: AppTypography.priceMedium.copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'M.R.P: ${CurrencyFormatter.format(product.mrp)}',
                          style: AppTypography.priceOriginal.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(product);
                  SnackBarUtils.showSuccess(
                    context,
                    'Added "${product.name}" to cart',
                    actionLabel: 'VIEW CART',
                    onAction: () => context.pushNamed(RouteNames.cart),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInCart ? Icons.shopping_bag_rounded : Icons.add_shopping_cart_rounded,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isInCart ? 'In Cart (+1)' : 'Add to Cart',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
