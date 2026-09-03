import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive wrapper that provides desktop mouse hover micro-interactions
/// (smooth lift, subtle glow, pointer cursor) while preserving native touch
/// feedback and standard 44x44 minimum touch targets on mobile/tablet screens.
class ResponsiveHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? hoverColor;
  final Border? border;
  final Border? hoverBorder;

  const ResponsiveHoverCard({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.margin,
    this.baseColor,
    this.hoverColor,
    this.border,
    this.hoverBorder,
  }) : super(key: key);

  @override
  State<ResponsiveHoverCard> createState() => _ResponsiveHoverCardState();
}

class _ResponsiveHoverCardState extends State<ResponsiveHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    final isClickable = widget.onTap != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isClickable && mounted) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (isClickable && mounted) {
          setState(() => _isHovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        transform: Matrix4.translationValues(0, _isHovered ? -3.0 : 0.0, 0),
        decoration: BoxDecoration(
          color: _isHovered
              ? (widget.hoverColor ?? AppColors.surfaceContainerLowest)
              : (widget.baseColor ?? AppColors.surfaceContainerLowest),
          borderRadius: radius,
          border: _isHovered
              ? (widget.hoverBorder ??
                  Border.all(
                    color: AppColors.primaryContainer.withOpacity(0.35),
                    width: 1.5,
                  ))
              : (widget.border ??
                  Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.6),
                    width: 1.0,
                  )),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryContainer.withOpacity(0.12)
                  : AppColors.primaryContainer.withOpacity(0.04),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
