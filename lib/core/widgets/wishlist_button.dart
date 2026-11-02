import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../shared/providers/wishlist_provider.dart';

class WishlistButton extends ConsumerWidget {
  final String productId;
  final String? productName;
  final double size;
  final bool hasBackground;

  const WishlistButton({
    super.key,
    required this.productId,
    this.productName,
    this.size = 20,
    this.hasBackground = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(wishlistProvider).contains(productId);

    final button = Material(
      color: hasBackground ? Colors.white.withValues(alpha: 0.9) : Colors.transparent,
      shape: const CircleBorder(),
      elevation: hasBackground ? 1.5 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          ref.read(wishlistProvider.notifier).toggle(productId);
          if (!isWishlisted) {
            SnackBarUtils.showSuccess(
              context,
              productName != null ? 'Added $productName to Wishlist' : 'Added to Wishlist',
            );
          } else {
            SnackBarUtils.showInfo(
              context,
              'Removed from Wishlist',
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(hasBackground ? 6 : 4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isWishlisted),
              color: isWishlisted ? AppColors.primary : AppColors.textMuted,
              size: size,
            ),
          ),
        ),
      ),
    );

    return button;
  }
}

