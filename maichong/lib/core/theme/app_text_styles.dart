import 'package:flutter/material.dart';
import 'app_colors.dart';

class FontSizes {
  static const double displayLarge = 32.0;
  static const double displayMedium = 28.0;
  static const double displaySmall = 24.0;
  static const double headlineLarge = 20.0;
  static const double headlineMedium = 18.0;
  static const double headlineSmall = 16.0;
  static const double titleLarge = 16.0;
  static const double titleMedium = 14.0;
  static const double titleSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;
}

class FontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: FontSizes.displayLarge,
    fontWeight: FontWeights.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: FontSizes.headlineMedium,
    fontWeight: FontWeights.semiBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: FontSizes.bodyLarge,
    fontWeight: FontWeights.regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: FontSizes.bodyMedium,
    fontWeight: FontWeights.regular,
    color: AppColors.textSecondary,
  );
}
