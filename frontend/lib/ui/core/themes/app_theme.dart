import 'package:flutter/material.dart';
import 'app_bar_theme.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';
import 'button_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }
}
