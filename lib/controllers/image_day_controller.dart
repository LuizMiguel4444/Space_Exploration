import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/nasa_image.dart';

class ImageDayController extends GetxController {
  var imageOfTheDay = NasaImage(
    title: '',
    date: '',
    description: '',
    imageUrlHD: '',
    imageUrl: '',
  ).obs;
  var isLoading = false.obs;

  final String _googleTranslateApiKey = 'AIzaSyDFOl_kuFleMqKRAnvE8McG6XY2JKcxZVw';

  @override
  void onInit() {
    fetchImageOfTheDay();
    super.onInit();
  }

  void fetchImageOfTheDay() async {
    isLoading(true);
    try {
      final response = await http.get(
        Uri.parse('https://api.nasa.gov/planetary/apod?api_key=t3SsIs2r23ufLDzlS9qHAZqoszVvSSwOPODaXcTc&date'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedImage = NasaImage.fromJson(data);

        String extension = fetchedImage.imageUrlHD.split('.').last.toLowerCase();
        if (extension == 'png' || extension == 'gif' || extension == 'jpg' || extension == 'jpeg') {
          // Translate the content
          final translatedTitle = await _translateText(fetchedImage.title, Get.locale?.languageCode ?? 'en');
          final translatedDescription = await _translateText(fetchedImage.description, Get.locale?.languageCode ?? 'en');

          imageOfTheDay(NasaImage(
            title: translatedTitle,
            date: fetchedImage.date,
            description: translatedDescription,
            imageUrlHD: fetchedImage.imageUrlHD,
            imageUrl: fetchedImage.imageUrl,
          ));
        }
      } else {
        Get.snackbar('Error', 'Failed to load image of the day');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image of the day');
    } finally {
      isLoading(false);
    }
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
