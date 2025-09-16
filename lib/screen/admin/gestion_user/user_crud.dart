import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/theme.dart';

final _usersCol = FirebaseFirestore.instance.collection('users');

FirebaseApp? _secondaryApp;
FirebaseAuth? _secondaryAuth;

/// auth secondaire pour créer d'autres comptes sans déconnecter l'admin
Future<FirebaseAuth> _getSecondaryAuth() async {
  if (_secondaryAuth != null) return _secondaryAuth!;
  final defaultApp = Firebase.app();
  _secondaryApp = await Firebase.initializeApp(
    name: 'adminSecondary',
    options: defaultApp.options,
  );
  _secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp!);
  return _secondaryAuth!;
}

/// --- Utils ---
String _randPassword([int len = 12]) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#%*?';
  final r = Random.secure();
  return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
}

String _randAgencyCode() {
  // AG-ABCDE-123 (lisible)
  const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  final r = Random.secure();
  String five() => List.generate(5, (_) => letters[r.nextInt(letters.length)]).join();
  String three() => (100 + r.nextInt(900)).toString();
  return 'AG-${five()}-${three()}';
}

Future<String> _uniqueAgencyCode() async {
  for (int i = 0; i < 10; i++) {
    final code = _randAgencyCode();
    final q = await _usersCol.where('agencyCode', isEqualTo: code).limit(1).get();
    if (q.docs.isEmpty) return code;
  }
  return 'AG-${DateTime.now().millisecondsSinceEpoch}';
}

/// --- auth + Firestore ---

Future<String> createAuthAccount({
  required String email,
  required String tempPassword,
  bool sendVerify = true,
  bool sendResetEmail = false,
}) async {
  final auth = await _getSecondaryAuth();

  final cred = await auth.createUserWithEmailAndPassword(
    email: email.trim(),
    password: tempPassword,
  );

  if (sendVerify) {
    try { await cred.user?.sendEmailVerification(); } catch (_) {}
  }
  if (sendResetEmail) {
    try { await auth.sendPasswordResetEmail(email: email.trim()); } catch (_) {}
  }

  await auth.signOut();
  return cred.user!.uid;
}

