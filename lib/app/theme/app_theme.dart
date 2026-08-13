import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/app/theme/app_text_themes.dart';

final ThemeData appTheme = ThemeData(
  textTheme: appTextTheme,
  fontFamily: 'RobotoCondsed',
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: .fromSeed(seedColor: AppColors.primary),
  brightness: Brightness.light,
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    ),
  ),
);
