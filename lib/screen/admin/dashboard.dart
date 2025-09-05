/*import 'package:flutter/material.dart';

// =================== Palette / Constantes ===================
const kPrimaryBlue = Color(0xFFF0F4FF);
const kAccentBlue  = Color(0xFF6B9FFF);
const kTextDark    = Color(0xFF2D3748);
const kTextLight   = Color(0xFF718096);
const kSurface     = Colors.white;
const kGradientStart = Color(0xFFF8FAFF);
const kGradientEnd   = Color(0xFFEDF2FF);
const kCardShadow    = Color(0x0F1A365D);

const kSuccessGreen = Color(0xFF10B981);
const kWarningOrange = Color(0xFFF59E0B);
const kErrorRed = Color(0xFFEF4444);
const kPurpleAccent = Color(0xFF8B5CF6);
const kSoftGray = Color(0xFFF8FAFC);

const double kBpMobile   = 720;
const double kBpDesktop  = 1100;
const double kSidebarW   = 280;
const double kSidebarWMin = 84;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  bool sidebarCollapsed = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<String> menuItems = [
    'Dashboard', 'Utilisateurs', 'Agences', 'Bus',
    'Transactions', 'Réservations', 'Signalements', 'Paramètres'
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_rounded, Icons.people_rounded, Icons.business_rounded,
    Icons.directions_bus_rounded, Icons.payment_rounded, Icons.book_online_rounded,
    Icons.report_problem_rounded, Icons.settings_rounded
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectTab(int i) {
    setState(() => selectedIndex = i);
    _fadeCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final isMobile  = w < kBpMobile;
      final isDesktop = w >= kBpDesktop;
      final isTablet  = !isMobile && !isDesktop;

      return Scaffold(
        key: scaffoldKey,
        backgroundColor: kPrimaryBlue,
        drawer: isMobile ? Drawer(child: _SidebarList(
          items: menuItems,
          icons: menuIcons,
          selectedIndex: selectedIndex,
          onSelect: (i) { Navigator.pop(context); _selectTab(i); },
          collapsed: false,
        )) : null,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGradientStart, kGradientEnd]),
            ),
            child: Row(
              children: [
                // --- Navigation à gauche ---
                if (isDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sidebarCollapsed ? kSidebarWMin : kSidebarW,
                    child: _Sidebar(
                      items: menuItems,
                      icons: menuIcons,
                      selectedIndex: selectedIndex,
                      onSelect: _selectTab,
                      collapsed: sidebarCollapsed,
                      onToggleCollapse: () => setState(() => sidebarCollapsed = !sidebarCollapsed),
                    ),
                  )
                else if (!isMobile)
                  _Rail(
                    items: menuItems,
                    icons: menuIcons,
                    selectedIndex: selectedIndex,
                    onSelect: _selectTab,
                    extended: w > 900,
                  ),

                // --- Contenu principal ---
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        _TopBar(
                          title: menuItems[selectedIndex],
                          isMobile: isMobile,
                          onMenuTap: isMobile ? () => scaffoldKey.currentState?.openDrawer() : null,
                          onSearch: (q) {}, // TODO: brancher à Firestore
                        ),
                        Expanded(child: _PageSwitcher(index: selectedIndex)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/* ============================================================
 * Top Bar
 * ============================================================ */
class _TopBar extends StatelessWidget {
  final String title;
  final bool isMobile;
  final VoidCallback? onMenuTap;
  final ValueChanged<String> onSearch;

  const _TopBar({
    required this.title,
    required this.isMobile,
    required this.onMenuTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 72 : 86,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 14),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(.92),
        boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuTap,
              tooltip: 'Menu',
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: kTextDark,
            ),
          ),
          const Spacer(),
          if (!isMobile)
            SizedBox(
              width: 360,
              child: _SearchField(onChanged: onSearch),
            ),
          const SizedBox(width: 12),
          _IconBadge(icon: Icons.notifications_rounded, count: '3', color: kWarningOrange),
          const SizedBox(width: 10),
          _IconBadge(icon: Icons.message_rounded, count: '12', color: kSuccessGreen),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: kAccentBlue,
            child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher…',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        isDense: true,
        filled: true,
        fillColor: kSoftGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon; final String count; final Color color;
  const _IconBadge({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 12)]),
          child: Icon(icon, color: kTextLight, size: 20),
        ),
        Positioned(
          right: -2, top: -2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 6)]),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

/* ============================================================
 * Navigation
 * ============================================================ */
