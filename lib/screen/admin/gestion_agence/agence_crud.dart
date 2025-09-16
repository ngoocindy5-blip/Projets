import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, ValueListenableBuilder;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/theme.dart';

final _usersCol = FirebaseFirestore.instance.collection('users');

/// ========================= HELPERS GÉNÉRAUX =========================

String _randLetters(int n) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  final r = Random.secure();
  return List.generate(n, (_) => chars[r.nextInt(chars.length)]).join();
}

String _randDigits(int n) {
  final r = Random.secure();
  return List.generate(n, (_) => r.nextInt(10).toString()).join();
}

/// Code agence du type : AG-ABCDE-123
Future<String> _uniqueAgencyCode() async {
  while (true) {
    final code = 'AG-${_randLetters(5)}-${_randDigits(3)}';
    final q = await _usersCol
        .where('role', isEqualTo: 'agence')
        .where('agencyCode', isEqualTo: code)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return code;
  }
}

Future<FirebaseApp> _secondaryApp() async {
  try {
    return Firebase.app('secondary');
  } catch (_) {
    final defaultApp = Firebase.app();
    return Firebase.initializeApp(
      name: 'secondary',
      options: defaultApp.options,
    );
  }
}

final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? _vNotEmpty(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Requis' : null;

String? _vEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requis';
  return _emailRe.hasMatch(v.trim()) ? null : 'Email invalide';
}

String? _vPhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requis';
  final s = v.replaceAll(RegExp(r'\s+'), '');
  return s.length < 6 ? 'Téléphone invalide' : null;
}

String? _vPassword(String? v) {
  if (v == null || v.length < 6) return 'Min. 6 caractères';
  return null;
}

/// ========================= CRUD AGENCE ===============================

/// Création d’un compte **Firebase auth** pour l’agence via une app secondaire,
/// puis création du document Firestore `users/{uid}` avec role: "agence".
Future<String> createAgencyAccount({
  required String name,
  required String email,
  required String phone,
  required String managerName,
  required String managerPhone,
  required String password,
  String status = 'actif', // actif | suspendu | inactif
}) async {
  // Vérifs côté Firestore (email déjà utilisé)
  final exists = await _usersCol.where('email', isEqualTo: email.trim()).limit(1).get();
  if (exists.docs.isNotEmpty) {
    throw 'Un compte avec cet email existe déjà dans Firestore.';
  }

  final app = await _secondaryApp();
  final secAuth = FirebaseAuth.instanceFor(app: app);

  try {
    final cred = await secAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name.trim());

    final uid = cred.user!.uid;
    final code = await _uniqueAgencyCode();

    await _usersCol.doc(uid).set({
      'uid': uid,
      'role': 'agence',
      'status': status,
      'agencyCode': code,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'managerName': managerName.trim(),
      'managerPhone': managerPhone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw 'Email déjà utilisé dans Firebase auth.';
    }
    throw e.message ?? e.code;
  } finally {
    // NE PAS perturber la session de l’admin
    await secAuth.signOut();
  }
}

