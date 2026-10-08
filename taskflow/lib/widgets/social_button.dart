import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SocialButton extends StatefulWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.logoAsset,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? logoAsset;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E4F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (highlighted) =>
                setState(() => _pressed = highlighted),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.logoAsset ??
                      (widget.icon != null
                          ? Icon(
                              widget.icon,
                              size: 22,
                              color: AppColors.textPrimary,
                            )
                          : const SizedBox.shrink()),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        size: Size(size, size),
        painter: _FallbackGooglePainter(),
      ),
    );
  }
}

class _FallbackGooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final r = Rect.fromLTWH(0, 0, s, s);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.22;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(r.deflate(s * 0.11), -0.7, 1.4, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(r.deflate(s * 0.11), 0.7, 1.4, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(r.deflate(s * 0.11), 2.1, 1.4, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(r.deflate(s * 0.11), 3.5, 1.4, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
