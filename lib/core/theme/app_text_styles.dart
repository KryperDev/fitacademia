import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle headline1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);
  static const TextStyle headline2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const TextStyle headline3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);
  static const TextStyle body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const TextStyle bodySecondary = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const TextStyle caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2);
  static const TextStyle label = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4);
}
