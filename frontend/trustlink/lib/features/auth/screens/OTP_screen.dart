import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════
//  OTP SCREEN — TrustLink v3
//  Phone SMS verification — 4 digits
//  Light Clean design
//  States: filling → success (green)
// ═══════════════════════════════════════════

class OtpScreen extends StatefulWidget {
  final String phoneNumber; // passed from register screen

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {

  static const int _otpLength = 4;
  static const int _resendSeconds = 60;

  // 4 controllers + focus nodes
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isVerifying  = false;
  bool _isSuccess    = false;
  bool _isError      = false;
  int  _timerSeconds = _resendSeconds;
  bool _canResend    = false;
  Timer? _timer;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;

  // Success animation
  late AnimationController _successController;
  late Animation<double>   _successScale;
  late Animation<double>   _successFade;

  // Shake animation (error)
  late AnimationController _shakeController;
  late Animation<double>   _shakeAnim;

  // Shimmer on button
  late AnimationController _shimmerController;
  late Animation<double>   _shimmerAnim;

  // ─── Colours ───
  static const _navy      = Color(0xFF0A1628);
  static const _blue      = Color(0xFF1B4FD8);
  static const _blueLight = Color(0xFF3B82F6);
  static const _blueBg    = Color(0xFFEFF6FF);
  static const _blueBorder= Color(0xFFBFDBFE);
  static const _amber     = Color(0xFFF59E0B);
  static const _white     = Colors.white;
  static const _surface   = Color(0xFFF7F8FC);
  static const _border    = Color(0xFFE8EDF5);
  static const _hint      = Color(0xFFCBD5E1);
  static const _muted     = Color(0xFF94A3B8);
  static const _green     = Color(0xFF10B981);
  static const _greenBg   = Color(0xFFF0FDF4);
  static const _greenBorder= Color(0xFFA7F3D0);
  static const _greenDark = Color(0xFF065F46);
  static const _red       = Color(0xFFEF4444);
  static const _redBg     = Color(0xFFFEF2F2);
  static const _redBorder = Color(0xFFFECACA);

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    // Success
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );

    // Shake
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _entranceController.forward();
    _startTimer();

    // Auto-focus first box
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    _successController.dispose();
    _shakeController.dispose();
    _shimmerController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ─── Timer countdown ───
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = _resendSeconds;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _timerText {
    final m = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Get full OTP string ───
  String get _otp =>
      _controllers.map((c) => c.text).join();

  // ─── Handle digit input ───
  void _onChanged(int index, String value) {
    setState(() {
      _isError = false;
    });

    if (value.length == 1) {
      // Move to next
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit — auto verify
        _focusNodes[index].unfocus();
        _handleVerify();
      }
    }
  }

