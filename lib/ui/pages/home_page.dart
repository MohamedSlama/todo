import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/services/theme_services.dart';

import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //? Testing UI with changing theme mode
        leading: IconButton(
          onPressed: () {
            ThemeServices().changeThemeMode();
            Get.to(const NotificationScreen(
                payload: 'Hello| notification screen|27/12/2012'));
          },
          icon: const Icon(Icons.nightlight_round),
        ),
      ),
      body: Container(),
    );
  }
}
