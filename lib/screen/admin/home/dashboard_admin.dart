import 'package:bus_easy/screen/admin/home/reponsive_data.dart';
import 'package:bus_easy/screen/admin/home/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../gestion_agence/agence_view.dart';
import '../gestion_bus/bus_view.dart';
import '../gestion_user/user_view.dart';
import 'theme.dart';
import 'navigation.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool sidebarCollapsed = false;
  String _searchQuery = '';

  String? _adminName;
  String? _adminEmail;

  late final AnimationController _fadeCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  late final Animation<double> _fadeAnim =
  CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

  final List<String> menuItems = const [
    'Dashboard', 'Utilisateurs', 'Agences', 'Bus',
    'Transactions', 'Réservations', 'Signalements','Consulter IA','Paramètres'
  ];
  final List<IconData> menuIcons = const [
    Icons.dashboard_rounded, Icons.people_rounded, Icons.business_rounded,
    Icons.directions_bus_rounded, Icons.payment_rounded, Icons.book_online_rounded,
    Icons.report_problem_rounded, Icons.settings_rounded
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl.forward();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      final snap =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snap.data() ?? {};

      setState(() {
        _adminName = (data['name'] ?? user.displayName ?? 'Administrateur').toString();
        _adminEmail = (data['email'] ?? user.email ?? '').toString();
      });
    } catch (_) {
      final u = FirebaseAuth.instance.currentUser;
      setState(() {
        _adminName = u?.displayName ?? 'Administrateur';
        _adminEmail = u?.email ?? '';
      });
    }
  }

  void _selectTab(int i) {
    setState(() => selectedIndex = i);
    _fadeCtrl..reset()..forward();
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
          child: AdminSidebar(
            items: menuItems,
            icons: menuIcons,
            selectedIndex: selectedIndex,
            onSelect: (i) { Navigator.pop(context); _selectTab(i); },
            collapsed: false,
            onToggleCollapse: () {},
            displayName: _adminName,
            email: _adminEmail,
          ),
        )
            : null,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [kGradientStart, kGradientEnd]),
            ),
            child: Row(
              children: [
                if (isDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sidebarCollapsed ? kSidebarWMin : kSidebarW,
                    child: AdminSidebar(
                      items: menuItems,
                      icons: menuIcons,
                      selectedIndex: selectedIndex,
                      onSelect: _selectTab,
                      collapsed: sidebarCollapsed,
                      onToggleCollapse: () =>
                          setState(() => sidebarCollapsed = !sidebarCollapsed),
                      displayName: _adminName,
                      email: _adminEmail,
                    ),
                  )
                else if (!isMobile)
                  AdminRail(
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
                        AdminTopBar(
                          title: menuItems[selectedIndex],
                          isMobile: isMobile,
                          onMenuTap: isMobile
                              ? () => scaffoldKey.currentState?.openDrawer()
                              : null,
                          onSearch: (q) => setState(() => _searchQuery = q),
                          greetingName: _adminName,
                        ),
                        Expanded(
                          child: _PageSwitcher(
                            index: selectedIndex,
                            search: _searchQuery,
                          ),
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

/* =================== Switcher =================== */
class _PageSwitcher extends StatelessWidget {
  final int index;
  final String search;
  const _PageSwitcher({required this.index, required this.search});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0: return const DashboardHomeView();
      case 1: return UsersView(search: search);
      case 2: return const AgencyView();
      case 3: return const BusView();
      case 4: return const TransactionsView();
      case 5: return const ReservationsView();
      case 6: return const ReportsView();
      case 7: return const SettingsView();
      default: return const DashboardHomeView();
    }
  }
}


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
              Expanded(child: _StatCard(title: 'Utilisateurs', value: '1,234', icon: Icons.people_rounded, color: kAccentBlue, trend: '+12%', hint: 'vs mois dernier')),
              SizedBox(width: 16, height: 16),
              Expanded(child: _StatCard(title: 'Agences', value: '45', icon: Icons.business_rounded, color: kSuccessGreen, trend: '+5%', hint: 'nouvelles agences')),
              SizedBox(width: 16, height: 16),
              Expanded(child: _StatCard(title: 'Bus', value: '156', icon: Icons.directions_bus_rounded, color: kWarningOrange, trend: '+3%', hint: 'flotte active')),
              SizedBox(width: 16, height: 16),
              Expanded(child: _StatCard(title: 'Revenus', value: '125,300 FCFA', icon: Icons.trending_up_rounded, color: kPurpleAccent, trend: '+18%', hint: 'ce mois-ci')),
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
  const _RecentActivity();

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
              _ActivityItem(title: 'Nouvelle réservation', subtitle: 'Bus YAOUNDE-DOUALA', time: '5 min', icon: Icons.book_online_rounded, color: kSuccessGreen),
              _ActivityItem(title: 'Bus assigné', subtitle: 'Agence Nord', time: '15 min', icon: Icons.directions_bus_rounded, color: kAccentBlue),
              _ActivityItem(title: 'Paiement reçu', subtitle: '6000', time: '32 min', icon: Icons.payment_rounded, color: kPurpleAccent),
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
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: kTextDark)),
            Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 12)),
          ]),
        ),
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
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Actions Rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
          SizedBox(height: 16),
          _ActionBtn(text: 'Ajouter Bus', icon: Icons.add_circle_rounded, color: kAccentBlue),
          SizedBox(height: 12),
          _ActionBtn(text: 'Nouvelle Agence', icon: Icons.business_center_rounded, color: kSuccessGreen),
          SizedBox(height: 12),
          _ActionBtn(text: 'Voir Rapports', icon: Icons.analytics_rounded, color: kWarningOrange),
          SizedBox(height: 12),
          _ActionBtn(text: 'Paramètres', icon: Icons.settings_rounded, color: kTextLight),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text; final IconData icon; final Color color;
  const _ActionBtn({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
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


class _EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _EmptyState({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: kSoftGray, borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, color: kTextLight, size: 36),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: kTextLight)),
      ]),
    );
  }
}


