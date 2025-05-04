import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/screens/main_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite initialization
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await dotenv.load(fileName: ".env");

  // Permission handler initialization
  await Permission.storage.request();

  // Check for access token
  const storage = FlutterSecureStorage();
  final String? token = await storage.read(key: 'access-token');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qoo Quote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: token != null ? const MyHomePage() : LoginPage(),
    ),
  );
}
