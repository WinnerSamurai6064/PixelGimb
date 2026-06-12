import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets/pixel_assets.dart';
import 'pixel_asset_image.dart';

class SpinningRecord extends StatefulWidget {
  final String albumArtUrl;
  final bool isPlaying;
  final bool isTransitioning;
  final double size;

  const SpinningRecord({
    super.key,
    required this.albumArtUrl,
    required this.isPlaying,
    required this.isTransitioning,
    this.size = 300,
  });

  @override
  State<SpinningRecord> createState() => _SpinningRecordState();
}

class _SpinningRecordState extends State<SpinningRecord>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    );

    if (widget.isPlaying) {
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SpinningRecord oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !_spinController.isAnimating) {
      _spinController.repeat();
    } else if (!widget.isPlaying && _spinController.isAnimating) {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordSize = widget.size;
    final albumSize = recordSize * 0.54;
    final holeSize = recordSize * 0.08;

    return SizedBox(
      width: recordSize,
      height: recordSize,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 460),
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(begin: math.pi / 2.4, end: 0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotate.value),
                child: child,
              );
            },
          );
        },
        child: AnimatedBuilder(
          key: ValueKey(widget.albumArtUrl),
          animation: _spinController,
          builder: (context, _) {
            return Transform.rotate(
              angle: _spinController.value * math.pi * 2,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: recordSize * 0.90,
                    height: recordSize * 0.90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.56),
                          blurRadius: 24,
                          spreadRadius: 3,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                  ClipOval(
                    child: Image.network(
                      widget.albumArtUrl,
                      width: albumSize,
                      height: albumSize,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, __, ___) => Container(
                        width: albumSize,
                        height: albumSize,
                        color: const Color(0xFF6E4A22),
                        alignment: Alignment.center,
                        child: const Icon(Icons.music_note, color: Color(0xFFFFD37A)),
                      ),
                    ),
                  ),
                  PixelAssetImage(
                    PixelAssets.record(widget.isTransitioning ? 'spin01' : 'empty'),
                    width: recordSize,
                    height: recordSize,
                  ),
                  Container(
                    width: holeSize,
                    height: holeSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFF090908),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
