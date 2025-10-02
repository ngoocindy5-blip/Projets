import 'package:flutter/material.dart';

// ================= Theme Constants =================
const kPrimaryBlue = Color(0xFF1976D2);
const kSurface = Colors.white;
const kTextDark = Colors.black87;
const kTextLight = Colors.grey;
const kAccentBlue = Colors.blueAccent;
const kSuccessGreen = Colors.green;
const kWarningOrange = Colors.orange;
const kErrorRed = Colors.red;
const kCardShadow = Colors.black12;
const kSoftGray = Color(0xFFF5F5F5);
const kPurpleAccent = Color(0xFF9C27B0);
const kBpMobile = 600.0;
const kBpDesktop = 1000.0;
const kSidebarW = 260.0;
const kSidebarWMin = 70.0;
const kGradientStart = Color(0xFFE3F2FD);
const kGradientEnd = Color(0xFFBBDEFB);

class AgencyDashboard extends StatefulWidget {
  const AgencyDashboard({super.key});

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  bool sidebarCollapsed = false;

  final List<String> menuItems = const [
    'Dashboard',
    'Pannes',
    'Trajets',
    'Chauffeurs',
    'Réservations'
  ];
  final List<IconData> menuIcons = const [
    Icons.dashboard_rounded,
    Icons.report_problem_rounded,
    Icons.map_rounded,
    Icons.person_rounded,
    Icons.book_online_rounded,
  ];

  late final AnimationController _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250));
  late final Animation<double> _fadeAnim =
  CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _fadeCtrl.forward();
  }

  void _selectTab(int i) {
    setState(() => selectedIndex = i);
    _fadeCtrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final isMobile = w < kBpMobile;
      final isDesktop = w >= kBpDesktop;

      return Scaffold(
        key: scaffoldKey,
        backgroundColor: kPrimaryBlue,
        drawer: isMobile
            ? Drawer(
          child: AgencySidebar(
            items: menuItems,
            icons: menuIcons,
            selectedIndex: selectedIndex,
            onSelect: (i) {
              Navigator.pop(context);
              _selectTab(i);
            },
            collapsed: false,
          ),
        )
            : null,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kGradientStart, kGradientEnd]),
            ),
            child: Row(
              children: [
                if (isDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sidebarCollapsed ? kSidebarWMin : kSidebarW,
                    child: AgencySidebar(
                      items: menuItems,
                      icons: menuIcons,
                      selectedIndex: selectedIndex,
                      onSelect: _selectTab,
                      collapsed: sidebarCollapsed,
                      onToggleCollapse: () =>
                          setState(() => sidebarCollapsed = !sidebarCollapsed),
                    ),
                  )
                else if (!isMobile)
                  AgencyRail(
                    items: menuItems,
                    icons: menuIcons,
                    selectedIndex: selectedIndex,
                    onSelect: _selectTab,
                    extended: w > 900,
                  ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        AgencyTopBar(
                          title: menuItems[selectedIndex],
                          isMobile: isMobile,
                          onMenuTap: isMobile
                              ? () => scaffoldKey.currentState?.openDrawer()
                              : null,
                        ),
                        Expanded(
                          child: _PageSwitcher(index: selectedIndex),
                        ),
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

// ================= Sidebar =================
class AgencySidebar extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onSelect;
  final bool collapsed;
  final VoidCallback? onToggleCollapse;

  const AgencySidebar({
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    this.collapsed = false,
    this.onToggleCollapse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(color: kCardShadow, blurRadius: 12, offset: Offset(2, 0))
        ],
      ),
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryBlue, kAccentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: collapsed
                ? const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.directions_bus, color: kPrimaryBlue),
            )
                : Column(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.directions_bus, color: kPrimaryBlue, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BusAgence',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Global Voyages',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (onToggleCollapse != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                onPressed: onToggleCollapse,
                icon: Icon(
                  collapsed ? Icons.chevron_right : Icons.chevron_left,
                  color: kTextLight,
                ),
                tooltip: collapsed ? 'Développer' : 'Réduire',
              ),
            ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? kPrimaryBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(color: kPrimaryBlue.withOpacity(0.3))
                        : null,
                  ),
                  child: ListTile(
                    leading: Icon(
                      icons[i],
                      color: selected ? kPrimaryBlue : kTextLight,
                    ),
                    title: collapsed
                        ? null
                        : Text(
                      items[i],
                      style: TextStyle(
                        color: selected ? kPrimaryBlue : kTextDark,
                        fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: selected,
                    onTap: () => onSelect(i),
                  ),
                );
              },
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: collapsed
                ? IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: kErrorRed),
            )
                : ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kErrorRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Rail Navigation (Tablet) =================
