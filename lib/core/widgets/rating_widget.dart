import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final bool compact;
  final bool showStarPill;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.compact = false,
    this.showStarPill = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showStarPill) {
      // Green pill as seen in product details screenshot: "4.5 ★"
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: AppRadius.radiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.star_rounded, size: 12, color: Colors.white),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            IconData iconData;
            Color iconColor;

            if (rating >= starIndex) {
              iconData = Icons.star_rounded;
              iconColor = AppColors.starGold;
            } else if (rating >= starIndex - 0.5) {
              iconData = Icons.star_half_rounded;
              iconColor = AppColors.starGold;
            } else {
              iconData = Icons.star_outline_rounded;
              iconColor = AppColors.border;
            }

            return Icon(
              iconData,
              size: compact ? 14 : 16,
              color: iconColor,
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: (compact ? AppTypography.bodySmall : AppTypography.bodyMedium).copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

