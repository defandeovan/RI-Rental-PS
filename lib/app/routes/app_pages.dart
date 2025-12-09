import 'package:get/get.dart';
import 'package:psrental/app/modules/home/views/Register.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/Register.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Ubah INITIAL menjadi Routes.RegisterPage
  static const INITIAL = Routes.RegisterPage;

  static final routes = [
    // GetPage(
    //   name: _Paths.HOME,
    //   page: () => const HomeView(),
    //   binding: HomeBinding(),
    // ),
    // Tambahkan route untuk Register page
    GetPage(
      name: _Paths.RegisterPage,
      page: () => const Register(), // Pastikan nama class Register sesuai
    ),
  ];
}