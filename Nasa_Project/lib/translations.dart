import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'appTitle': 'Space Exploration',
      'favorites': 'Favorites',
      'today': 'Today',
      'home': 'Home',
      'noFavoritesAdded': 'No favorites added',
      'clickToZoom': 'Click the image to zoom',
      'description': 'Description:',
      'refresh': 'Refresh',
      'errorLoadingData': 'Error loading data',
      'idleMessage': 'Tap the reload button',
      'loadingMessage': 'Loading...',
      'imageOfTheDay': 'Image of the Day',
      'noImageForToday': 'No image for today',
      "english": "English",
      "portuguese": "Portuguese",
      "Image saved to gallery!": "Image saved to gallery!",
      "Failed to save image.": "Failed to save image.",
      "Failed to download image.": "Failed to download image.",
      "Success": "Success",
      "Error": "Error",
    },
    'pt_BR': {
      'appTitle': 'Exploração Espacial',
      'favorites': 'Favoritos',
      'today': 'Hoje',
      'home': 'Início',
      'noFavoritesAdded': 'Nenhum favorito adicionado',
      'clickToZoom': 'Clique na imagem para dar zoom',
      'description': 'Descrição:',
      'refresh': 'Recarregar',
      'errorLoadingData': 'Erro ao carregar dados',
      'idleMessage': 'Toque no botão de recarregar',
      'loadingMessage': 'Carregando...',
      'imageOfTheDay': 'Imagem do Dia',
      'noImageForToday': 'Não tem imagem para o dia de hoje.',
      "english": "Inglês",
      "portuguese": "Português",
      "Image saved to gallery!": "Imagem salva na galeria!",
      "Failed to save image.": "Falha ao salvar a imagem.",
      "Failed to download image.": "Falha ao baixar a imagem.",
      "Success": "Sucesso",
      "Error": "Erro",
    },
  };
}
