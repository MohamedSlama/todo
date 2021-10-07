import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo/services/theme_services.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/notification_screen.dart';
import 'ui/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      home: const HomePage(),
    );
  }
}
