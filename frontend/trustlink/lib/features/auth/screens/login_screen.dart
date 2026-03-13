import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════
//  LOGIN SCREEN — Option A : Full Dark
//  Fond #060B18, anneaux concentriques,
//  carte formulaire navy #0D1F3C
// ═══════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _topFade;
  late Animation<double> _topSlide;
  late Animation<double> _cardFade;
  late Animation<double> _cardSlide;

  // Ring pulse animation
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  // Shimmer on button
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  // Floating dots
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    // Entrance — staggered top then card
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _topFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _topSlide = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _cardSlide = Tween<double>(begin: 32, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Ring pulse — 3s loop
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _ringAnim = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    // Shimmer — 2.5s loop
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Dots float — 4s loop
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Focus listeners
    _emailFocus.addListener(() =>
        setState(() => _emailFocused = _emailFocus.hasFocus));
    _passwordFocus.addListener(() =>
        setState(() => _passwordFocused = _passwordFocus.hasFocus));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    _dotController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: appeler l'API login
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      if (mounted) context.go('/home');
    }
  }

  // ─── Couleurs ───
  static const _bg       = Color(0xFF060B18);

  static const _blue     = Color(0xFF1B4FD8);
  static const _blueLight= Color(0xFF3B82F6);
  static const _amber    = Color(0xFFF59E0B);
  static const _white    = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background rings ──
          _buildBackgroundRings(),

          // ── Floating dots ──
          _buildFloatingDots(),

          // ── Content ──
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopSection(),
                  _buildFormCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  BACKGROUND RINGS
  // ═══════════════════════════════════
  Widget _buildBackgroundRings() {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (_, __) {
        return Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 280,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Transform.scale(
                    scale: _ringAnim.value,
                    child: Container(
                      width: 260, height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _blue.withOpacity(0.1), width: 1),
                      ),
                    ),
                  ),
                  // Mid ring
                  Transform.scale(
                    scale: 2.0 - _ringAnim.value * 0.08,
                    child: Container(
                      width: 185, height: 185,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _blue.withOpacity(0.18), width: 1),
                      ),
                    ),
                  ),
                  // Inner ring with fill
                  Container(
                    width: 118, height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _blue.withOpacity(0.3), width: 1),
                      color: _blue.withOpacity(0.07),
                    ),
                  ),
                  // Glow core
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _blue.withOpacity(0.22),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  //  FLOATING DOTS
  // ═══════════════════════════════════
  Widget _buildFloatingDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (_, __) {
        final t = _dotController.value;
        return Stack(
          children: [
            Positioned(top: 72 + t * 10, left: 52,
                child: _dot(_amber, 7, 0.7)),
            Positioned(top: 120 - t * 8, right: 48,
                child: _dot(_blueLight, 5, 0.55)),
            Positioned(top: 190 + t * 6, left: 38,
                child: _dot(const Color(0xFF10B981), 4, 0.5)),
            Positioned(top: 160 - t * 5, right: 68,
                child: _dot(_amber, 3, 0.4)),
          ],
        );
      },
    );
  }

  Widget _dot(Color color, double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity),
    ),
  );

  // ═══════════════════════════════════
  //  TOP SECTION — Logo + Brand
  // ═══════════════════════════════════
  Widget _buildTopSection() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, child) => FadeTransition(
        opacity: _topFade,
        child: Transform.translate(
          offset: Offset(0, _topSlide.value),
          child: child,
        ),
      ),
      child: SizedBox(
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_blue, _blueLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.55),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.handshake_rounded,
                    color: _white, size: 32),
              ),
            ),

            const SizedBox(height: 16),

            // App name
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(text: 'Trust',
                      style: TextStyle(color: _white)),
                  TextSpan(text: 'Link',
                      style: TextStyle(color: _amber)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle pill
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _white.withOpacity(0.05),
                border: Border.all(
                    color: _white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'TRUSTED CRAFTSMEN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _white.withOpacity(0.3),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  FORM CARD
  // ═══════════════════════════════════
  Widget _buildFormCard() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, child) => FadeTransition(
        opacity: _cardFade,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sign In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _white,
                  )),
              const SizedBox(height: 4),
              Text('Enter your credentials',
                  style: TextStyle(
                    fontSize: 12,
                    color: _white.withOpacity(0.35),
                  )),
              const SizedBox(height: 24),

              _buildEmailField(),
              const SizedBox(height: 14),
              _buildPasswordField(),
              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                        fontSize: 12,
                        color: _blueLight,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 22),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EMAIL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _white.withOpacity(0.4),
              letterSpacing: 0.1,
            )),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _emailFocused
                ? _blue.withOpacity(0.12)
                : _white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _emailFocused
                  ? _blue.withOpacity(0.6)
                  : _white.withOpacity(0.1),
              width: _emailFocused ? 1.5 : 1,
            ),
            boxShadow: _emailFocused
                ? [BoxShadow(
                    color: _blue.withOpacity(0.15),
                    blurRadius: 12)]
                : [],
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
                fontSize: 14, color: _white, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: 'you@email.com',
              hintStyle: TextStyle(
                  color: _white.withOpacity(0.25), fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(Icons.email_outlined,
                    size: 18,
                    color: _emailFocused
                        ? _blueLight
                        : _white.withOpacity(0.35)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PASSWORD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _white.withOpacity(0.4),
              letterSpacing: 0.1,
            )),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _passwordFocused
                ? _blue.withOpacity(0.12)
                : _white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _passwordFocused
                  ? _blue.withOpacity(0.6)
                  : _white.withOpacity(0.1),
              width: _passwordFocused ? 1.5 : 1,
            ),
            boxShadow: _passwordFocused
                ? [BoxShadow(
                    color: _blue.withOpacity(0.15),
                    blurRadius: 12)]
                : [],
          ),
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            style: const TextStyle(
                fontSize: 14, color: _white, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                  color: _white.withOpacity(0.25), fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(Icons.lock_outline_rounded,
                    size: 18,
                    color: _passwordFocused
                        ? _blueLight
                        : _white.withOpacity(0.35)),
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(
                    () => _obscurePassword = !_obscurePassword),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: _white.withOpacity(0.35),
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleLogin,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_blue, _blueLight]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    child!,
                    if (!_isLoading)
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(
                              _shimmerAnim.value * 220, 0),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                _white.withOpacity(0.12),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: _white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sign In',
                          style: TextStyle(
                            color: _white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 10),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: _white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: _amber, size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(
            height: 0.5, color: _white.withOpacity(0.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('ou',
                style: TextStyle(
                    fontSize: 11,
                    color: _white.withOpacity(0.3))),
          ),
        ),
        Expanded(child: Container(
            height: 0.5, color: _white.withOpacity(0.08))),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No account? ',
              style: TextStyle(
                  fontSize: 13,
                  color: _white.withOpacity(0.35))),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _blue.withOpacity(0.3)),
              ),
              child: const Text("Sign Up →",
                  style: TextStyle(
                    fontSize: 13,
                    color: _blueLight,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
