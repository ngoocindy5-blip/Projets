import 'package:flutter/material.dart';

void main() {
  runApp(GlobalVoyageAdminApp());
}

class GlobalVoyageAdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Voyage Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _selectedRoute = 'Tous';
  String _selectedStatus = 'Tous';

  final List<Map<String, dynamic>> _stats = [
    {
      'title': 'Réservations',
      'value': '1,247',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'change': '+12%'
    },
    {
      'title': 'Revenus',
      'value': '15.4M',
      'icon': Icons.attach_money,
      'color': Colors.green,
      'change': '+18%'
    },
    {
      'title': 'Utilisateurs',
      'value': '856',
      'icon': Icons.people,
      'color': Colors.purple,
      'change': '+5%'
    },
    {
      'title': 'Remboursements',
      'value': '23',
      'icon': Icons.refresh,
      'color': Colors.orange,
      'change': 'En attente'
    },
  ];

  final List<Map<String, dynamic>> _reservations = [
    {
      'id': 'GV001234',
      'user': 'Hassan Oulahe',
      'route': 'Yaoundé → Douala',
      'date': '2024-09-15',
      'time': '08:30',
      'price': 15000,
      'status': 'confirmé',
      'payment': 'payé',
      'phone': '+237 6XX XX XX XX'
    },
    {
      'id': 'GV001235',
      'user': 'Marie Ngono',
      'route': 'Douala → Yaoundé',
      'date': '2024-09-16',
      'time': '14:00',
      'price': 15000,
      'status': 'en attente',
      'payment': 'en attente',
      'phone': '+237 6XX XX XX XX'
    },
    {
      'id': 'GV001236',
      'user': 'Jean Mbarga',
      'route': 'Yaoundé → Douala',
      'date': '2024-09-14',
      'time': '10:15',
      'price': 25000,
      'status': 'annulé',
      'payment': 'remboursé',
      'phone': '+237 6XX XX XX XX'
    },
    {
      'id': 'GV001237',
      'user': 'Fatima Bello',
      'route': 'Douala → Yaoundé',
      'date': '2024-09-17',
      'time': '12:45',
      'price': 15000,
      'status': 'confirmé',
      'payment': 'payé',
      'phone': '+237 6XX XX XX XX'
    },
  ];

  final List<Map<String, dynamic>> _tarifs = [
    {
      'id': 1,
      'route': 'Yaoundé → Douala',
      'category': 'Standard',
      'price': 15000,
      'duration': '4h30',
      'lastUpdate': '2024-08-30'
    },
    {
      'id': 2,
      'route': 'Douala → Yaoundé',
      'category': 'Standard',
      'price': 15000,
      'duration': '4h30',
      'lastUpdate': '2024-08-30'
    },
    {
      'id': 3,
      'route': 'Yaoundé → Douala',
      'category': 'VIP',
      'price': 25000,
      'duration': '4h00',
      'lastUpdate': '2024-08-30'
    },
    {
      'id': 4,
      'route': 'Douala → Yaoundé',
      'category': 'VIP',
      'price': 25000,
      'duration': '4h00',
      'lastUpdate': '2024-08-30'
    },
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'name': 'Hassan Oulahe',
      'email': 'hassan@email.com',
      'phone': '+237 6XX XX XX XX',
      'status': 'actif',
      'joinDate': '2024-01-15',
      'totalTrips': 12,
      'totalSpent': 180000
    },
    {
      'id': 2,
      'name': 'Marie Ngono',
      'email': 'marie@email.com',
      'phone': '+237 6XX XX XX XX',
      'status': 'actif',
      'joinDate': '2024-02-20',
      'totalTrips': 8,
      'totalSpent': 120000
    },
    {
      'id': 3,
      'name': 'Jean Mbarga',
      'email': 'jean@email.com',
      'phone': '+237 6XX XX XX XX',
      'status': 'suspendu',
      'joinDate': '2024-03-10',
      'totalTrips': 3,
      'totalSpent': 45000
    },
    {
      'id': 4,
      'name': 'Fatima Bello',
      'email': 'fatima@email.com',
      'phone': '+237 6XX XX XX XX',
      'status': 'actif',
      'joinDate': '2024-04-05',
      'totalTrips': 6,
      'totalSpent': 90000
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: Colors.white,
            child: Column(
              children: [
                // Header du sidebar
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_bus, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Voyage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Admin Panel',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(8),
                    children: [
                      _buildMenuItem(0, Icons.dashboard, 'Tableau de Bord'),
                      _buildMenuItem(1, Icons.calendar_today, 'Réservations'),
                      _buildMenuItem(2, Icons.attach_money, 'Tarifs'),
                      _buildMenuItem(3, Icons.people, 'Utilisateurs'),
                      _buildMenuItem(4, Icons.settings, 'Paramètres'),
                    ],
                  ),
                ),

                // Admin info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[600],
                        child: Text('AD', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin User',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Administrateur',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getPageTitle(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Stack(
                          children: [
                            Icon(Icons.notifications, color: Colors.grey[600]),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue[600] : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue[600] : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Tableau de Bord';
      case 1: return 'Gestion des Réservations';
      case 2: return 'Gestion des Tarifs';
      case 3: return 'Gestion des Utilisateurs';
      case 4: return 'Paramètres';
      default: return 'Global Voyage Admin';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildReservations();
      case 2: return _buildTarifs();
      case 3: return _buildUsers();
      case 4: return _buildSettings();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: _stats.map((stat) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: _stats.indexOf(stat) < _stats.length - 1 ? 16 : 0),
                child: _buildStatCard(stat),
              ),
            )).toList(),
          ),

          SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                // Recent reservations
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Réservations Récentes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selectedIndex = 1),
                              child: Text('Voir tout'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              var reservation = _reservations[index];
                              return _buildReservationCard(reservation, isCompact: true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Quick actions
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions Rapides',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _buildQuickAction(
                                'Nouvelle Réservation',
                                Icons.add_circle,
                                Colors.blue,
                                    () => setState(() => _selectedIndex = 1),
                              ),
                              SizedBox(height: 12),
                              _buildQuickAction(
                                'Modifier Tarifs',
                                Icons.edit,
                                Colors.green,
                                    () => setState(() => _selectedIndex = 2),
                              ),
                              SizedBox(height: 12),
                              _buildQuickAction(
                                'Gérer Utilisateurs',
                                Icons.people,
                                Colors.purple,
                                    () => setState(() => _selectedIndex = 3),
                              ),
                              SizedBox(height: 12),
                              _buildQuickAction(
                                'Remboursements',
                                Icons.refresh,
                                Colors.orange,
                                    () => _showRefundDialog(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 24,
                ),
              ),
              Text(
                stat['change'],
                style: TextStyle(
                  color: stat['change'].startsWith('+') ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            stat['value'],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            stat['title'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReservations() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Filters
          Row(
            children: [
              Container(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedRoute,
                  decoration: InputDecoration(
                    labelText: 'Route',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Tous', 'Yaoundé → Douala', 'Douala → Yaoundé'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRoute = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Tous', 'confirmé', 'en attente', 'annulé'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddReservationDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouvelle Réservation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Reservations list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  var reservation = _reservations[index];
                  if (_selectedRoute != 'Tous' && reservation['route'] != _selectedRoute) {
                    return SizedBox.shrink();
                  }
                  if (_selectedStatus != 'Tous' && reservation['status'] != _selectedStatus) {
                    return SizedBox.shrink();
                  }
                  return _buildReservationCard(reservation);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation, {bool isCompact = false}) {
    Color statusColor = _getStatusColor(reservation['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation['id'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      reservation['user'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reservation['status'].toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.route, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text(
                reservation['route'],
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              SizedBox(width: 16),
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text(
                '${reservation['date']} ${reservation['time']}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${reservation['price'].toString()} FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[600],
                ),
              ),
              if (!isCompact)
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showReservationDetails(reservation),
                      icon: Icon(Icons.visibility, color: Colors.blue[600], size: 20),
                      tooltip: 'Voir détails',
                    ),
                    IconButton(
                      onPressed: () => _showEditReservationDialog(reservation),
                      icon: Icon(Icons.edit, color: Colors.green[600], size: 20),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      onPressed: () => _showCancelDialog(reservation),
                      icon: Icon(Icons.cancel, color: Colors.red[600], size: 20),
                      tooltip: 'Annuler',
                    ),
                    IconButton(
                      onPressed: () => _showRefundDialog(reservation),
                      icon: Icon(Icons.refresh, color: Colors.orange[600], size: 20),
                      tooltip: 'Rembourser',
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarifs() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des Tarifs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTarifDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouveau Tarif'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _tarifs.length,
              itemBuilder: (context, index) {
                return _buildTarifCard(_tarifs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarifCard(Map<String, dynamic> tarif) {
    bool isVIP = tarif['category'] == 'VIP';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVIP ? Colors.purple[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tarif['category'],
                  style: TextStyle(
                    color: isVIP ? Colors.purple[600] : Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.green[600]),
                      title: Text('Modifier'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    value: 'edit',
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red[600]),
                      title: Text('Supprimer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    value: 'delete',
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTarifDialog(tarif);
                  } else if (value == 'delete') {
                    _showDeleteTarifDialog(tarif);
                  }
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            tarif['route'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            '${tarif['price'].toString()} FCFA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isVIP ? Colors.purple[600] : Colors.blue[600],
            ),
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text(
                'Durée: ${tarif['duration']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),

          Spacer(),

          Text(
            'Mis à jour: ${tarif['lastUpdate']}',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des Utilisateurs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouvel Utilisateur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 60,
                  dataRowHeight: 70,
                  columnSpacing: 20,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  columns: [
                    DataColumn(label: Text('Utilisateur')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Voyages')),
                    DataColumn(label: Text('Dépenses')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _users.map((user) {
                    bool isActive = user['status'] == 'actif';
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue[600],
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user['name'],
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    user['email'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(user['phone'])),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user['status'].toUpperCase(),
                              style: TextStyle(
                                color: isActive ? Colors.green[600] : Colors.red[600],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            user['totalTrips'].toString(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${user['totalSpent'].toString()} FCFA',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showUserDetails(user),
                                icon: Icon(Icons.visibility, color: Colors.blue[600], size: 18),
                                tooltip: 'Voir profil',
                              ),
                              IconButton(
                                onPressed: () => _showEditUserDialog(user),
                                icon: Icon(Icons.edit, color: Colors.green[600], size: 18),
                                tooltip: 'Modifier',
                              ),
                              IconButton(
                                onPressed: () => _toggleUserStatus(user),
                                icon: Icon(
                                  isActive ? Icons.block : Icons.check_circle,
                                  color: isActive ? Colors.red[600] : Colors.green[600],
                                  size: 18,
                                ),
                                tooltip: isActive ? 'Suspendre' : 'Activer',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres du Système',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 24),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildSettingCard(
                  'Configuration Routes',
                  'Gérer les destinations et horaires',
                  Icons.route,
                  Colors.blue,
                      () {},
                ),
                _buildSettingCard(
                  'Notifications',
                  'Paramètres des alertes système',
                  Icons.notifications,
                  Colors.orange,
                      () {},
                ),
                _buildSettingCard(
                  'Paiements',
                  'Configuration des moyens de paiement',
                  Icons.payment,
                  Colors.green,
                      () {},
                ),
                _buildSettingCard(
                  'Rapports',
                  'Génération de rapports automatiques',
                  Icons.analytics,
                  Colors.purple,
                      () {},
                ),
                _buildSettingCard(
                  'Sauvegarde',
                  'Backup et restauration des données',
                  Icons.backup,
                  Colors.teal,
                      () {},
                ),
                _buildSettingCard(
                  'Sécurité',
                  'Gestion des accès et permissions',
                  Icons.security,
                  Colors.red,
                      () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmé': return Colors.green;
      case 'en attente': return Colors.orange;
      case 'annulé': return Colors.red;
      default: return Colors.grey;
    }
  }

  // Dialog methods
  void _showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Réservation'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom du client',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
                items: ['Yaoundé → Douala', 'Douala → Yaoundé'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date de voyage',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la Réservation'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', reservation['id']),
              _buildDetailRow('Client', reservation['user']),
              _buildDetailRow('Téléphone', reservation['phone']),
              _buildDetailRow('Route', reservation['route']),
              _buildDetailRow('Date', reservation['date']),
              _buildDetailRow('Heure', reservation['time']),
              _buildDetailRow('Prix', '${reservation['price']} FCFA'),
              _buildDetailRow('Statut', reservation['status']),
              _buildDetailRow('Paiement', reservation['payment']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditReservationDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier la Réservation'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom du client',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: reservation['user']),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                value: reservation['status'],
                items: ['confirmé', 'en attente', 'annulé'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'Annulation'),
        content: Text('Êtes-vous sûr de vouloir annuler la réservation ${reservation['id']} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                reservation['status'] = 'annulé';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Oui, Annuler'),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog([Map<String, dynamic>? reservation]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Traitement du Remboursement'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reservation != null) ...[
                Text('Réservation: ${reservation['id']}'),
                Text('Client: ${reservation['user']}'),
                Text('Montant: ${reservation['price']} FCFA'),
                SizedBox(height: 16),
              ],
              TextField(
                decoration: InputDecoration(
                  labelText: 'Motif du remboursement',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reservation != null) {
                setState(() {
                  reservation['payment'] = 'remboursé';
                  reservation['status'] = 'annulé';
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Confirmer Remboursement'),
          ),
        ],
      ),
    );
  }

  void _showAddTarifDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau Tarif'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
                items: ['Yaoundé → Douala', 'Douala → Yaoundé'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: ['Standard', 'VIP'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Prix (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditTarifDialog(Map<String, dynamic> tarif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le Tarif'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: tarif['route']),
                enabled: false,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: tarif['category']),
                enabled: false,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Prix (FCFA)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: tarif['price'].toString()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTarifDialog(Map<String, dynamic> tarif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le Tarif'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce tarif ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tarifs.remove(tarif);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvel Utilisateur'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profil Utilisateur'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nom', user['name']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Téléphone', user['phone']),
              _buildDetailRow('Statut', user['status']),
              _buildDetailRow('Inscription', user['joinDate']),
              _buildDetailRow('Voyages totaux', user['totalTrips'].toString()),
              _buildDetailRow('Dépenses totales', '${user['totalSpent']} FCFA'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier l\'Utilisateur'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user['name']),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user['email']),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user['phone']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le Statut'),
        content: Text(
            user['status'] == 'actif'
                ? 'Suspendre l\'utilisateur ${user['name']} ?'
                : 'Activer l\'utilisateur ${user['name']} ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['status'] = user['status'] == 'actif' ? 'suspendu' : 'actif';
              });
              Navigator.pop(context);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}