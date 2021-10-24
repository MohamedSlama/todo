import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final DateTime _selectedDate = DateTime.now();
  final String _startTime =
      DateFormat('hh:mm a').format(DateTime.now()).toString();
  final String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: primaryClr, size: 24),
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //? Screen body title
              Text('Add Task', style: headingStyle),
              //? Title field with "_titleController"
              InputField(
                  title: 'Title',
                  hint: 'Enter title here',
                  controller: _titleController),
              //? Note field with "_noteController"
              InputField(
                  title: 'Note',
                  hint: 'Enter note here',
                  controller: _noteController),
              //? Date field with "Icon Widget"
              InputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              //? Start Time and End Time fields with "Icon Widgets and drop down menu"
              Row(
                children: [
                  //? Start Time
                  Expanded(
                    child: InputField(
                      title: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  //? Horizontal Space
                  const SizedBox(
                    width: 12,
                  ),
                  //? End Time
                  Expanded(
                    child: InputField(
                      title: 'End Time',
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //? Remind field with "Icon Widget and drop down menu""
              InputField(
                title: 'Remind',
                hint: '$_selectedRemind minutes early',
                widget: Row(
                  children: [
                    DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.blueGrey.withOpacity(0.5),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(height: 0),
                      style: subTitleStyle,
                      items: remindList
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedRemind = newValue!;
                        });
                      },
                    ),
                    //? Space between border and icon
                    const SizedBox(width: 6),
                  ],
                ),
              ),
              //? Repeat field with "Icon Widget and drop down menu"
              InputField(
                title: 'Repeat',
                hint: _selectedRepeat,
                widget: Row(
                  children: [
                    DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.blueGrey.withOpacity(0.5),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(height: 0),
                      style: subTitleStyle,
                      items: repeatList
                          .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value',
                                  style: const TextStyle(color: Colors.white))))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                        });
                      },
                    ),
                    //? Space between border and icon
                    const SizedBox(width: 6),
                  ],
                ),
              ),
              //? Vertical space between body and Colors area
              const SizedBox(height: 18),
              //? Choose Color of task and create new task
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                //? Color area
                children: [
                  Column(
                    children: [
                      //? Title
                      Text('Color', style: titleStyle),
                      //? space between colors and title
                      const SizedBox(height: 8),
                      //? Colors icons
                      _colorPalette(),
                    ],
                  ),
                  //? Add task button
                  MyButton(label: 'Create Task', onTap: () => _validateDate())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTasksToDb();
      Get.back();
    } else if (_titleController.text.isNotEmpty ||
        _noteController.text.isNotEmpty) {
      Get.snackbar(
        'Required',
        'All fields are required!!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      );
    } else {
      print('########### Something went wrong ###########');
    }
  }

  _addTasksToDb() async {
    int value = await _taskController.addTask(
      task: Task(
        //? title controller is input text controller
        title: _titleController.text,
        note: _noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
      ),
    );
    //? should print task id in DB
    print('Done adding value: $value');
  }

  _colorPalette() => Wrap(
        children: List.generate(
          3,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: index == 0
                    ? primaryClr
                    : index == 1
                        ? pinkClr
                        : orangeClr,
                child: _selectedColor == index
                    ? const Icon(Icons.done, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ),
      );
}
