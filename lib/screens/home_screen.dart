import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/task_controller.dart';
import 'add_task_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final TaskController taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4355B9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            buildHeader(),
            SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTodayHeader(),
                    SizedBox(height: 20),
                    Expanded(
                      child: _buildTaskList(),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 40.0,
        ),
        child: FloatingActionButton(
          backgroundColor: Color(0xFFFF7B54),
          onPressed: () {
            Get.to(() => AddTaskScreen());
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeFilterBottomSheet() {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter Tasks by Time Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Start Time'),
                        subtitle:
                            Text(startTime?.format(Get.context!) ?? 'Not set'),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final time = await Get.dialog(
                            TimePickerDialog(
                              initialTime: startTime ?? TimeOfDay.now(),
                            ),
                          );
                          if (time != null) {
                            setState(() => startTime = time);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('End Time'),
                        subtitle:
                            Text(endTime?.format(Get.context!) ?? 'Not set'),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final time = await Get.dialog(
                            TimePickerDialog(
                              initialTime: endTime ?? TimeOfDay.now(),
                            ),
                          );
                          if (time != null) {
                            setState(() => endTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        taskController.clearTimeFilter();
                        Get.back();
                      },
                      icon: Icon(Icons.clear),
                      label: Text('Clear Filter'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (startTime != null && endTime != null) {
                          taskController.filterTasksByTimeRange(
                              startTime, endTime);
                          Get.back();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select both start and end time',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      icon: Icon(Icons.filter_alt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4355B9),
                      ),
                      label: Text('Apply Filter',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello,",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          Text(
            "Dzaki",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              onChanged: (value) => taskController.filterBySearchQuery(value),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search, color: Colors.white54),
                hintText: "Cari task...",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () => _showTimeFilterBottomSheet(),
            ),
          ],
        ),
        Align(
          heightFactor: 3,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 30,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFff8b60), width: 3),
                ),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return GetBuilder<TaskController>(
      builder: (controller) {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${controller.error}',
                  style: TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: controller.retryLoadTasks,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tasks = controller.filteredTasks;
        if (tasks.isEmpty) {
          return Center(
            child: Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                controller.removeTask(index);
                Get.snackbar(
                  'Success',
                  'Task deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: GestureDetector(
                onTap: () => Get.to(() => DetailScreen(task: task)),
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Color(0xFF4355B9).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.access_time,
                          color: task.isCompleted
                              ? Colors.green
                              : Color(0xFF4355B9),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${task.time.hour.toString().padLeft(2, '0')}:${task.time.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (task.imageUrl != null)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(task.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          controller.toggleTaskCompletion(index);
                        },
                        activeColor: Color(0xFF4355B9),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.checklist, true),
          _buildNavItem(Icons.access_time, false),
          _buildNavItem(Icons.calendar_today, false),
          _buildNavItem(Icons.settings, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: isSelected ? Color(0xFF4355B9) : Colors.grey,
      size: 28,
    );
  }

  Color _getIconColor(int index) {
    List<Color> colors = [
      Color(0xFFFFF1E6),
      Color(0xFFE6F4FF),
      Color(0xFFF2FFE6),
      Color(0xFFFFE6E6),
    ];
    return colors[index % colors.length];
  }

  Icon _getIcon(int index) {
    List<IconData> icons = [
      Icons.description,
      Icons.coffee,
      Icons.work,
      Icons.beach_access,
    ];
    List<Color> iconColors = [
      Color(0xFFFFB067),
      Color(0xFF67B0FF),
      Color(0xFF67FF8C),
      Color(0xFFFF6767),
    ];
    return Icon(
      icons[index % icons.length],
      color: iconColors[index % iconColors.length],
      size: 24,
    );
  }
}
