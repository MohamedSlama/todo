import 'dart:io';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    //? Load tasks from db
    _taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //? Change theme
            ThemeServices().changeThemeMode();

            // //? Display Notification
            // notifyHelper.displayNotification(
            //     title: 'Theme changed', body: 'App theme has been changed!');
            // //? Schedule another notification after 5 seconds
            // //+ For testing scheduled
            // notifyHelper.scheduledNotification();
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
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 6),

          Obx(() {
            if (_taskController.taskList.isEmpty)
              return _noTaskMessage();
            else
              return _showTasks();
          }),
          // _taskController.taskList.isNotEmpty ? _showTasks() : _noTaskMessage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('Done', 'All tasks have been removed !',
              snackPosition: SnackPosition.BOTTOM);
          notifyHelper.deleteAllNotifications();
          _taskController.deleteAllTasks();
        },
        child: const Icon(Icons.cleaning_services_outlined),
      ),
    );
  }

  //? refresh database tasks
  Future<void> _onRefresh() async => _taskController.getTasks();

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
                _taskController.getTasks();
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
  _showTasks() => Expanded(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            scrollDirection: (SizeConfig.orientation == Orientation.landscape)
                ? Axis.horizontal
                : Axis.vertical,
            itemBuilder: (context, index) {
              //? task item from tasks list
              var _task = _taskController.taskList[index];
              if (_task.repeat == 'Daily' ||
                  _task.date == DateFormat.yMd().format(_selectedDate) ||
                  (_task.repeat == 'Weekly' &&
                      _selectedDate
                                  .difference(
                                      DateFormat.yMd().parse(_task.date!))
                                  .inDays %
                              7 ==
                          0) ||
                  (_task.repeat == 'Monthly' &&
                      DateFormat.yMd().parse(_task.date!).day ==
                          _selectedDate.day)) {
                //? Get hour and minutes from string e.g 15:30
                int hour = int.parse(
                    _timeConverter(_task.startTime!).toString().split(':')[0]);
                int minutes = int.parse(
                    _timeConverter(_task.startTime!).toString().split(':')[1]);

                //? Schedule notification
                notifyHelper.scheduledNotification(hour, minutes, _task);

                //? Animation from library flutter_staggered_animations
                return AnimationConfiguration.staggeredList(
                  duration: const Duration(milliseconds: 800),
                  position: index,
                  child: SlideAnimation(
                    horizontalOffset: 300,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          _showBottomSheet(context, _task);
                        },
                        child: TaskTile(
                          task: _task,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
            itemCount: _taskController.taskList.length,
          ),
        ),
      );

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

  //? show bottom sheet
  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape)
              ? (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.6
                  : SizeConfig.screenHeight * 0.8)
              : (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.30
                  : SizeConfig.screenHeight * 0.39),
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: 'Task Completed',
                      onTap: () {
                        _taskController.markTaskCompleted(task.id!);
                        notifyHelper.deleteNotification(task.id!);
                        Get.back();
                      },
                      color: primaryClr),
              _buildBottomSheet(
                  label: 'Delete Task',
                  onTap: () {
                    _taskController.deleteTasks(task: task);
                    notifyHelper.deleteNotification(task.id!);
                    Get.back();
                  },
                  color: Colors.red[300]!),
              Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
              _buildBottomSheet(
                  label: 'Cancel',
                  onTap: () {
                    Get.back();
                  },
                  color: primaryClr),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //? build bottom sheet item
  _buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color color,
    bool isClose = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 65,
          width: SizeConfig.screenWidth * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isClose
                  ? (Get.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!)
                  : color,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isClose ? Colors.transparent : color,
          ),
          child: Center(
            child: Text(label,
                style: isClose
                    ? titleStyle
                    : titleStyle.copyWith(color: Colors.white)),
          ),
        ),
      );

  _timeConverter(String time) {
    var date = DateFormat.jm().parse(time);
    return DateFormat('HH:mm').format(date);
  }
}
