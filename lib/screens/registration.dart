import 'dart:convert';
import 'package:blood_donation/models/place.dart';
import 'package:blood_donation/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blood_donation/common/app_bar.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _jmbgController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedGender = 'female';
  String _selectedBloodGroup = 'A-';
  String? _selectedCity;
  bool _obscureText = true;
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final response = await http.get(Uri.parse('https://10.87.0.161:7062/itk/places'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Place> places = data.map((json) => Place.fromJson(json)).toList();

        if(mounted) {
          setState(() {
            _cities = places.map((place) => place.placeName).toList();
          });
        }
      } else {
        print('Failed to load cities');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  int _getBloodTypeIndex(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return 0;
      case 'A-':
        return 1;
      case 'B+':
        return 2;
      case 'B-':
        return 3;
      case 'AB+':
        return 4;
      case 'AB-':
        return 5;
      case 'O+':
        return 6;
      case 'O-':
        return 7;
      default:
        return 0;
    }
  }

  Future<void> _register() async {
    final jmbg = _jmbgController.text;
    final donorFullName = _fullNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final sex = _selectedGender == 'male' ? 1 : 0;
    final bloodType = _getBloodTypeIndex(_selectedBloodGroup);
    const isActive = true;
    final lastDonationDate = DateTime.now().toIso8601String();
    final placeID = _cities.indexOf(_selectedCity!);

    final body = json.encode({
      "jmbg": jmbg,
      "donorFullName": donorFullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "sex": sex,
      "bloodType": bloodType,
      "isActive": isActive,
      "lastDonationDate": lastDonationDate,
      "placeID": placeID
    });

    final response = await http.post(
      Uri.parse('https://10.87.0.161:7062/register'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      context.pushReplacement('/login');
    } else {
      throw Exception('Failed to register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FC),
      appBar: const CustomAppBar(title: 'ITK FON'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kreiraj svoj nalog',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF490008),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jmbgController,
                decoration: const InputDecoration(
                  labelText: 'JMBG',
                  labelStyle: TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Ime i prezime',
                  labelStyle: TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Lozinka',
                  labelStyle: const TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF877E7F),
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Potvrdi lozinku',
                  labelStyle: TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Pol', style: TextStyle(color: Color(0xFF877E7F), fontSize: 12),),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'male';
                        });
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.male,
                            color: _selectedGender == 'male' ? Colors.red : Colors.grey,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 50,
                    color: const Color(0xFF490008),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'female';
                        });
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.female,
                            color: _selectedGender == 'female' ? Colors.red : Colors.grey,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Krvna grupa', style: TextStyle(color: Color(0xFF877E7F), fontSize: 12)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                children: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((bloodGroup) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBloodGroup = bloodGroup;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _selectedBloodGroup == bloodGroup ? const Color(0xFFD80032) : Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: _selectedBloodGroup == bloodGroup ? Colors.transparent : Colors.grey,
                      ),
                    ),
                    child: Text(
                      bloodGroup,
                      style: TextStyle(
                        color: _selectedBloodGroup == bloodGroup ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Grad', style: TextStyle(color: Color(0xFF877E7F), fontSize: 12)),
              _cities.isEmpty
                  ? const Loading()
                  : DropdownButtonFormField<String>(
                value: _selectedCity,
                items: _cities
                    .map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF877E7F)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD80032)),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF877E7F)),
                ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD80032),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Kreiraj nalog',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushReplacement('/login');
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Već imaš nalog? ', style: TextStyle(color: Color(0xFF877E7F), fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Prijavi se',
                          style: TextStyle(
                            color: Color(0xFFD80032),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}