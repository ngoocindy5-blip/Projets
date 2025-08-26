import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text('1', style: TextStyle(color: Colors.black)),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  child: Text('2', style: TextStyle(color: Colors.grey)),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  child: Text('3', style: TextStyle(color: Colors.grey)),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'CHOOSE PAYMENT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                print('Orange Money selected');
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('Orange Money', style: TextStyle(fontSize: 18, color: Colors.black)),
                      ],
                    ),
                    Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                print('MTN MoMo selected');
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.green),
                        SizedBox(width: 10),
                        Text('MTN MoMo', style: TextStyle(fontSize: 18, color: Colors.black)),
                      ],
                    ),
                    Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow[700],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Confirm Payment', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

// Page de succès de paiement (exemple simple)
class PaymentSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.yellow[700]),
            SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Your booking is confirmed',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'We\'ve sent booking details via email. Bring your',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'excitement and we\'ll handle the rest!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow[700],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Back to Home', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}