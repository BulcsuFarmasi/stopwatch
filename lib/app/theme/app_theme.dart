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
    style:
        FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ).copyWith(
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(color: AppColors.onPrimary, width: 3);
            }
            return null;
          }),
        ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style:
        OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ).copyWith(
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }

            final bool focused = states.contains(WidgetState.focused);
            return BorderSide(
              color: focused ? AppColors.text : AppColors.primary,
              width: focused ? 3 : 1,
            );
          }),
        ),
  ),
);
