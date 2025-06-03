import 'package:flutter/material.dart';
import 'package:adisyoon/constants.dart';

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final Color? hoverColor;
  final Color? splashColor;
  final double elevation;
  final double hoverElevation;
  final Duration animationDuration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool glassmorphism;
  
  const HoverButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color,
    this.hoverColor,
    this.splashColor,
    this.elevation = 2,
    this.hoverElevation = 4,
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.glassmorphism = false,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Constants.primaryTransparent;
    final effectiveHoverColor = widget.hoverColor ?? 
        (widget.color != null ? widget.color!.withAlpha((widget.color!.alpha * 0.8).round()) : Constants.primaryColor.withAlpha((Constants.primaryColor.alpha * 0.9).round()));
    final effectiveSplashColor = widget.splashColor ?? Constants.splashColor;
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(Constants.buttonRadius);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              elevation: _elevationAnimation.value,
              borderRadius: effectiveBorderRadius,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: effectiveBorderRadius,
                hoverColor: effectiveHoverColor.withAlpha((effectiveHoverColor.alpha * 0.1).round()),
                splashColor: effectiveSplashColor,
                highlightColor: effectiveHoverColor.withAlpha((effectiveHoverColor.alpha * 0.05).round()),
                child: Ink(
                  decoration: widget.glassmorphism
                      ? BoxDecoration(
                          borderRadius: effectiveBorderRadius,
                          color: _isHovered 
                              ? effectiveHoverColor.withAlpha((effectiveHoverColor.alpha * 0.25).round())
                              : effectiveColor.withAlpha((effectiveColor.alpha * 0.2).round()),
                          border: Border.all(
                            color: Colors.white.withAlpha((Colors.white.alpha * 0.3).round()),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((Colors.black.alpha * 0.05).round()),
                              blurRadius: _isHovered ? 10 : 5,
                              spreadRadius: _isHovered ? 1 : 0,
                            ),
                          ],
                        )
                      : BoxDecoration(
                          borderRadius: effectiveBorderRadius,
                          color: _isHovered ? effectiveHoverColor : effectiveColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((Colors.black.alpha * 0.1).round()),
                              blurRadius: _isHovered ? 8 : 4,
                              spreadRadius: _isHovered ? 1 : 0,
                            ),
                          ],
                        ),
                  child: Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double elevation;
  final double hoverElevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;
  final bool glassmorphism;
  final VoidCallback? onTap;
  
  const HoverCard({
    super.key,
    required this.child,
    this.color,
    this.elevation = 1,
    this.hoverElevation = 3,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 200),
    this.glassmorphism = false,
    this.onTap,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Constants.cardTransparentColor;
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(Constants.cardRadius);
    
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Widget content = Container(
            decoration: widget.glassmorphism
                ? BoxDecoration(
                    borderRadius: effectiveBorderRadius,
                    color: effectiveColor.withAlpha(_isHovered ? (effectiveColor.alpha * 0.25).round() : (effectiveColor.alpha * 0.2).round()),
                    border: Border.all(
                      color: Colors.white.withAlpha((Colors.white.alpha * 0.3).round()),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((Colors.black.alpha * 0.05).round()),
                        blurRadius: _isHovered ? 10 : 5,
                        spreadRadius: _isHovered ? 1 : 0,
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: effectiveBorderRadius,
                    color: effectiveColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((Colors.black.alpha * 0.1).round()),
                        blurRadius: _elevationAnimation.value * 2,
                        spreadRadius: _isHovered ? 1 : 0,
                      ),
                    ],
                  ),
            padding: widget.padding,
            child: widget.child,
          );
          
          if (widget.onTap != null) {
            content = Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: effectiveBorderRadius,
                hoverColor: Constants.primaryColor.withAlpha((Constants.primaryColor.alpha * 0.05).round()),
                splashColor: Constants.primaryColor.withAlpha((Constants.primaryColor.alpha * 0.1).round()),
                highlightColor: Constants.primaryColor.withAlpha((Constants.primaryColor.alpha * 0.05).round()),
                child: content,
              ),
            );
          }
          
          return content;
        }
      ),
    );
  }
} 