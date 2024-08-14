// ignore_for_file: file_names

import 'package:get/get.dart';

class NavBarController extends GetxController {
  var currentIndex = 1.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }
}

final navBarController = Get.put(NavBarController());
