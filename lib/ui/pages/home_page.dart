import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';

import 'add_task_page.dart';
import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyButton(
                label: 'Add Task',
                onTap: () {
                  Get.to(const AddTaskPage());
                }),
            const InputField(
              title: 'Title',
              hint: 'Write something here !!',
              widget: Icon(Icons.access_alarm),
            ),
          ],
        ),
      ),
    );
  }
}
