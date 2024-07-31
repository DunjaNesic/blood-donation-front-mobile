import 'package:blood_donation/screens/intro.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:blood_donation/screens/loading.dart';
import 'package:blood_donation/screens/home.dart';
import 'package:blood_donation/screens/registration.dart';
import 'package:blood_donation/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/intro',
    routes: [
      GoRoute(
        path: '/intro',
        builder: (context, state) => const StatisticsScreen(),
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Routeee',
      theme: ThemeData(fontFamily: 'Lexend'),
      routerConfig: router(),
    );
  }
}
