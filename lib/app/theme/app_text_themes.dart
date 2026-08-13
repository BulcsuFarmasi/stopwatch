import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';

final TextTheme appTextTheme = TextTheme(
  headlineMedium: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.title,
  ),
  displayMedium: TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w300,
    color: AppColors.time,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
  labelLarge: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
);
