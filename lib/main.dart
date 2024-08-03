import 'package:blood_donation/common/custom_scaffold.dart';
import 'package:blood_donation/common/user_cubit.dart';
import 'package:blood_donation/models/action.dart';
import 'package:blood_donation/screens/action_details.dart';
import 'package:blood_donation/screens/coming_soon.dart';
import 'package:blood_donation/screens/history.dart';
import 'package:blood_donation/screens/intro.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:blood_donation/screens/home.dart';
import 'package:blood_donation/screens/registration.dart';
import 'package:blood_donation/screens/statistics.dart';
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
        builder: (context, state) => const CustomScaffold(body: Home(), currentIndex: 0),
      ),
      GoRoute(
        path: '/coming_soon',
        builder: (context, state) => const CustomScaffold(body: ComingSoonScreen(), currentIndex: 1),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const CustomScaffold(body: UserHistoryScreen(), currentIndex: 2),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const CustomScaffold(body: StatisticsScreen(), currentIndex: 3),
      ),
      GoRoute(
        path: '/action_details',
        builder: (context, state) {
          final action = state.extra as TransfusionAction;
          return ActionDetailsScreen(action: action);
        },
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>(
      lazy: false,
      create: (context) => UserCubit(null),
      child: MaterialApp.router(
        title: 'Blood Donation',
        theme: ThemeData(fontFamily: 'Lexend'),
        routerConfig: router(initialRoute),
      ),
    );
  }
}
