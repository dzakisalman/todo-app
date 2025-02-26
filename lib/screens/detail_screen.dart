import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

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

  @override
  void initState() {
    super.initState();
    parseTimeFromTask();
    _loadImagePath();
  }

  Future<void> _loadImagePath() async {
    setState(() {
      isLoadingImage = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loadedPath = prefs.getString('imagePath_${widget.task.id}');

    if (loadedPath != null && File(loadedPath).existsSync()) {
      print('Loaded imagePath for task ${widget.task.id}: $loadedPath');
      setState(() {
        imagePath = loadedPath;
      });
    } else {
      print('No valid image found for task ${widget.task.id}');
      setState(() {
        imagePath = null;
      });
    }

    setState(() {
      isLoadingImage = false;
    });
  }

  void parseTimeFromTask() {
    try {
      List<String> timeParts = widget.task.time.split(":");
      if (timeParts.length == 2) {
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } else {
        selectedTime = TimeOfDay.now();
      }
    } catch (e) {
      print("Error parsing time: $e");
      selectedTime = TimeOfDay.now();
    }
  }

  Future<void> selectTime() async {
    final bool? result = await showModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
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
                  buildButton("Cancel", Colors.blue.shade700,
                      () => Navigator.pop(context)),
                  buildButton("Save", Colors.orange, () {
                    Navigator.pop(context, true);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waktu berhasil diubah')),
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
            onPressed: () => Navigator.pop(context),
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
                "Ipsum dolor sit amet, consectetur acide tempor adscing sed do eiusmod tempor magna",
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
                        ? Image.file(File(imagePath!))
                        : Text('No image found'),
              ),
            ],
          ),
        ),
      ),
    );
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
