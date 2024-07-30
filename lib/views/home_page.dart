import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../controllers/space_controller.dart';
import '../controllers/navBar_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/favorite_controller.dart';
import '../data/dataService.dart';
import '../models/nasa_image.dart';
import 'image_details_page.dart';
import 'favorite_page.dart';
import 'image_day_page.dart';

class HomePage extends StatelessWidget {
  final SpaceController controller = Get.put(SpaceController());
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyNewAppBar(),
      body: Obx(() {
        if (controller.isLoading.value || controller.isTranslating.value) {
          return Center(
            child: Lottie.asset(
              'assets/loading.json',
              width: 400,
              height: 500,
              fit: BoxFit.fill,
            ),
          );
        }
        if (themeController.isGridLayout.value) {
          return SecundaryLayout();
        } else {
          return MainLayout();
        }
      }),
      bottomNavigationBar: NewNavBar(
        itemSelectedCallback: (index) {
          if (index == 0) {
            Get.to(() => ImageDayPage());
          } else if (index == 1 && Get.currentRoute != '/') {
            Get.offAll(HomePage());
          } else if (index == 2) {
            Get.to(() => FavoritePage());
          }
        },
        icons: [
          Icons.today,
          Icons.public,
          Icons.star,
        ],
        iconColors: [
          Color.fromARGB(255, 255, 0, 0),
          Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
          Color.fromARGB(255, 255, 220, 0),
        ],
        labels: ["today".tr, "home".tr, "favorites".tr],
      ),
    );
  }
}

class MyNewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SpaceController spaceController = Get.put(SpaceController());
  final ThemeController themeController = Get.find<ThemeController>();

  MyNewAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
      leading: IconButton(
        icon: Icon(Icons.refresh),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        onPressed: () {
          spaceController.fetchNasaImages();
        },
      ),
      title: Text(
        'appTitle'.tr,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(() => IconButton(
          icon: Icon(
              themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          onPressed: () {
            themeController.toggleTheme();
          },
        )),
        Obx(() => IconButton(
          icon: Icon(
            themeController.isGridLayout.value ? Icons.list : Icons.grid_on,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            themeController.toggleLayout();
          },
        )),
        PopupMenuButton<String>(
          onSelected: (String value) async {
            if (Get.locale?.languageCode == value) {
              return;
            }
            spaceController.isTranslating.value = true;
            try {
              if (value == 'en') {
                Get.updateLocale(Locale('en', 'US'));
                Get.find<FavoriteController>().updateLanguage('en');
                await spaceController.updateLanguage('en');
              } else if (value == 'pt') {
                Get.updateLocale(Locale('pt', 'BR'));
                Get.find<FavoriteController>().updateLanguage('pt');
                await spaceController.updateLanguage('pt');
              }
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

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
                print(image.imageUrl);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 8,
                  color: Theme.of(context).brightness == Brightness.dark ? null : Colors.grey[300],
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
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
                            return Container(
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
                            return Icon(Icons.error, size: 100);
                          },
                        ),
                      ],
                    ),
                    title: Text(
                      image.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
        return Center(child: Text(""));
      },
    );
  }
}

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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              padding: EdgeInsets.all(25),
              itemCount: nasaImages.length,
              itemBuilder: (context, index) {
                final image = nasaImages[index];              
                print(image.imageUrl);
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ImageDetailsPage(image: image));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 12,
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
                            return Icon(Icons.error);
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
        return Center(child: Text(""));
      },
    );
  }
}

class NewNavBar extends HookWidget {
  final void Function(int)? itemSelectedCallback;
  final List<IconData> icons;
  final List<Color> iconColors;
  final List<String> labels;

  NewNavBar({
    required this.icons,
    required this.iconColors,
    required this.labels,
    this.itemSelectedCallback,
  });

  @override
  Widget build(BuildContext context) {
    assert(icons.length == labels.length && icons.length == iconColors.length);

    return Obx(() {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (navBarController.currentIndex.value == 1 && index == 1) {
            return;
          }
          navBarController.currentIndex.value = index;
          itemSelectedCallback?.call(index);
        },
        currentIndex: navBarController.currentIndex.value,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
        elevation: 15,
        selectedIconTheme: IconThemeData(size: 32),
        unselectedIconTheme: IconThemeData(size: 25),
        items: List.generate(icons.length, (index) {
          return BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: index == navBarController.currentIndex.value ? 0 : 10),
              child: Icon(
                icons[index],
                color: iconColors[index]
              ),
            ),
            label: labels[index],
          );
        }),
      );
    });
  }
}
