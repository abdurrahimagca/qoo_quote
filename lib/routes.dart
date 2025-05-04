import 'package:flutter/material.dart';
import 'package:qoo_quote/screens/home_page.dart';
import 'package:qoo_quote/screens/login.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginPage(),
  '/home': (context) => const HomePage(),
};
