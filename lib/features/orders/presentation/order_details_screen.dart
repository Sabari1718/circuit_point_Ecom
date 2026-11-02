import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(singleOrderProvider(orderId));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Order not found', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Orders'),
              ),
            ],
          ),
        ),
      );
    }

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber, style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Status Timeline Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Status', style: AppTypography.titleMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successBorder),
                        ),
                        child: Text(
                          order.status.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Placed on $formattedDate', style: AppTypography.bodySmall),
                  if (order.trackingNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tracking: ${order.trackingNumber}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Divider(height: 24),

                  // Progress Stepper
                  _buildTrackingStepper(order.status),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Items in Order
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
                  Text('Items (${order.items.length})', style: AppTypography.titleMedium),
                  const Divider(height: 16),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: AppRadius.radiusSm,
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              item.productImage,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.memory_rounded),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTypography.titleSmall.copyWith(fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: ${item.quantity} • ${CurrencyFormatter.format(item.price)} each',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.totalPrice),
                            style: AppTypography.priceMedium.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Delivery Address
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
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Shipping Address', style: AppTypography.titleMedium),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    order.deliveryAddress.name,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.deliveryAddress.formattedAddress,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text('Phone: ${order.deliveryAddress.phone}', style: AppTypography.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4. Payment & Price Breakdown
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
                  Text('Payment Summary', style: AppTypography.titleMedium),
                  const Divider(height: 16),
                  _buildDetailRow('Payment Mode', order.paymentMethod),
                  const SizedBox(height: 8),
                  _buildDetailRow('Items Subtotal', CurrencyFormatter.format(order.subtotal)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Delivery Fee', order.deliveryCharge == 0 ? 'FREE' : CurrencyFormatter.format(order.deliveryCharge)),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Discount Applied', '- ${CurrencyFormatter.format(order.discount)}', color: AppColors.success),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total', style: AppTypography.titleMedium),
                      Text(
                        CurrencyFormatter.format(order.totalAmount),
                        style: AppTypography.priceLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStepper(OrderStatus status) {
    final steps = ['Order Placed', 'Confirmed', 'Shipped', 'Delivered'];
    int activeStep = 0;
    if (status == OrderStatus.delivered) {
      activeStep = 3;
    } else if (status == OrderStatus.shipped) {
      activeStep = 2;
    } else if (status == OrderStatus.confirmed || status == OrderStatus.processing) {
      activeStep = 1;
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= activeStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0 ? Colors.transparent : (index <= activeStep ? AppColors.success : AppColors.border),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.white,
                      border: Border.all(
                        color: isCompleted ? AppColors.success : AppColors.border,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == steps.length - 1 ? Colors.transparent : (index < activeStep ? AppColors.success : AppColors.border),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 9.5,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