class _Sidebar extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  const _Sidebar({
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 12, 10),
            child: Row(
              children: [
                Container(
                  width: collapsed ? 40 : 48, height: collapsed ? 40 : 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kAccentBlue, kAccentBlue.withOpacity(.8)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: kAccentBlue.withOpacity(.25), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 24),
                ),
                if (!collapsed) const SizedBox(width: 12),
                if (!collapsed) const Text('BusAdmin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextDark)),
                const Spacer(),
                IconButton(
                  tooltip: collapsed ? 'Étendre' : 'Réduire',
                  onPressed: onToggleCollapse,
                  icon: Icon(collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: _SidebarList(
              items: items, icons: icons, selectedIndex: selectedIndex, onSelect: onSelect, collapsed: collapsed,
            ),
          ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSoftGray, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: kAccentBlue, radius: 16, child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Administrateur', style: TextStyle(fontWeight: FontWeight.w600, color: kTextDark, fontSize: 13)),
                      Text('admin@busapp.com', style: TextStyle(color: kTextLight, fontSize: 11)),
                    ])),
                    const Icon(Icons.more_horiz_rounded, color: kTextLight, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
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
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kAccentBlue.withOpacity(.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: kAccentBlue.withOpacity(.2)) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? kAccentBlue.withOpacity(.15) : kSoftGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icons[i], color: isSelected ? kAccentBlue : kTextLight, size: 20),
                    ),
                    if (!collapsed) const SizedBox(width: 12),
                    if (!collapsed)
                      Expanded(child: Text(items[i], style: TextStyle(color: isSelected ? kAccentBlue : kTextLight, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500))),
                    if (isSelected && !collapsed) Container(width: 6, height: 6, decoration: const BoxDecoration(color: kAccentBlue, shape: BoxShape.circle)),
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

class _Rail extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool extended;
  const _Rail({required this.items, required this.icons, required this.selectedIndex, required this.onSelect, required this.extended});

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
          width: 44, height: 44,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [kAccentBlue, kAccentBlue.withOpacity(.8)]), borderRadius: BorderRadius.circular(12)),
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

/* ============================================================
 * Page switcher (contenu)
 * ============================================================ */
class _PageSwitcher extends StatelessWidget {
  final int index;
  const _PageSwitcher({required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0: return _DashboardView();
      case 1: return _UsersView();
      case 2: return _AgenciesView();
      case 3: return _BusesView();
      case 4: return _TransactionsView();
      case 5: return _ReservationsView();
      case 6: return _ReportsView();
      case 7: return _SettingsView();
      default: return _DashboardView();
    }
  }
}

/* ============================================================
 * Dashboard
 * ============================================================ */
class _DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < kBpMobile;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          // Stats
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(child: _StatCard(title: 'Utilisateurs', value: '1,234', icon: Icons.people_rounded, color: kAccentBlue, trend: '+12%', hint: 'vs mois dernier')),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(child: _StatCard(title: 'Agences', value: '45', icon: Icons.business_rounded, color: kSuccessGreen, trend: '+5%', hint: 'nouvelles agences')),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(child: _StatCard(title: 'Bus', value: '156', icon: Icons.directions_bus_rounded, color: kWarningOrange, trend: '+3%', hint: 'flotte active')),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(child: _StatCard(title: 'Revenus', value: '€125,300', icon: Icons.trending_up_rounded, color: kPurpleAccent, trend: '+18%', hint: 'ce mois-ci')),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(flex: 2, child: _RecentActivity()),
                SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                const Expanded(child: _QuickActions()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, trend, hint;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.trend, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [color.withOpacity(.1), color.withOpacity(.05)]),
              border: Border.all(color: color.withOpacity(.12)),
            ),
            child: Icon(icon, color: color),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: kSuccessGreen.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
            child: Text(trend, style: const TextStyle(color: kSuccessGreen, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: kTextDark)),
        Text(title, style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
        Text(hint, style: const TextStyle(color: kTextLight, fontSize: 12)),
      ]),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Activité Récente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
          TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: kAccentBlue, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: const [
              _ActivityItem(title: 'Nouvelle réservation', subtitle: 'Bus Paris-Lyon', time: '5 min', icon: Icons.book_online_rounded, color: kSuccessGreen),
              _ActivityItem(title: 'Bus assigné', subtitle: 'Agence Nord', time: '15 min', icon: Icons.directions_bus_rounded, color: kAccentBlue),
              _ActivityItem(title: 'Paiement reçu', subtitle: '€45.50', time: '32 min', icon: Icons.payment_rounded, color: kPurpleAccent),
              _ActivityItem(title: 'Signalement panne', subtitle: 'Bus #156', time: '1h', icon: Icons.warning_rounded, color: kWarningOrange),
            ],
          ),
        ),
      ]),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  const _ActivityItem({required this.title, required this.subtitle, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSoftGray, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(.2))),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: kTextDark)),
          Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Text(time, style: const TextStyle(color: kTextLight, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Actions Rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 16),
        _ActionBtn(text: 'Ajouter Bus', icon: Icons.add_circle_rounded, color: kAccentBlue, onTap: () {}),
        const SizedBox(height: 12),
        _ActionBtn(text: 'Nouvelle Agence', icon: Icons.business_center_rounded, color: kSuccessGreen, onTap: () {}),
        const SizedBox(height: 12),
        _ActionBtn(text: 'Voir Rapports', icon: Icons.analytics_rounded, color: kWarningOrange, onTap: () {}),
        const SizedBox(height: 12),
        _ActionBtn(text: 'Paramètres', icon: Icons.settings_rounded, color: kTextLight, onTap: () {}),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text; final IconData icon; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.text, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(.12))),
          child: Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withOpacity(.7)),
          ]),
        ),
      ),
    );
  }
}