  // ─── Handle backspace ───
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // ─── Verify OTP ───
  Future<void> _handleVerify() async {
    if (_otp.length < _otpLength) return;

    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    // TODO: call API to verify OTP
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Simulate success (replace with real API response check)
    const bool apiSuccess = true;

    if (apiSuccess) {
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      _successController.forward();
    } else {
      setState(() {
        _isVerifying = false;
        _isError = true;
      });
      _shakeController.forward(from: 0);
      // Clear boxes on error
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  // ─── Resend OTP ───
  void _handleResend() {
    if (!_canResend) return;
    // TODO: call API to resend OTP
    for (final c in _controllers) c.clear();
    setState(() {
      _isError = false;
      _isSuccess = false;
    });
    _startTimer();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          // Accent strip
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_navy, _blue, _blueLight],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        _buildIcon(),
                        _buildTitle(),
                        _buildSubtitle(),
                        const SizedBox(height: 36),
                        _buildOtpBoxes(),
                        const SizedBox(height: 16),
                        if (_isError) _buildErrorBadge(),
                        if (_isSuccess) _buildSuccessBadge(),
                        const SizedBox(height: 28),
                        _buildButton(),
                        const SizedBox(height: 24),
                        _buildResendRow(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  TOP BAR
  // ═══════════════════════════════════
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 32),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _surface,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 4),
                Text('Back',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  ICON
  // ═══════════════════════════════════
  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (_, __) {
        final color = _isSuccess ? _green : _blue;
        final bgColor = _isSuccess ? _greenBg : _blueBg;
        final borderColor = _isSuccess ? _greenBorder : _blueBorder;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 60, height: 60,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: _isSuccess
                ? ScaleTransition(
                    scale: _successScale,
                    child: const Icon(Icons.check_rounded,
                        color: _green, size: 28),
                  )
                : Icon(Icons.phone_android_rounded,
                    color: color, size: 26),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  //  TITLE
  // ═══════════════════════════════════
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (_, __) {
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _navy,
              height: 1.2,
              letterSpacing: -0.4,
            ),
            children: [
              TextSpan(
                  text: _isSuccess ? 'Phone\n' : 'Check your\n'),
              WidgetSpan(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isSuccess ? _green : _blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isSuccess ? 'verified!' : 'phone',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════
  //  SUBTITLE
  // ═══════════════════════════════════
  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSuccess
                ? 'Your phone number has been verified.'
                : 'We sent a 4-digit SMS code to',
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
          if (!_isSuccess) ...[
            const SizedBox(height: 4),
            Text(
              widget.phoneNumber,
              style: const TextStyle(
                fontSize: 14,
                color: _navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  OTP BOXES
  // ═══════════════════════════════════
  Widget _buildOtpBoxes() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (_, child) {
        final shake = _isError
            ? 8 * (0.5 - (_shakeAnim.value - 0.5).abs()) *
                (_shakeController.value < 0.5 ? 1 : -1)
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_otpLength, (i) {
          final isFilled = _controllers[i].text.isNotEmpty;
          return Padding(
            padding: EdgeInsets.only(
                right: i < _otpLength - 1 ? 14 : 0),
            child: _buildOtpBox(i, isFilled),
          );
        }),
      ),
    );
  }

  Widget _buildOtpBox(int index, bool isFilled) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (_isSuccess) {
      borderColor = _green;
      bgColor     = _greenBg;
      textColor   = _greenDark;
    } else if (_isError) {
      borderColor = _red;
      bgColor     = _redBg;
      textColor   = _red;
    } else if (isFilled) {
      borderColor = _blue;
      bgColor     = _surface;
      textColor   = _navy;
    } else {
      borderColor = _border;
      bgColor     = _white;
      textColor   = _navy;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 64, height: 68,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isFilled || _isSuccess || _isError ? 2 : 1.5,
        ),
        boxShadow: isFilled && !_isError && !_isSuccess
            ? [BoxShadow(
                color: _blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1)]
            : _isSuccess
                ? [BoxShadow(
                    color: _green.withOpacity(0.12),
                    blurRadius: 10)]
                : [],
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) => _onKeyEvent(index, e),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          enabled: !_isSuccess,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onChanged(index, v),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  ERROR BADGE
  // ═══════════════════════════════════
  Widget _buildErrorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _redBg,
        border: Border.all(color: _redBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline_rounded, color: _red, size: 18),
          SizedBox(width: 8),
          Text('Invalid code. Please try again.',
              style: TextStyle(
                  fontSize: 13,
                  color: _red,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  SUCCESS BADGE
  // ═══════════════════════════════════
  Widget _buildSuccessBadge() {
    return FadeTransition(
      opacity: _successFade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _greenBg,
          border: Border.all(color: _greenBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: _green, size: 18),
            SizedBox(width: 8),
            Text('Phone verified successfully!',
                style: TextStyle(
                    fontSize: 13,
                    color: _greenDark,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  BUTTON
  // ═══════════════════════════════════
  Widget _buildButton() {
    final isComplete = _otp.length == _otpLength;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: GestureDetector(
        onTap: _isVerifying || _isSuccess
            ? (_isSuccess ? () => context.go('/home') : null)
            : (_handleVerify),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSuccess
                      ? [_greenDark, _green]
                      : isComplete
                          ? [_navy, _blue]
                          : [
                              _navy.withOpacity(0.4),
                              _blue.withOpacity(0.4)
                            ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: (_isSuccess ? _green : _blue)
                        .withOpacity(isComplete ? 0.35 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    child!,
                    if (!_isVerifying && isComplete)
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_shimmerAnim.value * 220, 0),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                _white.withOpacity(0.1),
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
            child: _isVerifying
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: _white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSuccess ? 'Continue' : 'Verify Phone',
                        style: const TextStyle(
                          color: _white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: _isSuccess ? _white : _amber,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  RESEND ROW
  // ═══════════════════════════════════
  Widget _buildResendRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn't receive the code? ",
                style: TextStyle(fontSize: 13, color: _muted)),
            GestureDetector(
              onTap: _canResend ? _handleResend : null,
              child: Text(
                'Resend',
                style: TextStyle(
                  fontSize: 13,
                  color: _canResend ? _blue : _hint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!_canResend) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Resend available in ',
                  style: TextStyle(
                      fontSize: 11, color: _hint)),
              Text(_timerText,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _navy,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ],
    );
  }
}