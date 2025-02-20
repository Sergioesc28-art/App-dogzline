// import 'package:flutter/material.dart';
// import 'services/api_service.dart';
// import 'models/data_model.dart';

// class DogzlineScreen extends StatefulWidget {
//   final String selectedDogName;

//   const DogzlineScreen({required this.selectedDogName});
  
//   @override
//   _DogzlineScreenState createState() => _DogzlineScreenState();
// }

// class _DogzlineScreenState extends State<DogzlineScreen> {
//   final ApiService _apiService = ApiService();
//   List<Data> dogs = [];
//   List<Data> filteredDogs = [];
//   TextEditingController searchController = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   int _currentPage = 1;
//   bool _isLoading = false;
//   bool _hasMoreData = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDogs();
//     searchController.addListener(_filterDogs);
//     _scrollController.addListener(_onScroll);
//   }

//   Future<void> _fetchDogs({int page = 1}) async {
//     if (_isLoading) return;
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await _apiService.getDogs(page: page, limit: 10);
//       setState(() {
//         if (response.isEmpty) {
//           _hasMoreData = false;
//         } else {
//           dogs.addAll(response);
//           filteredDogs = dogs;
//           _currentPage++;
//         }
//       });
//     } catch (error) {
//       print('Error fetching dogs: $error');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _filterDogs() {
//     setState(() {
//       filteredDogs = dogs.where((dog) {
//         return dog.nombre.toLowerCase().contains(searchController.text.toLowerCase());
//       }).toList();
//     });
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMoreData) {
//       _fetchDogs(page: _currentPage);
//     }
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.amber.shade100,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text('Dogzline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
//         actions: [
//           Icon(Icons.notifications_none, color: Colors.black),
//           SizedBox(width: 10),
//           Icon(Icons.settings, color: Colors.black),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           CircleAvatar(
//             radius: 50,
//             backgroundImage: AssetImage('assets/chucho.jpg'),
//           ),
//           SizedBox(height: 10),
//           Text(widget.selectedDogName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Busqueda',
//                 prefixIcon: Icon(Icons.search),
//                 suffixIcon: DropdownButtonHideUnderline(
//                   child: DropdownButton(
//                     icon: Icon(Icons.filter_list),
//                     items: [],
//                     onChanged: (value) {},
//                   ),
//                 ),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: filteredDogs.length + (_hasMoreData ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == filteredDogs.length) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 final dog = filteredDogs[index];
//                 return Card(
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(dog.fotos),
//                     ),
//                     title: Text(dog.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
//                     subtitle: Text('${dog.sexo}, ${dog.edad} años\n${dog.distancia} de distancia'),
//                     trailing: Icon(Icons.location_on, color: Colors.orange),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }