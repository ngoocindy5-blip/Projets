import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER - Hauteur fixe responsive
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Global Voyage",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Où souhaitez-vous voyager ?",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isTablet ? 18 : 16,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // FORMULAIRE
                      _buildFormSection(context, isTablet),

                      SizedBox(height: screenHeight * 0.02),

                      // Bouton recherche
                      _buildSearchButton(isTablet),

                      SizedBox(height: screenHeight * 0.03),

                      // Résultats
                      _buildResultsSection(context, isTablet),

                      // Padding bottom pour éviter que le contenu soit coupé
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
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue[50],
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Colors.blue,
                        size: isTablet ? 24 : 20),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: Text(
                        "Yaoundé (YDE)",
                        style: TextStyle(fontSize: isTablet ? 18 : 16),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
                  child: const Divider(),
                ),
                Row(
                  children: [
                    Icon(Icons.flag,
                        color: Colors.blue,
                        size: isTablet ? 24 : 20),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: Text(
                        "Douala (DLA)",
                        style: TextStyle(fontSize: isTablet ? 18 : 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Date du voyage
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue[50],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: Colors.blue,
                  size: isTablet ? 24 : 20),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Text(
                  "12 Décembre 2024",
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Passagers + Classe
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              // Disposition verticale pour les petits écrans
              return Column(
                children: [
                  _buildPassengerContainer(isTablet),
                  SizedBox(height: isTablet ? 16 : 12),
                  _buildClassContainer(isTablet),
                ],
              );
            } else {
              // Disposition horizontale pour les écrans plus larges
              return Row(
                children: [
                  Expanded(child: _buildPassengerContainer(isTablet)),
                  SizedBox(width: isTablet ? 16 : 10),
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
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue[50],
      ),
      child: Row(
        children: [
          Icon(Icons.people,
              color: Colors.blue,
              size: isTablet ? 24 : 20),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Text(
              "2 Adultes",
              style: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassContainer(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue[50],
      ),
      child: Row(
        children: [
          Icon(Icons.chair,
              color: Colors.blue,
              size: isTablet ? 24 : 20),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Text(
              "VIP",
              style: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(bool isTablet) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: Size(double.infinity, isTablet ? 60 : 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        "Rechercher un Ticket",
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
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
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // Liste des résultats
        ...List.generate(2, (index) {
          final titles = ["Global Voyage - VIP", "Global Voyage - Classe Éco"];
          final times = ["6h30 - 12h30", "7h00 - 13h00"];

          return Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 16 : 10),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                leading: Icon(
                  Icons.directions_bus,
                  color: Colors.blue,
                  size: isTablet ? 48 : 40,
                ),
                title: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Yaoundé → Douala\n${times[index]}",
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      height: 1.4,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}