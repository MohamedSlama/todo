import 'dart:io';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';
import 'package:todo/ui/widgets/task_tile.dart';

import '../theme.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO after
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();

  //? Notification Helper
  late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    // //? Check if platform is ios request permissions
    // if (Platform.isIOS) notifyHelper.requestIOSPermission();
    //? Initialize notification for usage
    notifyHelper.initializationNotification();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          /*
          TODO
          + change theme
          + display notification
          + display another one after 5 seconds
          */
          onPressed: () {
            //? Change theme
            ThemeServices().changeThemeMode();
            //? Display Notification
            notifyHelper.displayNotification(
                title: 'Theme changed', body: 'App theme has been changed!');
            //? Schedule another notification after 5 seconds
            //+ For testing scheduled
            notifyHelper.scheduledNotification();
          },
          // onPressed: () => ThemeServices().changeThemeMode(),
          icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
            size: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        actions: const [
          //? Avatar image
          CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
            radius: 18,
          ),
          //? Space between screen border and avatar
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ////TODO: _addTaskBar
            _addTaskBar(),
            //TODO: _addDateBar
            _addDateBar(),
            //? Vertical Space above tasks
            const SizedBox(height: 6),
            //TODO: _showTasks
            //- isTask pass true
            //- noTask pass false
            _showTasks(isTask: true),
          ],
        ),
      ),
    );
  }

  //? invoke tasks bar
  _addTaskBar() => Container(
        margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: headingStyle),
                Text('Today', style: subHeadingStyle),
              ],
            ),
            MyButton(
              label: '+ Add Task',
              onTap: () async {
                await Get.to(const AddTaskPage());
                //Todo result from add task !!
              },
            )
          ],
        ),
      );

  //? invoke date bar
  _addDateBar() => Container(
        margin: const EdgeInsets.only(top: 6, left: 20),
        child: DatePicker(
          DateTime.now(),
          width: 70,
          height: 100,
          initialSelectedDate: DateTime.now(),
          selectedTextColor: Colors.white,
          selectionColor: primaryClr,
          dateTextStyle: datePickerStyle(size: 20),
          dayTextStyle: datePickerStyle(size: 16),
          monthTextStyle: datePickerStyle(size: 12),
          onDateChange: (newDate) {
            setState(() {
              _selectedDate = newDate;
            });
          },
        ),
      );

  //? invoke tasks
  _showTasks({required isTask}) => isTask
      ? TaskTile(
          task: Task(
            id: 1,
            title: 'Title 1',
            note: 'Note something',
            isCompleted: 0,
            startTime: '8:18',
            endTime: '2:40',
            color: 2,
          ),
        )
      : _noTaskMessage();

  //? no task
  _noTaskMessage() => Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  //? distance between image and text vertically and horizontally
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 220),
                  //? SVG Image
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    semanticsLabel: 'Task',
                    color: primaryClr.withOpacity(0.5),
                  ),
                  //? Text area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'You do not have any tasks yet!\nAdd new tasks to make your days productive.',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //? Distance between screen bottom and text
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 120)
                      : const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      );
}
