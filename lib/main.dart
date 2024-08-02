import 'package:blood_donation/models/user.dart';
import 'package:blood_donation/screens/intro.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:blood_donation/screens/home.dart';
import 'package:blood_donation/screens/registration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class UserCubit extends Cubit<User?> {
  UserCubit(super.state);

  void login(User user) => emit(user);

  void logout() => emit(null);
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(initialRoute: token != null ? '/home' : '/intro'));
}

GoRouter router(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/intro',
        builder: (context, state) => const Intro(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Home(),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (BuildContext context) => UserCubit(null),
        ),
      ],
      child: MaterialApp.router(
        title: 'Blood Donation',
        theme: ThemeData(fontFamily: 'Lexend'),
        routerConfig: router(initialRoute),
      ),
    );
  }
}
