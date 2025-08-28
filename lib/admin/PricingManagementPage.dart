import 'package:flutter/material.dart';

class PricingManagementPage extends StatefulWidget {
  const PricingManagementPage({super.key});

  @override
  State<PricingManagementPage> createState() => _PricingManagementPageState();
}

class _PricingManagementPageState extends State<PricingManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous'; // Correction: supprimé final
  bool _isAddingPrice = false;

  // Controllers pour le formulaire d'ajout
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _seasonalPriceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String _selectedCategory = 'Classique';

  // Données simulées des tarifs pour les bus
  List<Map<String, dynamic>> _prices = [
    {
      'id': 'BUS001',
      'origin': 'Yaoundé',
      'destination': 'Douala',
      'type': 'Bus',
      'category': 'VIP',
      'basePrice': 5000.0,
      'seasonalPrice': 6000.0,
      'currency': 'FCFA',
      'duration': '3h30',

    },
    {
      'id': 'BUS002',
      'origin': 'Douala',
      'destination': 'Yaoundé',
      'type': 'Bus',
      'category': 'Classique',
      'basePrice': 3500.0,
      'seasonalPrice': 4200.0,
      'currency': 'FCFA',
      'duration': '4h00',

    },
  ];

  final List<String> _filters = ['Tous', 'VIP', 'Classique'];
  final List<String> _categories = ['Classique', 'VIP'];
  final List<String> _cameroonCities = ['Yaoundé', 'Douala', 'Bamenda', 'Garoua', 'Bafoussam', 'Ngaoundéré'];

  @override
  void dispose() {
    _searchController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _basePriceController.dispose();
    _seasonalPriceController.dispose();
    _durationController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPrices {
    List<Map<String, dynamic>> filtered = _prices;

    // Filtrer par catégorie
    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((price) => price['category'] == _selectedFilter).toList();
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((price) =>
      price['origin'].toLowerCase().contains(searchTerm) ||
          price['destination'].toLowerCase().contains(searchTerm) ||
          price['id'].toLowerCase().contains(searchTerm) ||
          price['company'].toLowerCase().contains(searchTerm)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildFiltersBar(),
          Expanded(
            child: _isAddingPrice ? _buildAddPriceForm() : _buildPricesList(),
          ),
        ],
      ),
      floatingActionButton: !_isAddingPrice
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isAddingPrice = true;
          });
        },
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter Tarif',
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
        'Gestion des Tarifs Bus',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download, color: Colors.grey.shade600),
          onPressed: _exportPrices,
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
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
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
                    'EasyBus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_prices.length} tarifs configurés',
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
                  Icons.directions_bus,
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
              hintText: 'Rechercher par ville, compagnie ou ID...',
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
                      selectedColor: Colors.green.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
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

  Widget _buildPricesList() {
    final filteredPrices = _filteredPrices;

    if (filteredPrices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun tarif trouvé',
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
      itemCount: filteredPrices.length,
      itemBuilder: (context, index) {
        final price = filteredPrices[index];
        return _buildPriceCard(price);
      },
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> price) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${price['origin']} → ${price['destination']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price['company'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: price['category'] == 'VIP'
                        ? Colors.purple.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    price['category'],
                    style: TextStyle(
                      color: price['category'] == 'VIP'
                          ? Colors.purple.shade700
                          : Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Tarif Normal',
                    '${price['basePrice'].toStringAsFixed(0)} ${price['currency']}',
                    Icons.money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Tarif Saisonnier',
                    '${price['seasonalPrice'].toStringAsFixed(0)} ${price['currency']}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Durée',
                    price['duration'],
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Statut',
                    price['status'],
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${price['id']}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      onPressed: () => _editPrice(price),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      onPressed: () => _deletePrice(price['id']),
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
        Column(
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
      ],
    );
  }

  Widget _buildAddPriceForm() {
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
                    Icons.add_circle,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ajouter un nouveau tarif',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormField(
                controller: _originController,
                label: 'Ville de départ',
                icon: Icons.my_location,
                isDropdown: true,
                dropdownItems: _cameroonCities,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _destinationController,
                label: 'Ville d\'arrivée',
                icon: Icons.location_on,
                isDropdown: true,
                dropdownItems: _cameroonCities,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _basePriceController,
                      label: 'Tarif normal (FCFA)',
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _seasonalPriceController,
                      label: 'Tarif saisonnier (FCFA)',
                      icon: Icons.trending_up,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _durationController,
                      label: 'Durée du trajet',
                      icon: Icons.access_time,
                      hint: 'Ex: 3h30',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catégorie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _companyController,
                label: 'Compagnie de transport',
                icon: Icons.business,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isAddingPrice = false;
                        });
                        _clearForm();
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
                      onPressed: _savePrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Enregistrer'),
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
    bool isDropdown = false,
    List<String>? dropdownItems,
  }) {
    if (isDropdown && dropdownItems != null) {
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Sélectionner $label',
            ),
            items: dropdownItems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              controller.text = value!;
            },
          ),
        ],
      );
    }

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

  void _clearForm() {
    _originController.clear();
    _destinationController.clear();
    _basePriceController.clear();
    _seasonalPriceController.clear();
    _durationController.clear();
    _companyController.clear();
    _selectedCategory = 'Classique';
  }

  void _savePrice() {
    if (_originController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _basePriceController.text.isEmpty ||
        _seasonalPriceController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPrice = {
      'id': 'BUS${(_prices.length + 1).toString().padLeft(3, '0')}',
      'origin': _originController.text,
      'destination': _destinationController.text,
      'type': 'Bus',
      'category': _selectedCategory,
      'basePrice': double.parse(_basePriceController.text),
      'seasonalPrice': double.parse(_seasonalPriceController.text),
      'currency': 'FCFA',
      'duration': _durationController.text,
      'validFrom': DateTime.now(),
      'validTo': DateTime(2025, 12, 31),
      'lastUpdated': DateTime.now(),
      'status': 'Actif',
      'company': _companyController.text,
    };

    setState(() {
      _prices.add(newPrice);
      _isAddingPrice = false;
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarif ajouté avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPrice(Map<String, dynamic> price) {
    // Implémentation de l'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'édition en cours de développement'),
      ),
    );
  }

  void _deletePrice(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce tarif ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _prices.removeWhere((price) => price['id'] == id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarif supprimé avec succès'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportPrices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export des tarifs en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualiser'),
              onTap: () {
                Navigator.pop(context);
                setState(() {});
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
}