import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

MaterialColor customSwatch = const MaterialColor(0xFF00A0FF, {
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

MaterialColor customSwatchSecundary = const MaterialColor(0xFF690096, {
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

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  void toggleTheme() async {
    isDarkMode.toggle();
    await _savePreferences();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLayout() async {
    isGridLayout.toggle();
    await _savePreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    isGridLayout.value = prefs.getBool('isGridLayout') ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
    await prefs.setBool('isGridLayout', isGridLayout.value);
  }
}
