import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Gris très clair
      body: SafeArea(
        child: Column(
          children: [
            // HEADER - Design moderne épuré
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Global Voyage",
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Où souhaitez-vous voyager ?",
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENU SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // FORMULAIRE
                      _buildFormSection(context, isTablet),

                      SizedBox(height: screenHeight * 0.03),

                      // Bouton recherche
                      _buildSearchButton(isTablet),

                      SizedBox(height: screenHeight * 0.04),

                      // Résultats
                      _buildResultsSection(context, isTablet),

                      // Padding bottom
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, bool isTablet) {
    return Column(
      children: [
        // Champs départ / arrivée
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFF0EA5E9),
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Text(
                      "Yaoundé (YDE)",
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                child: Container(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      color: const Color(0xFF10B981),
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Text(
                      "Douala (DLA)",
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 20 : 16),

        // Date du voyage
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: const Color(0xFFF59E0B),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  "12 Décembre 2024",
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 20 : 16),

        // Passagers + Classe
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return Column(
                children: [
                  _buildPassengerContainer(isTablet),
                  SizedBox(height: isTablet ? 20 : 16),
                  _buildClassContainer(isTablet),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: _buildPassengerContainer(isTablet)),
                  SizedBox(width: isTablet ? 20 : 16),
                  Expanded(child: _buildClassContainer(isTablet)),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPassengerContainer(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.people_outline,
              color: const Color(0xFFEC4899),
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Text(
              "2 Adultes",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassContainer(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chair_outlined,
              color: const Color(0xFF8B5CF6),
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Text(
              "VIP",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285FF),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, isTablet ? 64 : 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          "Rechercher un Ticket",
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Voyages Disponibles",
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Liste des résultats
        ...List.generate(2, (index) {
          final titles = ["Global Voyage - VIP", "Global Voyage - Classe Éco"];
          final times = ["6h30 - 12h30", "7h00 - 13h00"];
          final colors = [const Color(0xFF8B5CF6), const Color(0xFF10B981)];
          final bgColors = [const Color(0xFFF3E8FF), const Color(0xFFF0FDF4)];

          return Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(isTablet ? 24 : 20),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColors[index],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_bus_outlined,
                    color: colors[index],
                    size: isTablet ? 32 : 28,
                  ),
                ),
                title: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Yaoundé → Douala\n${times[index]}",
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      height: 1.4,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFF1A1A1A),
                    size: isTablet ? 20 : 18,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}