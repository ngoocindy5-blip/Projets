import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  // Liste des destinations avec descriptions et images
  final List<Map<String, String>> destinations = [
    {
      'name': 'Yaoundé',
      'description': 'La capitale politique du Cameroun, surnommée la ville aux sept collines, offre une richesse culturelle avec ses musées, marchés colorés comme Mokolo et ses vues panoramiques.',
      'image': 'https://via.placeholder.com/150/1E88E5/FFFFFF?text=Yaoundé', // Remplacer par une vraie URL d'image
    },
    {
      'name': 'Douala',
      'description': 'Le poumon économique du Cameroun, Douala séduit par son port animé, ses restaurants de fruits de mer et son marché artisanal de Bonanjo.',
      'image': 'https://via.placeholder.com/150/1E88E5/FFFFFF?text=Douala', // Remplacer par une vraie URL d'image
    },
    {
      'name': 'Kribi',
      'description': 'Une escapade balnéaire avec des plages de sable blanc, les chutes de la Lobé et une ambiance tropicale idéale pour la détente.',
      'image': 'https://via.placeholder.com/150/1E88E5/FFFFFF?text=Kribi', // Remplacer par une vraie URL d'image
    },
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explorez',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Remplacer par une vraie image
              backgroundColor: Colors.blue[200],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche avec style amélioré
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une destination...',
                prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            // Titre de la section
            Text(
              'Destinations Phares',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            // Liste des destinations
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Action au clic (naviguer vers une page de détails)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${destination['name']} sélectionnée'),
                            backgroundColor: Colors.blue[800],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image de la destination
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                destination['image']!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.blue[100],
                                    child: Icon(Icons.error, color: Colors.blue[800]),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            // Détails de la destination
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination['name']!,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    destination['description']!,
                                    style: Theme.of(context).textTheme.titleSmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Icône de navigation
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue[800],
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bouton flottant pour une action (ex: carte ou favoris)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ouvrir la carte des destinations'),
              backgroundColor: Colors.blue[800],
            ),
          );
        },
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.map),
      ),
    );
  }
}