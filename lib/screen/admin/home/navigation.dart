import 'package:flutter/material.dart';
import 'theme.dart';

class AdminSidebar extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  // Identité réelle
  final String? displayName;
  final String? email;

  const AdminSidebar({
    super.key,
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    this.displayName,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _SidebarList(
              items: items,
              icons: icons,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
              collapsed: collapsed,
            ),
          ),
          _profileCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 12, 10),
      child: Row(
        children: [
          Container(
            width: collapsed ? 40 : 48,
            height: collapsed ? 40 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentBlue, kAccentBlue.withOpacity(.8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kAccentBlue.withOpacity(.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.directions_bus_rounded, color: Colors.white),
          ),
          if (!collapsed) const SizedBox(width: 12),
          if (!collapsed)
            const Text('BusAdmin',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTextDark)),
          const Spacer(),
          IconButton(
            tooltip: collapsed ? 'Étendre' : 'Réduire',
            onPressed: onToggleCollapse,
            icon: Icon(collapsed
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    if (collapsed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSoftGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kAccentBlue,
              radius: 16,
              child: Text(
                _initials(displayName ?? 'Administrateur'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName ?? 'Administrateur',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                          fontSize: 13)),
                  Text(email ?? '',
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(color: kTextLight, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.more_horiz_rounded,
                color: kTextLight, size: 18),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'AD';
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (a + b).toUpperCase();
  }
}

class _SidebarList extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;

  const _SidebarList({
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final isSelected = i == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(i),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: collapsed ? 12 : 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                  isSelected ? kAccentBlue.withOpacity(.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: kAccentBlue.withOpacity(.2))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kAccentBlue.withOpacity(.15)
                            : kSoftGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icons[i],
                          color: isSelected ? kAccentBlue : kTextLight,
                          size: 20),
                    ),
                    if (!collapsed) const SizedBox(width: 12),
                    if (!collapsed)
                      Expanded(
                        child: Text(
                          items[i],
                          style: TextStyle(
                            color:
                            isSelected ? kAccentBlue : kTextLight,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isSelected && !collapsed)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: kAccentBlue, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Variante tablette
class AdminRail extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool extended;

  const AdminRail({
    super.key,
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      extended: extended,
      indicatorColor: kAccentBlue.withOpacity(.12),
      backgroundColor: kSurface,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kAccentBlue, kAccentBlue.withOpacity(.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_bus_rounded, color: Colors.white),
        ),
      ),
      destinations: [
        for (int i = 0; i < items.length; i++)
          NavigationRailDestination(
            icon: Icon(icons[i], color: kTextLight),
            selectedIcon: Icon(icons[i]),
            label: Text(items[i]),
          ),
      ],
    );
  }
}
