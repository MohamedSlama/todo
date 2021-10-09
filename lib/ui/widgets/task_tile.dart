import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/size_config.dart';
import '../theme.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({Key? key,required this.task}) : super(key: key);
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      //? Configure view according to screen orientation and screen size
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(
              SizeConfig.orientation == Orientation.landscape ? 4 : 20)),
      width: SizeConfig.orientation == Orientation.landscape
          ? SizeConfig.screenWidth / 2
          : SizeConfig.screenWidth,
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        //? Background according to user choice between three fixed colors
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task.color),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //? Note title
                    Text(task.title!,
                        style: taskTileTextStyle(
                            size: 16,
                            color: Colors.white,
                            bold: FontWeight.bold)),
                    //? Vertical space
                    const SizedBox(height: 12),
                    //? Row of icon and start and end time of note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: Colors.grey[200], size: 18),
                        const SizedBox(width: 12),
                        Text(
                          '${task.startTime} - ${task.endTime}',
                          style: taskTileTextStyle(size: 12),
                        ),
                      ],
                    ),
                    //? Vertical space
                    const SizedBox(height: 12),
                    //? Note body
                    Text(task.note!, style: taskTileTextStyle(size: 13)),
                  ],
                ),
              ),
            ),
            //? Vertical line between rotated text and note area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey[200]!.withOpacity(0.7),
            ),
            //? Rotated text to right size with 270°
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task.isCompleted == 0 ? 'TODO' : 'Completed',
                style: rotatedTextStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //? returns color of note 0,1,2
  _getBGClr(int? color) {
    switch (color) {
      case 0:
        return bluishClr;
      case 1:
        return pinkClr;
      case 2:
        return orangeClr;
      default:
        return primaryClr;
    }
  }
}
