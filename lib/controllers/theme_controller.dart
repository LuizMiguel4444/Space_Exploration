import 'package:flutter/material.dart';
import 'package:get/get.dart';

MaterialColor customSwatch = MaterialColor(0xFF00A0FF, {
  50: Color(0xFF00A0FF),
  100: Color(0xFF00A0FF),
  200: Color(0xFF00A0FF),
  300: Color(0xFF00A0FF),
  400: Color(0xFF00A0FF),
  500: Color(0xFF00A0FF),
  600: Color(0xFF00A0FF),
  700: Color(0xFF00A0FF),
  800: Color(0xFF00A0FF),
  900: Color(0xFF00A0FF),
});

MaterialColor customSwatchSecundary = MaterialColor(0xFF690096, {
  50: Color(0xFF690096),
  100: Color(0xFF690096),
  200: Color(0xFF690096),
  300: Color(0xFF690096),
  400: Color(0xFF690096),
  500: Color(0xFF690096),
  600: Color(0xFF690096),
  700: Color(0xFF690096),
  800: Color(0xFF690096),
  900: Color(0xFF690096),
});

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  var isGridLayout = false.obs;

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLayout() {
    isGridLayout.value = !isGridLayout.value;
  }
}
