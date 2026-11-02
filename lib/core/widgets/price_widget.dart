import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../utils/currency_formatter.dart';
import 'discount_badge.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final double? mrp;
  final int? discountPercentage;
  final bool isLarge;
  final bool showSavings;

  const PriceWidget({
    super.key,
    required this.price,
    this.mrp,
    this.discountPercentage,
    this.isLarge = false,
    this.showSavings = false,
  });

  @override
  Widget build(BuildContext context) {
    final priceStyle = isLarge ? AppTypography.priceLarge : AppTypography.priceMedium;
    final mrpStyle = isLarge
        ? AppTypography.bodyMedium.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.textMuted,
          )
        : AppTypography.priceOriginal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              CurrencyFormatter.format(price),
              style: priceStyle,
            ),
            if (mrp != null && mrp! > price) ...[
              const SizedBox(width: 8),
              Text(
                'M.R.P: ${CurrencyFormatter.format(mrp!)}',
                style: mrpStyle,
              ),
            ],
            if (discountPercentage != null && discountPercentage! > 0 && isLarge) ...[
              const SizedBox(width: 8),
              DiscountBadge(discountPercentage: discountPercentage!, isSmall: true),
            ],
          ],
        ),
        if (showSavings && mrp != null && mrp! > price) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_offer_rounded, size: 14, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                'You Save ${CurrencyFormatter.format(mrp! - price)} ($discountPercentage% off)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

