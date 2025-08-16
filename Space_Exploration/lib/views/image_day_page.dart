// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../controllers/image_day_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/navBar_controller.dart';
import '../controllers/theme_controller.dart';
import '../views/image_details_page.dart';

class ImageDayPage extends StatelessWidget {
  final ImageDayController imageDayController = Get.put(ImageDayController());
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  Future<void> _downloadImage(String imageUrlHD, String imageTitle) async {
    try {
      // Baixe a imagem
      var response = await Dio().get(
        imageUrlHD,
        options: Options(responseType: ResponseType.bytes),
      );

      // Obtenha o diretório temporário
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$imageTitle.jpg').create();
      file.writeAsBytesSync(response.data);

      // Salve a imagem na galeria
      final result = await ImageGallerySaverPlus.saveFile(file.path);
      if (result['isSuccess']) {
        Get.snackbar("Success".tr, "Image saved to gallery!".tr,
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Error".tr, "Failed to save image.".tr,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to download image.".tr,
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navBarController.currentIndex.value = 1;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? customSwatchSecundary
              : customSwatch,
          iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          title: Text(
            'imageOfTheDay'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          actions: [
            Obx(() {
              if (imageDayController.isLoading.value ||
                  imageDayController.imageOfTheDay.value.imageUrlHD.isEmpty) {
                return Container();
              } else {
                final image = imageDayController.imageOfTheDay.value;
                bool isFavorite = favoriteController.isFavorite(image);
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.red
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          favoriteController.removeFavorite(image);
                        } else {
                          favoriteController.addFavorite(image);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.download, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      onPressed: () => _downloadImage(image.imageUrlHD, image.title),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
        body: Obx(() {
          if (imageDayController.isLoading.value) {
            return Center(
              child: Lottie.asset(
                'assets/loading.json',
                width: 400,
                height: 500,
                fit: BoxFit.fill,
              ),
            );
          } else if (imageDayController.imageOfTheDay.value.imageUrlHD.isEmpty) {
            return Center(
                child: Text('noImageForToday'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold)));
          } else {
            final image = imageDayController.imageOfTheDay.value;
            final locale = Get.locale?.languageCode ?? 'en';
            final formattedDate =
                DateFormat.yMMMMd(locale).format(DateTime.parse(image.date));
            return Stack(
              children: [
                // Background image
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image.imageUrlHD),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                // Content
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ImageZoomPage(image: image),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'imageHero',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Container(
                                      width: 650.0,
                                      height: 420.0,
                                      color: Colors.grey[300],
                                      child: Image.network(
                                        image.imageUrlHD,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: progress.expectedTotalBytes !=
                                                      null
                                                  ? progress
                                                          .cumulativeBytesLoaded /
                                                      (progress.expectedTotalBytes ??
                                                          1)
                                                  : null,
                                              color: Colors.grey[500],
                                            ),
                                          );
                                        },
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                image.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.travel_explore, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "clickToZoom".tr,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "description".tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                image.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
