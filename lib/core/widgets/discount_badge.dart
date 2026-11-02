import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

class DiscountBadge extends StatelessWidget {
  final int discountPercentage;
  final bool isSmall;
  final Color? backgroundColor;

  const DiscountBadge({
    super.key,
    required this.discountPercentage,
    this.isSmall = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPercentage <= 0) return const SizedBox.shrink();

    // Alternate colors based on discount value (as seen in screenshots where some are red and some are purple)
    final bg = backgroundColor ??
        (discountPercentage >= 25 ? AppColors.primary : const Color(0xFF7C3AED));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        '$discountPercentage% OFF',
        style: (isSmall ? AppTypography.labelSmall : AppTypography.labelMedium).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: isSmall ? 10 : 11,
        ),
      ),
    );
  }
}

