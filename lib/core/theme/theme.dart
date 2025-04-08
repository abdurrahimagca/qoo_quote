import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    displayLarge: AppTypography.h1,
    displayMedium: AppTypography.h2,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.bodyFaded,
    labelLarge: AppTypography.buttonText,
  ),
);
