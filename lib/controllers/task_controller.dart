import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  final takList = <Task>[
    Task(
        title: 'Title 1',
        note: 'Note something',
        isCompleted: 1,
        startTime: DateFormat('hh:mm a')
            .format(DateTime.now().add(const Duration(minutes: 1))),
        color: 0)
  ];

  //   //? Dummy Data for testing
  //   Task(
  //     title: 'Title 1',
  //     note: 'Note something',
  //     isCompleted: 0,
  //     startTime: '8:10',
  //     endTime: '10:00',
  //     color: 0
  //   ),Task(
  //       title: 'Title 2',
  //       note: 'Note something',
  //       isCompleted: 1,
  //       startTime: '8:10',
  //       endTime: '10:00',
  //       color: 1
  //   ),Task(
  //       title: 'Title 3',
  //       note: 'Note something',
  //       isCompleted: 2,
  //       startTime: '8:10',
  //       endTime: '10:00',
  //       color: 2
  //   )
  @override
  void onReady() {
    super.onReady();
  }

  addTask({Task? task}) => null;

  getTasks() => null;
}
