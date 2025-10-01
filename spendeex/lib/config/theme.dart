import 'package:flutter/material.dart';

class AppTheme {
  // Color palette - Black and White theme
  static const Color primaryBlack = Color(0xFF000000);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color surfaceBlack = Color(0xFF2A2A2A);
  static const Color cardBlack = Color(0xFF333333);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color greyWhite = Color(0xFFF5F5F5);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Accent colors for status (minimal)
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryWhite,
        secondary: lightGrey,
        surface: secondaryBlack,
        error: errorRed,
        onPrimary: primaryBlack,
        onSecondary: primaryBlack,
        onSurface: primaryWhite,
        onError: primaryWhite,
      ),

      // Scaffold
      scaffoldBackgroundColor: primaryBlack,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlack,
        foregroundColor: primaryWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: primaryWhite),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryWhite,
          foregroundColor: primaryBlack,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryWhite,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 6,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryWhite, width: 2),
        ),
        labelStyle: TextStyle(color: lightGrey),
        hintStyle: TextStyle(color: mediumGrey),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: primaryWhite, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: primaryWhite, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: primaryWhite, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: primaryWhite),
        bodyMedium: TextStyle(color: primaryWhite),
        bodySmall: TextStyle(color: lightGrey),
        labelLarge: TextStyle(color: primaryWhite),
        labelMedium: TextStyle(color: lightGrey),
        labelSmall: TextStyle(color: mediumGrey),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        textColor: primaryWhite,
        iconColor: primaryWhite,
        tileColor: cardBlack,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryBlack,
        selectedItemColor: primaryWhite,
        unselectedItemColor: mediumGrey,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: darkGrey,
        thickness: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryWhite,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: primaryWhite,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceBlack,
        selectedColor: primaryWhite,
        labelStyle: TextStyle(color: primaryWhite),
        secondaryLabelStyle: TextStyle(color: primaryBlack),
        brightness: Brightness.dark,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBlack,
        titleTextStyle: TextStyle(
          color: primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: primaryWhite),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBlack,
        modalBackgroundColor: cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  // Helper methods for status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'settled':
      case 'paid':
        return successGreen;
      case 'error':
      case 'failed':
        return errorRed;
      case 'pending':
      case 'warning':
        return warningOrange;
      default:
        return mediumGrey;
    }
  }

  // Helper for category colors (keeping minimal color for categories)
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return primaryWhite;
      case 'family':
        return lightGrey;
      case 'couple':
        return greyWhite;
      case 'event':
        return mediumGrey;
      case 'project':
        return darkGrey;
      default:
        return mediumGrey;
    }
  }
}