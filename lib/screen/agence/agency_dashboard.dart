import 'package:flutter/material.dart';

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
    'Dashboard', 'Pannes', 'Trajets', 'Chauffeurs', 'Réservations'
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

  void _selectTab(int i) {
    setState(() => selectedIndex = i);
    _fadeCtrl..reset()..forward();
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
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
        child: Row(
          children: [
            if (isDesktop)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: sidebarCollapsed ? 70 : 220,
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
                    Container(
                      color: kSurface,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (!isDesktop)
                            IconButton(
                                onPressed: () {
                                  scaffoldKey.currentState?.openDrawer();
                                },
                                icon: const Icon(Icons.menu)),
                          const Text(
                            'Agence Dashboard',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
    );
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

  const AgencySidebar(
      {required this.items,
        required this.icons,
        required this.selectedIndex,
        required this.onSelect,
        this.collapsed = false,
        this.onToggleCollapse,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      child: Column(
        children: [
          if (onToggleCollapse != null)
            IconButton(onPressed: onToggleCollapse!, icon: const Icon(Icons.arrow_back)),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return ListTile(
                  leading: Icon(icons[i], color: selected ? kPrimaryBlue : kTextLight),
                  title: collapsed ? null : Text(items[i], style: TextStyle(color: selected ? kPrimaryBlue : kTextLight)),
                  selected: selected,
                  onTap: () => onSelect(i),
                );
              },
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
                      color: Colors.red,
                      trend: '+2',
                      hint: 'ce mois-ci')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Trajets',
                      value: '25',
                      icon: Icons.map_rounded,
                      color: Colors.blue,
                      trend: '+3',
                      hint: 'nouveaux trajets')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Chauffeurs',
                      value: '18',
                      icon: Icons.person_rounded,
                      color: Colors.orange,
                      trend: '+1',
                      hint: 'nouveaux chauffeurs')),
              SizedBox(width: 16, height: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Réservations',
                      value: '154',
                      icon: Icons.book_online_rounded,
                      color: Colors.green,
                      trend: '+15',
                      hint: 'ce mois-ci')),
            ],
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

  const _StatCard(
      {required this.title,
        required this.value,
        required this.icon,
        required this.color,
        required this.trend,
        required this.hint,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Text(trend, style: const TextStyle(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark)),
          Text(title, style: const TextStyle(color: kTextDark)),
          Text(hint, style: const TextStyle(color: kTextLight)),
        ],
      ),
    );
  }
}

// ================= Pages simulées =================
class PanneView extends StatelessWidget {
  const PanneView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gestion des Pannes"));
  }
}

class TrajetView extends StatelessWidget {
  const TrajetView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gestion des Trajets"));
  }
}

class ChauffeurView extends StatelessWidget {
  const ChauffeurView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gestion des Chauffeurs"));
  }
}

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gestion des Réservations"));
  }
}
