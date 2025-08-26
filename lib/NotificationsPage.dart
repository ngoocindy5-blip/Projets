import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Aujourd\'hui',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            _buildNotificationCard(
              title: 'Départ du trajet',
              time: '10:35 PM',
              message: 'Le bus VIP Paris-Lyon vient de partir. Bon voyage !',
              isNew: true,
            ),
            _buildNotificationCard(
              title: 'Mise à jour de l\'itinéraire',
              time: '10:15 PM',
              message: 'Prochain arrêt : Lyon Centre dans 45 min.',
            ),
            Text(
              'Hier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            _buildNotificationCard(
              title: 'Fin du trajet',
              time: '08:00 PM',
              message: 'Le trajet Paris-Lyon est terminé. Merci d\'avoir voyagé avec nous !',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({required String title, required String time, required String message, bool isNew = false}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          isNew ? Icons.circle : Icons.circle_outlined,
          size: 12,
          color: isNew ? Colors.blue : Colors.grey,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: isNew ? FontWeight.bold : FontWeight.normal)),
            Text(time, style: TextStyle(color: Colors.grey)),
          ],
        ),
        subtitle: Text(message, style: TextStyle(color: Colors.black87)),
      ),
    );
  }
}