Future<void> createUserSimple({
  required String name,
  required String email,
  required String phone,
  required String role, // 'user' | 'admin'
  required String tempPassword,
  bool sendVerify = true,
  bool sendResetEmail = false,
}) async {
  final uid = await createAuthAccount(
    email: email,
    tempPassword: tempPassword,
    sendVerify: sendVerify,
    sendResetEmail: sendResetEmail,
  );
  await _usersCol.doc(uid).set({
    'uid': uid,
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
  required String name, // nom de l’agence
  required String email,
  required String phone,
  required String managerName,
  required String managerPhone,
  required String tempPassword,
  bool sendVerify = true,
  bool sendResetEmail = false,
}) async {
  final uid = await createAuthAccount(
    email: email,
    tempPassword: tempPassword,
    sendVerify: sendVerify,
    sendResetEmail: sendResetEmail,
  );
  final code = await _uniqueAgencyCode();

  await _usersCol.doc(uid).set({
    'uid': uid,
    'name': name.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'role': 'agence',
    'managerName': managerName.trim(),
    'managerPhone': managerPhone.trim(),
    'agencyCode': code,
    'status': 'actif',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
  data['updatedAt'] = FieldValue.serverTimestamp();
  await _usersCol.doc(uid).set(data, SetOptions(merge: true));
}

Future<void> disableUser(String uid) async {
  await _usersCol.doc(uid).set({
    'status': 'desactive',
    'disabledAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

/// ===================== Dialogs stylés (thème moderne) =====================

Future<void> showCreateChoiceDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: 'Créer',
      subtitle: 'Que souhaitez-vous créer ?',
      child: Row(
        children: [
          Expanded(
            child: _PrimaryButton(
              text: 'Utilisateur',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: () {
                Navigator.pop(context);
                showUserFormDialog(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PrimaryButton(
              text: 'Agence',
              color: kSuccessGreen,
              icon: Icons.business_rounded,
              onPressed: () {
                Navigator.pop(context);
                showAgencyFormDialog(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

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
  final role = ValueNotifier<String>((data?['role'] ?? 'client').toString());
  final pwd  = TextEditingController(text: _randPassword());

  final sendVerify     = ValueNotifier<bool>(true);
  final sendResetEmail = ValueNotifier<bool>(false);

  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: isEdit ? 'Modifier l’utilisateur' : 'Nouvel utilisateur',
      subtitle: isEdit
          ? 'Mettez à jour les informations du compte'
          : 'Créer un compte auth + Firestore',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _TF(controller: name, label: 'Nom', validator: _vReq),
            const SizedBox(height: 10),
            _TF(
              controller: email,
              label: 'Email',
              keyboard: TextInputType.emailAddress,
              validator: _vEmail,
              readOnly: isEdit,
              helper: isEdit ? 'Pour changer l’email auth, passez par l’utilisateur.' : null,
            ),
            const SizedBox(height: 10),
            _TF(controller: phone, label: 'Téléphone', keyboard: TextInputType.phone, validator: _vReq),
            const SizedBox(height: 10),

            _Dropdown<String>(
              label: 'Rôle',
              valueListenable: role,
              items: const [
                DropdownMenuItem(value: 'client',  child: Text('Client')),
                DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              ],
            ),
            const SizedBox(height: 10),

            if (!isEdit) ...[
              _PasswordLine(controller: pwd),
              const SizedBox(height: 10),
              _SwitchLine(v: sendVerify, label: 'Envoyer email de vérification'),
              _SwitchLine(v: sendResetEmail, label: 'Envoyer lien de réinitialisation'),
              const SizedBox(height: 6),
              const Text(
                'Un mot de passe temporaire sera utilisé pour créer le compte. '
                    'Vous pouvez aussi envoyer un email de réinitialisation.',
                style: TextStyle(color: kTextLight, fontSize: 12),
              ),
            ],

            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                const Spacer(),
                _PrimaryButton(
                  text: isEdit ? 'Enregistrer' : 'Créer',
                  icon: isEdit ? Icons.save_rounded : Icons.check_circle_rounded,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      if (isEdit) {
                        await updateUserDoc(doc!.id, {
                          'name': name.text.trim(),
                          'phone': phone.text.trim(),
                          'role': role.value,
                        });
                      } else {
                        await createUserSimple(
                          name: name.text.trim(),
                          email: email.text.trim(),
                          phone: phone.text.trim(),
                          role: role.value,
                          tempPassword: pwd.text,
                          sendVerify: sendVerify.value,
                          sendResetEmail: sendResetEmail.value,
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showAgencyFormDialog(
    BuildContext context, {
      DocumentSnapshot<Map<String, dynamic>>? doc,
    }) async {
  final isEdit = doc != null;
  final data = doc?.data();

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: data?['name'] ?? '');
  final email = TextEditingController(text: data?['email'] ?? '');
  final phone = TextEditingController(text: data?['phone'] ?? '');
  final managerName  = TextEditingController(text: data?['managerName'] ?? '');
  final managerPhone = TextEditingController(text: data?['managerPhone'] ?? '');
  final agencyCode   = ValueNotifier<String>(data?['agencyCode'] ?? '');
  final pwd          = TextEditingController(text: _randPassword());

  final sendVerify     = ValueNotifier<bool>(true);
  final sendResetEmail = ValueNotifier<bool>(false);

  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: isEdit ? 'Modifier l’agence' : 'Nouvelle agence',
      subtitle: isEdit
          ? 'Mettez à jour les informations de l’agence'
          : 'Créer un compte agence (auth + Firestore)',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _TF(controller: name, label: 'Nom de l’agence', validator: _vReq),
            const SizedBox(height: 10),
            _TF(controller: email, label: 'Email', keyboard: TextInputType.emailAddress, validator: _vEmail, readOnly: isEdit),
            const SizedBox(height: 10),
            _TF(controller: phone, label: 'Téléphone', keyboard: TextInputType.phone, validator: _vReq),
            const SizedBox(height: 10),
            _TF(controller: managerName, label: 'Nom du responsable', validator: _vReq),
            const SizedBox(height: 10),
            _TF(controller: managerPhone, label: 'Téléphone du responsable', keyboard: TextInputType.phone, validator: _vReq),
            const SizedBox(height: 10),

            _ReadonlyWithAction(
              label: 'Code agence',
              valueListenable: agencyCode,
              actionIcon: Icons.refresh_rounded,
              onAction: () async => agencyCode.value = await _uniqueAgencyCode(),
              hint: 'Code unique attribué à l’agence',
            ),
            const SizedBox(height: 10),

            if (!isEdit) ...[
              _PasswordLine(controller: pwd),
              const SizedBox(height: 10),
              _SwitchLine(v: sendVerify, label: 'Envoyer email de vérification'),
              _SwitchLine(v: sendResetEmail, label: 'Envoyer lien de réinitialisation'),
            ],

            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                const Spacer(),
                _PrimaryButton(
                  text: isEdit ? 'Enregistrer' : 'Créer',
                  icon: isEdit ? Icons.save_rounded : Icons.check_circle_rounded,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      if (isEdit) {
                        await updateUserDoc(doc!.id, {
                          'name': name.text.trim(),
                          'phone': phone.text.trim(),
                          'managerName': managerName.text.trim(),
                          'managerPhone': managerPhone.text.trim(),
                          'role': 'agence',
                          'agencyCode': agencyCode.value.isEmpty
                              ? await _uniqueAgencyCode()
                              : agencyCode.value,
                        });
                      } else {
                        await createUserAgency(
                          name: name.text.trim(),
                          email: email.text.trim(),
                          phone: phone.text.trim(),
                          managerName: managerName.text.trim(),
                          managerPhone: managerPhone.text.trim(),
                          tempPassword: pwd.text,
                          sendVerify: sendVerify.value,
                          sendResetEmail: sendResetEmail.value,
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showDeleteUserDialog(
    BuildContext context, {
      required String uid,
      required String displayName,
    }) async {
  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: 'Supprimer / désactiver',
      subtitle: 'Choisissez l’action pour "$displayName"',
      child: Column(
        children: [
          _PrimaryButton(
            text: 'Désactiver le compte (recommandé)',
            color: kWarningOrange,
            icon: Icons.block_rounded,
            onPressed: () async {
              try {
                await disableUser(uid);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compte désactivé')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            text: 'Supprimer uniquement du Firestore',
            color: kErrorRed,
            icon: Icons.delete_forever_rounded,
            onPressed: () async {
              try {
                await _usersCol.doc(uid).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document supprimé (auth NON supprimé)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: côté client, on ne peut pas supprimer un autre compte auth.\n'
                'La désactivation via Firestore est la meilleure approche.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextLight, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

/// ====================== UI helpers (thème) ======================

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
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 24, offset: const Offset(0, 8))],
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
                  child: const Icon(Icons.admin_panel_settings_rounded, color: kAccentBlue),
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

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color = kAccentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TF extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final String? helper;
  final bool readOnly;

  const _TF({
    required this.controller,
    required this.label,
    this.keyboard,
    this.validator,
    this.helper,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        filled: true,
        fillColor: kSoftGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _PasswordLine extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordLine({required this.controller});

  @override
  State<_PasswordLine> createState() => _PasswordLineState();
}

class _PasswordLineState extends State<_PasswordLine> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: (v) => (v == null || v.trim().length < 6) ? 'Au moins 6 caractères' : null,
      decoration: InputDecoration(
        labelText: 'Mot de passe temporaire',
        filled: true,
        fillColor: kSoftGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Générer',
              onPressed: () => setState(() => widget.controller.text = _randPassword()),
              icon: const Icon(Icons.auto_awesome_rounded, color: kTextLight),
            ),
            IconButton(
              tooltip: _obscure ? 'Afficher' : 'Masquer',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: kTextLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final ValueListenable<T> valueListenable;
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
              onChanged: (v) {
                if (valueListenable is ValueNotifier<T>) {
                  (valueListenable as ValueNotifier<T>).value = v as T;
                }
              },
              items: items,
            ),
          ),
        );
      },
    );
  }
}

class _SwitchLine extends StatelessWidget {
  final ValueNotifier<bool> v;
  final String label;
  const _SwitchLine({required this.v, required this.label});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: v,
      builder: (_, value, __) {
        return Row(
          children: [
            Switch(value: value, onChanged: (nv) => v.value = nv),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: kTextDark))),
          ],
        );
      },
    );
  }
}

class _ReadonlyWithAction extends StatelessWidget {
  final String label;
  final ValueListenable<String> valueListenable;
  final IconData actionIcon;
  final VoidCallback onAction;
  final String? hint;

  const _ReadonlyWithAction({
    required this.label,
    required this.valueListenable,
    required this.actionIcon,
    required this.onAction,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: valueListenable,
      builder: (_, value, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: kSoftGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(value.isEmpty ? '— généré automatiquement —' : value)),
                  IconButton(onPressed: onAction, icon: Icon(actionIcon, color: kTextLight)),
                ],
              ),
            ),
            if (hint != null) const SizedBox(height: 6),
            if (hint != null)
              Text(hint!, style: const TextStyle(color: kTextLight, fontSize: 12)),
          ],
        );
      },
    );
  }
}

/// Validators
String? _vReq(String? v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null;
String? _vEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email requis';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Email invalide';
}
