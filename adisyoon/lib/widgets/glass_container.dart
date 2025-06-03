import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderColor,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? Colors.white.withAlpha((Colors.white.alpha * 0.3).round());
    
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withAlpha((Colors.black.alpha * 0.05).round()),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              gradient: gradient,
              color: Colors.white.withAlpha((Colors.white.alpha * opacity).round()),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double hoverOpacity;
  final List<BoxShadow>? boxShadow;
  final List<BoxShadow>? hoverBoxShadow;
  
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderColor,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.onTap,
    this.hoverOpacity = 0.25,
    this.boxShadow,
    this.hoverBoxShadow,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? 
        Colors.white.withAlpha((Colors.white.alpha * 0.3).round());
        
    final effectiveBoxShadow = widget.boxShadow ?? [
      BoxShadow(
        color: Colors.black.withAlpha((Colors.black.alpha * 0.05).round()),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ];
    
    final effectiveHoverBoxShadow = widget.hoverBoxShadow ?? [
      BoxShadow(
        color: Colors.black.withAlpha((Colors.black.alpha * 0.1).round()),
        blurRadius: 15,
        spreadRadius: 1,
      ),
    ];
    
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered ? effectiveHoverBoxShadow : effectiveBoxShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: widget.borderWidth,
                  ),
                  color: Colors.white.withAlpha(
                    (Colors.white.alpha * (_isHovered ? widget.hoverOpacity : widget.opacity)).round()
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 