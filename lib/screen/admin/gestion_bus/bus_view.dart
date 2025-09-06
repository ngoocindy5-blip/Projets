import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/reponsive_data.dart';
import '../home/theme.dart';
import 'bus_crud.dart';

class BusView extends StatelessWidget {
  final String search;
  const BusView({super.key, this.search = ''});

  @override
  Widget build(BuildContext context) {
    final query = search.trim().toLowerCase();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('buses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Erreur: ${snap.error}', style: const TextStyle(color: kErrorRed)),
          );
        }

        final docs = snap.data?.docs ?? [];
        final rows = <List<String>>[];
        final listDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        for (final d in docs) {
          final m = d.data();
          final plate  = (m['plate'] ?? '').toString();
          final brand  = (m['brand'] ?? '').toString();
          final model  = (m['model'] ?? '').toString();
          final agency = (m['agencyName'] ?? '').toString();
          final status = (m['status'] ?? 'actif').toString();

          final displayModel = [brand, model].where((e) => e.trim().isNotEmpty).join(' ');
          final row = [
            plate,
            displayModel.isEmpty ? '—' : displayModel,
            agency.isEmpty ? '—' : agency,
            status,
          ];

          final searchable = (plate + ' ' + displayModel + ' ' + agency + ' ' + status).toLowerCase();
          if (query.isEmpty || searchable.contains(query)) {
            rows.add(row);
            listDocs.add(d);
          }
        }

        return AdminResponsiveData(
          title: 'Gestion des Bus',
          subtitle: 'Créer, attribuer à une agence, transférer, retirer ou supprimer',
          icon: Icons.directions_bus_rounded,
          color: kWarningOrange,
          headers: const ['Immatriculation', 'Modèle', 'Agence', 'Statut', 'Actions'],
          rows: rows,
          onAdd: () => showBusFormDialog(context),
          onRowAction: (action, index) async {
            final d = listDocs[index];
            if (action == 'edit') {
              await showBusFormDialog(context, doc: d);
            } else if (action == 'delete') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer le bus'),
                  content: Text('Confirmer la suppression de "${d['plate'] ?? d.id}" ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await deleteBus(d.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bus supprimé')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              }
            }
          },
        );
      },
    );
  }
}
