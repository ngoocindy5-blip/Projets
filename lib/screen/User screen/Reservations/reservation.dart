import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Global Voyage",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Où souhaitez-vous voyager ?",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // FORMULAIRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Champs départ / arrivée
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue[50],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Yaoundé (YDE)",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: const [
                            Icon(Icons.flag, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Douala (DLA)",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date du voyage
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue[50],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 10),
                        Text("12 Décembre 2024",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Passagers + Classe
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[50],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.people, color: Colors.blue),
                              SizedBox(width: 10),
                              Text("2 Adultes"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[50],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.chair, color: Colors.blue),
                              SizedBox(width: 10),
                              Text("VIP"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bouton recherche
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Rechercher un Ticket",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Résultats
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    "Voyages Disponibles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Exemple Bus 1
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus,
                          color: Colors.blue, size: 40),
                      title: const Text("Global Voyage - VIP"),
                      subtitle: const Text("Yaoundé → Douala\n6h30 - 12h30"),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Exemple Bus 2
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus,
                          color: Colors.blue, size: 40),
                      title: const Text("Global Voyage - Classe Éco"),
                      subtitle: const Text("Yaoundé → Douala\n7h00 - 13h00"),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Navigation bas de page
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
