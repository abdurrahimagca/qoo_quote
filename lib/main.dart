import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/screens/main_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qoo_quote/services/graphql_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveForFlutter();

  // SQLite initialization
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await dotenv.load(fileName: ".env");

  // Permission handler initialization
  await Permission.storage.request();

  // Check for access token
  const storage = FlutterSecureStorage();
  final String? token = await storage.read(key: 'refresh-token');

  final client = await GraphQLService.initializeClient();

  runApp(
    GraphQLProvider(
      client: client,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Qoo Quote',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: token != null ? const MyHomePage() : LoginPage(),
      ),
    ),
  );
}
