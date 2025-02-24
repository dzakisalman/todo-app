import 'package:flutter/material.dart';
import '../models/task_model.dart';

class DetailScreen extends StatefulWidget {
  final TaskModel task;

  DetailScreen({required this.task});

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    parseTimeFromTask();
  }

  void parseTimeFromTask() {
    selectedTime = TimeOfDay(hour: 22, minute: 45); // Hardcoded sesuai gambar
  }

  Future<void> selectTime() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.transparent,
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
                      selectedTime = TimeOfDay(hour: value, minute: selectedTime.minute);
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
                      selectedTime = TimeOfDay(hour: selectedTime.hour, minute: value);
                    });
                  }),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Cancel", Colors.blue.shade700, () => Navigator.pop(context)),
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
                color: index == selectedValue ? Colors.white : Colors.white.withOpacity(0.5),
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
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Piknik ke Pantai Selatan",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Text(
                "Ipsum dolor sit amet, consectetur acide tempor adscing sed do eiusmod tempor magna",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoItem(Icons.calendar_today, "24/11/2019", "Date"),
                  GestureDetector(
                    onTap: selectTime,
                    child: buildInfoItem(
                      Icons.access_time,
                      "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} WIB",
                      "Time"
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoItem(Icons.category, "Travel", "Category"),
                  buildInfoItem(Icons.location_on, "Sukabumi", "Location"),
                ],
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
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    ],
  );
}
