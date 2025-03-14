import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../controllers/task_controller.dart';

class DetailScreen extends StatefulWidget {
  final TaskModel task;

  DetailScreen({required this.task});

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  late TimeOfDay selectedTime;
  String? imagePath;
  bool isLoadingImage = false;
  final TaskController taskController = Get.find();

  @override
  void initState() {
    super.initState();
    parseTimeFromTask();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      isLoadingImage = true;
    });

    try {
      // First try to get local image
      String? localPath = await taskController.getLocalImage(widget.task.id);
      
      if (localPath != null) {
        print('Found local image: $localPath');
        setState(() {
          imagePath = localPath;
          isLoadingImage = false;
        });
        return;
      }

      // If local image not available, use Firebase URL
      if (widget.task.imageUrl != null) {
        print('Using Firebase URL: ${widget.task.imageUrl}');
        setState(() {
          imagePath = widget.task.imageUrl;
          isLoadingImage = false;
        });
      } else {
        setState(() {
          imagePath = null;
          isLoadingImage = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        imagePath = null;
        isLoadingImage = false;
      });
    }
  }

  void parseTimeFromTask() {
    selectedTime = TimeOfDay(
      hour: widget.task.time.hour,
      minute: widget.task.time.minute,
    );
  }

  Future<void> selectTime() async {
    final bool? result = await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF3B5CB8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  "EDIT TIME",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTimePicker(24, selectedTime.hour, (value) {
                  setState(() {
                    selectedTime =
                        TimeOfDay(hour: value, minute: selectedTime.minute);
                  });
                }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                buildTimePicker(60, selectedTime.minute, (value) {
                  setState(() {
                    selectedTime =
                        TimeOfDay(hour: selectedTime.hour, minute: value);
                  });
                }),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton("Cancel", Colors.blue.shade700, () => Get.back()),
                buildButton("Save", Colors.orange, () {
                  Get.back(result: true);
                }),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );

    if (result == true) {
      // Update task with new time
      final now = DateTime.now();
      final newTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final updatedTask = TaskModel(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        time: newTime,
        imageUrl: widget.task.imageUrl,
        isCompleted: widget.task.isCompleted,
      );

      await taskController.updateTask(updatedTask);

      Get.snackbar(
        'Success',
        'Waktu berhasil diubah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  Widget buildTimePicker(int max, int selectedValue, Function(int) onSelected) {
    return Container(
      width: 60,
      height: 180,
      child: ListWheelScrollView(
        itemExtent: 50,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        children: List.generate(max, (index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: index == selectedValue
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.task.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 30,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFff8b60), width: 5),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoItem(Icons.calendar_today, "26/02/2025", "Date"),
                  GestureDetector(
                    onTap: selectTime,
                    child: buildInfoItem(
                        Icons.access_time,
                        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} WIB",
                        "Time"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoItem(Icons.category, "Travel", "Category"),
                  buildInfoItem(Icons.location_on, "Surabaya", "Location"),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: isLoadingImage
                    ? CircularProgressIndicator()
                    : imagePath != null
                        ? _buildImage(imagePath!)
                        : Text('No image found'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    try {
      if (path.startsWith('http')) {
        // It's a Firebase URL
        return Image.network(
          path,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return Text('Failed to load image');
          },
        );
      } else {
        // It's a local file
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading local image: $error');
              return Text('Failed to load image');
            },
          );
        } else {
          return Text('Image file not found');
        }
      }
    } catch (e) {
      print('Error building image: $e');
      return Text('Error loading image');
    }
  }
}

Widget buildInfoItem(IconData icon, String value, String label) {
  return Row(
    children: [
      Icon(icon, color: Colors.blue, size: 20),
      SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    ],
  );
}
