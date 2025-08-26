import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for item...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(Icons.clear),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent search',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Watermelon')),
                    Chip(label: Text('Chicken drumsticks')),
                    Chip(label: Text('Chicken fillets')),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Popular Search',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    ListTile(
                      leading: Image.network('https://via.placeholder.com/40'),
                      title: Text('Mango'),
                      subtitle: Text('\$10/kg  4.8/5.0 (200 reviews)'),
                      trailing: Icon(Icons.circle, size: 12, color: Colors.green),
                    ),
                    ListTile(
                      leading: Image.network('https://via.placeholder.com/40'),
                      title: Text('Orange'),
                      subtitle: Text('\$10/kg  4.8/5.0 (200 reviews)'),
                      trailing: Icon(Icons.circle, size: 12, color: Colors.green),
                    ),
                    ListTile(
                      leading: Image.network('https://via.placeholder.com/40'),
                      title: Text('Pineapple'),
                      subtitle: Text('\$10/kg  4.8/5.0 (200 reviews)'),
                      trailing: Icon(Icons.circle, size: 12, color: Colors.green),
                    ),
                    ListTile(
                      leading: Image.network('https://via.placeholder.com/40'),
                      title: Text('Bananas'),
                      subtitle: Text('\$10/kg  4.8/5.0 (200 reviews)'),
                      trailing: Icon(Icons.circle, size: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green,
      ),
    );
  }
}