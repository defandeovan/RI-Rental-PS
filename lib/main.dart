import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/views/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Reset Password",
      debugShowCheckedModeBanner: false,
      initialRoute: '/reset',
      getPages: [
        GetPage(
          name: '/reset',
          page: () => const ResetPasswordScreen(),
        ),
      ],
    );
  }
}