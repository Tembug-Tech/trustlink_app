import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════
//  ONBOARDING SCREEN — TrustLink v3 Design
// ═══════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;

  // Float animation
  late Animation<double> _floatAnim;

  // Pulse animations (3 rings)
  late Animation<double> _pulse1Scale;
  late Animation<double> _pulse1Opacity;
  late Animation<double> _pulse2Scale;
  late Animation<double> _pulse2Opacity;
  late Animation<double> _pulse3Scale;
  late Animation<double> _pulse3Opacity;

  // Orbit animation
  late Animation<double> _orbitAnim;

  // Bounce-in animation
  late Animation<double> _bounceAnim;

  // Shimmer animation
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    // Float controller — 4s loop
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse controller — 2.5s loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Ring 1
    _pulse1Scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse1Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    // Ring 2 — delayed 0.8s (= 0.32 of 2.5s)
    _pulse2Scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.32, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse2Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.32, 1.0, curve: Curves.easeOut),
      ),
    );
    // Ring 3 — delayed 1.6s (= 0.64 of 2.5s)
    _pulse3Scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.64, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse3Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.64, 1.0, curve: Curves.easeOut),
      ),
    );

    // Orbit controller — 6s loop
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
    _orbitAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );

    // Shimmer controller — 3s loop
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Bounce controller — one shot on page change
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
    _bounceController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _bounceController.reset();
    _bounceController.forward();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildSlide1(),
          _buildSlide2(),
          _buildSlide3(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  SLIDE 1 — VIOLET
  // ═══════════════════════════════════
  Widget _buildSlide1() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF2D1259), Color(0xFF6D28D9), Color(0xFF7C3AED)],
        ),
      ),
      child: Stack(
        children: [
          // Orb 1 top-right
          Positioned(
            top: -100, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFA78BFA).withOpacity(0.4),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Orb 2 bottom-left
          Positioned(
            bottom: 200, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFEC4899).withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(
                  dotColor: const Color(0xFFA78BFA),
                  skipColor: Colors.white.withOpacity(0.45),
                ),

                // Illustration
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Pulse rings
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) => Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildPulseRing(_pulse1Scale.value, _pulse1Opacity.value, 110),
                              _buildPulseRing(_pulse2Scale.value, _pulse2Opacity.value, 110),
                              _buildPulseRing(_pulse3Scale.value, _pulse3Opacity.value, 110),
                            ],
                          ),
                        ),

                        // Central floating icon
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          ),
                          child: Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(0.6),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🤝', style: TextStyle(fontSize: 52)),
                            ),
                          ),
                        ),

                        // Stat card top-left
                        Positioned(
                          top: -20, left: -100,
                          child: _buildFloatCard1(),
                        ),

                        // Stat card bottom-right
                        Positioned(
                          bottom: -20, right: -110,
                          child: _buildFloatCard2(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom sheet
                _buildBottomSheet(
                  sheetColor: const Color(0xFFFAFAFA),
                  tagColor: const Color(0xFFEDE9FE),
                  tagTextColor: const Color(0xFF6D28D9),
                  tagDotColor: const Color(0xFF7C3AED),
                  tagLabel: 'Welcome',
                  title: 'Find the perfect ',
                  titleAccent: 'Artisans',
                  titleEnd: ' near you',
                  accentColor: const Color(0xFF7C3AED),
                  description:
                      'TrustLink connects clients and trusted Artisans. Simple, fast and secure.',
                  btnColors: const [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFFA855F7)],
                  btnShadowColor: const Color(0xFF6D28D9),
                  btnLabel: 'Get Started',
                  btnIcon: '→',
                  activeIndex: 0,
                  progressActiveColor: const Color(0xFF7C3AED),
                  progressBgColor: const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double scale, double opacity, double size) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFA78BFA).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatCard1() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value * 0.8),
        child: Transform.rotate(angle: -0.05, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2.4k+',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4C1D95),
                    height: 1)),
            const SizedBox(height: 3),
            Text('Active Artisans',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B5CF6),
                    letterSpacing: 0.05)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatCard2() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value * 0.6),
        child: Transform.rotate(angle: 0.07, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                ),
              ),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Kofi A.',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E1E2E))),
                Text('✓ Verified',
                    style: TextStyle(fontSize: 10, color: Color(0xFF10B981))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  SLIDE 2 — TEAL
  // ═══════════════════════════════════
  Widget _buildSlide2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
          colors: [Color(0xFF042F2E), Color(0xFF065F46), Color(0xFF0891B2)],
        ),
      ),
      child: Stack(
        children: [
          // Hex grid pattern
          Positioned.fill(
            child: CustomPaint(painter: _HexGridPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(
                  dotColor: const Color(0xFF67E8F9),
                  skipColor: Colors.white.withOpacity(0.4),
                ),

                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Orbit ring
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (_, __) => Transform.rotate(
                            angle: _orbitAnim.value,
                            child: Container(
                              width: 150, height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF67E8F9).withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Center shield
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0891B2).withOpacity(0.8),
                                const Color(0xFF06B6D4).withOpacity(0.6),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF67E8F9).withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06B6D4).withOpacity(0.5),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🛡️', style: TextStyle(fontSize: 42)),
                          ),
                        ),

                        // Orbiting items
                        AnimatedBuilder(
                          animation: _orbitAnim,
                          builder: (_, __) => SizedBox(
                            width: 150, height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildOrbitItem('⭐', _orbitAnim.value, 0),
                                _buildOrbitItem('✅', _orbitAnim.value, 2 * math.pi / 3),
                                _buildOrbitItem('🔒', _orbitAnim.value, 4 * math.pi / 3),
                              ],
                            ),
                          ),
                        ),

                        // Verified badge — bottom right
                        Positioned(
                          bottom: -20, right: -90,
                          child: ScaleTransition(
                            scale: _bounceAnim,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('✓', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 6),
                                  Text('Vérifié', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Rating card — top left
                        Positioned(
                          top: -15, left: -100,
                          child: AnimatedBuilder(
                            animation: _floatAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value * 0.8),
                              child: child,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('4.9',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0891B2),
                                          height: 1)),
                                  SizedBox(height: 3),
                                  Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildBottomSheet(
                  sheetColor: const Color(0xFFF0FDFC),
                  tagColor: const Color(0xFFCCFBF1),
                  tagTextColor: const Color(0xFF0E7490),
                  tagDotColor: const Color(0xFF0891B2),
                  tagLabel: 'Trust',
                  title: 'Verified ',
                  titleAccent: 'Artisans',
                  titleEnd: ' & Rated',
                  accentColor: const Color(0xFF0891B2),
                  description:
                      'Every artisans undergoes strict identity verification. Work safely.',
                  btnColors: const [Color(0xFF065F46), Color(0xFF0891B2)],
                  btnShadowColor: const Color(0xFF0891B2),
                  btnLabel: 'Next',
                  btnIcon: '→',
                  activeIndex: 1,
                  progressActiveColor: const Color(0xFF0891B2),
                  progressBgColor: const Color(0xFFCCFBF1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitItem(String emoji, double angle, double offset) {
    final x = 65 * math.cos(angle + offset);
    final y = 65 * math.sin(angle + offset);
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10),
          ],
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
      ),
    );
  }

  // ═══════════════════════════════════
  //  SLIDE 3 — ORANGE
  // ═══════════════════════════════════
  Widget _buildSlide3() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.45, 1.0],
          colors: [Color(0xFF431407), Color(0xFFC2410C), Color(0xFFF97316)],
        ),
      ),
      child: Stack(
        children: [
          // Diagonal stripes
          Positioned.fill(
            child: CustomPaint(painter: _StripePainter()),
          ),
          // Orbs
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFBBF24).withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(
                  dotColor: const Color(0xFFFCD34D),
                  skipColor: Colors.white.withOpacity(0.4),
                ),

                Expanded(
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Stacked cards
                        SizedBox(
                          width: 220, height: 170,
                          child: Stack(
                            children: [
                              // Card 1 — ghost back
                              Positioned(
                                top: 0, left: 20,
                                child: _buildGhostCard(
                                  emoji: '🔧',
                                  name: 'Koffi B.',
                                  job: 'Electrician',
                                  price: '45€/h',
                                  angle: -0.14,
                                  animOffset: _floatAnim.value * 0.5,
                                ),
                              ),
                              // Card 2 — ghost mid
                              Positioned(
                                top: 8, left: 10,
                                child: _buildGhostCard(
                                  emoji: '🪣',
                                  name: 'Ama D.',
                                  job: 'Plumber',
                                  price: '50€/h',
                                  angle: -0.05,
                                  animOffset: _floatAnim.value * 0.7,
                                ),
                              ),
                              // Card 3 — real top
                              Positioned(
                                top: 14, left: 0,
                                child: AnimatedBuilder(
                                  animation: _floatAnim,
                                  builder: (_, child) => Transform.translate(
                                    offset: Offset(0, _floatAnim.value * 0.9),
                                    child: child,
                                  ),
                                  child: _buildRealCard(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Counter badge
                        Positioned(
                          bottom: -30, right: -50,
                          child: ScaleTransition(
                            scale: _bounceAnim,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEA580C).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('500+',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1)),
                                  SizedBox(height: 2),
                                  Text('TASKS/MONTH',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.05)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildBottomSheet(
                  sheetColor: const Color(0xFFFFFBF5),
                  tagColor: const Color(0xFFFFF7ED),
                  tagTextColor: const Color(0xFFC2410C),
                  tagDotColor: const Color(0xFFEA580C),
                  tagLabel: 'Booking',
                  title: 'Book in ',
                  titleAccent: 'seconds',
                  titleEnd: '',
                  accentColor: const Color(0xFFEA580C),
                  description:
                      'Compare, choose and book. Track every step of your task in real-time.',
                  btnColors: const [Color(0xFFC2410C), Color(0xFFF97316), Color(0xFFFBBF24)],
                  btnShadowColor: const Color(0xFFC2410C),
                  btnLabel: 'Let\'s Go!',
                  btnIcon: '🚀',
                  activeIndex: 2,
                  progressActiveColor: const Color(0xFFEA580C),
                  progressBgColor: const Color(0xFFFEE2E2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostCard({
    required String emoji,
    required String name,
    required String job,
    required String price,
    required double angle,
    required double animOffset,
  }) {
    return Transform.translate(
      offset: Offset(0, animOffset),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15))),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8))),
                      Text(job, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('★★★★☆', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                  Text(price, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealCard() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
                  ),
                ),
                child: const Center(child: Text('🎨', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Yaw M.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  Text('Painter • 1.2 km', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('★ 4.9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEA580C))),
              Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 4),
                  const Text('Available', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('38€/h', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFC2410C))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════

  Widget _buildTopBar({required Color dotColor, required Color skipColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [BoxShadow(color: dotColor, blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 8),
              Text('TrustLink',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.02)),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Skip', style: TextStyle(fontSize: 12, color: skipColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet({
    required Color sheetColor,
    required Color tagColor,
    required Color tagTextColor,
    required Color tagDotColor,
    required String tagLabel,
    required String title,
    required String titleAccent,
    required String titleEnd,
    required Color accentColor,
    required String description,
    required List<Color> btnColors,
    required Color btnShadowColor,
    required String btnLabel,
    required String btnIcon,
    required int activeIndex,
    required Color progressActiveColor,
    required Color progressBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bars
          Row(
            children: List.generate(3, (i) {
              final isActive = i == activeIndex;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? progressActiveColor : progressBgColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),

          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: tagDotColor),
                ),
                const SizedBox(width: 5),
                Text(tagLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tagTextColor,
                        letterSpacing: 0.04)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Title
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.2),
              children: [
                TextSpan(text: title),
                TextSpan(text: titleAccent, style: TextStyle(color: accentColor)),
                TextSpan(text: titleEnd),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.65)),
          const SizedBox(height: 22),

          // Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: _nextPage,
              child: AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: btnColors),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: btnShadowColor.withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          child!,
                          // Shimmer overlay
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(_shimmerAnim.value * 300, 0),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(btnLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(btnIcon,
                            style: const TextStyle(fontSize: 14, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════

class _HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const w = 56.0;
    const h = 48.0;

    for (double y = -h; y < size.height + h; y += h) {
      for (double x = -w; x < size.width + w; x += w) {
        final path = Path();
        final cx = x + w / 2;
        final cy = y + h / 2;
        path.moveTo(cx, cy - h / 2);
        path.lineTo(cx + w / 2, cy - h / 4);
        path.lineTo(cx + w / 2, cy + h / 4);
        path.lineTo(cx, cy + h / 2);
        path.lineTo(cx - w / 2, cy + h / 4);
        path.lineTo(cx - w / 2, cy - h / 4);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 21.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}