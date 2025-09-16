import 'package:bus_easy/screen/user_screen/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/nav_manage.dart';

// TODO : importe ta page d'accueil

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text.trim();

    if (email.isEmpty || pwd.isEmpty) {
      _showSnack("Veuillez remplir tous les champs.", error: true);
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pwd);

      _showSnack("Connexion réussie !");
      if (!mounted) return;

      // Nettoie les champs
      _emailCtrl.clear();
      _pwdCtrl.clear();

      // Redirige vers la HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavManage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Erreur de connexion.";
      switch (e.code) {
        case 'user-not-found':
          msg = "Aucun utilisateur trouvé avec cet email.";
          break;
        case 'wrong-password':
          msg = "Mot de passe incorrect.";
          break;
        case 'invalid-email':
          msg = "Email invalide.";
          break;
        case 'user-disabled':
          msg = "Ce compte est désactivé.";
          break;
        case 'network-request-failed':
          msg = "Problème de connexion réseau.";
          break;
        case 'too-many-requests':
          msg = "Trop de tentatives. Réessayez plus tard.";
          break;
        default:
          msg = e.message ?? msg;
      }
      _showSnack(msg, error: true);
    } catch (e) {
      _showSnack("Erreur inattendue : $e", error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // --- Fond dégradé ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDDF7E8),
                  Color(0xFFE8E0FA),
                  Color(0xFFF4DFF0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -60, left: -40, child: _BlurDot(size: 160, color: Colors.white24)),
          Positioned(top: 90, right: -50, child: _BlurDot(size: 120, color: Colors.white)),
          Positioned(bottom: -50, left: -40, child: _BlurDot(size: 150, color: Colors.white)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sz.height - 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    Image.asset('assets/img/Tablet login-rafiki.png', fit: BoxFit.contain, width: 500),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connectez-vous pour continuer',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _emailCtrl,
                      hint: 'Entrez votre Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel('Mot de passe'),
                    const SizedBox(height: 8),
                    _PillTextField(
                      controller: _pwdCtrl,
                      hint: 'Entrez votre mot de passe',
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        splashRadius: 20,
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.black.withOpacity(.45),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7BFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // --- Bouton Login ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
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
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Connexion'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- Lien Register ---
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black.withOpacity(.65),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: "Vous n'avez pas de compte ? "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                  child: Text(
                                    'Inscription',
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


/* ------------------ Widgets utilitaires (mêmes styles) ------------------ */

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
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _PillTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
