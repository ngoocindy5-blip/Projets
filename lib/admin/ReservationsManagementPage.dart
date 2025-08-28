import 'package:flutter/material.dart';

class ReservationsManagementPage extends StatefulWidget {
  const ReservationsManagementPage({super.key});

  @override
  State<ReservationsManagementPage> createState() => _ReservationsManagementPageState();
}

class _ReservationsManagementPageState extends State<ReservationsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Réservations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Global Voyages - Yaoundé & Douala',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Confirmées'),
            Tab(text: 'En attente'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndStats(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationsList(_getAllReservations()),
                _buildReservationsList(_getConfirmedReservations()),
                _buildReservationsList(_getPendingReservations()),
                _buildReservationsList(_getCancelledReservations()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReservationDialog(),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, téléphone ou code...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1976D2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Statistiques rapides
          Row(
            children: [
              _buildStatCard('Total', '156', Colors.blue[100]!, const Color(0xFF1976D2)),
              const SizedBox(width: 12),
              _buildStatCard('Confirmées', '98', Colors.green[100]!, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('En attente', '42', Colors.orange[100]!, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Annulées', '16', Colors.red[100]!, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations) {
    final filteredReservations = reservations.where((reservation) {
      if (_searchQuery.isEmpty) return true;
      return reservation.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reservation.phone.contains(_searchQuery) ||
          reservation.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation trouvée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReservations.length,
      itemBuilder: (context, index) {
        return _buildReservationCard(filteredReservations[index]);
      },
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    Color statusColor;
    IconData statusIcon;

    switch (reservation.status) {
      case 'Confirmée':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'En attente':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Annulée':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reservation.code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          reservation.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Informations client
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Téléphone
              Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    reservation.phone,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Itinéraire
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      reservation.departure,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      reservation.destination,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Date, heure et prix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            reservation.date,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            reservation.time,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${reservation.seats} siège${reservation.seats > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${reservation.price} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editReservation(reservation),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelReservation(reservation),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Annuler'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les réservations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Toutes les réservations'),
              leading: Radio<String>(
                value: 'Toutes',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Yaoundé → Douala'),
              leading: Radio<String>(
                value: 'Yaoundé-Douala',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Douala → Yaoundé'),
              leading: Radio<String>(
                value: 'Douala-Yaoundé',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDetails(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${reservation.code}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Client', reservation.clientName),
              _buildDetailRow('Téléphone', reservation.phone),
              _buildDetailRow('Départ', reservation.departure),
              _buildDetailRow('Destination', reservation.destination),
              _buildDetailRow('Date', reservation.date),
              _buildDetailRow('Heure', reservation.time),
              _buildDetailRow('Sièges', reservation.seats.toString()),
              _buildDetailRow('Prix', '${reservation.price} FCFA'),
              _buildDetailRow('Statut', reservation.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editReservation(reservation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _editReservation(Reservation reservation) {
    // Logique pour modifier une réservation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification de la réservation ${reservation.code}'),
        backgroundColor: const Color(0xFF1976D2),
      ),
    );
  }

  void _cancelReservation(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: Text('Êtes-vous sûr de vouloir annuler la réservation ${reservation.code} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                reservation.status = 'Annulée';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Réservation ${reservation.code} annulée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showAddReservationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'ajout de réservation à implémenter'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  // Données de test
  List<Reservation> _getAllReservations() {
    return [
      Reservation(
        code: 'GV001',
        clientName: 'Jean-Paul Mbarga',
        phone: '+237 690 123 456',
        departure: 'Yaoundé',
        destination: 'Douala',
        date: '15 Mars 2024',
        time: '08:00',
        seats: 2,
        price: 6000,
        status: 'Confirmée',
      ),
      Reservation(
        code: 'GV002',
        clientName: 'Marie Fotso',
        phone: '+237 677 987 654',
        departure: 'Douala',
        destination: 'Yaoundé',
        date: '16 Mars 2024',
        time: '14:30',
        seats: 1,
        price: 3000,
        status: 'En attente',
      ),
      Reservation(
        code: 'GV003',
        clientName: 'Pierre Nkomo',
        phone: '+237 694 555 777',
        departure: 'Yaoundé',
        destination: 'Douala',
        date: '17 Mars 2024',
        time: '06:30',
        seats: 3,
        price: 9000,
        status: 'Confirmée',
      ),
      Reservation(
        code: 'GV004',
        clientName: 'Josephine Kom',
        phone: '+237 681 222 333',
        departure: 'Douala',
        destination: 'Yaoundé',
        date: '18 Mars 2024',
        time: '10:00',
        seats: 1,
        price: 3000,
        status: 'Annulée',
      ),
    ];
  }

  List<Reservation> _getConfirmedReservations() {
    return _getAllReservations().where((r) => r.status == 'Confirmée').toList();
  }

  List<Reservation> _getPendingReservations() {
    return _getAllReservations().where((r) => r.status == 'En attente').toList();
  }

  List<Reservation> _getCancelledReservations() {
    return _getAllReservations().where((r) => r.status == 'Annulée').toList();
  }
}

class Reservation {
  final String code;
  final String clientName;
  final String phone;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int seats;
  final int price;
  String status;

  Reservation({
    required this.code,
    required this.clientName,
    required this.phone,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.seats,
    required this.price,
    required this.status,
  });
}