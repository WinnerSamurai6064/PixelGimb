import 'package:flutter/material.dart';

import '../assets/pixel_assets.dart';
import 'pixel_asset_image.dart';

class PixelIconButton extends StatefulWidget {
  final String assetKey;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  const PixelIconButton({
    super.key,
    required this.assetKey,
    required this.onPressed,
    this.size = 78,
    this.tooltip,
  });

  @override
  State<PixelIconButton> createState() => _PixelIconButtonState();
}

class _PixelIconButtonState extends State<PixelIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        scale: _pressed ? 0.92 : 1,
        child: PixelAssetImage(
          PixelAssets.icon(widget.assetKey),
          width: widget.size,
          height: widget.size,
          opacity: widget.onPressed == null ? 0.45 : 1,
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
