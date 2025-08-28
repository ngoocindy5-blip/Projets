import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous'; // Corrigé : rendu mutable
  bool _isAddingUser = false;
  bool _isEditingUser = false;
  Map<String, dynamic>? _userToEdit;

  // Controllers pour le formulaire
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedGender = 'Masculin';
  String _selectedStatus = 'Actif';
  DateTime? _selectedBirthDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Données simulées des utilisateurs
  List<Map<String, dynamic>> _users = [
    {
      'id': 'USR001',
      'firstName': 'Jean',
      'lastName': 'Mbarga',
      'email': 'jean.mbarga@email.com',
      'phone': '+237 698 123 456',
      'gender': 'Masculin',
      'birthDate': DateTime(1990, 5, 15),
      'address': 'Bastos, Yaoundé',
      'city': 'Yaoundé',
      'status': 'Actif',
      'accountType': 'Premium',
      'registrationDate': DateTime(2024, 1, 15),
      'lastLogin': DateTime(2025, 8, 26, 14, 30),
      'totalTrips': 12,
      'totalSpent': 85000.0,
      'avatar': null,
    },
    {
      'id': 'USR002',
      'firstName': 'Marie',
      'lastName': 'Fotso',
      'email': 'marie.fotso@email.com',
      'phone': '+237 677 987 654',
      'gender': 'Féminin',
      'birthDate': DateTime(1988, 11, 22),
      'address': 'Akwa, Douala',
      'city': 'Douala',
      'status': 'Actif',
      'accountType': 'Standard',
      'registrationDate': DateTime(2024, 3, 10),
      'lastLogin': DateTime(2025, 8, 27, 10, 15),
      'totalTrips': 8,
      'totalSpent': 45000.0,
      'avatar': null,
    },
    {
      'id': 'USR003',
      'firstName': 'Paul',
      'lastName': 'Nkomo',
      'email': 'paul.nkomo@email.com',
      'phone': '+237 694 555 777',
      'gender': 'Masculin',
      'birthDate': DateTime(1995, 7, 8),
      'address': 'Commercial, Bamenda',
      'city': 'Bamenda',
      'status': 'Suspendu',
      'accountType': 'Standard',
      'registrationDate': DateTime(2024, 6, 5),
      'lastLogin': DateTime(2025, 8, 20, 16, 45),
      'totalTrips': 3,
      'totalSpent': 18000.0,
      'avatar': null,
    },
  ];

  final List<String> _filters = ['Tous', 'Actif', 'Suspendu', 'Premium', 'Standard'];
  final List<String> _genders = ['Masculin', 'Féminin'];
  final List<String> _statuses = ['Actif', 'Suspendu', 'Inactif'];
  final List<String> _accountTypes = ['Standard', 'Premium'];
  final List<String> _cameroonCities = [
    'Yaoundé', 'Douala', 'Bamenda', 'Garoua', 'Bafoussam',
    'Ngaoundéré', 'Maroua', 'Bertoua', 'Kribi', 'Limbe'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> filtered = _users;

    // Filtrer par statut/type
    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((user) =>
      user['status'] == _selectedFilter ||
          user['accountType'] == _selectedFilter).toList();
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((user) =>
      user['firstName'].toLowerCase().contains(searchTerm) ||
          user['lastName'].toLowerCase().contains(searchTerm) ||
          user['email'].toLowerCase().contains(searchTerm) ||
          user['phone'].toLowerCase().contains(searchTerm) ||
          user['id'].toLowerCase().contains(searchTerm)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltersBar(),
            _buildStatsCards(),
            Expanded(
              child: _isAddingUser || _isEditingUser
                  ? _buildUserForm()
                  : _buildUsersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isAddingUser && !_isEditingUser
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isAddingUser = true;
          });
        },
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nouveau Client',
          style: TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Gestion des Comptes Clients',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download, color: Colors.grey.shade600),
          onPressed: _exportUsers,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: () => setState(() {}),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clients Plateforme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_users.length} comptes enregistrés',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, email, téléphone ou ID...',
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _selectedGender = 'Masculin';
    _selectedStatus = 'Actif';
    _selectedBirthDate = null;
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _isEditingUser = true;
      _userToEdit = user;
      _firstNameController.text = user['firstName'];
      _lastNameController.text = user['lastName'];
      _emailController.text = user['email'];
      _phoneController.text = user['phone'];
      _addressController.text = user['address'];
      _cityController.text = user['city'];
      _selectedGender = user['gender'];
      _selectedStatus = user['status'];
      _selectedBirthDate = user['birthDate'];
    });
  }

  void _saveUser() {
    // Validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation email
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un email valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation téléphone (format simple pour +237)
    if (!_phoneController.text.startsWith('+237') || _phoneController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro valide commençant par +237'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now(); // 09:16 AM WAT, 28/08/2025
    if (_isEditingUser && _userToEdit != null) {
      // Modifier l'utilisateur existant
      final index = _users.indexWhere((u) => u['id'] == _userToEdit!['id']);
      if (index != -1) {
        setState(() {
          _users[index] = {
            ..._users[index],
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'gender': _selectedGender,
            'birthDate': _selectedBirthDate!,
            'address': _addressController.text,
            'city': _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
            'status': _selectedStatus,
            'lastLogin': now,
          };
          _isEditingUser = false;
          _userToEdit = null;
        });

        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte client modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Créer un nouvel utilisateur
      final newUser = {
        'id': 'USR${(_users.length + 1).toString().padLeft(3, '0')}',
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'birthDate': _selectedBirthDate!,
        'address': _addressController.text,
        'city': _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
        'status': _selectedStatus,
        'accountType': 'Standard',
        'registrationDate': now,
        'lastLogin': now,
        'totalTrips': 0,
        'totalSpent': 0.0,
        'avatar': null,
      };

      setState(() {
        _users.add(newUser);
        _isAddingUser = false;
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau compte client créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteUser(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Confirmer la suppression'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement ce compte client ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((user) => user['id'] == id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte client supprimé avec succès'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'Actif' ? 'Suspendu' : 'Actif';
    final action = newStatus == 'Actif' ? 'réactiver' : 'suspendre';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmer l\'action'),
        content: Text(
          'Voulez-vous $action le compte de ${user['firstName']} ${user['lastName']} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _users.indexWhere((u) => u['id'] == user['id']);
                if (index != -1) {
                  _users[index]['status'] = newStatus;
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compte ${newStatus.toLowerCase()} avec succès'),
                  backgroundColor: newStatus == 'Actif' ? Colors.green : Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Actif' ? Colors.green.shade600 : Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(StringExtension(action).capitalize()),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: user['accountType'] == 'Premium'
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    child: Text(
                      '${user['firstName'][0]}${user['lastName'][0]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: user['accountType'] == 'Premium'
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user['firstName']} ${user['lastName']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('ID Client', user['id']),
              _buildDetailRow('Téléphone', user['phone']),
              _buildDetailRow('Genre', user['gender']),
              _buildDetailRow('Date de naissance',
                  '${user['birthDate'].day}/${user['birthDate'].month}/${user['birthDate'].year}'),
              _buildDetailRow('Adresse', user['address']),
              _buildDetailRow('Ville', user['city']),
              _buildDetailRow('Statut', user['status']),
              _buildDetailRow('Type de compte', user['accountType']),
              _buildDetailRow('Date d\'inscription',
                  '${user['registrationDate'].day}/${user['registrationDate'].month}/${user['registrationDate'].year}'),
              _buildDetailRow('Nombre de voyages', user['totalTrips'].toString()),
              _buildDetailRow('Total dépensé', '${user['totalSpent'].toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Dernière connexion', _formatLastLogin(user['lastLogin'])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editUser(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Modifier ce compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }

  void _exportUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exporter les données'),
        content: const Text('Choisissez le format d\'export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export Excel en cours...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Excel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export PDF en cours...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualiser la liste'),
              onTap: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistiques détaillées'),
              onTap: () {
                Navigator.pop(context);
                _showDetailedStats();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Envoyer notification groupée'),
              onTap: () {
                Navigator.pop(context);
                _sendGroupNotification();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedStats() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u['status'] == 'Actif').length;
    final premiumUsers = _users.where((u) => u['accountType'] == 'Premium').length;
    final totalRevenue = _users.fold<double>(0.0, (sum, user) => sum + user['totalSpent']);
    final totalTrips = _users.fold<int>(0, (sum, user) => sum + user['totalTrips'] as int);
    final avgSpentPerUser = totalUsers > 0 ? totalRevenue / totalUsers : 0.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Statistiques Détaillées',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatRow('Total utilisateurs', totalUsers.toString()),
              _buildStatRow('Utilisateurs actifs', '$activeUsers (${(activeUsers / totalUsers * 100).toStringAsFixed(1)}%)'),
              _buildStatRow('Comptes Premium', '$premiumUsers (${(premiumUsers / totalUsers * 100).toStringAsFixed(1)}%)'),
              _buildStatRow('Total des voyages', totalTrips.toString()),
              _buildStatRow('Revenus total', '${totalRevenue.toStringAsFixed(0)} FCFA'),
              _buildStatRow('Dépense moyenne/utilisateur', '${avgSpentPerUser.toStringAsFixed(0)} FCFA'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _sendGroupNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notification Groupée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envoyer une notification à:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Tous les utilisateurs'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Tous les utilisateurs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Utilisateurs actifs uniquement'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Utilisateurs actifs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Utilisateurs Premium uniquement'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Utilisateurs Premium');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSuccess(String target) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification envoyée à: $target'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Filtrer par:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeUsers = _users.where((user) => user['status'] == 'Actif').length;
    final premiumUsers = _users.where((user) => user['accountType'] == 'Premium').length;
    final totalRevenue = _users.fold<double>(0.0, (sum, user) => sum + user['totalSpent']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Utilisateurs Actifs',
              activeUsers.toString(),
              Icons.people,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Comptes Premium',
              premiumUsers.toString(),
              Icons.star,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenus Total',
              '${(totalRevenue / 1000).toStringAsFixed(0)}K',
              Icons.monetization_on,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final filteredUsers = _filteredUsers;

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres de recherche',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['status'] == 'Actif';
    final isPremium = user['accountType'] == 'Premium';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isPremium ? Colors.orange.shade100 : Colors.blue.shade100,
                  child: Text(
                    '${user['firstName'][0]}${user['lastName'][0]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.orange.shade700 : Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user['firstName']} ${user['lastName']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user['status'],
                              style: TextStyle(
                                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['phone'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Voyages',
                    user['totalTrips'].toString(),
                    Icons.directions_bus,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Dépenses',
                    '${user['totalSpent'].toStringAsFixed(0)} FCFA',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ville',
                    user['city'],
                    Icons.location_on,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Dernière connexion',
                    _formatLastLogin(user['lastLogin']),
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${user['id']}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      onPressed: () => _viewUserDetails(user),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      onPressed: () => _editUser(user),
                    ),
                    IconButton(
                      icon: Icon(
                        user['status'] == 'Actif' ? Icons.block : Icons.check_circle,
                        color: user['status'] == 'Actif' ? Colors.red.shade600 : Colors.green.shade600,
                        size: 20,
                      ),
                      onPressed: () => _toggleUserStatus(user),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      onPressed: () => _deleteUser(user['id']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isEditingUser ? Icons.edit : Icons.person_add,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditingUser ? 'Modifier le compte client' : 'Créer un nouveau compte client',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _lastNameController,
                      label: 'Nom de famille',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Genre',
                      value: _selectedGender,
                      items: _genders,
                      icon: Icons.wc,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Statut',
                      value: _selectedStatus,
                      items: _statuses,
                      icon: Icons.verified_user,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Ville',
                value: _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
                items: _cameroonCities,
                icon: Icons.location_city,
                onChanged: (value) {
                  setState(() {
                    _cityController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _clearForm();
                        setState(() {
                          _isAddingUser = false;
                          _isEditingUser = false;
                          _userToEdit = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_isEditingUser ? 'Modifier' : 'Enregistrer'),
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hint ?? 'Saisir $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _selectedBirthDate != null ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();

class _UserManagementPage extends State<UserManagementPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous'; // Corrigé : rendu mutable
  bool _isAddingUser = false;
  bool _isEditingUser = false;
  Map<String, dynamic>? _userToEdit;

  // Controllers pour le formulaire
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedGender = 'Masculin';
  String _selectedStatus = 'Actif';
  DateTime? _selectedBirthDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Données simulées des utilisateurs
  List<Map<String, dynamic>> _users = [
    {
      'id': 'USR001',
      'firstName': 'Jean',
      'lastName': 'Mbarga',
      'email': 'jean.mbarga@email.com',
      'phone': '+237 698 123 456',
      'gender': 'Masculin',
      'birthDate': DateTime(1990, 5, 15),
      'address': 'Bastos, Yaoundé',
      'city': 'Yaoundé',
      'status': 'Actif',
      'accountType': 'Premium',
      'registrationDate': DateTime(2024, 1, 15),
      'lastLogin': DateTime(2025, 8, 26, 14, 30),
      'totalTrips': 12,
      'totalSpent': 85000.0,
      'avatar': null,
    },
    {
      'id': 'USR002',
      'firstName': 'Marie',
      'lastName': 'Fotso',
      'email': 'marie.fotso@email.com',
      'phone': '+237 677 987 654',
      'gender': 'Féminin',
      'birthDate': DateTime(1988, 11, 22),
      'address': 'Akwa, Douala',
      'city': 'Douala',
      'status': 'Actif',
      'accountType': 'Standard',
      'registrationDate': DateTime(2024, 3, 10),
      'lastLogin': DateTime(2025, 8, 27, 10, 15),
      'totalTrips': 8,
      'totalSpent': 45000.0,
      'avatar': null,
    },
    {
      'id': 'USR003',
      'firstName': 'Paul',
      'lastName': 'Nkomo',
      'email': 'paul.nkomo@email.com',
      'phone': '+237 694 555 777',
      'gender': 'Masculin',
      'birthDate': DateTime(1995, 7, 8),
      'address': 'Commercial, Bamenda',
      'city': 'Bamenda',
      'status': 'Suspendu',
      'accountType': 'Standard',
      'registrationDate': DateTime(2024, 6, 5),
      'lastLogin': DateTime(2025, 8, 20, 16, 45),
      'totalTrips': 3,
      'totalSpent': 18000.0,
      'avatar': null,
    },
  ];

  final List<String> _filters = ['Tous', 'Actif', 'Suspendu', 'Premium', 'Standard'];
  final List<String> _genders = ['Masculin', 'Féminin'];
  final List<String> _statuses = ['Actif', 'Suspendu', 'Inactif'];
  final List<String> _accountTypes = ['Standard', 'Premium'];
  final List<String> _cameroonCities = [
    'Yaoundé', 'Douala', 'Bamenda', 'Garoua', 'Bafoussam',
    'Ngaoundéré', 'Maroua', 'Bertoua', 'Kribi', 'Limbe'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> filtered = _users;

    // Filtrer par statut/type
    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((user) =>
      user['status'] == _selectedFilter ||
          user['accountType'] == _selectedFilter).toList();
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((user) =>
      user['firstName'].toLowerCase().contains(searchTerm) ||
          user['lastName'].toLowerCase().contains(searchTerm) ||
          user['email'].toLowerCase().contains(searchTerm) ||
          user['phone'].toLowerCase().contains(searchTerm) ||
          user['id'].toLowerCase().contains(searchTerm)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltersBar(),
            _buildStatsCards(),
            Expanded(
              child: _isAddingUser || _isEditingUser
                  ? _buildUserForm()
                  : _buildUsersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isAddingUser && !_isEditingUser
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isAddingUser = true;
          });
        },
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nouveau Client',
          style: TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Gestion des Comptes Clients',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download, color: Colors.grey.shade600),
          onPressed: _exportUsers,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: () => setState(() {}),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clients Plateforme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_users.length} comptes enregistrés',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, email, téléphone ou ID...',
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _selectedGender = 'Masculin';
    _selectedStatus = 'Actif';
    _selectedBirthDate = null;
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _isEditingUser = true;
      _userToEdit = user;
      _firstNameController.text = user['firstName'];
      _lastNameController.text = user['lastName'];
      _emailController.text = user['email'];
      _phoneController.text = user['phone'];
      _addressController.text = user['address'];
      _cityController.text = user['city'];
      _selectedGender = user['gender'];
      _selectedStatus = user['status'];
      _selectedBirthDate = user['birthDate'];
    });
  }

  void _saveUser() {
    // Validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation email
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un email valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation téléphone (format simple pour +237)
    if (!_phoneController.text.startsWith('+237') || _phoneController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro valide commençant par +237'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now(); // 09:16 AM WAT, 28/08/2025
    if (_isEditingUser && _userToEdit != null) {
      // Modifier l'utilisateur existant
      final index = _users.indexWhere((u) => u['id'] == _userToEdit!['id']);
      if (index != -1) {
        setState(() {
          _users[index] = {
            ..._users[index],
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'gender': _selectedGender,
            'birthDate': _selectedBirthDate!,
            'address': _addressController.text,
            'city': _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
            'status': _selectedStatus,
            'lastLogin': now,
          };
          _isEditingUser = false;
          _userToEdit = null;
        });

        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte client modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Créer un nouvel utilisateur
      final newUser = {
        'id': 'USR${(_users.length + 1).toString().padLeft(3, '0')}',
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'birthDate': _selectedBirthDate!,
        'address': _addressController.text,
        'city': _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
        'status': _selectedStatus,
        'accountType': 'Standard',
        'registrationDate': now,
        'lastLogin': now,
        'totalTrips': 0,
        'totalSpent': 0.0,
        'avatar': null,
      };

      setState(() {
        _users.add(newUser);
        _isAddingUser = false;
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau compte client créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteUser(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Confirmer la suppression'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement ce compte client ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((user) => user['id'] == id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte client supprimé avec succès'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'Actif' ? 'Suspendu' : 'Actif';
    final action = newStatus == 'Actif' ? 'réactiver' : 'suspendre';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmer l\'action'),
        content: Text(
          'Voulez-vous $action le compte de ${user['firstName']} ${user['lastName']} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _users.indexWhere((u) => u['id'] == user['id']);
                if (index != -1) {
                  _users[index]['status'] = newStatus;
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compte ${newStatus.toLowerCase()} avec succès'),
                  backgroundColor: newStatus == 'Actif' ? Colors.green : Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Actif' ? Colors.green.shade600 : Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(StringExtension(action).capitalize()),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: user['accountType'] == 'Premium'
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    child: Text(
                      '${user['firstName'][0]}${user['lastName'][0]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: user['accountType'] == 'Premium'
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user['firstName']} ${user['lastName']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('ID Client', user['id']),
              _buildDetailRow('Téléphone', user['phone']),
              _buildDetailRow('Genre', user['gender']),
              _buildDetailRow('Date de naissance',
                  '${user['birthDate'].day}/${user['birthDate'].month}/${user['birthDate'].year}'),
              _buildDetailRow('Adresse', user['address']),
              _buildDetailRow('Ville', user['city']),
              _buildDetailRow('Statut', user['status']),
              _buildDetailRow('Type de compte', user['accountType']),
              _buildDetailRow('Date d\'inscription',
                  '${user['registrationDate'].day}/${user['registrationDate'].month}/${user['registrationDate'].year}'),
              _buildDetailRow('Nombre de voyages', user['totalTrips'].toString()),
              _buildDetailRow('Total dépensé', '${user['totalSpent'].toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Dernière connexion', _formatLastLogin(user['lastLogin'])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editUser(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Modifier ce compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }

  void _exportUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exporter les données'),
        content: const Text('Choisissez le format d\'export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export Excel en cours...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Excel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export PDF en cours...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualiser la liste'),
              onTap: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistiques détaillées'),
              onTap: () {
                Navigator.pop(context);
                _showDetailedStats();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Envoyer notification groupée'),
              onTap: () {
                Navigator.pop(context);
                _sendGroupNotification();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedStats() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u['status'] == 'Actif').length;
    final premiumUsers = _users.where((u) => u['accountType'] == 'Premium').length;
    final totalRevenue = _users.fold<double>(0.0, (sum, user) => sum + user['totalSpent']);
    final totalTrips = _users.fold<int>(0, (sum, user) => sum + user['totalTrips'] as int);
    final avgSpentPerUser = totalUsers > 0 ? totalRevenue / totalUsers : 0.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Statistiques Détaillées',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatRow('Total utilisateurs', totalUsers.toString()),
              _buildStatRow('Utilisateurs actifs', '$activeUsers (${(activeUsers / totalUsers * 100).toStringAsFixed(1)}%)'),
              _buildStatRow('Comptes Premium', '$premiumUsers (${(premiumUsers / totalUsers * 100).toStringAsFixed(1)}%)'),
              _buildStatRow('Total des voyages', totalTrips.toString()),
              _buildStatRow('Revenus total', '${totalRevenue.toStringAsFixed(0)} FCFA'),
              _buildStatRow('Dépense moyenne/utilisateur', '${avgSpentPerUser.toStringAsFixed(0)} FCFA'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _sendGroupNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notification Groupée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envoyer une notification à:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Tous les utilisateurs'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Tous les utilisateurs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Utilisateurs actifs uniquement'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Utilisateurs actifs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Utilisateurs Premium uniquement'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationSuccess('Utilisateurs Premium');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSuccess(String target) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification envoyée à: $target'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Filtrer par:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeUsers = _users.where((user) => user['status'] == 'Actif').length;
    final premiumUsers = _users.where((user) => user['accountType'] == 'Premium').length;
    final totalRevenue = _users.fold<double>(0.0, (sum, user) => sum + user['totalSpent']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Utilisateurs Actifs',
              activeUsers.toString(),
              Icons.people,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Comptes Premium',
              premiumUsers.toString(),
              Icons.star,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenus Total',
              '${(totalRevenue / 1000).toStringAsFixed(0)}K',
              Icons.monetization_on,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final filteredUsers = _filteredUsers;

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres de recherche',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['status'] == 'Actif';
    final isPremium = user['accountType'] == 'Premium';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isPremium ? Colors.orange.shade100 : Colors.blue.shade100,
                  child: Text(
                    '${user['firstName'][0]}${user['lastName'][0]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.orange.shade700 : Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user['firstName']} ${user['lastName']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user['status'],
                              style: TextStyle(
                                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['phone'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Voyages',
                    user['totalTrips'].toString(),
                    Icons.directions_bus,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Dépenses',
                    '${user['totalSpent'].toStringAsFixed(0)} FCFA',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ville',
                    user['city'],
                    Icons.location_on,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Dernière connexion',
                    _formatLastLogin(user['lastLogin']),
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${user['id']}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      onPressed: () => _viewUserDetails(user),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      onPressed: () => _editUser(user),
                    ),
                    IconButton(
                      icon: Icon(
                        user['status'] == 'Actif' ? Icons.block : Icons.check_circle,
                        color: user['status'] == 'Actif' ? Colors.red.shade600 : Colors.green.shade600,
                        size: 20,
                      ),
                      onPressed: () => _toggleUserStatus(user),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      onPressed: () => _deleteUser(user['id']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isEditingUser ? Icons.edit : Icons.person_add,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditingUser ? 'Modifier le compte client' : 'Créer un nouveau compte client',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _lastNameController,
                      label: 'Nom de famille',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Genre',
                      value: _selectedGender,
                      items: _genders,
                      icon: Icons.wc,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Statut',
                      value: _selectedStatus,
                      items: _statuses,
                      icon: Icons.verified_user,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Ville',
                value: _cityController.text.isEmpty ? _cameroonCities[0] : _cityController.text,
                items: _cameroonCities,
                icon: Icons.location_city,
                onChanged: (value) {
                  setState(() {
                    _cityController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _clearForm();
                        setState(() {
                          _isAddingUser = false;
                          _isEditingUser = false;
                          _userToEdit = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_isEditingUser ? 'Modifier' : 'Enregistrer'),
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hint ?? 'Saisir $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _selectedBirthDate != null ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

