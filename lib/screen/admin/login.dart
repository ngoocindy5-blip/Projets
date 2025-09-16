import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home/dashboard_admin.dart';

// =================== Thème / Constantes ===================
const kPrimaryBlue = Color(0xFFF0F4FF); // fond doux
const kAccentBlue  = Color(0xFF6B9FFF); // accents
const kTextDark    = Color(0xFF2D3748);
const kTextLight   = Color(0xFF718096);
const kSurface     = Colors.white;

// Nouvelles couleurs pour le design moderne
const kGradientStart = Color(0xFFF8FAFF);
const kGradientEnd   = Color(0xFFEDF2FF);
const kCardShadow    = Color(0x0F1A365D);
const kInputFocus    = Color(0xFF8BB5FF);

const String kUsersCollection = 'users';
const Set<String> kAdminRoles = {'admin'};

const double _kCardRadius   = 24;
const double _kBreakpoint   = 980; // à partir de cette largeur : split view

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> with TickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userFocus = FocusNode();
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
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // -------------------- NAVIGATION ROBUSTE --------------------
  void _goToDashboard() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        // Remplace par ton vrai dashboard importé
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
      );
    });
  }

  // -------------------- LOGIQUE DE CONNEXION --------------------
  Future<void> _login() async {
    final email = _userCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _toast('Email et mot de passe requis.');
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) auth Firebase
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      final user = cred.user!;
      final uid  = user.uid;

      // 2) Doc Firestore: d'abord par uid, sinon par email
      final usersCol = FirebaseFirestore.instance.collection(kUsersCollection);
      Map<String, dynamic>? data;

      final byUid = await usersCol.doc(uid).get();
      if (byUid.exists) {
        data = byUid.data();
      } else {
        final byEmail = await usersCol.where('email', isEqualTo: email).limit(1).get();
        if (byEmail.docs.isNotEmpty) data = byEmail.docs.first.data();
      }

      // 3) Si pas de doc -> créer un doc minimal (évite les incohérences)
      if (data == null) {
        await usersCol.doc(uid).set({
          'uid': uid,
          'email': email,
          'name': user.displayName ?? '',
          'role': 'user', // par défaut
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        data = (await usersCol.doc(uid).get()).data();
      }

      // 4) Rôle + fallback sur claims
      final role = (data?['role'] ?? data?['Role'] ?? '')
          .toString().trim().toLowerCase();

      final token  = await user.getIdTokenResult(true);
      final claims = token.claims ?? {};
      final isAdminClaim = (claims['admin'] as bool?) ?? false;

      final isAdmin = kAdminRoles.contains(role) || isAdminClaim;

      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        _toast("Ce compte n'a pas les droits administrateur.");
        return;
      }

      _toast('Connexion administrateur réussie.');
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found'    => "Aucun compte trouvé pour cet email.",
        'wrong-password'    => "Mot de passe incorrect.",
        'invalid-email'     => "Email invalide.",
        'user-disabled'     => "Compte désactivé.",
        'too-many-requests' => "Trop de tentatives. Réessayez plus tard.",
        _                   => "Échec de connexion: ${e.message ?? e.code}",
      };
      _toast(msg);
    } on FirebaseException catch (e) {
      _toast('Erreur Firestore: ${e.message ?? e.code}');
    } catch (e) {
      _toast('Erreur inattendue: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _userCtrl.text.trim();
    if (email.isEmpty) {
      _toast('Entrez votre email pour réinitialiser.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _toast('Email de réinitialisation envoyé.');
    } catch (e) {
      _toast("Impossible d'envoyer l'email: $e");
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: kAccentBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

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
                              // ----- Panneau gauche image -----
                              const Expanded(flex: 6, child: _LeftImagePanel()),
                              // ----- Panneau droit formulaire -----
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                                  child: _FormBlock(
                                    userCtrl: _userCtrl,
                                    passCtrl: _passCtrl,
                                    userFocus: _userFocus,
                                    passFocus: _passFocus,
                                    obscure: _obscure,
                                    loading: _loading,
                                    onToggleObscure: () => setState(() => _obscure = !_obscure),
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
                              // En mobile : image en haut, hauteur fixe
                              const SizedBox(height: 240, child: _LeftImagePanel()),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                                child: _FormBlock(
                                  userCtrl: _userCtrl,
                                  passCtrl: _passCtrl,
                                  userFocus: _userFocus,
                                  passFocus: _passFocus,
                                  obscure: _obscure,
                                  loading: _loading,
                                  onToggleObscure: () => setState(() => _obscure = !_obscure),
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
        // Tente de charger l'asset (image locale). Si absent, fallback gradient.
        Image.asset(
          'assets/img/Tablet login-rafiki.png',
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7CA9FF), Color(0xFF4D8DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        // Voile/overlay pour le contraste - plus doux
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
        // Branding + baseline
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
                    Icons.directions_bus_filled,
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
                    'ADMIN',
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
                  'Plateforme de gestion avancée\nBus • Agences • Utilisateurs • Analytics',
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

// =================== BLOC FORMULAIRE (droite) ===================
class _FormBlock extends StatelessWidget {
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final FocusNode userFocus;
  final FocusNode passFocus;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback? onSubmit;
  final VoidCallback onForgot;

  const _FormBlock({
    required this.userCtrl,
    required this.passCtrl,
    required this.userFocus,
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
        // Header modernisé
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kAccentBlue.withOpacity(.15),
                    kAccentBlue.withOpacity(.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kAccentBlue.withOpacity(.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: kAccentBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administration',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Espace sécurisé',
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

        // Email modernisé
        _InputField(
          label: 'Adresse email',
          controller: userCtrl,
          focusNode: userFocus,
          hintText: 'admin@exemple.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          onSubmitted: (_) => passFocus.requestFocus(),
        ),
        const SizedBox(height: 20),

        // Password modernisé
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

        // Bouton Login modernisé
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kAccentBlue.withOpacity(.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: kAccentBlue.withOpacity(.3),
            ),
            child: loading
                ? const SizedBox(
              height: 22, width: 22,
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
            icon: Icon(Icons.help_outline, size: 18, color: kAccentBlue),
            label: Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                color: kAccentBlue,
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
            boxShadow: _isFocused ? [
              BoxShadow(
                color: kInputFocus.withOpacity(.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
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
              fillColor: _isFocused
                  ? kPrimaryBlue.withOpacity(.7)
                  : kPrimaryBlue.withOpacity(.4),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  widget.prefixIcon,
                  color: _isFocused ? kAccentBlue : kTextLight,
                  size: 22,
                ),
              ),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: widget.suffixIcon,
              )
                  : null,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ],
    );
  }
}