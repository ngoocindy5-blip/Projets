import 'package:flutter/material.dart';

class BusDetailPage extends StatelessWidget {
  const BusDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Bus'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du bus (placeholder)
            Image.network(
              'https://via.placeholder.com/300x150',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            // Informations du bus
            Text(
              'Bus VIP - Trajet Paris-Lyon',
              style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.event_seat, color: Colors.grey),
                SizedBox(width: 5),
                Text('Capacité totale : 50 places'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 5),
                Text('Places disponibles : 15'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_off, color: Colors.red),
                SizedBox(width: 5),
                Text('Places occupées : 35'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 5),
                Text('Type : VIP'),
              ],
            ),
            SizedBox(height: 20),
            // Détails supplémentaires
            Text(
              'Départ : 26/08/2025 08:00 AM',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Arrivée : 26/08/2025 12:00 PM',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Prix : 45€',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            // Bouton de réservation
            ElevatedButton(
              onPressed: () {
                print('Réservation effectuée');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Réserver maintenant', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
      ),
    );
  }
}