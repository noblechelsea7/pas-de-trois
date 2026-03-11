import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/wishlist/presentation/providers/wishlist_providers.dart';

/// Animated heart toggle button for wishlisting a product.
/// Handles unauthenticated state with a SnackBar prompt.
class WishlistHeartButton extends ConsumerStatefulWidget {
  const WishlistHeartButton({
    super.key,
    required this.productId,
    this.size = 20,
    this.padding = const EdgeInsets.all(6),
    this.withBackground = true,
  });

  final String productId;
  final double size;
  final EdgeInsetsGeometry padding;

  /// Show a semi-transparent circle background (good for overlaying on images).
  final bool withBackground;

  @override
  ConsumerState<WishlistHeartButton> createState() =>
      _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends ConsumerState<WishlistHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final isLoggedIn =
        Supabase.instance.client.auth.currentUser != null;

    if (!isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請先登入才能收藏商品')),
        );
      }
      return;
    }

    // Bounce animation
    await _ctrl.reverse();
    _ctrl.forward();

    final wished = ref.read(isWishedProvider(widget.productId));
    try {
      await toggleWishlist(ref, widget.productId,
          currentlyWished: wished);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wished = ref.watch(isWishedProvider(widget.productId));
    final colorScheme = Theme.of(context).colorScheme;

    final icon = ScaleTransition(
      scale: _scale,
      child: Icon(
        wished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.size,
        color: wished
            ? colorScheme.error
            : (widget.withBackground ? Colors.white : colorScheme.onSurfaceVariant),
      ),
    );

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: widget.withBackground
          ? Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: wished
                    ? colorScheme.error.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: icon,
            )
          : Padding(padding: widget.padding, child: icon),
    );
  }
}
