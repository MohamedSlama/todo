import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'ui/pages/home_page.dart';
import 'ui/theme.dart';

void main() async {
  runApp(const MyApp());
  //? For Initializing notification
  WidgetsFlutterBinding.ensureInitialized();
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
