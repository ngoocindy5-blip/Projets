import 'package:flutter/material.dart';
import 'dart:async';


class RouteTrackingPage extends StatefulWidget {
  const RouteTrackingPage({super.key});

  @override
  _RouteTrackingPageState createState() => _RouteTrackingPageState();
}

class _RouteTrackingPageState extends State<RouteTrackingPage> {
  double _progress = 0.0; // Simule l'avancement
  String _status = "En route";
  String _eta = "Arrivée prévue : 02:00 AM";

  @override
  void initState() {
    super.initState();
    // Simulation de mise à jour en temps réel
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _progress = (_progress + 0.1) % 1.0; // Avance de 10% toutes les 5 secondes
        if (_progress > 0.8) {
          _status = "Proche de la destination";
          _eta = "Arrivée dans 10 min";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi de l\'Itinéraire'),
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
            // Placeholder pour la carte
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Carte simulée (intégrer Google Maps API ici)',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bus VIP - Yaounde-Douala',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              'Avancement : ${( _progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Statut$_status',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              _eta,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prochain arrêt : Douala',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '10 min',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                print('Mettre à jour la position');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Rafraîchir', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}