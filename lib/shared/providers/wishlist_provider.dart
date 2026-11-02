import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import 'cart_provider.dart';
import 'product_providers.dart';

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({});

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  void add(String productId) {
    if (!state.contains(productId)) {
      state = {...state, productId};
    }
  }

  void remove(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    }
  }

  bool contains(String productId) => state.contains(productId);

  void clear() {
    state = {};
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier();
});

// Live count provider
final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).length;
});

// Full Wishlist Products Provider
final wishlistProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productIds = ref.watch(wishlistProvider);
  final allProductsAsync = ref.watch(allProductsProvider);

  return allProductsAsync.whenData((products) {
    return products.where((p) => productIds.contains(p.id)).toList();
  });
});

// Helper action to move wishlist item to cart
final moveToCartProvider = Provider((ref) {
  return (ProductModel product) {
    ref.read(cartProvider.notifier).addToCart(product);
    ref.read(wishlistProvider.notifier).remove(product.id);
  };
});

