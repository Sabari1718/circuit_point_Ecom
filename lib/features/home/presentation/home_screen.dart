import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/widgets/cart_badge.dart';
import '../../../core/widgets/category_card.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/promo_banner_carousel.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/providers/product_providers.dart';
import '../../../shared/providers/recently_viewed_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final hotDealsAsync = ref.watch(hotDealsProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final bestSellersAsync = ref.watch(bestSellersProvider);
    final recommendedAsync = ref.watch(recommendedProductsProvider);
    final recentlyViewed = ref.watch(recentlyViewedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              AssetConstants.logo,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.memory_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CIRCUIT ',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'POINT',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  'POWER FULL LIFE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline_rounded, color: AppColors.textPrimary, size: 23),
            tooltip: 'Wishlist',
            onPressed: () {
              context.pushNamed(RouteNames.wishlist);
            },
          ),
          const CartBadgeButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(allProductsProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(bannersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Area
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SearchBarWidget(
                  readOnly: true,
                  onTap: () {
                    context.pushNamed(RouteNames.search);
                  },
                ),
              ),

              // Promotional Banner Carousel
              bannersAsync.when(
                data: (banners) => PromoBannerCarousel(banners: banners),
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Shop by Categories Header
              SectionHeader(
                title: 'Shop by Category',
                subtitle: 'Explore top electronics & components',
                actionLabel: 'View All',
                onAction: () {
                  context.pushNamed(RouteNames.categories);
                },
              ),

              // Categories Horizontal List (from website screenshot)
              categoriesAsync.when(
                data: (categories) => SizedBox(
                  height: 86,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        category: category,
                        isHorizontal: true,
                        onTap: () {
                          // Navigate to Products filtered by this category
                          ref.read(productFilterProvider.notifier).clearFilters();
                          ref.read(productFilterProvider.notifier).setCategory(category.id);
                          context.pushNamed(RouteNames.products);
                        },
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 86),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // Hot Deals Section
              SectionHeader(
                title: 'Hot Deals',
                subtitle: 'Limited-time special discounts',
                actionLabel: 'See All',
                icon: Icons.local_fire_department_rounded,
                onAction: () {
                  ref.read(productFilterProvider.notifier).clearFilters();
                  context.pushNamed(RouteNames.products);
                },
              ),
              hotDealsAsync.when(
                data: (products) => SizedBox(
                  height: 295,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        width: 175,
                        margin: const EdgeInsets.only(right: 12),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 295),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Featured Products Section (Grid)
              SectionHeader(
                title: 'Featured Products',
                subtitle: 'Top rated components handpicked for you',
                actionLabel: 'See All',
                onAction: () {
                  ref.read(productFilterProvider.notifier).clearFilters();
                  context.pushNamed(RouteNames.products);
                },
              ),
              featuredAsync.when(
                data: (products) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.take(4).length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 300),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Best Sellers Section
              SectionHeader(
                title: 'Best Sellers',
                subtitle: 'Most popular modules & dev boards',
                actionLabel: 'See All',
                onAction: () {
                  ref.read(productFilterProvider.notifier).clearFilters();
                  ref.read(productFilterProvider.notifier).setSortOption(ProductSortOption.popularity);
                  context.pushNamed(RouteNames.products);
                },
              ),
              bestSellersAsync.when(
                data: (products) => SizedBox(
                  height: 295,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 175,
                        margin: const EdgeInsets.only(right: 12),
                        child: ProductCard(product: products[index]),
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 295),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Recommended Products
              SectionHeader(
                title: 'Recommended For You',
                subtitle: 'Based on trending maker projects',
                actionLabel: 'See All',
                onAction: () {
                  context.pushNamed(RouteNames.products);
                },
              ),
              recommendedAsync.when(
                data: (products) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.take(4).length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 300),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              // Recently Viewed Section
              if (recentlyViewed.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Recently Viewed',
                  subtitle: 'Pick up where you left off',
                  actionLabel: 'Clear',
                  onAction: () {
                    ref.read(recentlyViewedProvider.notifier).clear();
                  },
                ),
                SizedBox(
                  height: 295,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentlyViewed.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 175,
                        margin: const EdgeInsets.only(right: 12),
                        child: ProductCard(product: recentlyViewed[index]),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
