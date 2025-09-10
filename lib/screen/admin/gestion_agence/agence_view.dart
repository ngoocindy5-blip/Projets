import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../gestion_user/user_crud.dart';
import '../home/reponsive_data.dart';
import '../home/theme.dart';
import 'agence_crud.dart' hide showAgencyFormDialog;


class AgencyView extends StatelessWidget {
  final String search;
  const AgencyView({super.key, this.search = ''});

  @override
  Widget build(BuildContext context) {
    final qSearch = search.trim().toLowerCase();

    // On évite un index composite : on filtre seulement par role côté serveur,
    // et on trie + filtre côté client.
    final stream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'agence')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Erreur: ${snap.error}', style: const TextStyle(color: kErrorRed)));
        }

        final docs = snap.data?.docs ?? [];
        // tri client par nom
        docs.sort((a, b) =>
            ((a['name'] ?? '') as String).toLowerCase().compareTo(((b['name'] ?? '') as String).toLowerCase()));

        final rows = <List<String>>[];
        final list = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        for (final d in docs) {
          final m = d.data();
          final name = (m['name'] ?? '').toString();
          final code = (m['agencyCode'] ?? '—').toString();
          final manager = (m['managerName'] ?? '—').toString();
          final phone = (m['phone'] ?? '—').toString();
          final email = (m['email'] ?? '—').toString();
          final status = (m['status'] ?? 'actif').toString();

          final row = [name, code, manager, phone, email, status];

          final searchable = (row.join(' ')).toLowerCase();
          if (qSearch.isEmpty || searchable.contains(qSearch)) {
            rows.add(row);
            list.add(d);
          }
        }

        return AdminResponsiveData(
          title: 'Gestion des Agences',
          subtitle: 'Créer des comptes agence, modifier, suspendre ou désactiver',
          icon: Icons.business_rounded,
          color: kSuccessGreen,
          headers: const ['Nom', 'Code', 'Responsable', 'Téléphone', 'Email', 'Statut', 'Actions'],
          rows: rows,
          onAdd: () => showAgencyFormDialog(context),
          onRowAction: (action, index) async {
            final d = list[index];
            if (action == 'edit') {
              await showAgencyFormDialog(context, doc: d);
            } else if (action == 'delete') {
              // Par défaut : désactivation douce (recommandé)
              final choice = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Action sur l’agence'),
                  content: const Text(
                    'Souhaitez-vous désactiver l’agence (statut: inactif) ou supprimer le document Firestore ?\n'
                        '⚠️ La suppression ne retire pas le compte Auth (limitation côté client).',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, 'cancel'), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, 'disable'), child: const Text('Désactiver')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, 'delete'), child: const Text('Supprimer')),
                  ],
                ),
              );

              if (choice == 'disable') {
                await updateAgencyDoc(d.id, status: 'inactif');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agence désactivée')));
                }
              } else if (choice == 'delete') {
                try {
                  await deleteAgencyDoc(d.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document supprimé')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
