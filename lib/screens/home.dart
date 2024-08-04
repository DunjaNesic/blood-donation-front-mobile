import 'package:blood_donation/common/api_handler.dart';
import 'package:blood_donation/common/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:blood_donation/models/place.dart';
import 'package:blood_donation/models/action.dart';
import 'package:blood_donation/common/action_card.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCity;
  List<String> _cities = [];
  List<TransfusionAction> _actions = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchActions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _fetchActions();
  }

  Future<void> _fetchActions() async {

    final minDate = _dateFromController.text.isNotEmpty ? _dateFromController.text : null;
    final maxDate = _dateToController.text.isNotEmpty ? _dateToController.text : null;
    //na beku treba da odradim filtriranje za grad
    final city = _selectedCity != null && _selectedCity != 'Svi gradovi' ? _selectedCity : null;
    final searchQuery = _searchController.text.isNotEmpty ? _searchController.text : null;

    final queryParams = {
      if (minDate != null) 'MinDate': minDate,
      if (maxDate != null) 'MaxDate': maxDate,
      if (city != null) 'Search': city,
      if (searchQuery != null) 'Search': searchQuery,
    };

    final uri = Uri.https('${BaseAPI.ip$port}', '/itk/actions', queryParams);

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<TransfusionAction> actions = data.map((json) => TransfusionAction.fromJson(json)).toList();

        if (mounted) {
          setState(() {
            _actions = actions;
          });
        }
      } else {
        print('Failed to load actions. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }


  Future<void> _fetchCities() async {
    try {
      final response = await http.get(Uri.parse('${BaseAPI.api}/places'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Place> places = data.map((json) => Place.fromJson(json)).toList();

        if(mounted) {
          setState(() {
            _cities = ['Svi gradovi'];
            _cities.addAll(places.map((place) => place.placeName).toList());
          });
        }
      } else {
        print('Failed to load cities');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _fetchActions();
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _dateFromController.clear();
      _dateToController.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FC),
      appBar: const CustomAppBar(title: 'ITK FON'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF64F472),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ispunjavate uslove za doniranje',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.check_circle_outline, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Pretraži...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _dateFromController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateFromController),
                      decoration: InputDecoration(
                        hintText: 'Datum od',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _dateToController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateToController),
                      decoration: InputDecoration(
                        hintText: 'Datum do',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _resetFilters,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            CustomDropdownButton(
              hint: 'Grad',
              value: _selectedCity,
              items: _cities,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value == 'All Cities' ? null : value;
                  // _fetchActions(); uraditi ovo posle
                });
              },
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: _actions.isNotEmpty
                  ? ListView.builder(
                itemCount: _actions.length,
                itemBuilder: (context, index) {
                  final action = _actions[index];
                  return ActionCard(
                    action: action,
                  );
                },
              )
                  : const Center(child: Text('No actions available')),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownButton extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownButton({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          items: items.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: DropdownItem(city: city),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ),
    );
  }
}

class DropdownItem extends StatelessWidget {
  final String city;

  const DropdownItem({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(city, style: const TextStyle(color: Colors.black)),
    );
  }
}
