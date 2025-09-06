import 'package:bus_easy/screen/admin/gestion_user/user_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../home/reponsive_data.dart';
import '../home/theme.dart';

class UsersView extends StatelessWidget {
  final String search;
  const UsersView({super.key, this.search = ''});

  @override
  Widget build(BuildContext context) {
    final query = search.trim().toLowerCase();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Erreur de chargement: ${snap.error}',
                style: const TextStyle(color: kErrorRed)),
          );
        }

        final docs = snap.data?.docs ?? [];
        final rows = <List<String>>[];
        final mapDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        for (final d in docs) {
          final m = d.data();
          final name = (m['name'] ?? '').toString();
          final email = (m['email'] ?? '').toString();
          final role = (m['role'] ?? 'user').toString();
          final status = (m['status'] ?? 'actif').toString();
          final row = [name, email, role, status];

          if (query.isEmpty || row.any((c) => c.toLowerCase().contains(query))) {
            rows.add(row);
            mapDocs.add(d);
          }
        }

        return AdminResponsiveData(
          title: 'Gestion des Utilisateurs',
          subtitle: 'Création de comptes (Client / Admin / Agence)',
          icon: Icons.people_rounded,
          color: kAccentBlue,
          headers: const ['Nom', 'Email', 'Rôle', 'Statut', 'Actions'],
          rows: rows,
          onAdd: () => showCreateChoiceDialog(context),
          onRowAction: (action, index) async {
            final d = mapDocs[index];
            final role = (d['role'] ?? 'user').toString().toLowerCase();

            if (action == 'edit') {
              if (role == 'agence') {
                await showAgencyFormDialog(context, doc: d);
              } else {
                await showUserFormDialog(context, doc: d);
              }
            } else if (action == 'delete') {
              await showDeleteUserDialog(
                context,
                uid: d.id,
                displayName: (d['name'] ?? d.id).toString(),
              );
            }
          },
        );
      },
    );
  }
}