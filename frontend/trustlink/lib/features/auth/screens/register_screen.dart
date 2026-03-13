import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════
//  REGISTER SCREEN — TrustLink v3
//  Light Clean design
//  Toggle Customer / Artisan
//  Fields: Full Name, Email, Phone, Location, Password
// ═══════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {

  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameController       = TextEditingController();
  final _emailController      = TextEditingController();
  final _phoneController      = TextEditingController();
  final _locationController   = TextEditingController();
  final _passwordController   = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading       = false;
  bool _agreedToTerms   = false;
  bool _isCustomer      = true; // toggle state

  // Focus nodes
  final _nameFocus     = FocusNode();
  final _emailFocus    = FocusNode();
  final _phoneFocus    = FocusNode();
  final _passwordFocus = FocusNode();

  bool _nameFocused     = false;
  bool _emailFocused    = false;
  bool _phoneFocused    = false;
  bool _passwordFocused = false;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double>   _headerFade;
  late Animation<double>   _headerSlide;
  late Animation<double>   _formFade;
  late Animation<double>   _formSlide;

  // Toggle animation
  late AnimationController _toggleController;
  late Animation<double>   _toggleAnim;

  // Button shimmer
  late AnimationController _shimmerController;
  late Animation<double>   _shimmerAnim;

  // ─── Colours ───
  static const _navy      = Color(0xFF0A1628);
  static const _blue      = Color(0xFF1B4FD8);
  static const _blueLight = Color(0xFF3B82F6);
  static const _blueBg    = Color(0xFFEFF6FF);
  static const _amber     = Color(0xFFF59E0B);
  static const _white     = Colors.white;
  static const _surface   = Color(0xFFF7F8FC);
  static const _border    = Color(0xFFE8EDF5);
  static const _hint      = Color(0xFFCBD5E1);
  static const _muted     = Color(0xFF94A3B8);
  static const _label     = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    _headerSlide = Tween<double>(begin: -20, end: 0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    ));
    _formFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    _formSlide = Tween<double>(begin: 28, end: 0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Toggle slide (0 = Customer left, 1 = Artisan right)
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _toggleAnim = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Focus listeners
    _nameFocus.addListener(()  => setState(() => _nameFocused  = _nameFocus.hasFocus));
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _phoneFocus.addListener(() => setState(() => _phoneFocused = _phoneFocus.hasFocus));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _toggleController.dispose();
    _shimmerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _switchToggle(bool toCustomer) {
    if (_isCustomer == toCustomer) return;
    setState(() => _isCustomer = toCustomer);
    if (toCustomer) {
      _toggleController.reverse();
    } else {
      _toggleController.forward();
    }
  }

  void _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms of Service')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: call API register
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      if (mounted) context.go('/home');
    }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildToggle(),
                    _buildForm(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, child) => FadeTransition(
        opacity: _headerFade,
        child: Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: child,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: logo + back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.handshake_rounded,
                          color: _white, size: 18),
                    ),
                  ),

                  // Back to sign in pill
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _surface,
                        border: Border.all(color: _border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.chevron_left_rounded,
                              size: 16, color: _label),
                          SizedBox(width: 4),
                          Text('Sign In',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _label,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _navy,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    const TextSpan(text: 'Create your\n'),
                    WidgetSpan(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Join thousands of users on TrustLink',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  CUSTOMER / ARTISAN TOGGLE
  // ═══════════════════════════════════
  Widget _buildToggle() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, child) => FadeTransition(
        opacity: _headerFade,
        child: child,
      ),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: _blueBg,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _toggleAnim,
          builder: (_, __) {
            return Row(
              children: [
                // Customer tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchToggle(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _isCustomer ? _blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isCustomer
                            ? [BoxShadow(
                                color: _blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: _isCustomer ? _white : _muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isCustomer ? _white : _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Artisan tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchToggle(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: !_isCustomer ? _blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !_isCustomer
                            ? [BoxShadow(
                                color: _blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 16,
                            color: !_isCustomer ? _white : _muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Artisan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: !_isCustomer ? _white : _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  //  FORM
  // ═══════════════════════════════════
  Widget _buildForm() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, child) => FadeTransition(
        opacity: _formFade,
        child: Transform.translate(
          offset: Offset(0, _formSlide.value),
          child: child,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Full Name
            _fieldLabel('FULL NAME'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              isFocused: _nameFocused,
              hint: 'Kofi Mensah',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 16),

            // Email
            _fieldLabel('EMAIL'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              isFocused: _emailFocused,
              hint: 'you@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            _fieldLabel('PHONE'),
            const SizedBox(height: 7),
            _buildPhoneField(),
            const SizedBox(height: 16),

            // Location
            _fieldLabel('LOCATION'),
            const SizedBox(height: 7),
            _buildLocationField(),
            const SizedBox(height: 16),

            // Password
            _fieldLabel('PASSWORD'),
            const SizedBox(height: 7),
            _buildPasswordField(),
            const SizedBox(height: 24),

            // Terms
            _buildTermsCheckbox(),
            const SizedBox(height: 24),

            // Register button
            _buildRegisterButton(),
            const SizedBox(height: 20),

            // Sign in link
            _buildSignInLink(),
          ],
        ),
      ),
    );
  }

  // ─── Field label ───
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _label,
        letterSpacing: 0.1,
      ),
    );
  }

  // ─── Generic text field ───
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isFocused ? _surface : _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? _blue : _border,
          width: isFocused ? 1.5 : 1.5,
        ),
        boxShadow: isFocused
            ? [BoxShadow(
                color: _blue.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 2)]
            : [BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 14, color: _navy, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _hint, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(icon,
                size: 19,
                color: isFocused ? _blue : _muted),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        validator: validator,
      ),
    );
  }

  // ─── Phone field with country code ───
  Widget _buildPhoneField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: _phoneFocused ? _surface : _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _phoneFocused ? _blue : _border,
          width: 1.5,
        ),
        boxShadow: _phoneFocused
            ? [BoxShadow(
                color: _blue.withOpacity(0.08),
                blurRadius: 12, spreadRadius: 2)]
            : [BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Country code selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _surface,
              border: Border(
                right: BorderSide(color: _border, width: 1.5),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                const Text('🇨🇲', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                const Text('+237',
                    style: TextStyle(
                        fontSize: 13,
                        color: _navy,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: _muted),
              ],
            ),
          ),

          // Phone input
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontSize: 14, color: _navy, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                hintText: '6XX XXX XXX',
                hintStyle: TextStyle(color: _hint, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Enter your phone number' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Location field (dropdown style) ───
  Widget _buildLocationField() {
    return GestureDetector(
      onTap: () {
        // TODO: open city picker
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 19, color: _muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _locationController.text.isEmpty
                    ? 'Select your city'
                    : _locationController.text,
                style: TextStyle(
                  fontSize: 14,
                  color: _locationController.text.isEmpty ? _hint : _navy,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: _muted),
          ],
        ),
      ),
    );
  }

  // ─── Password field ───
  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _passwordFocused ? _surface : _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _passwordFocused ? _blue : _border,
          width: 1.5,
        ),
        boxShadow: _passwordFocused
            ? [BoxShadow(
                color: _blue.withOpacity(0.08),
                blurRadius: 12, spreadRadius: 2)]
            : [BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocus,
        obscureText: _obscurePassword,
        style: const TextStyle(
            fontSize: 14, color: _navy, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: _hint, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(Icons.lock_outline_rounded,
                size: 19,
                color: _passwordFocused ? _blue : _muted),
          ),
          suffixIcon: GestureDetector(
            onTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: _muted,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Enter your password';
          if (v.length < 6) return 'Minimum 6 characters';
          return null;
        },
      ),
    );
  }

  // ─── Terms checkbox ───
  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms ? _blue : _white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms ? _blue : _border,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded,
                    color: _white, size: 13)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 12,
                    color: _label,
                    height: 1.5),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                        color: _blue, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                        color: _blue, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Register button ───
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleRegister,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_navy, _blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(0.35),
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
                    if (!_isLoading)
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
            child: _isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: _white, strokeWidth: 2.5))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Account',
                          style: TextStyle(
                            color: _white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded,
                          color: _amber, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Sign in link ───
  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account? ',
              style: TextStyle(fontSize: 13, color: _muted)),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: const Text(
              'Sign In →',
              style: TextStyle(
                fontSize: 13,
                color: _blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}