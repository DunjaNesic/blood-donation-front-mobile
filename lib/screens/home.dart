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
  Place? _selectedCity;
  List<Place> _cities = [];
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
    final city = _selectedCity?.placeID;
    final searchQuery = _searchController.text.isNotEmpty ? _searchController.text : null;

    final queryParams = {
      if (minDate != null) 'MinDate': minDate,
      if (maxDate != null) 'MaxDate': maxDate,
      if (city != null) 'PlaceID': city.toString(),
      if (searchQuery != null) 'Search': searchQuery,
    };

    final uri = Uri.https(BaseAPI.ip$port, '/itk/actions', queryParams);

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

        if (mounted) {
          setState(() {
            _cities = [Place(placeID: 0, placeName: 'Svi gradovi')] + places;
            _selectedCity = _cities.first;
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
      _selectedCity = _cities.first;
    });
    _fetchActions();
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
              selectedValue: _selectedCity,
              items: _cities,
              onChanged: (Place? newValue) {
                setState(() {
                  _selectedCity = newValue;
                  _fetchActions();
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _actions.length,
                itemBuilder: (context, index) {
                  final action = _actions[index];
                  return ActionCard(action: action);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CustomDropdownButton extends StatelessWidget {
  final Place? selectedValue;
  final List<Place> items;
  final ValueChanged<Place?> onChanged;

  const CustomDropdownButton({
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
      child: DropdownButton<Place>(
        isExpanded: true,
        underline: const SizedBox(),
        value: selectedValue,
        onChanged: onChanged,
        items: items.map((Place place) {
          return DropdownMenuItem<Place>(
            value: place,
            child: Text(place.placeName),
          );
        }).toList(),
        style: const TextStyle(color: Colors.black, fontSize: 16),
        dropdownColor: Colors.white,
      ),
    );
  }
}
