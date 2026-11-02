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

class ProductListCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCart = ref.watch(cartProvider).isInCart(product.id);

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.pushNamed(RouteNames.productDetails, pathParameters: {'id': product.id}),
        child: Row(
          children: [
            // Left Image
            Stack(
              children: [
                Container(
                  width: 120,
                  height: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Center(
                    child: Image.asset(
                      product.images.first,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.memory_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                if (product.discountPercentage > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: DiscountBadge(
                      discountPercentage: product.discountPercentage,
                      isSmall: true,
                    ),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),

            // Right Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              product.brand.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            WishlistButton(
                              productId: product.id,
                              productName: product.name,
                              size: 16,
                              hasBackground: false,
                            ),
                          ],
                        ),
                        Text(
                          product.name,
                          style: AppTypography.titleSmall.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        RatingWidget(rating: product.rating, compact: true),
                      ],
                    ),

                    // Price & Add to Cart row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.price),
                              style: AppTypography.priceMedium.copyWith(fontSize: 16),
                            ),
                            Text(
                              'M.R.P: ${CurrencyFormatter.format(product.mrp)}',
                              style: AppTypography.priceOriginal.copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInCart ? AppColors.secondary : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(product);
                            SnackBarUtils.showSuccess(
                              context,
                              'Added to cart',
                              actionLabel: 'VIEW',
                              onAction: () => context.pushNamed(RouteNames.cart),
                            );
                          },
                          child: Text(
                            isInCart ? 'In Cart' : 'Add to Cart',
                            style: AppTypography.labelSmall.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
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

