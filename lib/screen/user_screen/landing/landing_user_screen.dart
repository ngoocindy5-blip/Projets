import 'package:flutter/material.dart';

import '../auth/login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const _blue = Color(0xFF2E7BFF);
  static const _bluedark = Color(0xFF2E7BFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    Image.asset("assets/img/Order ride-bro.png", fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    const Text(
                      'GLOBALE VOYAGES\ UN VOYAGE AU COEUR DU CONFORD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24, height: 1.25,
                        fontWeight: FontWeight.w800, color: Color(0xFF121417),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reservation de billet en ligne\n'
                          'suivit du trajet en temps reel\n'
                          'tout ça en un clic',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5, height: 1.45,
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_blue, _bluedark],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 28, offset: Offset(0, 10)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));

                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0, backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          child: const Text('Commencer'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18, bottom: 18 + MediaQuery.of(context).padding.bottom,
              child: Material(
                color: Colors.black87, shape: const CircleBorder(), elevation: 8,
                child: InkWell(
                  customBorder: const CircleBorder(), onTap: () {},
                  child: const SizedBox(width: 54, height: 54, child: Icon(Icons.autorenew, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
