import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'payment.dart'; // Importa el PaymentPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DialogueScreen(),
    );
  }
}

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  _DialogueScreenState createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  String _selectedPlan = '';

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2DE), // Fondo beige
      appBar: AppBar(
        backgroundColor: Colors.white, // Banner blanco
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Dogzline',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800], // Mismo color que usas con los demás
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '❤️ Ya no te quedan Likes?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Muestra tu interés con un like y haz match. ¡Tendrás la posibilidad de hacer match!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedPlanCard(
                  duration: '5 Likes',
                  price: 'MxN 30.00',
                  isSelected: _selectedPlan == '5 Likes',
                  onTap: () => _selectPlan('5 Likes'),
                ),
                AnimatedPlanCard(
                  duration: '10 Likes',
                  price: 'MxN 60.00',
                  isSelected: _selectedPlan == '10 Likes',
                  onTap: () => _selectPlan('10 Likes'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedPlanCard(
              duration: 'Inscripción',
              price: 'MxN 150.00',
              isBestOffer: true,
              isSelected: _selectedPlan == 'Inscripción',
              onTap: () => _selectPlan('Inscripción'),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5C8),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _FeatureItem(text: 'Recomendaciones Personalizadas'),
                  _FeatureItem(text: 'Coincidencias Prioritarias'),
                  _FeatureItem(text: 'Historial Detallado de Salud y Genética'),
                  _FeatureItem(text: 'Mensajería Ilimitada'),
                  _FeatureItem(text: 'Likes Ilimitados'),
                  _FeatureItem(text: 'Perro en Destacados'),
                  _FeatureItem(text: 'Sin Anuncios'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedPlan.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentPage()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A66E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Realizar pago',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedPlanCard extends StatelessWidget {
  final String duration;
  final String price;
  final bool isBestOffer;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedPlanCard({
    Key? key,
    required this.duration,
    required this.price,
    this.isBestOffer = false,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        width: 140,
        height: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isBestOffer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Mejor oferta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              duration,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}