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
import '../../../core/widgets/discount_badge.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/quantity_selector.dart';
import '../../../core/widgets/rating_widget.dart';
import '../../../core/widgets/wishlist_button.dart';
import '../../../shared/providers/cart_provider.dart';
import '../../../shared/providers/product_providers.dart';
import '../../../shared/providers/recently_viewed_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _selectedQuantity = 1;
  final TextEditingController _pincodeController = TextEditingController(text: '560100');
  String _pincodeStatus = 'Delivery available in 2 days (Standard)';

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  void _checkPincode() {
    final code = _pincodeController.text.trim();
    if (code.length == 6) {
      setState(() {
        _pincodeStatus = 'Delivery available in 24 - 48 hours to $code (Free Delivery eligible)';
      });
      SnackBarUtils.showSuccess(context, 'Delivery is available for pincode $code!');
    } else {
      SnackBarUtils.showError(context, 'Please enter a valid 6-digit pincode');
    }
  }

  void _openImageZoom(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.memory_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pinch to zoom / Pan to inspect details',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text('Product ID "${widget.productId}" not found.', style: AppTypography.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        // Add to recently viewed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(recentlyViewedProvider.notifier).add(product);
        });

        final relatedAsync = ref.watch(
          relatedProductsProvider(
            RelatedProductsParams(productId: product.id, categoryId: product.categoryId),
          ),
        );

        final currentImage = product.images.isNotEmpty
            ? product.images[_selectedImageIndex % product.images.length]
            : product.images.first;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              product.name,
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              WishlistButton(
                productId: product.id,
                productName: product.name,
                hasBackground: false,
                size: 24,
              ),
              const CartBadgeButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image Gallery Container
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // Main Image with Zoom Tap
                      GestureDetector(
                        onTap: () => _openImageZoom(context, currentImage),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.white,
                              child: Hero(
                                tag: 'product-img-${product.id}',
                                child: Image.asset(
                                  currentImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.memory_rounded,
                                    size: 100,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            // Zoom hint pill
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: AppRadius.radiusFull,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tap to Zoom & Fullscreen',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image Thumbnails Row (if multiple images)
                      if (product.images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(product.images.length, (index) {
                            final isSelected = _selectedImageIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImageIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 52,
                                height: 52,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadius.radiusMd,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Image.asset(
                                  product.images[index],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.memory_rounded, size: 24),
                                ),
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Product Header Information Container
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Tag and In Stock Pill Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: AppRadius.radiusSm,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  product.brand.toUpperCase(),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: AppRadius.radiusSm,
                              border: Border.all(color: AppColors.successBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  product.inStock ? 'In Stock & Ready to Ship' : 'Out of Stock',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        product.name,
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Model and Category Breadcrumb
                      Text(
                        'Model: ${product.model} • ${product.categoryName} > ${product.subCategory}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Rating & Sold Row
                      Row(
                        children: [
                          RatingWidget(
                            rating: product.rating,
                            showStarPill: true,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.reviewCount * 3} Ratings & ${product.reviewCount} Reviews',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (product.soldCount > 0)
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.soldCount} sold',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Offer Pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on_rounded, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'OFFER PRICE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          DiscountBadge(discountPercentage: product.discountPercentage, isSmall: true),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.format(product.price),
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'M.R.P: ${CurrencyFormatter.format(product.mrp)}',
                            style: AppTypography.bodyMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Savings
                      Text(
                        '🏷 You Save ${CurrencyFormatter.format(product.savings)} (${product.discountPercentage}% off) • Inclusive of all taxes',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Available Offers Box (matches screenshot)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.offerBoxBackground,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.offerBoxBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_rounded, size: 18, color: AppColors.offerTagOrange),
                            const SizedBox(width: 6),
                            Text(
                              'Available Offers',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildOfferItem(
                          tag: 'Bank Offer',
                          text: '10% Instant Discount: Up to ₹1,000 on SBI, HDFC & ICICI Credit Card EMI',
                        ),
                        _buildOfferItem(
                          tag: 'Special Price',
                          text: 'Extra ₹150 OFF: Get additional savings applied on prepaid UPI / NetBanking',
                        ),
                        _buildOfferItem(
                          tag: 'Partner Offer',
                          text: 'Flat 15% Cashback: Buy alongside breadboards / sensors and get 15% reward points',
                        ),
                        _buildOfferItem(
                          tag: 'Free Delivery',
                          text: 'Free Express Shipping: Standard delivery is FREE on catalog orders above ₹499',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 4. Delivery & Pincode Checker
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Delivery Details', style: AppTypography.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: TextField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                style: AppTypography.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: 'Enter 6-digit Pincode',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _checkPincode,
                              child: const Text('Check', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pincodeStatus,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 5. Why Buy This Product? Trust Badges (from screenshot)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🛡 WHY BUY THIS PRODUCT?',
                        style: AppTypography.labelMedium.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: const [
                          _TrustBadgeItem(
                            icon: Icons.verified_user_rounded,
                            title: 'Genuine Product',
                            subtitle: '100% authentic component',
                          ),
                          _TrustBadgeItem(
                            icon: Icons.fact_check_rounded,
                            title: 'Quality Checked',
                            subtitle: 'Multi-point bench tested',
                          ),
                          _TrustBadgeItem(
                            icon: Icons.electric_bolt_rounded,
                            title: 'Fast Delivery',
                            subtitle: 'Express 24h dispatch',
                          ),
                          _TrustBadgeItem(
                            icon: Icons.lock_outline_rounded,
                            title: 'Secure Payment',
                            subtitle: '256-bit encrypted checkout',
                          ),
                          _TrustBadgeItem(
                            icon: Icons.shield_outlined,
                            title: 'Warranty Support',
                            subtitle: '1-Year replacement support',
                          ),
                          _TrustBadgeItem(
                            icon: Icons.sync_rounded,
                            title: 'Easy Replacement',
                            subtitle: '7-day hassle-free return',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 6. Technical Specifications Table
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Technical Specifications', style: AppTypography.titleMedium),
                      const SizedBox(height: 12),
                      Table(
                        border: TableBorder.all(color: AppColors.borderLight, width: 1),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: product.specifications.entries.map((entry) {
                          return TableRow(
                            decoration: BoxDecoration(
                              color: entry.key.hashCode % 2 == 0 ? Colors.white : AppColors.surfaceSecondary,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.key,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.value,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 7. Product Features List
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Key Features', style: AppTypography.titleMedium),
                      const SizedBox(height: 10),
                      ...product.features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_circle_outline_rounded,
                                    size: 16, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 8. Product Description
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Description', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTypography.bodyMedium.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 9. Related Products Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Related Products',
                          style: AppTypography.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      relatedAsync.when(
                        data: (relatedList) {
                          if (relatedList.isEmpty) return const SizedBox.shrink();
                          return SizedBox(
                            height: 295,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: relatedList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 175,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: ProductCard(product: relatedList[index]),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const SizedBox(height: 100),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 10. Sticky Bottom Action Bar (Quantity + Add to Cart + Buy Now)
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: AppShadows.bottomNav,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Quantity selector
                  QuantitySelector(
                    quantity: _selectedQuantity,
                    isCompact: true,
                    onChanged: (qty) {
                      setState(() {
                        _selectedQuantity = qty;
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  // Add to Cart Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product, quantity: _selectedQuantity);
                        SnackBarUtils.showSuccess(
                          context,
                          'Added $_selectedQuantity x "${product.name}" to cart',
                          actionLabel: 'VIEW CART',
                          onAction: () => context.pushNamed(RouteNames.cart),
                        );
                      },
                      child: Text(
                        'Add to Cart',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Buy Now Button (Direct Checkout)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product, quantity: _selectedQuantity);
                        context.pushNamed(RouteNames.checkout);
                      },
                      child: Text(
                        'Buy Now',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Failed to load product details: $err'),
        ),
      ),
    );
  }

  Widget _buildOfferItem({required String tag, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.offerTagOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadgeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustBadgeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
