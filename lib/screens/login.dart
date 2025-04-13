import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/testPage.dart';

class LoginPage extends StatefulWidget {
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
    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (!mounted) return; // `mounted` kontrolü eklendi
      setState(() {
        if (isTyping) {
          if (currentText.length < languages[languageIndex].length) {
            currentText += languages[languageIndex][currentText.length];
          } else {
            // Yazı bittiğinde silmeye başlamadan önce bir süre bekle
            isTyping = false;
            Future.delayed(Duration(seconds: 1), () {
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
              ), // Logo kısmı için bir ikon
              SizedBox(height: 50),
              Text(
                currentText,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 200),
              Container(
                width: 255,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                  icon: SvgPicture.asset("assets/google.svg"),
                  label: Text(
                    'Google ile giriş yap',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
