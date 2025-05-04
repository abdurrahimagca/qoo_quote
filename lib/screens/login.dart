import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/features/auth/components/login_or_signup_button.dart';
import 'package:qoo_quote/screens/home_page.dart';
import 'package:qoo_quote/screens/main_screen.dart';
import 'package:qoo_quote/screens/patch_user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<String> languages = [
    "Merhaba", // Türkçe
    "Hello", // İngilizce
    "Hallo", // Almanca
    "Ciao", // İtalyanca
    "Bonjour", // Fransızca
    "Привет", // Rusça
    "Hola", // İspanyolca
    "Witaj" // Lehçe
  ];

  int languageIndex = 0;
  String currentText = '';
  bool isTyping = true;
  bool isDeleting = false;
  int textIndex = 0;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return; // `mounted` kontrolü eklendi
      setState(() {
        if (isTyping) {
          if (currentText.length < languages[languageIndex].length) {
            currentText += languages[languageIndex][currentText.length];
          } else {
            // Yazı bittiğinde silmeye başlamadan önce bir süre bekle
            isTyping = false;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  isDeleting = true;
                });
              }
            });
          }
        } else if (isDeleting) {
          if (currentText.isNotEmpty) {
            currentText = currentText.substring(0, currentText.length - 1);
          } else {
            // Silme işlemi bittiğinde yeni dile geç
            isDeleting = false;
            languageIndex = (languageIndex + 1) % languages.length;
            isTyping = true;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/appicon.svg",
                height: 150,
              ),
              const SizedBox(height: 50),
              Text(
                currentText,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 200),
              SizedBox(
                width: 255,
                height: 55,
                child: LoginOrSignupButton(
                  onLoginSuccess: (String authCode, bool isNewUser) {
                    if (isNewUser) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatchUserPage(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                      );
                    }
                  },
                  onLoginError: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
