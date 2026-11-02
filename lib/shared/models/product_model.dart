class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String categoryId;
  final String categoryName;
  final String subCategory;
  final String description;
  final double price;
  final double mrp;
  final int discountPercentage;
  final double rating;
  final int reviewCount;
  final int stock;
  final int viewsCount;
  final int soldCount;
  final List<String> images;
  final Map<String, String> specifications;
  final List<String> features;
  final bool isFeatured;
  final bool isHotDeal;
  final bool isBestSeller;
  final bool isRecommended;
  final List<String> tags;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.categoryId,
    required this.categoryName,
    required this.subCategory,
    required this.description,
    required this.price,
    required this.mrp,
    required this.discountPercentage,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    this.viewsCount = 0,
    this.soldCount = 0,
    required this.images,
    required this.specifications,
    required this.features,
    this.isFeatured = false,
    this.isHotDeal = false,
    this.isBestSeller = false,
    this.isRecommended = false,
    this.tags = const [],
  });

  double get savings => mrp - price;
  bool get inStock => stock > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? categoryId,
    String? categoryName,
    String? subCategory,
    String? description,
    double? price,
    double? mrp,
    int? discountPercentage,
    double? rating,
    int? reviewCount,
    int? stock,
    int? viewsCount,
    int? soldCount,
    List<String>? images,
    Map<String, String>? specifications,
    List<String>? features,
    bool? isFeatured,
    bool? isHotDeal,
    bool? isBestSeller,
    bool? isRecommended,
    List<String>? tags,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategory: subCategory ?? this.subCategory,
      description: description ?? this.description,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      viewsCount: viewsCount ?? this.viewsCount,
      soldCount: soldCount ?? this.soldCount,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      features: features ?? this.features,
      isFeatured: isFeatured ?? this.isFeatured,
      isHotDeal: isHotDeal ?? this.isHotDeal,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isRecommended: isRecommended ?? this.isRecommended,
      tags: tags ?? this.tags,
    );
  }
}

