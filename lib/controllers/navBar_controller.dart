import 'package:get/get.dart';

class NavBarController extends GetxController {
  var currentIndex = 1.obs;
}

final navBarController = Get.put(NavBarController());
