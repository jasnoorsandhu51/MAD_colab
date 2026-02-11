import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

void main() => runApp(const ValentineApp());

// Rippling Heart Gradient Background
class RipplingHeartGradient extends StatefulWidget {
  const RipplingHeartGradient({super.key});

  @override
  State<RipplingHeartGradient> createState() => _RipplingHeartGradientState();
}

class _RipplingHeartGradientState extends State<RipplingHeartGradient>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RipplingHeartGradientPainter(progress: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class RipplingHeartGradientPainter extends CustomPainter {
  final double progress;

  RipplingHeartGradientPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw multiple ripples
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress + i * 0.3) % 1.0;
      final radius = size.width * 0.6 * rippleProgress;
      final opacity = (1.0 - rippleProgress) * 0.15;

      final paint = Paint()
        ..color = Colors.red.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }

    // Gradient overlay
    final gradient = RadialGradient(
      colors: [
        Colors.red.withOpacity(0.08),
        Colors.pink.withOpacity(0.04),
        Colors.transparent,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(RipplingHeartGradientPainter oldDelegate) => true;
}

// Particle class for animations
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  String emoji;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.emoji,
  });
}

// Confetti Shower Animation
class ConfettiShower extends StatefulWidget {
  final Animation<double> animation;

  const ConfettiShower({super.key, required this.animation});

  @override
  State<ConfettiShower> createState() => _ConfettiShowerState();
}

