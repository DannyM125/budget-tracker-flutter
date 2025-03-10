import 'package:flutter/material.dart';

class ColorUtils {
  static ValueNotifier<Color> primaryColorNotifier = ValueNotifier<Color>(Colors.blue);

  static Color get primaryColor => primaryColorNotifier.value;

  static void setPrimaryColor(Color newColor) {
    primaryColorNotifier.value = newColor;
  }
}
