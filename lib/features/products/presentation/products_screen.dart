import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/cart_badge.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/product_list_card.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../shared/providers/product_providers.dart';
import 'widgets/filter_bottom_sheet.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(productFilterProvider).searchQuery;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final filterState = ref.watch(productFilterProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('All Products', style: AppTypography.titleLarge),
        actions: const [
          CartBadgeButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter & Sort Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Search products by title, model, or brand...',
                  onChanged: (value) {
                    ref.read(productFilterProvider.notifier).setSearchQuery(value);
                  },
                  onClear: () {
                    ref.read(productFilterProvider.notifier).setSearchQuery('');
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Filter Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        side: BorderSide(
                          color: filterState.hasActiveFilters ? AppColors.primary : AppColors.border,
                        ),
                        backgroundColor:
                            filterState.hasActiveFilters ? AppColors.primaryLight : Colors.transparent,
                      ),
                      icon: Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: filterState.hasActiveFilters ? AppColors.primary : AppColors.textPrimary,
                      ),
                      label: Text(
                        'Filters',
                        style: AppTypography.labelMedium.copyWith(
                          color:
                              filterState.hasActiveFilters ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      onPressed: _openFilterBottomSheet,
                    ),
                    const SizedBox(width: 8),

                    // Sort Dropdown
                    Expanded(
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ProductSortOption>(
                            value: filterState.sortOption,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            items: ProductSortOption.values.map((sort) {
                              return DropdownMenuItem(
                                value: sort,
                                child: Text(
                                  'Sort: ${sort.label}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (newSort) {
                              if (newSort != null) {
                                ref.read(productFilterProvider.notifier).setSortOption(newSort);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // View Toggle (Grid / List)
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                            icon: Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: isGridView ? AppColors.primary : AppColors.textMuted,
                            ),
                            onPressed: () {
                              ref.read(isGridViewProvider.notifier).state = true;
                            },
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                            icon: Icon(
                              Icons.view_list_rounded,
                              size: 20,
                              color: !isGridView ? AppColors.primary : AppColors.textMuted,
                            ),
                            onPressed: () {
                              ref.read(isGridViewProvider.notifier).state = false;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Horizontal Category Chips Bar
          categoriesAsync.when(
            data: (categories) => Container(
              height: 44,
              color: AppColors.surface,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: filterState.categoryId == null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: filterState.categoryId == null ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    onSelected: (selected) {
                      ref.read(productFilterProvider.notifier).setCategory(null);
                    },
                  ),
                  const SizedBox(width: 6),
                  ...categories.map((cat) {
                    final isSelected = filterState.categoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        onSelected: (selected) {
                          ref
                              .read(productFilterProvider.notifier)
                              .setCategory(selected ? cat.id : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // Active filter chip bar (if brand, rating or stock active)
          if (filterState.hasActiveFilters)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filterState.brand != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text('Brand: ${filterState.brand}'),
                          onDeleted: () {
                            ref.read(productFilterProvider.notifier).setBrand(null);
                          },
                          deleteIconColor: AppColors.primary,
                          labelStyle: AppTypography.labelSmall.copyWith(fontSize: 10),
                        ),
                      ),
                    if (filterState.minRating > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text('${filterState.minRating}+ Stars'),
                          onDeleted: () {
                            ref.read(productFilterProvider.notifier).setMinRating(0);
                          },
                          deleteIconColor: AppColors.primary,
                          labelStyle: AppTypography.labelSmall.copyWith(fontSize: 10),
                        ),
                      ),
                    if (filterState.inStockOnly)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: const Text('In Stock Only'),
                          onDeleted: () {
                            ref.read(productFilterProvider.notifier).setInStockOnly(false);
                          },
                          deleteIconColor: AppColors.primary,
                          labelStyle: AppTypography.labelSmall.copyWith(fontSize: 10),
                        ),
                      ),
                    ActionChip(
                      label: const Text('Clear All'),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productFilterProvider.notifier).clearFilters();
                      },
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),

          // Products List / Grid
          Expanded(
            child: filteredProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Products Found',
                    description: 'Try adjusting your filters or search terms to find what you need.',
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      ref.read(productFilterProvider.notifier).clearFilters();
                    },
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result count indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Text(
                        '${products.length} Products Available',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    Expanded(
                      child: isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: products.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return ProductListCard(product: products[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Error loading products: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
