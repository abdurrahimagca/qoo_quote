import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  // SQLite'ı başlat
  sqfliteFfiInit();
  // Veritabanı factory'sini ayarla
  databaseFactory = databaseFactoryFfi;

  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // Permission handler'ı initialize et
  await Permission.storage.request();

  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Qoo Quote',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginPage()),
  );
}
