import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/store/auth_store.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:permission_handler/permission_handler.dart';

/// unfortunately, all types assumings are wrong and never ever should be like this
/// pls refer to the dev branch backend repo before doing any assumptions, OR  just look
/// the graphql schema, erp schema, or even the frontend code
/// and then do the assumptions
/// this is a very bad practice and should be avoided

//actuall do not need any sqlite db on here. neither do u need any local storage
// even types are not necessary
// use gql generator to generate types and use them
// pls look the https://the-guild.dev/graphql/codegen/docs/guides/flutter-freezed


// u would want to create a fetcher for gql requests and make it 
// a provider and use it in the app
// NEVER expose the tokens 


// u may want to give snake_case names to files since dart wants to



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
      title: 'Qoo Quote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    ),
  );
}
