import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';

final TextTheme appTextTheme = TextTheme(
  headlineMedium: TextStyle(
    fontSize: 30,
    fontWeight: .w400,
    color: AppColors.title,
  ),
  bodyMedium: TextStyle(fontSize: 18, fontWeight: .w400, color: AppColors.text),
  labelLarge: TextStyle(fontWeight: .w500, fontSize: 16),
);
