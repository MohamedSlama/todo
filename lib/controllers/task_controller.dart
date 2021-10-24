import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  //? obs to change list to stream => converted to rxList
  final RxList<Task> taskList = <Task>[].obs;

  //?? return all tasks
  Future<void> getTasks() async{
    final tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((e) => Task.fromMap(e)).toList());
  }

  //? add task to database
  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task);
  }

  //? delete task from database
  deleteTasks({Task? task}) async{
    await DBHelper.delete(task);
    getTasks();
  }

  //? update database
  markTaskCompleted(int id) async{
    await DBHelper.update(id);
    getTasks();
  }
}