Future<void> updateAgencyDoc(
    String uid, {
      String? name,
      String? phone,
      String? managerName,
      String? managerPhone,
      String? status, // actif | suspendu | inactif
    }) async {
  final data = <String, dynamic>{
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if (name != null) data['name'] = name.trim();
  if (phone != null) data['phone'] = phone.trim();
  if (managerName != null) data['managerName'] = managerName.trim();
  if (managerPhone != null) data['managerPhone'] = managerPhone.trim();
  if (status != null) data['status'] = status;

  await _usersCol.doc(uid).set(data, SetOptions(merge: true));
}

/// Envoi d’un email de réinitialisation au compte agence (via app secondaire).
Future<void> sendAgencyPasswordReset(String email) async {
  final app = await _secondaryApp();
  final secAuth = FirebaseAuth.instanceFor(app: app);
  try {
    await secAuth.sendPasswordResetEmail(email: email.trim());
  } finally {
    await secAuth.signOut();
  }
}

/// Suppression du **document Firestore** (soft conseil : préférez status=inactif).
/// ⚠️ Depuis le client on ne peut PAS supprimer l’utilisateur auth d’un autre compte.
Future<void> deleteAgencyDoc(String uid) async {
  await _usersCol.doc(uid).delete();
}

/// ========================= DIALOGS MODERNES ===========================

Future<void> showAgencyFormDialog(
    BuildContext context, {
      DocumentSnapshot<Map<String, dynamic>>? doc,
    }) async {
  final isEdit = doc != null;
  final m = doc?.data() ?? {};

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController(text: (m['name'] ?? '').toString());
  final emailCtrl = TextEditingController(text: (m['email'] ?? '').toString());
  final phoneCtrl = TextEditingController(text: (m['phone'] ?? '').toString());
  final managerNameCtrl = TextEditingController(text: (m['managerName'] ?? '').toString());
  final managerPhoneCtrl = TextEditingController(text: (m['managerPhone'] ?? '').toString());
  final pwdCtrl = TextEditingController();
  final pwd2Ctrl = TextEditingController();

  final status = ValueNotifier<String>((m['status'] ?? 'actif').toString());
  final loading = ValueNotifier<bool>(false);

  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: isEdit ? 'Modifier une agence' : 'Nouvelle agence',
      subtitle: isEdit
          ? 'Mettre à jour les informations de l’agence'
          : 'Créer le compte agence (auth + Firestore)',
      child: Form(
        key: formKey,
        child: ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (_, isLoading, __) => AbsorbPointer(
            absorbing: isLoading,
            child: Column(
              children: [
                // Nom + Statut
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _TF(
                        controller: nameCtrl,
                        label: 'Nom de l’agence *',
                        validator: _vNotEmpty,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Dropdown<String>(
                        label: 'Statut',
                        valueListenable: status,
                        items: const [
                          DropdownMenuItem(value: 'actif', child: Text('Actif')),
                          DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
                          DropdownMenuItem(value: 'inactif', child: Text('Inactif')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Email / Téléphone
                Row(
                  children: [
                    Expanded(
                      child: _TF(
                        controller: emailCtrl,
                        label: 'Email *',
                        keyboard: TextInputType.emailAddress,
                        validator: _vEmail,
                        enabled: !isEdit, // éviter update email côté client
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TF(
                        controller: phoneCtrl,
                        label: 'Téléphone *',
                        keyboard: TextInputType.phone,
                        validator: _vPhone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Manager
                Row(
                  children: [
                    Expanded(
                      child: _TF(
                        controller: managerNameCtrl,
                        label: 'Nom du responsable *',
                        validator: _vNotEmpty,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TF(
                        controller: managerPhoneCtrl,
                        label: 'Téléphone du responsable *',
                        keyboard: TextInputType.phone,
                        validator: _vPhone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Mot de passe (création uniquement)
                if (!isEdit) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _TF(
                          controller: pwdCtrl,
                          label: 'Mot de passe initial *',
                          validator: _vPassword,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TF(
                          controller: pwd2Ctrl,
                          label: 'Confirmer le mot de passe *',
                          validator: (v) {
                            final err = _vPassword(v);
                            if (err != null) return err;
                            if (v != pwdCtrl.text) return 'Les mots de passe ne correspondent pas';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                if (isEdit)
                  _InfoStrip(
                    icon: Icons.qr_code_2_rounded,
                    text:
                    'Code agence : ${(m['agencyCode'] ?? '—').toString()}',
                  ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    if (isEdit)
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            loading.value = true;
                            await sendAgencyPasswordReset(emailCtrl.text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lien de réinitialisation envoyé')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          } finally {
                            loading.value = false;
                          }
                        },
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('Réinitialiser le mot de passe'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          loading.value = true;
                          if (isEdit) {
                            await updateAgencyDoc(
                              doc!.id,
                              name: nameCtrl.text,
                              phone: phoneCtrl.text,
                              managerName: managerNameCtrl.text,
                              managerPhone: managerPhoneCtrl.text,
                              status: status.value,
                            );
                          } else {
                            await createAgencyAccount(
                              name: nameCtrl.text,
                              email: emailCtrl.text,
                              phone: phoneCtrl.text,
                              managerName: managerNameCtrl.text,
                              managerPhone: managerPhoneCtrl.text,
                              password: pwdCtrl.text,
                              status: status.value,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit ? 'Agence mise à jour' : 'Agence créée',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        } finally {
                          loading.value = false;
                        }
                      },
                      icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded, size: 18),
                      label: Text(isEdit ? 'Enregistrer' : 'Créer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// ============================== UI HELPERS ==============================

class _GlassDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _GlassDialog({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: kCardShadow, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: kAccentBlue.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccentBlue.withOpacity(.2)),
                  ),
                  child: const Icon(Icons.business_rounded, color: kAccentBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                    if (subtitle != null)
                      Text(subtitle!, style: const TextStyle(color: kTextLight, fontSize: 13)),
                  ]),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: kTextLight),
                  tooltip: 'Fermer',
                )
              ]),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _TF extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final bool enabled;

  const _TF({
    required this.controller,
    required this.label,
    this.keyboard,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? kSoftGray : kSoftGray.withOpacity(.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final ValueNotifier<T> valueListenable;
  final List<DropdownMenuItem<T>> items;
  const _Dropdown({required this.label, required this.valueListenable, required this.items});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: (_, value, __) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: kSoftGray,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              onChanged: (v) => valueListenable.value = v as T,
              items: items,
            ),
          ),
        );
      },
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoStrip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSoftGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: kAccentBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
