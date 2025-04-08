import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w900,
    fontSize: 32,
    color: AppColors.primary, // Using primary color
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.secondary, // Using secondary color
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.tertiary, // Using tertiary color
  );

  static const TextStyle bodyFaded = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: Color(0x99FFFFFF), // Faded text with white opacity
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: Color(0xCCFFFFFF), // Background color with opacity
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Colors.white,
  );
}
