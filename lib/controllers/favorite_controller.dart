import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nasa_image.dart';

class FavoriteController extends GetxController {
  var favoriteImages = <NasaImage>[].obs;
  var isGridLayout = false.obs;
  var isLoading = false.obs;
  final String _googleTranslateApiKey = 'AIzaSyDFOl_kuFleMqKRAnvE8McG6XY2JKcxZVw';

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void addFavorite(NasaImage image) {
    if (!favoriteImages.contains(image)) {
      favoriteImages.add(image);
      _saveFavorites();
    }
  }

  void removeFavorite(NasaImage image) {
    favoriteImages.removeWhere((item) => item.imageUrlHD == image.imageUrlHD);
    _saveFavorites();
  }
  
  bool isFavorite(NasaImage image) {
    return favoriteImages.any((item) => item.imageUrlHD == image.imageUrlHD);
  }

  void _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedImages = favoriteImages.map((image) => jsonEncode(image.toJson())).toList();
    await prefs.setStringList('favorites', encodedImages);
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedImages = prefs.getStringList('favorites');
    if (encodedImages != null) {
      favoriteImages.assignAll(
        encodedImages.map((encodedImage) => NasaImage.fromJson(jsonDecode(encodedImage))).toList(),
      );
      _translateFavorites(Get.locale?.languageCode ?? 'en');
    }
  }

  void toggleLayout() {
    isGridLayout.value = !isGridLayout.value;
  }

  void updateLanguage(String languageCode) {
    _translateFavorites(languageCode);
  }

  Future<void> _translateFavorites(String targetLanguage) async {
    isLoading(true);
    for (var i = 0; i < favoriteImages.length; i++) {
      final image = favoriteImages[i];
      final translatedTitle = await _translateText(image.title, targetLanguage);
      final translatedDescription = await _translateText(image.description, targetLanguage);

      favoriteImages[i] = NasaImage(
        title: translatedTitle,
        date: image.date,
        description: translatedDescription,
        imageUrlHD: image.imageUrlHD,
        imageUrl: image.imageUrl,
      );
    }
    _saveFavorites();
    isLoading(false);
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    try {
      final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2')
            .replace(queryParameters: {
              'q': text,
              'target': targetLanguage,
              'key': _googleTranslateApiKey,
            }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        return text; // Retorna o texto original em caso de falha na tradução
      }
    } catch (e) {
      return text; // Retorna o texto original em caso de exceção
    }
  }
}
