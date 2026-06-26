import 'package:flutter/material.dart';
import 'package:tick_it/config/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;
  final LinearGradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.backgroundGradient,
      ),
      child: showBlobs
          ? Stack(
              children: [

                Positioned(
                  top: -30,
                  left: -30,
                  child: _BlobShape(
                    size: 160,
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                ),

                Positioned(
                  top: 60,
                  right: -40,
                  child: _BlobShape(
                    size: 140,
                    color: AppColors.accent.withValues(alpha: 0.15),
                    variant: 1,
                  ),
                ),

                Positioned(
                  bottom: -20,
                  left: -20,
                  child: _BlobShape(
                    size: 130,
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    variant: 2,
                  ),
                ),

                Positioned(
                  bottom: 40,
                  right: -30,
                  child: _BlobShape(
                    size: 150,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    variant: 3,
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 120),
                    painter: _CurveLinePainter(),
                  ),
                ),

                child,
              ],
            )
          : child,
    );
  }
}

class _BlobShape extends StatelessWidget {
  final double size;
  final Color color;
  final int variant;

  const _BlobShape({
    required this.size,
    required this.color,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BlobPainter(color: color, variant: variant),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final int variant;

  _BlobPainter({required this.color, required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (variant) {
      case 0:

        path.moveTo(w * 0.5, 0);
        path.cubicTo(w * 0.85, h * 0.05, w, h * 0.35, w * 0.9, h * 0.6);
        path.cubicTo(w * 0.8, h * 0.85, w * 0.5, h, w * 0.3, h * 0.9);
        path.cubicTo(0, h * 0.75, w * 0.05, h * 0.4, w * 0.15, h * 0.2);
        path.cubicTo(w * 0.25, 0, w * 0.35, h * 0.02, w * 0.5, 0);
        break;
      case 1:

        path.moveTo(w * 0.6, 0);
        path.cubicTo(w, h * 0.1, w * 0.95, h * 0.6, w * 0.7, h * 0.8);
        path.cubicTo(w * 0.5, h, w * 0.1, h * 0.8, w * 0.05, h * 0.5);
        path.cubicTo(0, h * 0.2, w * 0.3, 0, w * 0.6, 0);
        break;
      case 2:

        path.moveTo(0, h * 0.3);
        path.cubicTo(w * 0.2, 0, w * 0.7, h * 0.1, w, h * 0.3);
        path.cubicTo(w, h * 0.7, w * 0.8, h, w * 0.5, h);
        path.cubicTo(w * 0.2, h, 0, h * 0.7, 0, h * 0.3);
        break;
      case 3:

        path.addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(0, 0, w, h),
            topLeft: Radius.circular(w * 0.4),
            topRight: Radius.circular(w * 0.2),
            bottomLeft: Radius.circular(w * 0.3),
            bottomRight: Radius.circular(w * 0.5),
          ),
        );
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurveLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.cubicTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.6, size.height * 0.9,
      size.width, size.height * 0.4,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
