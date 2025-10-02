import 'package:flutter/material.dart';
import 'payment_page.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedTrajet = 'Yaoundé';
  String _selectedClasse = 'VIP';
  int _nombrePlaces = 1;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Bleu très clair
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.directions_bus,
                                      color: Colors.blue,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Global Voyage",
                                    style: TextStyle(
                                      fontSize: isTablet ? 32 : 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Où souhaitez-vous voyager ?",
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // FORMULAIRE
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Trajet
                                DropdownButtonFormField<String>(
                                  value: _selectedTrajet,
                                  decoration: _inputDecoration(
                                    "Sélectionnez votre trajet",
                                    Icons.location_on,
                                  ),
                                  items: ['Yaoundé', 'Douala']
                                      .map((trajet) => DropdownMenuItem(
                                    value: trajet,
                                    child: Text(trajet),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTrajet = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Date de départ
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                        "Date de départ", Icons.calendar_today),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedDate == null
                                              ? "Choisir une date"
                                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _selectedDate == null
                                                ? Colors.grey[500]
                                                : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Nombre de places
                                TextFormField(
                                  decoration: _inputDecoration(
                                      "Nombre de places", Icons.people),
                                  keyboardType: TextInputType.number,
                                  initialValue: _nombrePlaces.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _nombrePlaces = int.tryParse(value) ?? 1;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le nombre de places';
                                    }
                                    final number = int.tryParse(value);
                                    if (number == null || number < 1) {
                                      return 'Nombre de places invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Classe
                                DropdownButtonFormField<String>(
                                  value: _selectedClasse,
                                  decoration: _inputDecoration(
                                      "Classe", Icons.star),
                                  items: ['VIP', 'Classique']
                                      .map((classe) => DropdownMenuItem(
                                    value: classe,
                                    child: Row(
                                      children: [
                                        Icon(
                                          classe == 'VIP'
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: classe == 'VIP'
                                              ? Colors.amber
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(classe),
                                      ],
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClasse = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Bouton Payer
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Colors.blue, Color(0xFF1976D2)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate() &&
                                            _selectedDate != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PaymentPage(
                                              ),
                                            ),
                                          );
                                        } else if (_selectedDate == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Veuillez sélectionner une date de départ'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: isTablet ? 20 : 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.payment,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            "Procéder au paiement",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
