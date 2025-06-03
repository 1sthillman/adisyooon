import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Profesyonel görünümlü konteynır widget'ı
class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final Alignment? alignment;

  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin ?? const EdgeInsets.all(AppTheme.spacing2),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: boxShadow ?? AppTheme.shadowSm,
        border: border ?? Border.all(color: AppTheme.slate200, width: 1),
      ),
      child: child,
    );
  }
}

/// Profesyonel düğme tarzı widget
class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isOutlined;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor ?? AppTheme.primaryColor,
                side: BorderSide(color: backgroundColor ?? AppTheme.primaryColor),
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing6,
                      vertical: AppTheme.spacing3,
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppTheme.primaryColor,
                foregroundColor: textColor ?? Colors.white,
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing6,
                      vertical: AppTheme.spacing3,
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? (textColor ?? AppTheme.primaryColor) : (textColor ?? Colors.white),
          ),
        ),
      );
    }
    return child;
  }
}

/// Profesyonel görünümlü kart widget'ı
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(AppTheme.spacing2),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: boxShadow ?? AppTheme.shadowBase,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Profesyonel form giriş alanı
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: AppTheme.textSm,
              fontWeight: AppTheme.fontMedium,
              color: AppTheme.slate700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.all(AppTheme.spacing4),
            filled: true,
            fillColor: readOnly ? AppTheme.slate100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
      ],
    );
  }
} 