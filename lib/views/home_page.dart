import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import '../controllers/space_controller.dart';
import '../controllers/navBar_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/favorite_controller.dart';
//import '../controllers/language_controller.dart';
import '../data/dataService.dart';
import '../models/nasa_image.dart';
import 'image_details_page.dart';
import 'favorite_page.dart';
import 'image_day_page.dart';

// ignore: use_key_in_widget_constructors
class HomePage extends StatelessWidget {
  final SpaceController controller = Get.put(SpaceController());
  final ThemeController themeController = Get.put(ThemeController());
  final NavBarController navBarController = Get.put(NavBarController());
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_typing_uninitialized_variables
    return Scaffold(
      appBar: MyNewAppBar(),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            await controller.fetchNasaImages();
          },
          child: controller.isLoading.value || controller.isTranslating.value
            ? Center(
              child: Lottie.asset(
                'assets/loading.json',
                width: 400,
                height: 500,
                fit: BoxFit.fill,
              ),
            )
            : ValueListenableBuilder(
                valueListenable: dataService.tableStateNotifier,
                builder: (_, value, __) {
                  if (value['status'] == TableStatus.error) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Center(
                            child: Text("errorLoadingData".tr),
                          ),
                        ),
                      ],
                    );
                  }
                  return Obx(() => themeController.isGridLayout.value ? SecundaryLayout() : MainLayout());
                },
              ),
        );
      }),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: appController.notchBottomBarController,
        onTap: (index) async {
          if (navBarController.currentIndex.value == 1 && index == 1) {
            return;
          }
          if (index == 0) {
            await Future.delayed(const Duration(milliseconds: 320));
            Get.to(() => ImageDayPage())!.then((_) {
              navBarController.currentIndex.value = 1;
              appController.notchBottomBarController.jumpTo(1);
            });
          } else if (index == 1 && Get.currentRoute != '/') {
            Get.offAll(HomePage());
          } else if (index == 2) {
            await Future.delayed(const Duration(milliseconds: 320));
            Get.to(() => FavoritePage())!.then((_) {
              navBarController.currentIndex.value = 1;
              appController.notchBottomBarController.jumpTo(1);
            });
          }
        },
        bottomBarItems: [
          BottomBarItem(
            activeItem: const Icon(Icons.today, color: Color.fromARGB(255, 255, 0, 0)),
            inActiveItem: const Icon(Icons.today, color: Colors.grey),
            itemLabel: "today".tr,
          ),
          BottomBarItem(
            activeItem: Icon(Icons.public, color: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch),
            inActiveItem: const Icon(Icons.public, color: Colors.grey),
            itemLabel: "home".tr,
          ),
          BottomBarItem(
            activeItem: const Icon(Icons.star, color: Color.fromARGB(255, 255, 220, 0)),
            inActiveItem: const Icon(Icons.star, color: Colors.grey),
            itemLabel: "favorites".tr,
          ),
        ],
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        showLabel: false,
        blurOpacity: 0.75,
        blurFilterX: 10.0,
        blurFilterY: 20.0,
        kIconSize: 24,
        kBottomRadius: 32,
        notchColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    );
  }
}

class MyNewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SpaceController spaceController = Get.put(SpaceController());
  final ThemeController themeController = Get.find<ThemeController>();
  final AppController appController = Get.find<AppController>();

  // ignore: use_key_in_widget_constructors
  MyNewAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
      title: Container(
        //alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 26),
        child: Text(
          'appTitle'.tr,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
          ),
        ),
      ),
      actions: [
        Obx(() => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            icon: Icon(
                themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: () {
              themeController.toggleTheme();
            },
          )),
        ),
        Obx(() => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            icon: Icon(
              themeController.isGridLayout.value ? Icons.list : Icons.grid_on,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              themeController.toggleLayout();
            },
          )),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20),
          child: PopupMenuButton<String>(
            onSelected: (String value) async {
              if (Get.locale?.languageCode == value) {
                return;
              }
              spaceController.isTranslating.value = true;
              try {
                if (value == 'en') {
                  Get.updateLocale(const Locale('en', 'US'));
                  Get.find<FavoriteController>().updateLanguage('en');
                  await spaceController.updateLanguage('en');
                } else if (value == 'pt') {
                  Get.updateLocale(const Locale('pt', 'BR'));
                  Get.find<FavoriteController>().updateLanguage('pt');
                  await spaceController.updateLanguage('pt');
                }
                //await LanguageService.saveLanguageCode(value);
              } finally {
                spaceController.isTranslating.value = false;
              }
            },
            icon: Icon(
              Icons.language,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'en',
                  child: Text("english".tr),
                ),
                PopupMenuItem(
                  value: 'pt',
                  child: Text("portuguese".tr),
                ),
              ];
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

// ignore: use_key_in_widget_constructors
class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataService.tableStateNotifier,
      builder: (_, value, __) {
        switch (value['status']) {
          case TableStatus.idle:
            return Center(child: Text("idleMessage".tr));
          case TableStatus.loading:
            return Center(
              child: Lottie.asset(
                'assets/loading.json',
                width: 400,
                height: 500,
                fit: BoxFit.fill,
              ),
            );
          case TableStatus.ready:
            var nasaImages = value['dataObjects'] as List<NasaImage>;
            return ListView.builder(
              itemCount: nasaImages.length,
              itemBuilder: (context, index) {
                final image = nasaImages[index];
                final locale = Get.locale?.languageCode ?? 'en';
                final formattedDate = DateFormat.yMMMMd(locale).format(DateTime.parse(image.date));
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 8,
                  shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : null,
                  color: Theme.of(context).brightness == Brightness.dark ? null : Colors.grey[300],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          image.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                      : null,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 100);
                          },
                        ),
                      ],
                    ),
                    title: Text(
                      image.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formattedDate),
                    onTap: () {
                      Get.to(() => ImageDetailsPage(image: image));
                    },
                  ),
                );
              },
            );
          case TableStatus.error:
            return Center(child: Text("errorLoadingData".tr));
        }
        return const Center(child: Text(""));
      },
    );
  }
}

// ignore: use_key_in_widget_constructors
class SecundaryLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataService.tableStateNotifier,
      builder: (_, value, __) {
        switch (value['status']) {
          case TableStatus.idle:
            return Center(child: Text("idleMessage".tr));
          case TableStatus.loading:
            return Center(
              child: Lottie.asset(
                'assets/loading.json',
                width: 400,
                height: 500,
                fit: BoxFit.fill,
              ),
            );
          case TableStatus.ready:
            var nasaImages = value['dataObjects'] as List<NasaImage>;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: nasaImages.length,
              itemBuilder: (context, index) {
                final image = nasaImages[index];              
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ImageDetailsPage(image: image));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 12,
                    shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : null,
                    color: Theme.of(context).brightness == Brightness.dark ? null : Colors.grey[300],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GridTile(
                        footer: GridTileBar(
                          backgroundColor: Colors.black45,
                          title: Text(image.title),
                        ),
                        child: Image.network(
                          image.imageUrl,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                    : null,
                                color: Colors.grey[500],
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          case TableStatus.error:
            return Center(child: Text("errorLoadingData".tr));
        }
        return const Center(child: Text(""));
      },
    );
  }
}

class AppController extends GetxController {
  final NotchBottomBarController notchBottomBarController = NotchBottomBarController(index: 1);
}
