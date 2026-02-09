import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 现代AI助手风格主题
/// 参考豆包、千问等应用的设计语言
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      navigationBarTheme: _navigationBarTheme,
      navigationRailTheme: _navigationRailTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      bottomSheetTheme: _bottomSheetTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      textTheme: _textTheme,
      iconTheme: _iconTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.gray900,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
    );
  }

  // Material 3 ColorScheme
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: AppColors.primaryDark,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFEDD5),
    onSecondaryContainer: Color(0xFF311600),

    tertiary: AppColors.aiPrimary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFC5FEFF),
    onTertiaryContainer: Color(0xFF001F29),

    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: Color(0xFF410002),

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,

    outline: AppColors.outline,
    outlineVariant: AppColors.gray200,

    shadow: AppColors.shadow,
    scrim: Color(0x80000000),
    inverseSurface: AppColors.gray800,
    onInverseSurface: AppColors.gray100,
    inversePrimary: AppColors.primaryLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.gray900,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,

    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.gray900,
    secondaryContainer: Color(0xFF5C2D00),
    onSecondaryContainer: Color(0xFFFFEDD5),

    surface: AppColors.gray900,
    onSurface: AppColors.gray100,
    surfaceVariant: AppColors.gray800,
    onSurfaceVariant: AppColors.gray400,
  );

  // AppBar Theme - 现代无阴影
  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.titleLarge,
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),
  );

  // Card Theme - 大圆角、柔和阴影
  static const CardTheme _cardTheme = CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: AppColors.shadowLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  // Button Themes
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      textStyle: AppTextStyles.buttonLabel,
    ),
  );

  static const TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AppColors.primary),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textStyle: WidgetStatePropertyAll(AppTextStyles.button),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.outline, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      textStyle: AppTextStyles.buttonLabel,
    ),
  );

  // FAB Theme - 渐变效果
  static final FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
    elevation: 4,
    shadowColor: AppColors.shadow,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  // Input Decoration - 现代圆角
  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.gray100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: AppTextStyles.hint,
  );

  // Navigation Bar Theme
  static const NavigationBarThemeData _navigationBarTheme = NavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surface,
    height: 65,
    labelTextStyle: WidgetStatePropertyAll(AppTextStyles.navLabel),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(size: 24),
    ),
  );

  static const NavigationRailThemeData _navigationRailTheme = NavigationRailThemeData(
    elevation: 0,
    backgroundColor: AppColors.surface,
    labelTextStyle: WidgetStatePropertyAll(AppTextStyles.navLabel),
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiary,
    selectedLabelStyle: AppTextStyles.navLabelSelected,
    unselectedLabelStyle: AppTextStyles.navLabel,
    type: BottomNavigationBarType.fixed,
  );

  // Bottom Sheet Theme
  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  // Dialog Theme
  static const DialogTheme _dialogTheme = DialogTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    titleTextStyle: AppTextStyles.titleLarge,
    contentTextStyle: AppTextStyles.bodyLarge,
  );

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.gray800,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: Colors.white,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  );

  // Chip Theme
  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.gray100,
    selectedColor: AppColors.primaryContainer,
    labelStyle: AppTextStyles.chip,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    side: BorderSide.none,
  );

  // Divider Theme
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  // Text Theme
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,

    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,

    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,

    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,

    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  // Icon Theme
  static const IconThemeData _iconTheme = IconThemeData(
    color: AppColors.textSecondary,
    size: 24,
  );

  // Custom shadow for cards
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Custom shadow for floating elements
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
