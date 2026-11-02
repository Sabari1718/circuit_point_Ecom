class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final String? productId;
  final String? categoryId;
  final String imageUrl;
  final String actionLabel;
  final String? promoTag;
  final double? productPrice;
  final double? productMrp;
  final int? discountPercentage;
  final String? productTitle;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    this.productId,
    this.categoryId,
    required this.imageUrl,
    this.actionLabel = 'View Deals',
    this.promoTag,
    this.productPrice,
    this.productMrp,
    this.discountPercentage,
    this.productTitle,
  });
}