class _ConfettiShowerState extends State<ConfettiShower>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onAnimationUpdate);
    _initializeParticles();
  }

  @override
  void didUpdateWidget(ConfettiShower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_onAnimationUpdate);
      widget.animation.addListener(_onAnimationUpdate);
    }
  }

  void _onAnimationUpdate() {
    setState(() {
      if (widget.animation.value == 0.0) {
        _initializeParticles();
      }
    });
  }

  void _initializeParticles() {
    final confettiEmojis = ['🎉', '✨', '🎊', '💫', '⭐'];
    particles = List.generate(25, (index) {
      return Particle(
        x: random.nextDouble() * 500 - 250,
        y: random.nextDouble() * 150 - 75,
        vx: (random.nextDouble() - 0.5) * 300,
        vy: random.nextDouble() * 150 + 80,
        emoji: confettiEmojis[random.nextInt(confettiEmojis.length)],
      );
    });
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: particles,
            progress: widget.animation.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Calculate fall trajectory with gentle gravity
      final t = progress;
      final x = center.dx + particle.x + particle.vx * t;
      final y = center.dy + particle.y + particle.vy * t - 20 * t * t;

      // Fade out as it falls
      final opacity = (1 - progress).clamp(0.0, 1.0);

      // Draw emoji at particle position
      _drawEmojiAt(canvas, particle.emoji, x, y, 40 * opacity);
    }
  }

  void _drawEmojiAt(
    Canvas canvas,
    String emoji,
    double x,
    double y,
    double sizeOpacity,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 40,
          shadows: [
            BoxShadow(
              color: Colors.pink.withOpacity(sizeOpacity / 40 * 0.5),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

// Heart Rain Animation
class HeartRain extends StatefulWidget {
  final Animation<double> animation;

  const HeartRain({super.key, required this.animation});

  @override
  State<HeartRain> createState() => _HeartRainState();
}

class _HeartRainState extends State<HeartRain>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onAnimationUpdate);
    _initializeHearts();
  }

  @override
  void didUpdateWidget(HeartRain oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_onAnimationUpdate);
      widget.animation.addListener(_onAnimationUpdate);
    }
  }

  void _onAnimationUpdate() {
    setState(() {
      if (widget.animation.value == 0.0) {
        _initializeHearts();
      }
    });
  }

  void _initializeHearts() {
    final heartEmojis = ['❤️', '💕', '💖', '💗', '💝'];
    particles = List.generate(20, (index) {
      return Particle(
        x: random.nextDouble() * 450 - 225,
        y: random.nextDouble() * 80 - 40,
        vx: (random.nextDouble() - 0.5) * 120,
        vy: random.nextDouble() * 120 + 70,
        emoji: heartEmojis[random.nextInt(heartEmojis.length)],
      );
    });
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return CustomPaint(
          painter: HeartRainPainter(
            particles: particles,
            progress: widget.animation.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class HeartRainPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  HeartRainPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Calculate gentle falling trajectory with slight gravity
      final t = progress;
      final x = center.dx + particle.x + particle.vx * t;
      final y = center.dy + particle.y + particle.vy * t - 20 * t * t;

      // Fade out as it falls
      final opacity = (1 - progress).clamp(0.0, 1.0);

      // Draw heart emoji at particle position
      _drawHeartAt(canvas, particle.emoji, x, y, 36 * opacity);
    }
  }

  void _drawHeartAt(
    Canvas canvas,
    String emoji,
    double x,
    double y,
    double sizeOpacity,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 36,
          shadows: [
            BoxShadow(
              color: Colors.red.withOpacity(sizeOpacity / 36 * 0.4),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(HeartRainPainter oldDelegate) => true;
}

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE91E63),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _particleController.forward(from: 0.0);
  }

  // Helper method to get decorative asset based on selected emoji
  String _getDecorativeAsset(int index) {
    if (selectedEmoji == 'Party Heart') {
      final confettiAssets = [
        'confetti1.svg',
        'confetti2.svg',
        'confetti3.svg',
      ];
      return 'assets/images/${confettiAssets[index % 3]}';
    }
    return 'assets/images/heart.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cupid's Canvas",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade50,
              Colors.pink.shade100,
              Colors.red.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Decorative hearts at top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(_getDecorativeAsset(0)),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset(_getDecorativeAsset(1)),
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(_getDecorativeAsset(2)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown selector with elegant styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.pink.shade200, width: 1.5),
              ),
              child: DropdownButton<String>(
                value: selectedEmoji,
                items: emojiOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedEmoji = value ?? selectedEmoji);
                  _triggerAnimation();
                },
                underline: const SizedBox(),
                icon: Icon(
                  Icons.favorite,
                  color: Colors.pink.shade400,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Main heart display with arrows
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background image based on selected mode
                  Positioned.fill(
                    child: SvgPicture.asset(
                      selectedEmoji == 'Party Heart'
                          ? 'assets/images/party_heart_bg.svg'
                          : 'assets/images/sweet_heart_bg.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Animation layer
                  if (selectedEmoji == 'Party Heart')
                    ConfettiShower(animation: _particleController)
                  else
                    HeartRain(animation: _particleController),
                  // Left Cupid's arrow
                  Positioned(
                    left: 20,
                    top: 80,
                    child: Transform.rotate(
                      angle: math.pi / 12,
                      child: const CupidArrowPainter(),
                    ),
                  ),
                  // Right Cupid's arrow
                  Positioned(
                    right: 20,
                    bottom: 100,
                    child: Transform.rotate(
                      angle: -math.pi / 6,
                      child: const CupidArrowPainter(),
                    ),
                  ),
                  // Main heart
                  Center(
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(type: selectedEmoji),
                    ),
                  ),
                  // Floating decorative hearts
                  Positioned(
                    left: 30,
                    bottom: 80,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: selectedEmoji == 'Party Heart'
                          ? SvgPicture.asset('assets/images/confetti3.svg')
                          : SvgPicture.asset(
                              'assets/images/heart_with_arrow.svg',
                            ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 60,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(_getDecorativeAsset(3)),
                    ),
                  ),
                ],
              ),
            ),
            // Decorative hearts at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(_getDecorativeAsset(4)),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset(_getDecorativeAsset(5)),
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(_getDecorativeAsset(6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CupidArrowPainter extends StatelessWidget {
  const CupidArrowPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(80, 20), painter: ArrowPainter());
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.fill;

    // Arrow shaft
    canvas.drawLine(
      Offset(size.width, size.height / 2),
      Offset(0, size.height / 2),
      paint,
    );

    // Arrow head (triangle)
    final arrowPath = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(15, size.height / 2 - 8)
      ..lineTo(15, size.height / 2 + 8)
      ..close();

    canvas.drawPath(arrowPath, fillPaint);

    // Decorative heart at arrow tail
    final heartPaint = Paint()..color = Colors.red.shade400;
    canvas.drawCircle(
      Offset(size.width - 8, size.height / 2 - 5),
      4,
      heartPaint,
    );
    canvas.drawCircle(
      Offset(size.width - 2, size.height / 2 - 5),
      4,
      heartPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base with enhanced Valentine colors
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    // Enhanced color scheme for Valentine's theme
    if (type == 'Party Heart') {
      paint.color = const Color(0xFFFF6B9D); // Vibrant pink
    } else {
      paint.color = const Color(0xFFE91E63); // Deep rose pink
    }
    canvas.drawPath(heartPath, paint);

    // Add a subtle highlight/shine effect
    final shinePath = Path()
      ..moveTo(center.dx - 30, center.dy - 60)
      ..cubicTo(
        center.dx - 20,
        center.dy - 80,
        center.dx,
        center.dy - 70,
        center.dx + 10,
        center.dy - 50,
      )
      ..cubicTo(
        center.dx + 5,
        center.dy - 55,
        center.dx - 10,
        center.dy - 65,
        center.dx - 30,
        center.dy - 60,
      );

    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shinePath, shinePaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 12, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 12, eyePaint);

    // Pupils
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 6, pupilPaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 6, pupilPaint);

    // Smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Enhanced party hat with decorative accents
    if (type == 'Party Heart') {
      // Main hat cone
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 120)
        ..lineTo(center.dx - 45, center.dy - 40)
        ..lineTo(center.dx + 45, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      // Hat outline
      final hatOutline = Paint()
        ..color = Colors.amber.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(hatPath, hatOutline);

      // Hat pom-pom
      final pompomPaint = Paint()..color = Colors.red.shade400;
      canvas.drawCircle(Offset(center.dx, center.dy - 125), 8, pompomPaint);

      // Confetti-like details
      final confettiPaint = Paint()..color = Colors.red.shade400;
      canvas.drawCircle(
        Offset(center.dx - 30, center.dy - 80),
        4,
        confettiPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 30, center.dy - 75),
        4,
        confettiPaint,
      );

      confettiPaint.color = const Color(0xFFE91E63);
      canvas.drawCircle(
        Offset(center.dx - 10, center.dy - 90),
        3,
        confettiPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 20, center.dy - 85),
        3,
        confettiPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}