class AgencyRail extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onSelect;
  final bool extended;

  const AgencyRail({
    required this.items,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
    this.extended = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      extended: extended,
      backgroundColor: kSurface,
      selectedIconTheme: const IconThemeData(color: kPrimaryBlue),
      selectedLabelTextStyle: const TextStyle(
        color: kPrimaryBlue,
        fontWeight: FontWeight.bold,
      ),
      destinations: List.generate(
        items.length,
            (i) => NavigationRailDestination(
          icon: Icon(icons[i]),
          selectedIcon: Icon(icons[i]),
          label: Text(items[i]),
        ),
      ),
    );
  }
}

// ================= Top Bar =================
class AgencyTopBar extends StatelessWidget {
  final String title;
  final bool isMobile;
  final VoidCallback? onMenuTap;

  const AgencyTopBar({
    required this.title,
    required this.isMobile,
    this.onMenuTap,
    super.key,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: const BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(color: kCardShadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onMenuTap != null)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu, color: kPrimaryBlue),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, Global Voyages 👋',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: kTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_rounded, color: kPrimaryBlue),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: kErrorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kSoftGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: kTextLight),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================= Page Switcher =================
class _PageSwitcher extends StatelessWidget {
  final int index;
  const _PageSwitcher({required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const DashboardHomeView();
      case 1:
        return const PanneView();
      case 2:
        return const TrajetView();
      case 3:
        return const ChauffeurView();
      case 4:
        return const ReservationsView();
      default:
        return const DashboardHomeView();
    }
  }
}

// ================= Dashboard Home =================
class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < kBpMobile;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: const [
              Expanded(
                  child: _StatCard(
                      title: 'Pannes',
                      value: '12',
                      icon: Icons.report_problem_rounded,
                      color: kErrorRed,
                      trend: '+2',
                      hint: 'ce mois-ci')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Trajets',
                      value: '25',
                      icon: Icons.map_rounded,
                      color: kAccentBlue,
                      trend: '+3',
                      hint: 'nouveaux trajets')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Chauffeurs',
                      value: '18',
                      icon: Icons.person_rounded,
                      color: kWarningOrange,
                      trend: '+1',
                      hint: 'nouveaux chauffeurs')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Réservations',
                      value: '154',
                      icon: Icons.book_online_rounded,
                      color: kSuccessGreen,
                      trend: '+15',
                      hint: 'ce mois-ci')),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: const [
                Expanded(flex: 2, child: _RecentActivity()),
                SizedBox(width: 16, height: 16),
                Expanded(child: _QuickActions()),
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: kCardShadow, blurRadius: 18, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(.1), color.withOpacity(.05)],
                  ),
                  border: Border.all(color: color.withOpacity(.12)),
                ),
                child: Icon(icon, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kSuccessGreen.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: kSuccessGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: kTextDark,
            ),
          ),
          Text(title,
              style: const TextStyle(
                  color: kTextDark, fontWeight: FontWeight.w600)),
          Text(hint, style: const TextStyle(color: kTextLight, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: kCardShadow, blurRadius: 18)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activité Récente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: kAccentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                _ActivityItem(
                  title: 'Panne signalée',
                  subtitle: 'Bus #156 - Problème moteur',
                  time: '5 min',
                  icon: Icons.warning_rounded,
                  color: kErrorRed,
                ),
                _ActivityItem(
                  title: 'Nouveau trajet',
                  subtitle: 'Yaoundé-Douala',
                  time: '15 min',
                  icon: Icons.map_rounded,
                  color: kAccentBlue,
                ),
                _ActivityItem(
                  title: 'Chauffeur ajouté',
                  subtitle: 'Jean Dupont',
                  time: '32 min',
                  icon: Icons.person_add_rounded,
                  color: kSuccessGreen,
                ),
                _ActivityItem(
                  title: 'Réservation',
                  subtitle: '5 places - Départ 14h',
                  time: '1h',
                  icon: Icons.book_online_rounded,
                  color: kWarningOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSoftGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: kTextLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: kTextLight,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: kCardShadow, blurRadius: 18)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
            SizedBox(height: 16),
            _ActionBtn(
              text: 'Ajouter Bus',
              icon: Icons.directions_bus_rounded,
              color: kAccentBlue,
            ),
            SizedBox(height: 12),
            _ActionBtn(
              text: 'Nouveau Trajet',
              icon: Icons.add_road_rounded,
              color: kSuccessGreen,
            ),
            SizedBox(height: 12),
            _ActionBtn(
              text: 'Ajouter Chauffeur',
              icon: Icons.person_add_rounded,
              color: kWarningOrange,
            ),
            SizedBox(height: 12),
            _ActionBtn(
              text: 'Signaler Panne',
              icon: Icons.report_problem_rounded,
              color: kErrorRed,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _ActionBtn({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(.12)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: color.withOpacity(.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Pages simples =================
class PanneView extends StatelessWidget {
  const PanneView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Gestion des Pannes",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TrajetView extends StatelessWidget {
  const TrajetView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Gestion des Trajets",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ChauffeurView extends StatelessWidget {
  const ChauffeurView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Gestion des Chauffeurs",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Gestion des Réservations",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}