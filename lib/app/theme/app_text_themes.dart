import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';

final TextTheme appTextTheme = TextTheme(
  headlineMedium: TextStyle(
    fontSize: 30,
    fontWeight: .w400,
    color: AppColors.title,
  ),
  displayMedium: TextStyle(
    fontSize: 52,
    fontWeight: .w300,
    color: AppColors.text,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
  bodyMedium: TextStyle(fontSize: 18, fontWeight: .w400, color: AppColors.text),
  labelLarge: TextStyle(fontWeight: .w500, fontSize: 16),
);
