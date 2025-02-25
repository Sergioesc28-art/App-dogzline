import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'services/api_service.dart';
import 'models/data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  List<File?> images = []; // Lista de File
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final List<String> selectedVaccines = [];
  final List<String> selectedCertificates = [];
  final ApiService _apiService = ApiService();
  String? userId;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final File imageFile = File(image.path);

        // Comprimir la imagen
        final File? compressedImage = await compressImage(imageFile.path);

        if (compressedImage != null) {
          print(
              'Tamaño de la imagen comprimida: ${compressedImage.lengthSync()} bytes');
          setState(() {
            images.add(compressedImage);
          });
        }
      } catch (e) {
        print('Error procesando imagen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la imagen: $e')),
        );
      }
    }
  }

  Future<File?> compressImage(String imagePath) async {
    try {
      final XFile? compressedImagePath =
          await FlutterImageCompress.compressAndGetFile(
        imagePath,
        '${imagePath}_compressed.jpg',
        minWidth: 600, // Reducir el ancho mínimo
        minHeight: 400, // Reducir la altura mínima
        quality: 30, // Reducir la calidad a 30
      );

      return compressedImagePath != null
          ? File(compressedImagePath.path)
          : null;
    } catch (e) {
      print('Error comprimiendo imagen: $e');
      return null;
    }
  }

  void _saveDog() async {
    if (userId == null) {
      print('Error: userId is null');
      return;
    }

    // Convertir la primera imagen a base64 (si existe)
    String fotoBase64 = '';
    if (images.isNotEmpty && images[0] != null) {
      List<int> imageBytes =
          await images[0]!.readAsBytes(); // Usar File directamente
      fotoBase64 = 'data:image/png;base64,${base64Encode(imageBytes)}';
    }

    // Validaciones básicas
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        breedController.text.isEmpty ||
        colorController.text.isEmpty ||
        selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa todos los campos requeridos')),
      );
      return;
    }

    try {
      final Data mascota = Data(
        id: '', // El servidor generará el ID
        nombre: nameController.text,
        edad: int.tryParse(ageController.text) ?? 0,
        raza: breedController.text,
        sexo: selectedGender!, // Usar el género seleccionado
        color: colorController.text,
        vacunas: selectedVaccines.join(', '), // Convertimos array a string
        caracteristicas: 'Amigable',
        certificado:
            selectedCertificates.join(', '), // Convertimos array a string
        fotos: fotoBase64, // Una sola foto en base64
        comportamiento: 'Juguetón',
        idUsuario: userId!,
        distancia: '', // No se usa en la creación
      );

      print('Intentando crear mascota con datos: ${mascota.toJson()}');
      await _apiService.createMascota(mascota);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota creada exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al crear la mascota: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la mascota')),
      );
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
            fontSize: 24,
            color: Colors.brown,
            fontFamily: 'Roboto', // Especifica la fuente Roboto
            fontWeight: FontWeight.bold, // Aumenta el grosor del texto
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
                              image: FileImage(images[index]!),
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
            _buildGenderSelectField(
              label: 'Sexo',
              options: ['Macho', 'Hembra'],
              selectedOption: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveDog,
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

  Widget _buildGenderSelectField({
    required String label,
    required List<String> options,
    required String? selectedOption,
    required ValueChanged<String?> onChanged,
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
            final isSelected = selectedOption == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    onChanged(option);
                  } else {
                    onChanged(null);
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
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CustomTextField(
      {Key? key, required this.label, required this.controller})
      : super(key: key);

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