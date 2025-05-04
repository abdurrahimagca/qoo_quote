import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

//TODO: use this file as a starter of how you implement it
// typically u may wanna implement sth like a client to read jwt append every req res from gql
//

class LoginOrSignupScreen extends StatefulWidget {
  const LoginOrSignupScreen({super.key});

  @override
  LoginOrSignupScreenState createState() => LoginOrSignupScreenState();
}

class LoginOrSignupScreenState extends State<LoginOrSignupScreen> {
  bool _isLoading = true;
  String? _error;
  String? _authCode;
  StreamSubscription? _sub;
  final appLinks = AppLinks();

  final String loginUrl =
      "${dotenv.env["API_BASE_URL"]}/auth/google?redirect_uri=qoo-quote://auth/google/callback";

  final String redirectUri = "qoo-quote://auth/google/callback";
  final String? apiKey = dotenv.env["API_KEY"];

  @override
  void initState() {
    super.initState();
    _initAppLinks();
    _launchBrowser();
  }

  Future<void> _initAppLinks() async {
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null && uri.toString().startsWith(redirectUri)) {
        await _handleCallback(uri);
      }

      _sub = appLinks.uriLinkStream.listen((Uri? uri) async {
        if (uri != null && uri.toString().startsWith(redirectUri)) {
          await _handleCallback(uri);
        }
      });
    } catch (e) {
      setState(() {
        _error = "Failed to handle deep link: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _launchBrowser() async {
    try {
      final Uri url = Uri.parse(loginUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        setState(() {
          _error = 'Could not launch browser';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to launch browser: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCallback(Uri uri) async {
    final authCode = uri.queryParameters["auth_code"];
    var logger = Logger();
    logger.d("Auth code: $authCode");

    if (authCode == null) {
      setState(() {
        _error = "No auth code found in URI";
        _isLoading = false;
      });
      return;
    }
    final dio = Dio();
    await dio
        .post(
      "${dotenv.env["API_BASE_URL"]}/auth/exchange",
      data: {
        "auth_code": authCode,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "qq-api-key": apiKey,
        },
      ),
    )
        .then((response) async {
      logger.d("Response: ${response.data}");
      if (response.data != null) {
        try {
          final access = response.data["accessToken"]?.toString();
          final refresh = response.data["refreshToken"]?.toString();

          if (access == null || refresh == null) {
            throw Exception("Token data is missing from response");
          }
          const storage = FlutterSecureStorage();
          await storage.write(key: "access-token", value: access);
          await storage.write(key: "refresh-token", value: refresh);
          final tokensFromStorage = await storage.readAll();
          logger.d("Tokens stored successfully", tokensFromStorage);
        } catch (e) {
          logger.e("Error storing tokens: $e");
          setState(() {
            _error = "Failed to store tokens: $e";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "Failed to get access token";
          _isLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        _error = "Failed to get access token: $e";
        _isLoading = false;
      });
    });

    setState(() {
      _authCode = authCode;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with Google")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("Opening browser for login..."),
            ],
            if (_authCode != null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 20),
              Text(
                "Auth Code:\n$_authCode",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
            if (_error != null) ...[
              Icon(Icons.error, color: Colors.red[700], size: 48),
              const SizedBox(height: 20),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                  _authCode = null;
                });
                _launchBrowser();
              },
              child: const Text("Retry Login"),
            ),
          ],
        ),
      ),
    );
  }
}
