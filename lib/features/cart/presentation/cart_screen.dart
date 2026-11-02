import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/quantity_selector.dart';
import '../../../shared/models/cart_item_model.dart';
import '../../../shared/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    if (cartState.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('My Cart')),
        body: EmptyStateWidget(
          icon: Icons.shopping_cart_outlined,
          title: 'Your Cart is Empty',
          description: 'Looks like you haven\'t added any electronic components to your cart yet.',
          actionLabel: 'Explore Products',
          onAction: () {
            context.goNamed(RouteNames.products);
          },
        ),
      );
    }

    final freeShippingDiff = AppConstants.freeShippingThreshold - cartState.subtotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shopping Cart (${cartState.totalItemCount})',
          style: AppTypography.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              SnackBarUtils.showInfo(context, 'Cart has been cleared');
            },
            child: Text(
              'Clear',
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // Free shipping threshold banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: freeShippingDiff <= 0 ? AppColors.successLight : AppColors.primaryLight,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: freeShippingDiff <= 0 ? AppColors.successBorder : AppColors.primarySoft,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    freeShippingDiff <= 0 ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
                    color: freeShippingDiff <= 0 ? AppColors.success : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      freeShippingDiff <= 0
                          ? '🎉 You have unlocked FREE Express Delivery!'
                          : 'Add ${CurrencyFormatter.format(freeShippingDiff)} more to get FREE Express Delivery!',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: freeShippingDiff <= 0 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cart Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: cartState.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return _CartItemTile(item: item);
              },
            ),

            const SizedBox(height: 12),

            // Price Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  Text('Price Details', style: AppTypography.titleMedium),
                  const Divider(height: 20),
                  _buildPriceRow(
                    label: 'Price (${cartState.totalItemCount} items)',
                    value: CurrencyFormatter.format(cartState.totalMrp),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    label: 'Discount on M.R.P.',
                    value: '- ${CurrencyFormatter.format(cartState.totalSavings)}',
                    valueColor: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    label: 'Subtotal',
                    value: CurrencyFormatter.format(cartState.subtotal),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    label: 'Delivery Fee',
                    value: cartState.deliveryCharge == 0
                        ? 'FREE'
                        : CurrencyFormatter.format(cartState.deliveryCharge),
                    valueColor: cartState.deliveryCharge == 0 ? AppColors.success : AppColors.textPrimary,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: AppTypography.titleMedium),
                      Text(
                        CurrencyFormatter.format(cartState.grandTotal),
                        style: AppTypography.priceLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings_outlined, size: 14, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'You will save ${CurrencyFormatter.format(cartState.totalSavings)} on this order',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Checkout Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.bottomNav,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Payable', style: AppTypography.bodySmall),
                    Text(
                      CurrencyFormatter.format(cartState.grandTotal),
                      style: AppTypography.priceLarge.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                  ),
                  onPressed: () {
                    context.pushNamed(RouteNames.checkout);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Buy',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow({required String label, required String value, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          GestureDetector(
            onTap: () => context.pushNamed(
              RouteNames.productDetails,
              pathParameters: {'id': product.id},
            ),
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusSm,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Image.asset(
                product.images.first,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.memory_rounded, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
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
                          Text(
                            product.name,
                            style: AppTypography.titleSmall.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                      onPressed: () {
                        ref.read(cartProvider.notifier).removeFromCart(product.id);
                        SnackBarUtils.showInfo(context, 'Removed "${product.name}" from cart');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Unit Price & Savings
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: AppTypography.priceMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(item.totalMrp),
                      style: AppTypography.priceOriginal,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuantitySelector(
                      quantity: item.quantity,
                      isCompact: true,
                      onChanged: (newQty) {
                        ref.read(cartProvider.notifier).updateQuantity(product.id, newQty);
                      },
                    ),
                    Text(
                      '${CurrencyFormatter.format(product.price)} each',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
