import 'package:flutter/material.dart';
import 'theme.dart';

/// Table responsive (desktop-first).
/// Desktop/tablet : header fixe + ListView (pas de scroll horizontal).
/// Mobile : cartes key-value + menu d’actions.
class AdminResponsiveData extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final List<String> headers;      // inclure "Actions" si besoin
  final List<List<String>> rows;   // chaque ligne SANS la colonne Actions
  final bool showAdd;

  const AdminResponsiveData({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.headers,
    required this.rows,
    this.showAdd = true,
  });

  bool get _hasActions =>
      headers.any((h) => h.trim().toLowerCase() == 'actions');

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < kBpMobile;
    final dataHeaders = _hasActions
        ? headers.where((h) => h.trim().toLowerCase() != 'actions').toList()
        : headers;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre / bouton
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(.2)),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextDark)),
                    Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 13)),
                  ],
                ),
              ),
              if (showAdd && _hasActions)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Contenu
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18)],
              ),
              child: isMobile
                  ? _CardList(headers: dataHeaders, rows: rows, hasActions: _hasActions)
                  : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    decoration: const BoxDecoration(
                      color: kSoftGray,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(
                      children: [
                        for (final h in dataHeaders)
                          Expanded(
                            child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, color: kTextDark)),
                          ),
                        if (_hasActions) const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Rows
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final r = _normalizeRow(rows[i], dataHeaders.length);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              for (final cell in r)
                                Expanded(
                                  child: Text(cell,
                                      style: const TextStyle(
                                          color: kTextDark,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                ),
                              if (_hasActions)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: kTextLight, size: 18),
                                  onSelected: (v) {},
                                  itemBuilder: (context) => [
                                    _pm('edit', 'Modifier', Icons.edit_rounded),
                                    _pm('delete', 'Supprimer', Icons.delete_rounded, color: kErrorRed),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _normalizeRow(List<String> row, int expected) {
    final n = List<String>.from(row);
    if (n.length > expected) n.removeRange(expected, n.length);
    while (n.length < expected) n.add('');
    return n;
  }

  PopupMenuItem<String> _pm(String v, String label, IconData icon, {Color? color}) {
    return PopupMenuItem(
      value: v,
      child: Row(children: [
        Icon(icon, size: 16, color: color ?? kTextLight),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color ?? kTextDark)),
      ]),
    );
  }
}

// --- Cartes Mobile ---
class _CardList extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final bool hasActions;

  const _CardList({required this.headers, required this.rows, required this.hasActions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final r = rows[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int k = 0; k < headers.length && k < r.length; k++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(headers[k],
                            style: const TextStyle(
                                color: kTextLight, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r[k],
                            style: const TextStyle(
                                color: kTextDark, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              if (hasActions)
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: kTextLight, size: 18),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 16, color: kTextLight),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded, size: 16, color: kErrorRed),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: kErrorRed)),
                        ]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
