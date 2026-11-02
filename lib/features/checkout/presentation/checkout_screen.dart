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
import '../../../shared/models/order_model.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/providers/order_provider.dart';
import '../../../shared/providers/user_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'UPI (Google Pay / PhonePe)';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'UPI (Google Pay / PhonePe)',
    'Credit / Debit Card (Visa, Mastercard, RuPay)',
    'Net Banking (All Major Indian Banks)',
    'Cash on Delivery (COD)',
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final user = ref.watch(userProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Delivery Address', style: AppTypography.titleMedium),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          _showAddressSelector(context, user.addresses);
                        },
                        child: Text(
                          'Change',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Text(
                        selectedAddress.name,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          selectedAddress.type.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedAddress.formattedAddress,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${selectedAddress.phone}',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 2. Order Items Review
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items in Order (${cartState.totalItemCount})',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        CurrencyFormatter.format(cartState.subtotal),
                        style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                item.product.images.first,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.memory_rounded, size: 24),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'x${item.quantity}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Payment Method Selection
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Select Payment Method', style: AppTypography.titleMedium),
                    ],
                  ),
                  const Divider(height: 16),
                  ...List.generate(_paymentMethods.length, (index) {
                    final method = _paymentMethods[index];
                    final isSelected = _selectedPaymentMethod == method;
                    IconData iconData;
                    if (index == 0) {
                      iconData = Icons.account_balance_wallet_rounded;
                    } else if (index == 1) {
                      iconData = Icons.credit_card_rounded;
                    } else if (index == 2) {
                      iconData = Icons.account_balance_rounded;
                    } else {
                      iconData = Icons.money_rounded;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                        borderRadius: AppRadius.radiusMd,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Icon(iconData, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  method,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 4. Bill Summary
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Summary', style: AppTypography.titleMedium),
                  const Divider(height: 20),
                  _buildSummaryRow('Items Total', CurrencyFormatter.format(cartState.totalMrp)),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Product Discount',
                    '- ${CurrencyFormatter.format(cartState.totalSavings)}',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Delivery Charge',
                    cartState.deliveryCharge == 0 ? 'FREE' : CurrencyFormatter.format(cartState.deliveryCharge),
                    color: cartState.deliveryCharge == 0 ? AppColors.success : null,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Payable', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
                      Text(
                        CurrencyFormatter.format(cartState.grandTotal),
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

      // Sticky Bottom Place Order Button
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTypography.bodySmall),
                  Text(
                    CurrencyFormatter.format(cartState.grandTotal),
                    style: AppTypography.priceMedium.copyWith(fontSize: 18),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                ),
                onPressed: _isProcessing ? null : _placeOrder,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        children: [
                          Text(
                            'Place Order',
                            style: AppTypography.labelLarge.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, size: 18),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSelector(BuildContext context, List<AddressModel> addresses) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Delivery Address', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              ...addresses.map((addr) {
                return ListTile(
                  title: Text('${addr.name} (${addr.type})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(addr.formattedAddress),
                  onTap: () {
                    ref.read(selectedAddressProvider.notifier).state = addr;
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    final cartState = ref.read(cartProvider);
    final selectedAddress = ref.read(selectedAddressProvider);

    final orderItems = cartState.items.map((i) {
      return OrderItemModel(
        productId: i.product.id,
        productName: i.product.name,
        productImage: i.product.images.first,
        price: i.product.price,
        quantity: i.quantity,
      );
    }).toList();

    // Create the order in repository
    final orderId = ref.read(orderProvider.notifier).createOrder(
          items: orderItems,
          subtotal: cartState.subtotal,
          deliveryCharge: cartState.deliveryCharge,
          discount: cartState.totalSavings,
          totalAmount: cartState.grandTotal,
          deliveryAddress: selectedAddress,
          paymentMethod: _selectedPaymentMethod,
        );

    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      context.goNamed(RouteNames.orderSuccess, pathParameters: {'orderId': orderId});
    }
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
