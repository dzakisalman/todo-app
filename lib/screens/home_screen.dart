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
            "Zaid bin Tsabit",
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
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search, color: Colors.white54),
                hintText: "Cari...",
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
            Icon(Icons.sort),
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
    return Obx(() {
      if (taskController.isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (taskController.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                taskController.error,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => taskController.retryLoadTasks(),
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (taskController.tasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks yet. Add your first task!',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        itemCount: taskController.tasks.length,
        itemBuilder: (context, index) {
          final task = taskController.tasks[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => DetailScreen(task: task));
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Task'),
                    content: Text('Are you sure you want to delete this task?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      TextButton(
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          taskController.removeTask(index);
                          Get.back();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Task deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getIconColor(index),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _getIcon(index),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          task.time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) async {
                        await taskController.toggleTaskCompletion(index);
                      },
                      shape: CircleBorder(),
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
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
