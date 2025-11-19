import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(ProSignupApp());
}

class ProSignupApp extends StatelessWidget {
  const ProSignupApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soso — Professional Signup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),
      home: const ProSignupPage(),
    );
  }
}

/// A modern, polished signup screen with animated gradient background,
/// glassmorphism card, custom inputs, password strength meter and
/// polished social buttons.
///
/// Replace your previous main.dart with this file to get a very different,
/// professional UI. The code is self-contained and uses only Flutter built-ins.
class ProSignupPage extends StatefulWidget {
  const ProSignupPage({Key? key}) : super(key: key);

  @override
  State<ProSignupPage> createState() => _ProSignupPageState();
}

class _ProSignupPageState extends State<ProSignupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // UI state
  bool _obscure = true;
  bool _accept = false;
  bool _submitting = false;
  double _pwStrength = 0.0;

  // Animations
  late final AnimationController _bgController;
  late final AnimationController _cardController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardController.forward();

    _password.addListener(_evaluatePassword);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password
      ..removeListener(_evaluatePassword)
      ..dispose();
    _bgController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _evaluatePassword() {
    final pw = _password.text;
    double score = 0;
    if (pw.length >= 6) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(pw)) score += 0.25;
    if (RegExp(r'[!@#\$&*~%^]').hasMatch(pw)) score += 0.25;
    setState(() => _pwStrength = score);
  }

  // Fake submit to show polished success flow
  Future<void> _submit() async {
    if (!_accept) {
      _showSnack('يجب الموافقة على الشروط والسياسة أولاً', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // animate card slightly
    _cardController.reverse();
    await Future.delayed(const Duration(milliseconds: 600));
    // simulate network
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _submitting = false);
    _cardController.forward();

    _showSnack('تم إنشاء الحساب بنجاح 🎉', background: Colors.green.shade600);

    // simple success dialog with transition
    if (mounted) {
      showDialog(
        context: context,
        builder: (c) => Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _cardController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.celebration, size: 52, color: Colors.deepPurple),
                  SizedBox(height: 12),
                  Text(
                    'مرحباً بك!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'تم إعداد حسابك بنجاح — استمتع بالتجربة.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // auto-close
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showSnack(String text, {bool isError = false, Color? background}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor:
            background ??
            (isError ? Colors.red.shade600 : Colors.blue.shade700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Decorative animated radial gradient
  Widget _animatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
        final colorA = Color.lerp(
          Colors.deepPurple.shade700,
          Colors.indigo.shade400,
          t,
        )!;
        final colorB = Color.lerp(
          Colors.pink.shade400,
          Colors.deepPurple.shade200,
          t,
        )!;
        final colorC = Color.lerp(
          Colors.teal.shade300,
          Colors.purple.shade100,
          t,
        )!;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.6),
              radius: 1.8,
              colors: [colorA, colorB, colorC],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle floating circles
              Positioned(
                top: size.height * 0.12,
                left: size.width * 0.08,
                child: Opacity(
                  opacity: 0.08,
                  child: Transform.scale(
                    scale: 1 + (t * 0.08),
                    child: _decorCircle(120, Colors.white),
                  ),
                ),
              ),
              Positioned(
                right: -30,
                top: size.height * 0.02,
                child: Opacity(
                  opacity: 0.06,
                  child: Transform.rotate(
                    angle: t * 0.9,
                    child: _decorCircle(210, Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Opacity(
                  opacity: 0.04,
                  child: _decorCircle(260, Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // subtle gaussian blur via shadow
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 40)],
      ),
    );
  }

  // Custom glass card for the form
  Widget _glassCard(Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1).animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // Custom input row with leading icon and floating-like style
  Widget _field({
    required Widget child,
    required IconData icon,
    double height = 56,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Color _strengthColor(double v) {
    if (v <= 0.25) return Colors.redAccent;
    if (v <= 0.5) return Colors.orangeAccent;
    if (v <= 0.75) return Colors.amber;
    return Colors.greenAccent.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // extend behind to show animated background
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'عودة',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => _showSnack(
              'يتم فتح المساعدة...',
              background: Colors.deepPurple,
            ),
            child: const Text(
              'مساعدة',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // animated background
          _animatedBackground(size),

          // content center
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width > 900 ? 900 : size.width,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left decorative column (only on wide screens)
                      if (size.width > 900)
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 40),
                                const Hero(
                                  tag: 'logo',
                                  child: Icon(
                                    Icons.lock_clock,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Soso\nبخبرة واحترافية',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Opacity(
                                  opacity: 0.95,
                                  child: Text(
                                    'تصميم حديث، أداء سريع، وتجربة مستخدم لا تنسى — سجّل الآن وانطلق.',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 34),
                                // highlight cards
                                Row(
                                  children: [
                                    _miniFeature(
                                      'أمان',
                                      Icons.shield,
                                      Colors.indigo.shade50,
                                    ),
                                    const SizedBox(width: 12),
                                    _miniFeature(
                                      'دعم 24/7',
                                      Icons.headset,
                                      Colors.pink.shade50,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      // The glass form card
                      Expanded(
                        flex: size.width > 900 ? 6 : 1,
                        child: _glassCard(
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'إنشاء حساب احترافي',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'ابدأ الآن مع واجهة مُصممة بعناية',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // subtle badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.verified,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'محترف',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _field(
                                      icon: Icons.person,
                                      child: TextFormField(
                                        controller: _name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                          hintText: 'الاسم الكامل',
                                          hintStyle: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty)
                                            return 'الرجاء إدخال الاسم';
                                          if (v.trim().length < 3)
                                            return 'الاسم قصير جداً';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _field(
                                      icon: Icons.email_outlined,
                                      child: TextFormField(
                                        controller: _email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'البريد الإلكتروني',
                                          hintStyle: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'الرجاء إدخال البريد';
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(v)) {
                                            return 'البريد غير صالح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _field(
                                      icon: Icons.phone_android,
                                      child: TextFormField(
                                        controller: _phone,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'رقم الهاتف',
                                          hintStyle: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'الرجاء إدخال رقم الهاتف';
                                          if (v
                                                  .replaceAll(
                                                    RegExp(r'[^0-9]'),
                                                    '',
                                                  )
                                                  .length <
                                              10) {
                                            return 'الرقم غير صالح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _field(
                                      icon: Icons.lock_outline,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _password,
                                              obscureText: _obscure,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: 'كلمة المرور',
                                                hintStyle: TextStyle(
                                                  color: Colors.white54,
                                                ),
                                              ),
                                              validator: (v) {
                                                if (v == null || v.isEmpty)
                                                  return 'الرجاء إدخال كلمة المرور';
                                                if (v.length < 6)
                                                  return 'كلمة المرور قصيرة';
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () => setState(
                                              () => _obscure = !_obscure,
                                            ),
                                            child: Icon(
                                              _obscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Password strength indicator
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.06,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: _pwStrength,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: _strengthColor(
                                                    _pwStrength,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _pwStrength <= 0.25
                                              ? 'ضعيفة'
                                              : _pwStrength <= 0.5
                                              ? 'متوسطة'
                                              : _pwStrength <= 0.75
                                              ? 'قوية'
                                              : 'قوية جداً',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _accept,
                                          activeColor: Colors.white,
                                          checkColor: Colors.deepPurple,
                                          onChanged: (v) => setState(
                                            () => _accept = v ?? false,
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'أوافق على ',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'الشروط والأحكام',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  // onTap requires GestureRecognizer; keeping simple here
                                                ),
                                                const TextSpan(text: ' و '),
                                                const TextSpan(
                                                  text: 'سياسة الخصوصية',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),

                                    // Submit button with polished animation
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _submitting ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.deepPurple,
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 450,
                                          ),
                                          transitionBuilder: (child, anim) =>
                                              FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              ),
                                          child: _submitting
                                              ? Row(
                                                  key: const ValueKey(
                                                    'loading',
                                                  ),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text('جاري الإنشاء...'),
                                                  ],
                                                )
                                              : const Text(
                                                  'إنشاء حساب احترافي',
                                                  key: ValueKey('text'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Divider and social login
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'أو',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _socialButton(
                                          Icons.mail_outline,
                                          'Google',
                                          Colors.red.shade400,
                                          () {
                                            _showSnack(
                                              'جاري تسجيل الدخول عبر Google',
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        _socialButton(
                                          Icons.facebook,
                                          'Facebook',
                                          Colors.blue.shade700,
                                          () {
                                            _showSnack(
                                              'جاري تسجيل الدخول عبر Facebook',
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        _socialButton(
                                          Icons.apple,
                                          'Apple',
                                          Colors.black,
                                          () {
                                            _showSnack(
                                              'جاري تسجيل الدخول عبر Apple',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: TextButton(
                                        onPressed: () => _showSnack(
                                          'التحويل إلى تسجيل الدخول...',
                                        ),
                                        child: const Text(
                                          'هل لديك حساب؟ سجّل الدخول',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFeature(String title, IconData icon, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bg.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
