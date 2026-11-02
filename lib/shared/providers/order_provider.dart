import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/asset_constants.dart';
import '../models/order_model.dart';
import 'user_provider.dart';

final _initialOrders = [
  OrderModel(
    id: 'ord-101',
    orderNumber: 'CP-ORD-88421',
    items: const [
      OrderItemModel(
        productId: '5172',
        productName: 'Fine Fm Player Quantity Performance',
        productImage: AssetConstants.productTvRemote,
        price: 850,
        quantity: 1,
      ),
      OrderItemModel(
        productId: '5177',
        productName: 'ESP32 NodeMCU Development Board WiFi + BLE',
        productImage: AssetConstants.productMicrocontroller,
        price: 440,
        quantity: 2,
      ),
    ],
    subtotal: 1730,
    deliveryCharge: 0,
    discount: 0,
    totalAmount: 1730,
    status: OrderStatus.delivered,
    orderDate: DateTime.now().subtract(const Duration(days: 3)),
    deliveryAddress: mockAddresses[0],
    paymentMethod: 'UPI (Google Pay)',
    trackingNumber: 'TRK-BLR-9842190',
  ),
  OrderModel(
    id: 'ord-102',
    orderNumber: 'CP-ORD-92147',
    items: const [
      OrderItemModel(
        productId: '5178',
        productName: 'Arduino Uno R3 ATmega328P with USB Cable',
        productImage: AssetConstants.productMicrocontroller,
        price: 650,
        quantity: 1,
      ),
      OrderItemModel(
        productId: '5181',
        productName: '0.96 inch I2C OLED Display 128x64 Blue',
        productImage: AssetConstants.productIcTimer,
        price: 260,
        quantity: 2,
      ),
    ],
    subtotal: 1170,
    deliveryCharge: 0,
    discount: 50,
    totalAmount: 1120,
    status: OrderStatus.shipped,
    orderDate: DateTime.now().subtract(const Duration(days: 1)),
    deliveryAddress: mockAddresses[0],
    paymentMethod: 'Credit Card (Visa)',
    trackingNumber: 'TRK-EXP-4720193',
  ),
];

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super(_initialOrders);

  String createOrder({
    required List<OrderItemModel> items,
    required double subtotal,
    required double deliveryCharge,
    required double discount,
    required double totalAmount,
    required AddressModel deliveryAddress,
    required String paymentMethod,
  }) {
    final randomDigits = Random().nextInt(90000) + 10000;
    final orderNum = 'CP-ORD-$randomDigits';
    final id = 'ord-${DateTime.now().millisecondsSinceEpoch}';

    final newOrder = OrderModel(
      id: id,
      orderNumber: orderNum,
      items: items,
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      discount: discount,
      totalAmount: totalAmount,
      status: OrderStatus.placed,
      orderDate: DateTime.now(),
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      trackingNumber: 'TRK-PENDING-$randomDigits',
    );

    state = [newOrder, ...state];
    return id;
  }

  OrderModel? getOrderById(String id) {
    try {
      return state.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
  return OrderNotifier();
});

final singleOrderProvider = Provider.family<OrderModel?, String>((ref, id) {
  final orders = ref.watch(orderProvider);
  try {
    return orders.firstWhere((o) => o.id == id);
  } catch (_) {
    return null;
  }
});
