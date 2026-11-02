import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../shared/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool isHorizontal;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isHorizontal = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Pastel Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : category.bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 26,
                    color: isSelected ? Colors.white : category.iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Category Name
              Text(
                category.name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    // Grid View Card for Categories Screen
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: category.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 28,
                    color: category.iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                style: AppTypography.titleSmall.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${category.productCount}+ items',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

