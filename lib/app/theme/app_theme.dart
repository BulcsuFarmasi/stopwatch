import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/app/theme/app_text_themes.dart';

final ThemeData appTheme = ThemeData(
  textTheme: appTextTheme,
  fontFamily: 'RobotoCondensed',
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: .fromSeed(seedColor: AppColors.primary),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  ),
);
