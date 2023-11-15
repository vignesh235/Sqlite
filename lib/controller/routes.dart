import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:local_db/home_page.dart';
import 'package:local_db/item_list.dart';

class Routes {
  static String items = '/Item';
  static String homepage = '/homepage';
}

final getPages = [
  GetPage(
    name: Routes.items,
    page: () => const ItemList(),
  ),
  GetPage(
    name: Routes.homepage,
    page: () => const HomePage(),
  ),
];