/* ============================================================
 * Vues CRUD — Data responsive
 * ============================================================ */

/// Table responsive :
/// - Desktop: en lignes horizontales (header + lignes).
/// - Tablet: identique mais conteneur scrollable horizontal si besoin.
/// - Mobile: "Card mode" (key-value) + menu "..." pour actions.
class _ResponsiveData extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final List<String> headers;        // inclure "Actions" si nécessaire
  final List<List<String>> rows;     // chaque ligne SANS la colonne "Actions"
  final bool showAdd;

  const _ResponsiveData({
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

    // En desktop/tablette, on ne garde que les colonnes de données (sans "Actions")
    final dataHeaders = _hasActions
        ? headers.where((h) => h.trim().toLowerCase() != 'actions').toList()
        : headers;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------- Titre + bouton "Ajouter" ----------
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
                    Text(title, style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: kTextDark)),
                    Text(subtitle, style: const TextStyle(
                        color: kTextLight, fontSize: 13)),
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

          // --------- Contenu ----------
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18)],
              ),

              // MOBILE -> cartes lisibles
              child: isMobile
                  ? _CardList(headers: dataHeaders, rows: rows, hasActions: _hasActions)

              // DESKTOP/TABLET -> header fixe + liste (pas de scroll horizontal)
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
                          const Expanded(
                            child: _HeaderText(),
                          ).withText(h),
                        if (_hasActions)
                          const SizedBox(width: 40), // espace pour le bouton "..."
                      ],
                    ),
                  ),

                  // Liste
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
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (_hasActions)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      color: kTextLight, size: 18),
                                  onSelected: (v) {},
                                  itemBuilder: (context) => [
                                    _pm('edit', 'Modifier', Icons.edit_rounded),
                                    _pm('delete', 'Supprimer', Icons.delete_rounded,
                                        color: kErrorRed),
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

  // --- utils ---
  List<String> _normalizeRow(List<String> row, int expected) {
    final n = List<String>.from(row);
    if (n.length > expected) n.removeRange(expected, n.length);
    while (n.length < expected) n.add('');
    return n;
  }

  PopupMenuItem<String> _pm(String v, String label, IconData icon, {Color? color}) {
    return PopupMenuItem(
      value: v,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? kTextLight),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color ?? kTextDark)),
        ],
      ),
    );
  }
}

/// Peti helper pour les en-têtes (typo consistante)
class _HeaderText extends StatelessWidget {
  const _HeaderText({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
      '', // sera remplacé via extension withText
      style: TextStyle(fontWeight: FontWeight.w800, color: kTextDark),
    );
  }
}

// Extension pratique pour injecter le texte dans _HeaderText
extension on Widget {
  Widget withText(String text) {
    if (this is _HeaderText) {
      return Builder(
        builder: (_) => Text(text,
            style: const TextStyle(fontWeight: FontWeight.w800, color: kTextDark)),
      );
    }
    return this;
  }
}


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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int k = 0; k < headers.length && k < r.length; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 120, child: Text(headers[k], style: const TextStyle(color: kTextLight, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r[k], style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600))),
                ]),
              ),
            if (hasActions)
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: kTextLight, size: 18),
                  onSelected: (v) {},
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Row(children: const [Icon(Icons.edit_rounded, size: 16, color: kTextLight), SizedBox(width: 8), Text('Modifier') ])),
                    PopupMenuItem(value: 'delete', child: Row(children: const [Icon(Icons.delete_rounded, size: 16, color: kErrorRed), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: kErrorRed)) ])),
                  ],
                ),
              ),
          ]),
        );
      },
    );
  }
}

/* ============================================================
 * Vues concrètes
 * ============================================================ */