class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return const AdminResponsiveData(
      title: 'Gestion des Transactions',
      subtitle: 'Suivez toutes les transactions financières',
      icon: Icons.payment_rounded,
      color: kPurpleAccent,
      headers: ['ID', 'Montant', 'Client', 'Date', 'Statut', 'Actions'],
      rows: [
        ['#1234', '6000', 'Mbatoutchou Arthur', '05/09/2025', 'Validé'],
        ['#1235', '5000', 'Atangana felix', '05/09/2025', 'En attente'],
        ['#1236', '2500', 'Mimboe Stephane', '04/09/2025', 'Validé'],
      ],
    );
  }
}

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return const AdminResponsiveData(
      title: 'Gestion des Réservations',
      subtitle: 'Administrez toutes les réservations clients',
      icon: Icons.book_online_rounded,
      color: kAccentBlue,
      headers: ['Réf', 'Client', 'Trajet', 'Date', 'Statut', 'Actions'],
      rows: [
        ['R001', 'Mbatoutchou Arthur', 'Yaounde-Douala', '10/09/2025', 'Confirmée'],
        ['R002', 'Atangana felix', 'Douala-Yaounde', '12/09/2025', 'En attente'],
        ['R003', 'Mimboe Stephane', 'Yaounde-mbalmayo', '15/09/2025', 'Annulée'],
      ],
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});
  @override
  Widget build(BuildContext context) {
    return const AdminResponsiveData(
      title: 'Gestion des Signalements',
      subtitle: 'Traitez les signalements et incidents',
      icon: Icons.report_problem_rounded,
      color: kErrorRed,
      headers: ['ID', 'Type', 'Description', 'Priorité', 'Statut', 'Actions'],
      rows: [
        ['S001', 'Panne', 'Problème moteur Bus #156', 'Haute', 'En cours'],
        ['S002', 'Retard', 'Retard significatif ligne 12', 'Moyenne', 'Résolu'],
        ['S003', 'Accident', 'Accrochage parking agence', 'Haute', 'Nouveau'],
      ],
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < kBpMobile;
    final cross = isMobile ? 1 : 2;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Paramètres Système', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 6),
        const Text('Configurez et personnalisez votre système', style: TextStyle(color: kTextLight, fontSize: 14)),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.count(
            crossAxisCount: cross,
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
