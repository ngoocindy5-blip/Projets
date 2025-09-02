import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size sz = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Dégradé pastel de fond (vert -> mauve/rose)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDDF7E8), // pastel green
                  Color(0xFFE8E0FA), // soft lavender
                  Color(0xFFF4DFF0), // light pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Quelques bulles floues très légères comme sur certains dribbble shots
          Positioned(
            top: -60,
            left: -40,
            child: _BlurDot(size: 160, color: Colors.white.withOpacity(.25)),
          ),
          Positioned(
            top: 90,
            right: -50,
            child: _BlurDot(size: 120, color: Colors.white.withOpacity(.18)),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: _BlurDot(size: 150, color: Colors.white.withOpacity(.18)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sz.height - 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/img/Tablet login-rafiki.png', fit: BoxFit.contain, width: 500,),
                    const Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to learn Korean Language',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    const _FieldLabel('Name'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _nameCtrl,
                      hint: 'Enter your name',
                    ),
                    const SizedBox(height: 18),

                    // Email + Send OTP à droite
                    const _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _emailCtrl,
                      hint: 'Enter your email',
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ChipButton(
                          text: 'Send OTP',
                          onTap: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Password
                    const _FieldLabel('Password'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _pwdCtrl,
                      hint: 'Enter password',
                      obscure: _obscure1,
                      suffixIcon: IconButton(
                        splashRadius: 20,
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                        icon: Icon(
                          _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.black.withOpacity(.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Re-type Password
                    const _FieldLabel('Re-type Password'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _pwd2Ctrl,
                      hint: 're-type password',
                      obscure: _obscure2,
                      suffixIcon: IconButton(
                        splashRadius: 20,
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                        icon: Icon(
                          _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.black.withOpacity(.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Register button (dégradé bleu)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7BFF), Color(0xFF2A55FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7BFF).withOpacity(.25),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Already have an account ? Login
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black.withOpacity(.65),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account ?  '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {},
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF2E7BFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
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

/* ---------- Petits widgets utilitaires pour coller au design ---------- */

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(.82),
        fontWeight: FontWeight.w700,
        fontSize: 14.5,
      ),
    );
  }
}

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final Widget? suffixIcon;

  const _PillTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Remplit très clair et bords bien arrondis (style "pill")
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(.35),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
        // pour “Send OTP” placé à l’intérieur mais sans icône
        suffix: suffix,
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ChipButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2E7BFF),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurDot extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(size)),
    );
  }
}
