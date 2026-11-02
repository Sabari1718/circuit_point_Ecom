import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

class RecentlyViewedNotifier extends StateNotifier<List<ProductModel>> {
  RecentlyViewedNotifier() : super([]);

  void add(ProductModel product) {
    // Put most recently viewed at front, limit to 10 items
    final filtered = state.where((p) => p.id != product.id).toList();
    state = [product, ...filtered].take(10).toList();
  }

  void clear() {
    state = [];
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<ProductModel>>((ref) {
  return RecentlyViewedNotifier();
});

