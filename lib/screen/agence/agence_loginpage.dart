import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bus_easy/screen/agence/agency_dashboard.dart';

// =================== Thème / Constantes ===================
const kPrimaryGreen = Color(0xFFF0FFF4); // fond doux vert
const kAccentGreen = Color(0xFF48BB78); // accents verts
const kTextDark = Color(0xFF2D3748);
const kTextLight = Color(0xFF718096);
const kSurface = Colors.white;

const kGradientStart = Color(0xFFF7FAFC);
const kGradientEnd = Color(0xFFEDF7ED);
const kCardShadow = Color(0x0F1A5D29);
const kInputFocus = Color(0xFF68D391);

const double _kCardRadius = 24;
const double _kBreakpoint = 980;

class AgenceLoginPage extends StatefulWidget {
  const AgenceLoginPage({super.key});

  @override
  State<AgenceLoginPage> createState() => _AgenceLoginPageState();
}

class _AgenceLoginPageState extends State<AgenceLoginPage> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // -------------------- ACTIONS (Firebase) --------------------
  // NOTE: déclarées `void` async pour rester compatibles avec VoidCallback
  void _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _toast("Veuillez remplir tous les champs");
      return;
    }

    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        // Redirection vers le dashboard agence
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AgencyDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Erreur de connexion";
      if (e.code == 'user-not-found') {
        msg = "Utilisateur introuvable.";
      } else if (e.code == 'wrong-password') {
        msg = "Mot de passe incorrect.";
      } else if (e.code == 'invalid-email') {
        msg = "Adresse email invalide.";
      }
      _toast(msg);
    } catch (e) {
      _toast("Erreur inconnue. Réessayez.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _toast("Veuillez entrer votre email pour réinitialiser le mot de passe");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _toast("Email de réinitialisation envoyé !");
    } on FirebaseAuthException catch (e) {
      String msg = "Erreur lors de l'envoi";
      if (e.code == 'user-not-found') msg = "Aucun compte pour cet email.";
      _toast(msg);
    } catch (e) {
      _toast("Erreur lors de l'envoi de l'email.");
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kAccentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= _kBreakpoint;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kGradientStart, kGradientEnd],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(_kCardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: kCardShadow,
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_kCardRadius),
                          child: wide
                              ? Row(
                            children: [
                              const Expanded(flex: 6, child: _LeftImagePanel()),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 48, vertical: 40),
                                  child: _FormBlock(
                                    emailCtrl: _emailCtrl,
                                    passCtrl: _passCtrl,
                                    emailFocus: _emailFocus,
                                    passFocus: _passFocus,
                                    obscure: _obscure,
                                    loading: _loading,
                                    onToggleObscure: () =>
                                        setState(() => _obscure = !_obscure),
                                    onSubmit: _loading ? null : _login,
                                    onForgot: _resetPassword,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 240, child: _LeftImagePanel()),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                                child: _FormBlock(
                                  emailCtrl: _emailCtrl,
                                  passCtrl: _passCtrl,
                                  emailFocus: _emailFocus,
                                  passFocus: _passFocus,
                                  obscure: _obscure,
                                  loading: _loading,
                                  onToggleObscure: () =>
                                      setState(() => _obscure = !_obscure),
                                  onSubmit: _loading ? null : _login,
                                  onForgot: _resetPassword,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================== PANNEAU GAUCHE (Image + overlay) ===================
class _LeftImagePanel extends StatelessWidget {
  const _LeftImagePanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient de fallback avec thème agence
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF48BB78), Color(0xFF38A169)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Grande icône de bus en arrière-plan
        Center(
          child: Icon(
            Icons.directions_bus_filled,
            size: 280,
            color: Colors.white.withOpacity(.12),
          ),
        ),
        // Overlay pour contraste
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.15),
                Colors.black.withOpacity(.4),
              ],
            ),
          ),
        ),
        // Branding Agence
        Padding(
          padding: const EdgeInsets.all(32),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'GLOBAL VOYAGES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AGENCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Espace partenaire dédié\nRéservations • Billets • Rapports • Support',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =================== BLOC FORMULAIRE ===================
class _FormBlock extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback? onSubmit;
  final VoidCallback onForgot;

  const _FormBlock({
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kAccentGreen.withOpacity(.15),
                    kAccentGreen.withOpacity(.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kAccentGreen.withOpacity(.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.business_outlined,
                color: kAccentGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espace Agence',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    color: kTextLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Email
        _InputField(
          label: 'Adresse email',
          controller: emailCtrl,
          focusNode: emailFocus,
          hintText: 'agence@exemple.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          onSubmitted: (_) => passFocus.requestFocus(),
        ),
        const SizedBox(height: 20),

        // Password
        _InputField(
          label: 'Mot de passe',
          controller: passCtrl,
          focusNode: passFocus,
          hintText: '••••••••',
          obscureText: obscure,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: kTextLight,
              size: 22,
            ),
          ),
          onSubmitted: (_) => onSubmit?.call(),
        ),

        const SizedBox(height: 28),

        // Bouton Login
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kAccentGreen.withOpacity(.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: kAccentGreen.withOpacity(.3),
            ),
            child: loading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: onForgot,
            icon: Icon(Icons.help_outline, size: 18, color: kAccentGreen),
            label: Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                color: kAccentGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =================== CHAMP INPUT PERSONNALISÉ ===================
class _InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onSubmitted;

  const _InputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: kInputFocus.withOpacity(.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: kTextLight.withOpacity(.7)),
              filled: true,
              fillColor: _isFocused ? kPrimaryGreen.withOpacity(.7) : kPrimaryGreen.withOpacity(.4),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  widget.prefixIcon,
                  color: _isFocused ? kAccentGreen : kTextLight,
                  size: 22,
                ),
              ),
              suffixIcon: widget.suffixIcon != null ? Padding(padding: const EdgeInsets.only(right: 8), child: widget.suffixIcon) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: kInputFocus,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ],
    );
  }
}
