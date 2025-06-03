import 'dart:math';
import 'package:flutter/material.dart';
import 'package:adisyoon/constants.dart';

class BokehBackground extends StatefulWidget {
  final int numberOfBubbles;
  final Color primaryColor;
  final Color secondaryColor;
  final double maxRadius;
  final double minRadius;
  final double maxOpacity;
  final double minOpacity;
  final double speed;

  const BokehBackground({
    super.key,
    this.numberOfBubbles = 20,
    this.primaryColor = Constants.bokehPrimary,
    this.secondaryColor = Constants.bokehSecondary,
    this.maxRadius = 80,
    this.minRadius = 10,
    this.maxOpacity = 0.4,
    this.minOpacity = 0.1,
    this.speed = 1.0,
  });

  @override
  State<BokehBackground> createState() => _BokehBackgroundState();
}

class _BokehBackgroundState extends State<BokehBackground> with TickerProviderStateMixin {
  final List<BokehBubble> _bubbles = [];
  final Random _random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // Çok uzun süre çalışacak
    )..repeat();

    _controller.addListener(_updateBubbles);
    _generateBubbles();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateBubbles);
    _controller.dispose();
    super.dispose();
  }

  void _generateBubbles() {
    _bubbles.clear();
    for (int i = 0; i < widget.numberOfBubbles; i++) {
      _addBubble();
    }
  }

  void _addBubble() {
    final radius = widget.minRadius + _random.nextDouble() * (widget.maxRadius - widget.minRadius);
    final opacity = widget.minOpacity + _random.nextDouble() * (widget.maxOpacity - widget.minOpacity);
    final useSecondary = _random.nextBool();
    
    _bubbles.add(
      BokehBubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: radius,
        color: useSecondary 
            ? widget.secondaryColor.withAlpha((opacity * 255).round())
            : widget.primaryColor.withAlpha((opacity * 255).round()),
        speedX: (_random.nextDouble() - 0.5) * 0.001 * widget.speed,
        speedY: (_random.nextDouble() - 0.5) * 0.001 * widget.speed,
        pulseSpeed: 0.0005 + _random.nextDouble() * 0.002,
        pulsePhase: _random.nextDouble() * 2 * pi,
      ),
    );
  }

  void _updateBubbles() {
    for (final bubble in _bubbles) {
      // X ve Y pozisyonunu güncelle
      bubble.x += bubble.speedX;
      bubble.y += bubble.speedY;
      
      // Sınırlar dışına çıkarsa tekrar içeri al
      if (bubble.x < -0.2) bubble.x = 1.2;
      if (bubble.x > 1.2) bubble.x = -0.2;
      if (bubble.y < -0.2) bubble.y = 1.2;
      if (bubble.y > 1.2) bubble.y = -0.2;
      
      // Pulsing (Boyut değişimi) efekti
      final pulsingFactor = 0.2 * sin(bubble.pulsePhase + _controller.value * 2 * pi * bubble.pulseSpeed) + 1.0;
      bubble.currentRadius = bubble.radius * pulsingFactor;
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: BokehPainter(
            bubbles: _bubbles,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
        );
      },
    );
  }
}

class BokehBubble {
  double x; // 0-1 aralığında pozisyon (ekran oranı)
  double y; // 0-1 aralığında pozisyon
  final double radius; // Piksel cinsinden yarıçap
  double currentRadius; // Anlık (pulsing efektli) yarıçap
  final Color color; // Renk
  final double speedX; // X yönündeki hız
  final double speedY; // Y yönündeki hız
  final double pulseSpeed; // Pulsing hızı
  final double pulsePhase; // Pulsing başlangıç fazı
  
  BokehBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.pulseSpeed,
    required this.pulsePhase,
  }) : currentRadius = radius;
}

class BokehPainter extends CustomPainter {
  final List<BokehBubble> bubbles;
  final double width;
  final double height;
  
  BokehPainter({
    required this.bubbles,
    required this.width,
    required this.height,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
      final position = Offset(
        bubble.x * width,
        bubble.y * height,
      );
      
      canvas.drawCircle(position, bubble.currentRadius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant BokehPainter oldDelegate) {
    return true; // Her frame'de tekrar çiz
  }
} 