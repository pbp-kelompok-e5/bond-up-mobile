import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// BondUp Deep Sea Card Widget
/// Based on .global.css card-deep-sea design system
class DeepSeaCard extends StatefulWidget {
  final Widget? header;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool enableHoverEffect;

  const DeepSeaCard({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.onTap,
    this.padding,
    this.enableHoverEffect = true,
  });

  @override
  State<DeepSeaCard> createState() => _DeepSeaCardState();
}

class _DeepSeaCardState extends State<DeepSeaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.deepSea,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepSea.withValues(
                  alpha: widget.enableHoverEffect && _isHovered ? 0.5 : 0.4,
                ),
                blurRadius: widget.enableHoverEffect && _isHovered ? 20 : 12,
                offset: Offset(0, widget.enableHoverEffect && _isHovered ? 8 : 4),
              ),
            ],
          ),
          transform: widget.enableHoverEffect && _isHovered
              ? Matrix4.translationValues(0, -4, 0)
              : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.header != null) ...[
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  child: widget.header!,
                ),
                const SizedBox(height: 12),
              ],
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                  height: 1.5,
                ),
                child: widget.body,
              ),
              if (widget.footer != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.footer!,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

