import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = "Orange Money";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Mode de Paiement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choisissez votre mode de paiement :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Option 1 : Orange Money
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: RadioListTile<String>(
                  value: "Orange Money",
                  groupValue: _selectedPayment,
                  activeColor: Colors.orange,
                  title: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Colors.orange),
                      const SizedBox(width: 10),
                      const Text(
                        "Orange Money",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPayment = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Option 2 : MTN MoMo
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: RadioListTile<String>(
                  value: "MTN MoMo",
                  groupValue: _selectedPayment,
                  activeColor: Colors.yellow[800],
                  title: Row(
                    children: [
                      Icon(Icons.mobile_friendly, color: Colors.yellow[800]),
                      const SizedBox(width: 10),
                      const Text(
                        "MTN MoMo",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPayment = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Bouton Payer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Étape suivante : redirection vers la page correspondante
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Vous avez choisi : $_selectedPayment (redirection à faire)"),
                      ),
                    );

                    // TODO: Naviguer vers la page de paiement réelle
                    // if (_selectedPayment == "Orange Money") { ... }
                    // else if (_selectedPayment == "MTN MoMo") { ... }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 20 : 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Payer mon ticket",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
