import 'package:flutter/material.dart';

@immutable
class GithubTheme {
  const GithubTheme(
      {this.primaryColor = const Color(0xFF0969DA),
      this.tertiaryColor = const Color(0xFFF6F8FA),
      this.neutralColor = const Color(0xFF24292E)});

  final Color primaryColor, tertiaryColor, neutralColor;

  ThemeData toThemeData() {
    return ThemeData(useMaterial3: true);
  }
}
