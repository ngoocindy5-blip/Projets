import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'panne.dart'; // Import de la page des pannes

// ================= Thème =================
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
    'Réservations',
  ];

  final List<IconData> menuIcons = const [
    Icons.dashboard_rounded,
    Icons.report_problem_rounded,
    Icons.map_rounded,
    Icons.person_rounded,
    Icons.book_online_rounded,
  ];

  late final AnimationController _fadeCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

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
                colors: [kGradientStart, kGradientEnd],
              ),
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
          BoxShadow(color: kCardShadow, blurRadius: 12, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
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
                  child: Icon(Icons.directions_bus,
                      color: kPrimaryBlue, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BusAgence',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Global Voyages',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onToggleCollapse != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                onPressed: onToggleCollapse,
                icon: Icon(
                  collapsed ? Icons.chevron_right : Icons.chevron_left,
                  color: kTextLight,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? kPrimaryBlue.withOpacity(0.1)
                        : Colors.transparent,
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
                    onTap: () => onSelect(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TopBar =================
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
          BoxShadow(color: kCardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
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
        return const DashboardHome();
      case 1:
        return const BusBreakdownReportPage();
      case 2:
        return const Center(child: Text("Trajets"));
      case 3:
        return const Center(child: Text("Chauffeurs"));
      case 4:
        return const ReservationsList();
      default:
        return const DashboardHome();
    }
  }
}

// ================= Page Réservations =================
class ReservationsList extends StatelessWidget {
  const ReservationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune réservation trouvée."));
        }

        final reservations = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final data = reservations[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.book_online, color: kPrimaryBlue),
                title: Text(data['trajet'] ?? 'Trajet inconnu'),
                subtitle: Text(
                    "Classe : ${data['classe'] ?? '-'} | Places : ${data['places'] ?? '-'}"),
                trailing: Text(
                  data['date']?.toString() ?? '',
                  style: const TextStyle(color: kTextLight, fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ================= Placeholder Dashboard =================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Bienvenue sur le tableau de bord !",
        style: TextStyle(fontSize: 18, color: kTextDark),
      ),
    );
  }
}
