import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/theme.dart';


final _usersCol = FirebaseFirestore.instance.collection('users');

/// ===== Helpers Firestore =====
Future<void> createUserSimple({
  required String name,
  required String email,
  required String phone,
  String role = 'user',
}) async {
  final ref = _usersCol.doc(); // uid généré
  await ref.set({
    'uid': ref.id,
    'name': name.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'role': role.trim().toLowerCase(),
    'status': 'actif',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> createUserAgency({
  required String name,           // nom de l’agence
  required String email,
  required String phone,
  required String managerName,    // responsable
  required String managerPhone,
}) async {
  final ref = _usersCol.doc();
  await ref.set({
    'uid': ref.id,
    'name': name.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'role': 'agence',
    'managerName': managerName.trim(),
    'managerPhone': managerPhone.trim(),
    'status': 'actif',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
  data['updatedAt'] = FieldValue.serverTimestamp();
  await _usersCol.doc(uid).set(data, SetOptions(merge: true));
}

Future<void> deleteUserDoc(String uid) async {
  await _usersCol.doc(uid).delete();
}

/// ===== Dialogs =====

Future<void> showCreateChoiceDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Créer'),
      content: const Text('Que souhaitez-vous créer ?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showUserFormDialog(context);
          },
          child: const Text('Utilisateur'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showAgencyFormDialog(context);
          },
          child: const Text('Agence'),
        ),
      ],
    ),
  );
}

/// Formulaire Utilisateur simple (create / edit)
Future<void> showUserFormDialog(
    BuildContext context, {
      DocumentSnapshot<Map<String, dynamic>>? doc,
    }) async {
  final isEdit = doc != null;
  final data = doc?.data();

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: data?['name'] ?? '');
  final email = TextEditingController(text: data?['email'] ?? '');
  final phone = TextEditingController(text: data?['phone'] ?? '');
  final role = TextEditingController(text: (data?['role'] ?? 'user').toString());

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Modifier l’utilisateur' : 'Nouvel utilisateur',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _TF(controller: name, label: 'Nom', validator: _req),
                const SizedBox(height: 10),
                _TF(controller: email, label: 'Email', keyboard: TextInputType.emailAddress, validator: _email),
                const SizedBox(height: 10),
                _TF(controller: phone, label: 'Téléphone', keyboard: TextInputType.phone, validator: _req),
                const SizedBox(height: 10),
                _TF(controller: role, label: 'Rôle (user/admin)', validator: _req),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          if (isEdit) {
                            await updateUserDoc(doc!.id, {
                              'name': name.text,
                              'email': email.text,
                              'phone': phone.text,
                              'role': role.text.toLowerCase().trim(),
                            });
                          } else {
                            await createUserSimple(
                              name: name.text,
                              email: email.text,
                              phone: phone.text,
                              role: role.text.toLowerCase().trim(),
                            );
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEdit ? 'Utilisateur mis à jour' : 'Utilisateur créé')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                      child: Text(isEdit ? 'Enregistrer' : 'Créer'),
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

/// Formulaire Agence (create / edit — si edit, role doit déjà être "agence")
Future<void> showAgencyFormDialog(
    BuildContext context, {
      DocumentSnapshot<Map<String, dynamic>>? doc,
    }) async {
  final isEdit = doc != null;
  final data = doc?.data();

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: data?['name'] ?? ''); // nom d’agence
  final email = TextEditingController(text: data?['email'] ?? '');
  final phone = TextEditingController(text: data?['phone'] ?? '');
  final managerName = TextEditingController(text: data?['managerName'] ?? '');
  final managerPhone = TextEditingController(text: data?['managerPhone'] ?? '');

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEdit ? 'Modifier l’agence' : 'Nouvelle agence',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 16),
                _TF(controller: name, label: 'Nom de l’agence', validator: _req),
                const SizedBox(height: 10),
                _TF(controller: email, label: 'Email', keyboard: TextInputType.emailAddress, validator: _email),
                const SizedBox(height: 10),
                _TF(controller: phone, label: 'Téléphone', keyboard: TextInputType.phone, validator: _req),
                const SizedBox(height: 10),
                _TF(controller: managerName, label: 'Nom du responsable', validator: _req),
                const SizedBox(height: 10),
                _TF(controller: managerPhone, label: 'Téléphone du responsable', keyboard: TextInputType.phone, validator: _req),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          if (isEdit) {
                            await updateUserDoc(doc!.id, {
                              'name': name.text,
                              'email': email.text,
                              'phone': phone.text,
                              'role': 'agence',
                              'managerName': managerName.text,
                              'managerPhone': managerPhone.text,
                            });
                          } else {
                            await createUserAgency(
                              name: name.text,
                              email: email.text,
                              phone: phone.text,
                              managerName: managerName.text,
                              managerPhone: managerPhone.text,
                            );
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEdit ? 'Agence mise à jour' : 'Agence créée')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                      child: Text(isEdit ? 'Enregistrer' : 'Créer'),
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

/// Champ texte standardisé
class _TF extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const _TF({
    required this.controller,
    required this.label,
    this.keyboard,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: kSoftGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

/// Validations
String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null;
String? _email(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email requis';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Email invalide';
}
