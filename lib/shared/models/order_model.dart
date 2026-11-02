class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String streetAddress;
  final String locality;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final String type; // 'Home' or 'Work'

  const AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.streetAddress,
    required this.locality,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    this.type = 'Home',
  });

  String get formattedAddress => '$streetAddress, $locality, $city, $state - $pincode';

  AddressModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? streetAddress,
    String? locality,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
    String? type,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
    );
  }
}

enum OrderStatus {
  placed,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final String? trackingNumber;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.trackingNumber,
  });
}

