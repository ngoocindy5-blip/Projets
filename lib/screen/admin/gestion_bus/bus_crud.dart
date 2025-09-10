import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/theme.dart';


final _busesCol = FirebaseFirestore.instance.collection('buses');
final _usersCol = FirebaseFirestore.instance.collection('users');

/// =========================== HELPERS ===========================

String _normalizePlate(String plate) {
  final up = plate.toUpperCase();
  return up.replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

Future<bool> _plateExists(String normalizedPlate, {String? excludeBusId}) async {
  final snap = await _busesCol.where('normalizedPlate', isEqualTo: normalizedPlate).limit(1).get();
  if (snap.docs.isEmpty) return false;
  if (excludeBusId == null) return true;
  return snap.docs.first.id != excludeBusId;
}

class AgencyRef {
  final String id;
  final String name;
  AgencyRef(this.id, this.name);
  @override
  String toString() => name;
}

List<AgencyRef> _dedupAgencies(List<AgencyRef> list) {
  final seen = <String>{};
  final out = <AgencyRef>[];
  for (final a in list) {
    if (a.id.isEmpty) continue;
    if (seen.add(a.id)) out.add(a);
  }
  out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return out;
}


/// Agences actives (fallback si index composite manquant)
Future<List<AgencyRef>> fetchAgencies() async {
  try {
    final q = await _usersCol
        .where('role', isEqualTo: 'agence')
        .where('status', isEqualTo: 'actif')
        .orderBy('name')
        .get();

    final raw = q.docs
        .map((d) => AgencyRef(d.id, (d.data()['name'] ?? 'Agence').toString()))
        .toList();
    return _dedupAgencies(raw);
  } on FirebaseException catch (e) {
    final needsIndex = e.code == 'failed-precondition' ||
        (e.message?.toLowerCase().contains('index') ?? false);

    if (needsIndex) {
      final q = await _usersCol.where('role', isEqualTo: 'agence').get();
      final raw = q.docs
          .where((d) => (d.data()['status'] ?? 'actif').toString().toLowerCase() == 'actif')
          .map((d) => AgencyRef(d.id, (d.data()['name'] ?? 'Agence').toString()))
          .toList();
      return _dedupAgencies(raw);
    }
    rethrow;
  }
}


/// =========================== FIRESTORE CRUD =============================

Future<String> createBus({
  required String plate,
  String? brand,
  String? model,
  int? capacity,
  String status = 'actif', // actif | panne | maintenance | inactif
  String? agencyId,
  String? agencyName, // denormalisé
  int? mileageKm,
  Timestamp? lastMaintenanceAt,
  Timestamp? nextMaintenanceAt,
  String? notes,
}) async {
  final normalized = _normalizePlate(plate);
  if (await _plateExists(normalized)) {
    throw 'Cette immatriculation existe déjà.';
  }
  final ref = _busesCol.doc();
  await ref.set({
    'id': ref.id,
    'plate': plate.trim().toUpperCase(),
    'normalizedPlate': normalized,
    'brand': (brand ?? '').trim(),
    'model': (model ?? '').trim(),
    'capacity': capacity,
    'status': status,
    'agencyId': agencyId,
    'agencyName': agencyName,
    'assignedAt': agencyId != null ? FieldValue.serverTimestamp() : null,
    'mileageKm': mileageKm,
    'lastMaintenanceAt': lastMaintenanceAt,
    'nextMaintenanceAt': nextMaintenanceAt,
    'notes': (notes ?? '').trim(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  return ref.id;
}

Future<void> updateBus(
    String busId, {
      String? plate,
      String? brand,
      String? model,
      int? capacity,
      String? status,
      String? agencyId,   // '' => retirer
      String? agencyName,
      int? mileageKm,
      Timestamp? lastMaintenanceAt,
      Timestamp? nextMaintenanceAt,
      String? notes,
    }) async {
  final data = <String, dynamic>{
    'updatedAt': FieldValue.serverTimestamp(),
  };

  if (plate != null) {
    final normalized = _normalizePlate(plate);
    if (await _plateExists(normalized, excludeBusId: busId)) {
      throw 'Cette immatriculation existe déjà.';
    }
    data['plate'] = plate.trim().toUpperCase();
    data['normalizedPlate'] = normalized;
  }

  if (brand != null) data['brand'] = brand.trim();
  if (model != null) data['model'] = model.trim();
  if (capacity != null) data['capacity'] = capacity;
  if (status != null) data['status'] = status;
  if (mileageKm != null) data['mileageKm'] = mileageKm;
  if (lastMaintenanceAt != null) data['lastMaintenanceAt'] = lastMaintenanceAt;
  if (nextMaintenanceAt != null) data['nextMaintenanceAt'] = nextMaintenanceAt;
  if (notes != null) data['notes'] = notes.trim();

  if (agencyId != null) {
    data['agencyId']   = agencyId.isEmpty ? null : agencyId;
    data['agencyName'] = agencyId.isEmpty ? null : agencyName;
    data['assignedAt'] = agencyId.isEmpty ? null : FieldValue.serverTimestamp();
  }

  await _busesCol.doc(busId).set(data, SetOptions(merge: true));
}

Future<void> unassignBus(String busId) async {
  await _busesCol.doc(busId).set({
    'agencyId': null,
    'agencyName': null,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> deleteBus(String busId) async {
  await _busesCol.doc(busId).delete();
}

/// =========================== DIALOGS UI ===========================

Future<void> showBusFormDialog(
    BuildContext context, {
      DocumentSnapshot<Map<String, dynamic>>? doc,
    }) async {
  final isEdit = doc != null;
  final m = doc?.data() ?? {};

  final formKey = GlobalKey<FormState>();

  final plate = TextEditingController(text: (m['plate'] ?? '').toString());
  final brand = TextEditingController(text: (m['brand'] ?? '').toString());
  final model = TextEditingController(text: (m['model'] ?? '').toString());
  final capacityCtrl = TextEditingController(
      text: m['capacity'] == null ? '' : (m['capacity']).toString());
  final mileageCtrl = TextEditingController(
      text: m['mileageKm'] == null ? '' : (m['mileageKm']).toString());
  final notes = TextEditingController(text: (m['notes'] ?? '').toString());

  final status = ValueNotifier<String>((m['status'] ?? 'actif').toString());
  final agencyId = ValueNotifier<String?>(
      m['agencyId'] != null ? (m['agencyId']).toString() : null);
  final agencies = ValueNotifier<List<AgencyRef>>([]);

  Timestamp? lastMaintenanceAt = m['lastMaintenanceAt'] as Timestamp?;
  Timestamp? nextMaintenanceAt = m['nextMaintenanceAt'] as Timestamp?;

  // Charger agences (avec fallback + snackbar en cas d’erreur)
  fetchAgencies().then((list) {
    agencies.value = _dedupAgencies(list);
  }).catchError((e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement agences: $e')),
      );
    }
    agencies.value = const [];
  });

  await showDialog(
    context: context,
    builder: (_) => _GlassDialog(
      title: isEdit ? 'Modifier un bus' : 'Nouveau bus',
      subtitle: isEdit
          ? 'Mettez à jour les informations du véhicule'
          : 'Enregistrer un bus et (optionnel) l’attribuer à une agence',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // Ligne 1 : Plaque + Statut
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _TF(
                    controller: plate,
                    label: 'Immatriculation *',
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Dropdown<String>(
                    label: 'Statut',
                    valueListenable: status,
                    items: const [
                      DropdownMenuItem(value: 'actif', child: Text('Actif')),
                      DropdownMenuItem(value: 'panne', child: Text('En panne')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                      DropdownMenuItem(value: 'inactif', child: Text('Inactif')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ligne 2 : Marque / Modèle
            Row(
              children: [
                Expanded(child: _TF(controller: brand, label: 'Marque')),
                const SizedBox(width: 12),
                Expanded(child: _TF(controller: model, label: 'Modèle')),
              ],
            ),
            const SizedBox(height: 10),

            // Ligne 3 : Capacité / Kilométrage
            Row(
              children: [
                Expanded(
                  child: _TF(
                    controller: capacityCtrl,
                    label: 'Capacité (sièges)',
                    keyboard: TextInputType.number,
                    validator: _vIntOptional,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TF(
                    controller: mileageCtrl,
                    label: 'Kilométrage (km)',
                    keyboard: TextInputType.number,
                    validator: _vIntOptional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ligne 4 : Agence (+ Recharger + Retirer si edit)
            ValueListenableBuilder<List<AgencyRef>>(
              valueListenable: agencies,
              builder: (_, listRaw, __) {
                final list = _dedupAgencies(listRaw); // anti-doublons
                final bool exists = agencyId.value != null &&
                    list.any((a) => a.id == agencyId.value);
                final String? currentValue = exists ? agencyId.value : null;

                // Si la valeur ne correspond plus à un item, reset à null après le frame
                if (!exists && agencyId.value != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    agencyId.value = null;
                  });
                }

                final has = list.isNotEmpty;

                return Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Agence (optionnel)',
                          filled: true,
                          fillColor: kSoftGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: currentValue, // sécurisé
                            isExpanded: true,
                            hint: Text(has ? 'Sélectionner une agence' : 'Aucune agence disponible'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('— Aucune —'),
                              ),
                              ...list.map((a) => DropdownMenuItem<String?>(
                                value: a.id,
                                child: Text(a.name),
                              )),
                            ],
                            onChanged: has ? (v) => agencyId.value = v : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Recharger
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final l = await fetchAgencies();
                            agencies.value = _dedupAgencies(l);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Agences rechargées')),
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
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Recharger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isEdit && (currentValue != null))
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await unassignBus(doc!.id);
                              agencyId.value = null;
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bus retiré de l’agence')),
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
                          icon: const Icon(Icons.link_off_rounded, size: 18),
                          label: const Text('Retirer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kWarningOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Ligne 5 : Entretiens
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Dernier entretien',
                    initial: lastMaintenanceAt?.toDate(),
                    onPicked: (d) => lastMaintenanceAt =
                    d == null ? null : Timestamp.fromDate(d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'Prochain entretien',
                    initial: nextMaintenanceAt?.toDate(),
                    onPicked: (d) => nextMaintenanceAt =
                    d == null ? null : Timestamp.fromDate(d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _TF(controller: notes, label: 'Notes'),

            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      final cap = capacityCtrl.text.trim().isEmpty
                          ? null
                          : int.parse(capacityCtrl.text.trim());
                      final km = mileageCtrl.text.trim().isEmpty
                          ? null
                          : int.parse(mileageCtrl.text.trim());

                      // agencyName fiable depuis la liste dédupliquée
                      String? aName;
                      final list = _dedupAgencies(agencies.value);
                      if (agencyId.value != null) {
                        final a = list.firstWhere(
                              (e) => e.id == agencyId.value,
                          orElse: () => AgencyRef(agencyId.value!, ''),
                        );
                        aName = a.name;
                      }

                      if (isEdit) {
                        await updateBus(
                          doc!.id,
                          plate: plate.text,
                          brand: brand.text,
                          model: model.text,
                          capacity: cap,
                          status: status.value,
                          agencyId: agencyId.value ?? '',
                          agencyName: aName,
                          mileageKm: km,
                          lastMaintenanceAt: lastMaintenanceAt,
                          nextMaintenanceAt: nextMaintenanceAt,
                          notes: notes.text,
                        );
                      } else {
                        await createBus(
                          plate: plate.text,
                          brand: brand.text,
                          model: model.text,
                          capacity: cap,
                          status: status.value,
                          agencyId: agencyId.value,
                          agencyName: aName,
                          mileageKm: km,
                          lastMaintenanceAt: lastMaintenanceAt,
                          nextMaintenanceAt: nextMaintenanceAt,
                          notes: notes.text,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text(isEdit ? 'Bus mis à jour' : 'Bus créé'),
                          ),
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
                  icon: Icon(
                      isEdit ? Icons.save_rounded : Icons.add_rounded, size: 18),
                  label: Text(isEdit ? 'Enregistrer' : 'Créer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
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
            boxShadow: const [BoxShadow(color: kCardShadow, blurRadius: 24, offset: Offset(0, 8))],
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
                  child: const Icon(Icons.directions_bus_rounded, color: kAccentBlue),
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

  const _TF({required this.controller, required this.label, this.keyboard, this.validator});

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

String? _vIntOptional(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  return int.tryParse(v.trim()) == null ? 'Nombre invalide' : null;
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

class _DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initial;
  final void Function(DateTime?) onPicked;
  const _DatePickerField({required this.label, this.initial, required this.onPicked});

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  DateTime? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
          initialDate: _value ?? now,
        );
        if (d != null) {
          setState(() => _value = d);
          widget.onPicked(d);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: kSoftGray,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        child: Text(
          _value == null ? '—' : '${_value!.day.toString().padLeft(2, '0')}/${_value!.month.toString().padLeft(2, '0')}/${_value!.year}',
          style: const TextStyle(color: kTextDark),
        ),
      ),
    );
  }
}
