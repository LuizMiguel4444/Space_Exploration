// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'views/home_page.dart';
import 'controllers/theme_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/space_controller.dart';
import 'translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashScreen());
  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadPreferences();
  String? savedLanguageCode = await LanguageService.getLanguageCode();
  Locale initialLocale = Locale(savedLanguageCode ?? 'en', 'US');
  SpaceController spaceController = Get.put(SpaceController());
  await spaceController.fetchNasaImages();
  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  final ThemeController _themeController = Get.find();

  MyApp({required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale: initialLocale,
      fallbackLocale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Space Exploration',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: customSwatch,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: customSwatchSecundary,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(),
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController());
        Get.put(FavoriteController());
      }),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset(
          'assets/loading.json',
          width: 400,
          height: 500,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
