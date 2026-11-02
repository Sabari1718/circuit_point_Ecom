import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/cart_badge.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../shared/providers/product_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _currentQuery = '';

  final List<String> _recentSearches = [
    'ESP32',
    'Arduino Uno',
    'OLED Display',
    'Relay Module',
    'Raspberry Pi 4',
    'Buck Converter',
  ];

  final List<String> _popularSuggestions = [
    'DHT11 Sensor',
    'WiFi Module',
    'Network Switch',
    'Soldering Iron',
    'Breadboard',
    'NE555 Timer',
    'Jumper Wires',
    'Lithium Charger',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _currentQuery = query;
      _controller.text = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SearchBarWidget(
            controller: _controller,
            autofocus: true,
            hintText: 'Search products, brands, models, sensors...',
            onChanged: (val) {
              setState(() {
                _currentQuery = val;
              });
            },
            onClear: () {
              setState(() {
                _currentQuery = '';
              });
            },
          ),
        ),
        actions: const [
          CartBadgeButton(),
          SizedBox(width: 8),
        ],
      ),
      body: _currentQuery.trim().isEmpty
          ? _buildSuggestionsView()
          : allProductsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  final q = _currentQuery.toLowerCase().trim();
                  return p.name.toLowerCase().contains(q) ||
                      p.brand.toLowerCase().contains(q) ||
                      p.model.toLowerCase().contains(q) ||
                      p.categoryName.toLowerCase().contains(q) ||
                      p.subCategory.toLowerCase().contains(q) ||
                      p.tags.any((t) => t.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Products',
                    description: 'No products matched "$_currentQuery". Try searching for "ESP32", "Arduino", or "Sensors".',
                    actionLabel: 'Clear Search',
                    onAction: () {
                      _onSearch('');
                    },
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filtered.length} Results for "$_currentQuery"',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
                          ),
                          TextButton(
                            onPressed: () => _onSearch(''),
                            child: const Text('Clear', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filtered[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
    );
  }

  Widget _buildSuggestionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Recent Searches', style: AppTypography.titleSmall),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: Text('Clear', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((term) {
                return ActionChip(
                  avatar: const Icon(Icons.arrow_outward_rounded, size: 14, color: AppColors.textMuted),
                  label: Text(term),
                  onPressed: () => _onSearch(term),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Suggestions
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Popular Searches', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSuggestions.map((term) {
              return ActionChip(
                label: Text(term),
                onPressed: () => _onSearch(term),
                backgroundColor: AppColors.primaryLight,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
