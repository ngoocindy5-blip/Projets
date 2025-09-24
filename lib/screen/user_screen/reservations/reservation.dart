import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String trajet;
  final String classe;
  final int places;
  final DateTime date;

  const PaymentPage({
    super.key,
    required this.trajet,
    required this.classe,
    required this.places,
    required this.date,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = 'Orange Money';

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mode de Paiement — Global Voyage",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 28 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Résumé réservation
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Résumé de la réservation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _infoRow(Icons.location_on, 'Trajet', widget.trajet),
                    const SizedBox(height: 8),
                    _infoRow(Icons.calendar_today, 'Date', _formatDate(widget.date)),
                    const SizedBox(height: 8),
                    _infoRow(Icons.chair, 'Classe', widget.classe),
                    const SizedBox(height: 8),
                    _infoRow(Icons.people, 'Nombre de places', widget.places.toString()),
                  ]),
                ),
              ),

              const SizedBox(height: 8),

              const Text('Choisissez votre mode de paiement :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Option : Orange Money
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: RadioListTile<String>(
                  value: 'Orange Money',
                  groupValue: _selectedPayment,
                  activeColor: Colors.orange,
                  title: Row(children: [
                    // si tu as le logo en asset, remplace Icon par Image.asset(...)
                    const Icon(Icons.account_balance_wallet, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Text('Orange Money', style: TextStyle(fontSize: 16)),
                  ]),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),
              ),
              const SizedBox(height: 10),

              // Option : MTN MoMo
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: RadioListTile<String>(
                  value: 'MTN MoMo',
                  groupValue: _selectedPayment,
                  activeColor: Colors.yellow[800],
                  title: Row(children: [
                    const Icon(Icons.mobile_friendly, color: Colors.yellow),
                    const SizedBox(width: 12),
                    const Text('MTN MoMo', style: TextStyle(fontSize: 16)),
                  ]),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Payer mon ticket', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Ici on envoie la réservation + mode de paiement vers la page correspondante.
                    final args = {
                      'trajet': widget.trajet,
                      'classe': widget.classe,
                      'places': widget.places,
                      'date': widget.date.toIso8601String(),
                      'payment': _selectedPayment,
                    };

                    if (_selectedPayment == 'Orange Money') {
                      Navigator.pushNamed(context, '/om', arguments: args);
                    } else if (_selectedPayment == 'MTN MoMo') {
                      Navigator.pushNamed(context, '/momo', arguments: args);
                    } else {
                      // fallback: snack
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode de paiement non pris en charge.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
      ],
    );
  }
}
