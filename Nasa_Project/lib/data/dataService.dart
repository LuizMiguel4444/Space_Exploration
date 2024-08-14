import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nasa_image.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
  int _selectedQuantity = 10;
  final int _batchSize = 5;
  final String _googleTranslateApiKey = 'AIzaSyDFOl_kuFleMqKRAnvE8McG6XY2JKcxZVw';
  Map<String, Map<String, String>> _translationCache = {};

  DataService() {
    _loadTranslationCache();
  }

  void setSelectedQuantity(int quantity) {
    _selectedQuantity = quantity;
  }

  Future<void> carregarNasaImages() async {
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': []
    };

    List<NasaImage> allNasaImages = [];

    try {
      for (int i = 0; i < (_selectedQuantity / _batchSize).ceil(); i++) {
        var batchImages = await _fetchNasaImages(_batchSize);
        allNasaImages.addAll(batchImages);

        if (allNasaImages.length >= _selectedQuantity) {
          break;
        }
      }

      var validImages = allNasaImages.where((image) {
        String extension = image.imageUrlHD.split('.').last.toLowerCase();
        return extension == 'png' || extension == 'gif' || extension == 'jpg' || extension == 'jpeg';
      }).toList();

      validImages = validImages.take(_selectedQuantity).toList();

      var translatedImages = await translateImages(validImages, Get.locale?.languageCode ?? 'en');

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': translatedImages,
      };
    } catch (err) {
      tableStateNotifier.value = {
        'status': TableStatus.error,
        'dataObjects': []
      };
    }
  }

  Future<List<NasaImage>> _fetchNasaImages(int count) async {
    var nasaUri = Uri(
      scheme: 'https',
      host: 'api.nasa.gov',
      path: 'planetary/apod',
      queryParameters: {
        'api_key': 't3SsIs2r23ufLDzlS9qHAZqoszVvSSwOPODaXcTc',
        'count': '$count'
      },
    );

    var response = await http.get(nasaUri);

    if (response.statusCode == 200) {
      var nasaJson = jsonDecode(response.body);
      return (nasaJson as List).map((json) => NasaImage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load NASA images');
    }
  }

  Future<List<NasaImage>> translateImages(List<NasaImage> images, String targetLanguage) async {
    List<Future<NasaImage>> translationFutures = [];

    for (var image in images) {
      translationFutures.add(_translateImage(image, targetLanguage));
    }

    return await Future.wait(translationFutures);
  }

  Future<NasaImage> _translateImage(NasaImage image, String targetLanguage) async {
    String translatedTitle;
    String translatedDescription;

    if (_translationCache.containsKey(image.title) && _translationCache[image.title]!.containsKey(targetLanguage)) {
      translatedTitle = _translationCache[image.title]![targetLanguage]!;
      translatedDescription = _translationCache[image.description]![targetLanguage]!;
    } else {
      translatedTitle = await _translateText(image.title, targetLanguage);
      translatedDescription = await _translateText(image.description, targetLanguage);

      _translationCache.putIfAbsent(image.title, () => {})[targetLanguage] = translatedTitle;
      _translationCache.putIfAbsent(image.description, () => {})[targetLanguage] = translatedDescription;

      _saveTranslationCache();
    }

    return NasaImage(
      title: translatedTitle,
      date: image.date,
      description: translatedDescription,
      imageUrlHD: image.imageUrlHD,
      imageUrl: image.imageUrl,
    );
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

  Future<void> _loadTranslationCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('translationCache');
    if (cacheString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(cacheString);
      _translationCache = jsonMap.map((key, value) {
        final Map<String, String> innerMap = Map<String, String>.from(value);
        return MapEntry(key, innerMap);
      });
    }
  }

  Future<void> _saveTranslationCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = jsonEncode(_translationCache);
    await prefs.setString('translationCache', cacheString);
  }

  Future<void> translateCurrentImages(String targetLanguage) async {
    var currentImages = tableStateNotifier.value['dataObjects'] as List<NasaImage>;
    var translatedImages = await translateImages(currentImages, targetLanguage);

    tableStateNotifier.value = {
      'status': TableStatus.ready,
      'dataObjects': translatedImages,
    };
  }
}

final dataService = DataService();
