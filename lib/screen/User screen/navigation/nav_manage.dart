import 'package:bus_easy/screen/User%20screen/Home/Home_page.dart';
import 'package:bus_easy/screen/User%20screen/Itineraire/itineraire.dart';
import 'package:bus_easy/screen/User%20screen/Profile/profile.dart';
import 'package:bus_easy/screen/User%20screen/Reservations/reservation.dart';
import 'package:flutter/material.dart';

class NavManage extends StatefulWidget {
  const NavManage({super.key});

  @override
  State<NavManage> createState() => _NavManageState();
}

class _NavManageState extends State<NavManage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ReservationPage(),
    ItinerairePage(),
    ProfilePage(),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index; // ✅ Mettre à jour l'index courant
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF1666FF), Color(0xFF4285FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.car_crash_outlined, color: Colors.white, size: 24),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _changePage(0),
                child: _BottomItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  selected: _currentIndex == 0,
                ),
              ),
              GestureDetector(
                onTap: () => _changePage(1),
                child: _BottomItem(
                  icon: Icons.credit_card_rounded,
                  label: 'Reservations',
                  selected: _currentIndex == 1,
                ),
              ),
              const SizedBox(width: 48),
              GestureDetector(
                onTap: () => _changePage(2),
                child: _BottomItem(
                  icon: Icons.directions,
                  label: 'Itineraire',
                  selected: _currentIndex == 2,
                ),
              ),
              GestureDetector(
                onTap: () => _changePage(3),
                child: _BottomItem(
                  icon: Icons.person,
                  label: 'Profil',
                  selected: _currentIndex == 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1666FF).withOpacity(.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: selected ? const Color(0xFF1666FF) : const Color(0xFF9AA6BF),
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xFF1666FF) : const Color(0xFF9AA6BF),
          ),
        ),
      ],
    );
  }
}


