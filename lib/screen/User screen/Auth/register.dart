import 'package:bus_easy/screen/User%20screen/Home/Home_page.dart';
import 'package:bus_easy/screen/User%20screen/navigation/nav_manage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _tel = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    _tel.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  bool _isValidEmail(String v) {
    final email = v.trim();
    final reg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return reg.hasMatch(email);
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text.trim();
    final pwd2 = _pwd2Ctrl.text.trim();
    final phone = _tel.text.trim();

    // ✅ Validations simples (sans toucher à l’UI)
    if (name.isEmpty || email.isEmpty || pwd.isEmpty || pwd2.isEmpty || phone.isEmpty) {
      _showSnack("Veuillez remplir tous les champs.", error: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack("Adresse e-mail invalide.", error: true);
      return;
    }
    if (pwd.length < 6) {
      _showSnack("Le mot de passe doit contenir au moins 6 caractères.", error: true);
      return;
    }
    if (pwd != pwd2) {
      _showSnack("Les mots de passe ne correspondent pas.", error: true);
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      // 🔐 Création du compte
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pwd,
      );

      // Optionnel : MAJ displayName
      await cred.user?.updateDisplayName(name);

      // 🗄️ Écriture Firestore (users/{uid})
      final uid = cred.user!.uid;
      final now = DateTime.now();
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'client',
        'status': 'actif',
        'createdAt': now,
        'updatedAt': now,
      });

      _showSnack("Compte créé avec succès. Bienvenue sur GLOBAL VOYAGES !");

      // ✅ Nettoyage du formulaire
      _nameCtrl.clear();
      _emailCtrl.clear();
      _pwdCtrl.clear();
      _pwd2Ctrl.clear();
      _tel.clear();

      // ✅ Redirection vers la HomePage
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavManage()), // <-- Ta page d'accueil
      );
    } on FirebaseAuthException catch (e) {
      // 🎯 Messages précis pour les codes Firebase
      String msg = "Une erreur est survenue.";
      switch (e.code) {
        case 'email-already-in-use':
          msg = "Cet e-mail est déjà utilisé.";
          break;
        case 'invalid-email':
          msg = "Adresse e-mail invalide.";
          break;
        case 'operation-not-allowed':
          msg = "Inscription désactivée. Contactez l’administrateur.";
          break;
        case 'weak-password':
          msg = "Mot de passe trop faible.";
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
      _showSnack("Erreur inattendue: $e", error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size sz = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Fond et éléments décoratifs: inchangés
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
                    Image.asset(
                      'assets/img/Tablet login-rafiki.png',
                      fit: BoxFit.contain,
                      width: 500,
                    ),
                    const Text(
                      'Creer un nouveau compte',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Inscrivez-vous pour continuer votre experience sur GLOBAL VOYAGES',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    const _FieldLabel('Nom'),
                    const SizedBox(height: 8),
                    PillTextField(
                      controller: _nameCtrl,
                      hint: 'Entrer votre Nom',
                    ),
                    const SizedBox(height: 18),

                    // Email
                    const _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    PillTextField(
                      controller: _emailCtrl,
                      hint: 'Entrer votre Email',
                      suffix: const Padding(padding: EdgeInsets.only(right: 8)),
                    ),
                    const SizedBox(height: 15),

                    // Phone
                    const _FieldLabel("Telephone"),
                    const SizedBox(height: 8),
                    PillTextField(
                      controller: _tel,
                      hint: 'Entrer votre numero de telephone',
                      suffix: const Padding(padding: EdgeInsets.only(right: 8)),
                    ),
                    const SizedBox(height: 18),

                    // Password
                    const _FieldLabel('Mot de passe'),
                    const SizedBox(height: 8),
                    PillTextField(
                      controller: _pwdCtrl,
                      hint: 'Entrer votre mot de passe',
                      obscure: _obscure1,
                      suffixIcon: IconButton(
                        splashRadius: 20,
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                        icon: Icon(
                          _obscure1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black.withOpacity(.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Confirm password
                    const _FieldLabel('Confirmez votre mot de passe'),
                    const SizedBox(height: 8),
                    PillTextField(
                      controller: _pwd2Ctrl,
                      hint: 'Confirmer votre mot de passe',
                      obscure: _obscure2,
                      suffixIcon: IconButton(
                        splashRadius: 20,
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black.withOpacity(.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Register button (style inchangé)
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
                              color: Color(0xFF2E7BFF).withOpacity(.25),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register, // ✅ blocage pendant le chargement
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
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text("S'inscrire"),
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
                            const TextSpan(text: 'Vous avez deja un compte ?  '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  // TODO: navigation vers la page de connexion
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 4),
                                  child: Text(
                                    'Connexion',
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

class PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final Widget? suffixIcon;

  const PillTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
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
        suffix: suffix,
      ),
      keyboardType: obscure
          ? TextInputType.text
          : (hint.toLowerCase().contains('email')
          ? TextInputType.emailAddress
          : (hint.toLowerCase().contains('telephone')
          ? TextInputType.phone
          : TextInputType.text)),
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
