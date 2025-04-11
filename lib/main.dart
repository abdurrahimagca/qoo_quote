import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/store/auth_store.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: LoginPage(),
  )

      // MultiProvider(
      //   providers: [
      //     ChangeNotifierProvider(create: (_) => AuthProvider()),
      //   ],
      //   child: const QooQuoteApp(),
      // ),
      );
}
