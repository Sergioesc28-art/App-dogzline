import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFE6DD), // Beige
      appBar: AppBar(
        backgroundColor: Color(0xFF8B6F47), // Café bajo
        title: Text(
          'Dogzlime',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Asciende a Premium y descubre quién ya te dio Like',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.brown),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 60, color: Colors.brown.shade600),
                  SizedBox(height: 10),
                  Text('24', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                  Text('Relación', style: TextStyle(fontSize: 16, color: Colors.brown.shade400)),
                ],
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B6F47), // Café bajo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(
                'Descubre a quién le gustas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEFE6DD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}