class _UsersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Utilisateurs',
      subtitle: 'Gérez tous les utilisateurs de la plateforme',
      icon: Icons.people_rounded,
      color: kAccentBlue,
      headers: const ['Nom', 'Email', 'Rôle', 'Statut', 'Actions'],
      rows: const [
        ['Jean Martin', 'jean@email.com', 'Admin', 'Actif'],
        ['Marie Durand', 'marie@email.com', 'User', 'Actif'],
        ['Paul Leroux', 'paul@email.com', 'User', 'Inactif'],
      ],
    );
  }
}

class _AgenciesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Agences',
      subtitle: 'Administrez toutes les agences du réseau',
      icon: Icons.business_rounded,
      color: kSuccessGreen,
      headers: const ['Nom', 'Ville', 'Bus', 'Revenus', 'Actions'],
      rows: const [
        ['Agence Nord', 'Paris', '15', '€25,400'],
        ['Agence Sud', 'Lyon', '12', '€18,200'],
        ['Agence Ouest', 'Nantes', '8', '€12,100'],
      ],
    );
  }
}

class _BusesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Bus',
      subtitle: 'Suivez et gérez votre flotte de véhicules',
      icon: Icons.directions_bus_rounded,
      color: kWarningOrange,
      headers: const ['Immatriculation', 'Modèle', 'Agence', 'Statut', 'Actions'],
      rows: const [
        ['AB-123-CD', 'Mercedes Sprinter', 'Agence Nord', 'Actif'],
        ['EF-456-GH', 'Iveco Daily', 'Agence Sud', 'Maintenance'],
        ['IJ-789-KL', 'Ford Transit', 'Agence Ouest', 'Actif'],
      ],
    );
  }
}

class _TransactionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Transactions',
      subtitle: 'Suivez toutes les transactions financières',
      icon: Icons.payment_rounded,
      color: kPurpleAccent,
      headers: const ['ID', 'Montant', 'Client', 'Date', 'Statut', 'Actions'],
      rows: const [
        ['#1234', '€45.50', 'Jean Martin', '05/09/2025', 'Validé'],
        ['#1235', '€32.00', 'Marie Durand', '05/09/2025', 'En attente'],
        ['#1236', '€28.75', 'Paul Leroux', '04/09/2025', 'Validé'],
      ],
    );
  }
}

class _ReservationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Réservations',
      subtitle: 'Administrez toutes les réservations clients',
      icon: Icons.book_online_rounded,
      color: kAccentBlue,
      headers: const ['Réf', 'Client', 'Trajet', 'Date', 'Statut', 'Actions'],
      rows: const [
        ['R001', 'Jean Martin', 'Paris-Lyon', '10/09/2025', 'Confirmée'],
        ['R002', 'Marie Durand', 'Lyon-Marseille', '12/09/2025', 'En attente'],
        ['R003', 'Paul Leroux', 'Nantes-Bordeaux', '15/09/2025', 'Annulée'],
      ],
    );
  }
}

class _ReportsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ResponsiveData(
      title: 'Gestion des Signalements',
      subtitle: 'Traitez les signalements et incidents',
      icon: Icons.report_problem_rounded,
      color: kErrorRed,
      headers: const ['ID', 'Type', 'Description', 'Priorité', 'Statut', 'Actions'],
      rows: const [
        ['S001', 'Panne', 'Problème moteur Bus #156', 'Haute', 'En cours'],
        ['S002', 'Retard', 'Retard significatif ligne 12', 'Moyenne', 'Résolu'],
        ['S003', 'Accident', 'Accrochage parking agence', 'Haute', 'Nouveau'],
      ],
    );
  }
}

class _SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < kBpMobile;
    final crossCount = isMobile ? 1 : 2;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Paramètres Système', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 6),
        const Text('Configurez et personnalisez votre système', style: TextStyle(color: kTextLight, fontSize: 14)),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.count(
            crossAxisCount: crossCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: const [
              _SettingCard(title: 'Notifications', desc: 'Gérer les alertes système et notifications push', icon: Icons.notifications_rounded, color: kAccentBlue),
              _SettingCard(title: 'Sécurité', desc: 'Paramètres de sécurité et authentification', icon: Icons.security_rounded, color: kErrorRed),
              _SettingCard(title: 'Maintenance', desc: 'Planning et gestion de la maintenance', icon: Icons.build_rounded, color: kWarningOrange),
              _SettingCard(title: 'Rapports', desc: 'Configuration des rapports automatiques', icon: Icons.analytics_rounded, color: kPurpleAccent),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title, desc; final IconData icon; final Color color;
  const _SettingCard({required this.title, required this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 18)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [color.withOpacity(.15), color.withOpacity(.06)])),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(color: kTextLight, fontSize: 13)),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Configurer', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
*/