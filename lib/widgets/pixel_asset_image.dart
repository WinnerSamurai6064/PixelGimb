import 'package:flutter/material.dart';

class PixelAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double opacity;

  const PixelAssetImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF22150C),
              border: Border.all(color: const Color(0xFF8F5B24), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'ASSET\nMISSING',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFD37A),
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
