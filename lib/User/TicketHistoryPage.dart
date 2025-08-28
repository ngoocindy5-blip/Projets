import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TicketHistoryPage(),
    );
  }
}

class TicketHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Tickets'),
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
            _buildTicketCard(
              title: 'Paris-Lyon (VIP)',
              date: '25/08/2025',
              time: '10:00 AM - 02:00 PM',
              status: 'Complété',
            ),
            _buildTicketCard(
              title: 'Lyon-Paris (CLASSIQUE)',
              date: '25/08/2025',
              time: '03:00 PM - 07:00 PM',
              status: 'Annulé',
            ),
            Text(
              'Hier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            _buildTicketCard(
              title: 'Paris-Toulouse (VIP)',
              date: '24/08/2025',
              time: '09:00 AM - 01:00 PM',
              status: 'Complété',
            ),
            _buildTicketCard(
              title: 'Toulouse-Paris (CLASSIQUE)',
              date: '24/08/2025',
              time: '02:00 PM - 06:00 PM',
              status: 'Complété',
            ),
            Text(
              'Semaine dernière',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            _buildTicketCard(
              title: 'Marseille-Paris (VIP)',
              date: '18/08/2025',
              time: '08:00 AM - 12:00 PM',
              status: 'Complété',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard({required String title, required String date, required String time, required String status}) {
    Color statusColor = status == 'Complété' ? Colors.green : Colors.red;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.bus_alert, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$date | $time'),
            Text('Statut : $status', style: TextStyle(color: statusColor)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          print('Détails du ticket $title');
        },
      ),
    );
  }
}