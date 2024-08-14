import 'dart:ui';
import 'package:get/get.dart';
import '../data/dataService.dart';
import '../controllers/language_controller.dart';

class SpaceController extends GetxController {
  var isLoading = false.obs;
  var isTranslating = false.obs;

  @override
  void onInit() async {
    super.onInit();
    String? savedLanguageCode = await LanguageService.getLanguageCode();
    if (savedLanguageCode != null) {
      Get.updateLocale(Locale(savedLanguageCode));
    }
    fetchNasaImages();
  }

  Future<void> fetchNasaImages() async {
    try {
      isLoading.value = true;
      await dataService.carregarNasaImages();
    } catch (e) {
      dataService.tableStateNotifier.value = {
        'status': TableStatus.error,
        'message': e.toString()
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    isTranslating.value = true;
    await dataService.translateCurrentImages(languageCode);
    isTranslating.value = false;
  }
}
