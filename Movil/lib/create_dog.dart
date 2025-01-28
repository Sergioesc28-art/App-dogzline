import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CreateDogPage(),
    );
  }
}

class CreateDogPage extends StatefulWidget {
  const CreateDogPage({Key? key}) : super(key: key);

  @override
  State<CreateDogPage> createState() => _CreateDogPageState();
}

class _CreateDogPageState extends State<CreateDogPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile?> images = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final List<String> selectedVaccines = [];
  final List<String> selectedCertificates = [];

  void pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        images.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F2DE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Crear perro',
          style: TextStyle(
            fontFamily: 'Cursive',
            fontSize: 24,
            color: Colors.brown,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                      image: images.length > index
                          ? DecorationImage(
                              image: FileImage(
                                File(images[index]!.path),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: images.length > index
                        ? null
                        : const Icon(Icons.add, color: Colors.grey, size: 30),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nombre', controller: nameController),
            CustomTextField(label: 'Edad', controller: ageController),
            CustomTextField(label: 'Color', controller: colorController),
            CustomTextField(label: 'Raza', controller: breedController),
            const SizedBox(height: 16),
            _buildMultiSelectField(
              label: 'Vacunas',
              options: ['Rabia', 'Parvovirus', 'Moquillo'],
              selectedOptions: selectedVaccines,
            ),
            _buildMultiSelectField(
              label: 'Certificado',
              options: ['Pedigrí', 'Adiestramiento'],
              selectedOptions: selectedCertificates,
            ),
            ElevatedButton(
              onPressed: () {
                _showSummaryDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6A66E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar perro',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> options,
    required List<String> selectedOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen del perro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${nameController.text}'),
            Text('Edad: ${ageController.text}'),
            Text('Color: ${colorController.text}'),
            Text('Raza: ${breedController.text}'),
            Text('Vacunas: ${selectedVaccines.join(", ")}'),
            Text('Certificados: ${selectedCertificates.join(", ")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CustomTextField({Key? key, required this.label, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.brown),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.brown),
          ),
        ),
      ),
    );
  }
}
