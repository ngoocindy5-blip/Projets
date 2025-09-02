import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Création de l'utilisateur avec email et mot de passe
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inscription réussie !'),
        backgroundColor: Colors.green,
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Erreur inscription');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person_add_alt, size: 64, color: Color(0xFF667eea)),
                      const SizedBox(height: 24),

                      // Champ Prénom
                      TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Entrez votre prénom' : null,
                      ),
                      const SizedBox(height: 16),

                      // Champ Nom
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Entrez votre nom' : null,
                      ),
                      const SizedBox(height: 16),

                      // Champ Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Entrez votre email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Champ Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? 'Mot de passe min. 6 caractères'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Champ Confirmation mot de passe
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Confirmez votre mot de passe';
                          if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Bouton Créer un compte
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Créer un compte', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lien pour aller à la page de connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Déjà un compte ?'),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Se connecter'),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
