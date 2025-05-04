import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:qoo_quote/services/rest_services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

class LoginOrSignupButton extends StatefulWidget {
  final Function(String authCode, bool isNewUser) onLoginSuccess;
  final VoidCallback? onLoginError;

  const LoginOrSignupButton({
    super.key,
    required this.onLoginSuccess,
    this.onLoginError,
  });

  @override
  State<LoginOrSignupButton> createState() => _LoginOrSignupButtonState();
}

class _LoginOrSignupButtonState extends State<LoginOrSignupButton> {
  bool _isLoading = false;
  StreamSubscription? _sub;
  final _appLinks = AppLinks();
  final _logger = Logger();
  final authService = AuthService();

  final String _loginUrl =
      "${dotenv.env["API_BASE_URL"]}/auth/google?redirect_uri=qoo-quote://auth/google/callback";
  final String _redirectUri = "qoo-quote://auth/google/callback";

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null && uri.toString().startsWith(_redirectUri)) {
        await _handleCallback(uri);
      }

      _sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
        if (uri != null && uri.toString().startsWith(_redirectUri)) {
          await _handleCallback(uri);
        }
      });
    } catch (e) {
      _logger.e("Failed to handle deep link: $e");
      widget.onLoginError?.call();
    }
  }

  Future<void> _handleCallback(Uri uri) async {
    final authCode = uri.queryParameters["auth_code"];
    final isNewUser = uri.queryParameters["is_new_user"] == "true";
    _logger.d("Auth code: $authCode");
    _logger.d("Is new user: $isNewUser");

    if (authCode == null) {
      _logger.e("No auth code found in URI");
      widget.onLoginError?.call();
      return;
    }

    try {
      final tokens = await authService.exchangeToken(authCode);
      final access = tokens['accessToken']?.toString();
      final refresh = tokens['refreshToken']?.toString();

      const storage = FlutterSecureStorage();
      await storage.write(key: "access-token", value: access);
      await storage.write(key: "refresh-token", value: refresh);

      setState(() => _isLoading = false);
      widget.onLoginSuccess(authCode, isNewUser);
    } catch (e) {
      _logger.e("Error during token exchange: $e");
      setState(() => _isLoading = false);
      widget.onLoginError?.call();
    }
  }

  Future<void> _startLogin() async {
    setState(() => _isLoading = true);

    try {
      final Uri url = Uri.parse(_loginUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch browser');
      }
    } catch (e) {
      _logger.e("Failed to launch browser: $e");
      setState(() => _isLoading = false);
      widget.onLoginError?.call();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _startLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/google.svg",
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Google ile giriş yap',
                  style: TextStyle(fontSize: 16),
                ),
        ],
      ),
    );
  }
}
