import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minQuantity;
  final int maxQuantity;
  final bool isCompact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            onTap: quantity > minQuantity ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: isCompact ? 32 : 40),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 10),
            child: Text(
              quantity.toString(),
              style: (isCompact ? AppTypography.titleSmall : AppTypography.titleMedium).copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildButton(
            icon: Icons.add_rounded,
            onTap: quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          child: Icon(
            icon,
            size: isCompact ? 16 : 18,
            color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

