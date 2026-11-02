import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_point_ecom/app/theme/app_colors.dart';
import 'package:circuit_point_ecom/app/theme/app_radius.dart';
import 'package:circuit_point_ecom/app/theme/app_typography.dart';
import 'package:circuit_point_ecom/core/utils/currency_formatter.dart';
import 'package:circuit_point_ecom/shared/providers/product_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _selectedCategory;
  late String? _selectedBrand;
  late RangeValues _priceRange;
  late double _minRating;
  late bool _inStockOnly;

  final List<String> _brands = [
    'All',
    'CIRCUIT POINT',
    'ARDUINO',
    'ESPRESSIF',
    'FINE',
    'IMPORTED',
    'TEXAS INSTRUMENTS',
    'RASPBERRY PI',
    'TOWERPRO',
    'LUA',
  ];

  @override
  void initState() {
    super.initState();
    final filter = ref.read(productFilterProvider);
    _selectedCategory = filter.categoryId;
    _selectedBrand = filter.brand ?? 'All';
    _priceRange = RangeValues(filter.minPrice, filter.maxPrice);
    _minRating = filter.minRating;
    _inStockOnly = filter.inStockOnly;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title and Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Products', style: AppTypography.titleLarge),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedBrand = 'All';
                      _priceRange = const RangeValues(0, 50000);
                      _minRating = 0;
                      _inStockOnly = false;
                    });
                  },
                  child: Text(
                    'Reset All',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Category Filter
            Text('Category', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Categories'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategory == cat.id;
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat.id : null;
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }),
                ],
              ),
              loading: () => const SizedBox(height: 30),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Brand Filter
            Text('Brand', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _brands.map((brand) {
                final isSelected = _selectedBrand == brand;
                return ChoiceChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedBrand = selected ? brand : 'All';
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Price Range Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price Range', style: AppTypography.titleSmall),
                Text(
                  '${CurrencyFormatter.format(_priceRange.start)} - ${CurrencyFormatter.format(_priceRange.end)}',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 50000,
              divisions: 50,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              labels: RangeLabels(
                CurrencyFormatter.format(_priceRange.start),
                CurrencyFormatter.format(_priceRange.end),
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 16),

            // Min Rating
            Text('Customer Rating', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [0.0, 3.0, 4.0, 4.5].map((rating) {
                final isSelected = _minRating == rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(rating == 0.0 ? 'All' : '${rating.toStringAsFixed(1)}+'),
                        if (rating > 0) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.starGold),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _minRating = rating;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // In Stock Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('In Stock Only', style: AppTypography.titleSmall),
              value: _inStockOnly,
              activeTrackColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  _inStockOnly = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                ),
                onPressed: () {
                  final notifier = ref.read(productFilterProvider.notifier);
                  notifier.setCategory(_selectedCategory);
                  notifier.setBrand(_selectedBrand == 'All' ? null : _selectedBrand);
                  notifier.setPriceRange(_priceRange.start, _priceRange.end);
                  notifier.setMinRating(_minRating);
                  notifier.setInStockOnly(_inStockOnly);
                  Navigator.pop(context);
                },
                child: Text(
                  'Apply Filters',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
