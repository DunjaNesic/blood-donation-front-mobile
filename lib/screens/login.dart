import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_donation/common/errors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  bool _obscureText = true;
  bool _emailInteracted = false;
  bool _passwordInteracted = false;
  String? _emailError;
  String? _passwordError;

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode()..addListener(() => _handleFocusChange('email'));
    _passwordFocusNode = FocusNode()..addListener(() => _handleFocusChange('password'));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _handleFocusChange(String field) {
    if (field == 'email' && !_emailFocusNode.hasFocus) {
      setState(() {
        _emailInteracted = true;
      });
    } else if (field == 'password' && !_passwordFocusNode.hasFocus) {
      setState(() {
        _passwordInteracted = true;
      });
    }
    _validateFields();
  }

  void _validateFields() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    setState(() {
      if (_emailInteracted) {
        if (email.isEmpty) {
          _emailError = 'Unesite email adresu';
        } else if (!emailRegex.hasMatch(email)) {
          _emailError = 'Nevažeća email adresa';
        } else {
          _emailError = null;
        }
      }

      if (_passwordInteracted) {
        if (password.isEmpty) {
          _passwordError = 'Unesite lozinku';
        } else {
          _passwordError = null;
        }
      }
    });
  }

  Future<void> _login() async {
    _validateFields();

    // final url = 'http://10.0.2.2:5219/itk/actions';
    // final url = 'https://10.0.2.2:7062/itk/actions';

    // final headers = {
    //   'Accept': 'application/json',
    //   'Content-Type': 'application/json',
    // };
    //
    // final response = await http.get(
    //   Uri.parse(url),
    //   headers: headers,
    // );
    //
    // if (response.statusCode == 200) {
    //   print('Success: ${response.body}');
    // } else {
    //   print('Request failed with status: ${response.statusCode}');
    //   print('Response Body: ${response.body}');
    // }

    if (_emailError == null && _passwordError == null) {
      final url = Uri.parse('https://10.0.2.2:7062/login');

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);

          final accessToken = responseBody['accessToken'];
          final refreshToken = responseBody['refreshToken'];

          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);

          if (mounted) context.pushReplacement('/home');
        } else if(response.statusCode == 401) {
          setState(() {
            _passwordError = 'Pogrešni kredencijali';
          });
        }
        else {
          final responseBody = jsonDecode(response.body);
          setState(() {
            _emailError = responseBody['email'];
            _passwordError = responseBody['password'];
          });
          print(responseBody);
        }
      } catch (error) {
        print('Error logging in: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          color: const Color(0xFFF1F5FC),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dobrodošli nazad!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF490008),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: TextStyle(color: Color(0xFF877E7F)),
                    border: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _validateFields(),
                  validator: (value) {
                    return _emailError;
                  },
                ),
                if (_emailError != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomErrorText(errorText: _emailError),
                    ],
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Lozinka',
                    labelStyle: const TextStyle(color: Color(0xFF877E7F)),
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                      color: const Color(0xFF877E7F),
                    ),
                  ),
                  obscureText: _obscureText,
                  onChanged: (value) => _validateFields(),
                  validator: (value) {
                    return _passwordError;
                  },
                ),
                if (_passwordError != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomErrorText(errorText: _passwordError),
                    ],
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFD80032),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Prijavi se',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Nemaš nalog?',
                      style: TextStyle(color: Color(0xFF877E7F)),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushReplacement('/register');
                      },
                      child: const Text(
                        'Registruj se',
                        style: TextStyle(color: Color(0xFFD80032), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
