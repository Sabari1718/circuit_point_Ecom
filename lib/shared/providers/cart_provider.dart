import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartState {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => items.length;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalMrp => items.fold(0.0, (sum, item) => sum + item.totalMrp);
  double get totalSavings => items.fold(0.0, (sum, item) => sum + item.totalSavings);

  double get deliveryCharge {
    if (items.isEmpty) return 0.0;
    return subtotal >= AppConstants.freeShippingThreshold ? 0.0 : AppConstants.standardDeliveryCharge;
  }

  double get grandTotal => subtotal + deliveryCharge;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  bool isInCart(String productId) => items.any((item) => item.product.id == productId);

  int getQuantity(String productId) {
    final item = items.where((i) => i.product.id == productId);
    return item.isNotEmpty ? item.first.quantity : 0;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final currentItem = state.items[existingIndex];
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + quantity,
      );
      state = CartState(items: updatedList);
    } else {
      // Add new item
      final newItem = CartItemModel(product: product, quantity: quantity);
      state = CartState(items: [...state.items, newItem]);
    }
  }

  void removeFromCart(String productId) {
    state = CartState(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedList = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = CartState(items: updatedList);
  }

  void incrementQuantity(String productId) {
    final currentQty = state.getQuantity(productId);
    updateQuantity(productId, currentQty + 1);
  }

  void decrementQuantity(String productId) {
    final currentQty = state.getQuantity(productId);
    if (currentQty > 1) {
      updateQuantity(productId, currentQty - 1);
    } else {
      removeFromCart(productId);
    }
  }

  void clearCart() {
    state = const CartState(items: []);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Live count provider for badging
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItemCount;
});

