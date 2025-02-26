import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isButtonEnabled = false;
  File? _selectedImage;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    titleController.addListener(updateButtonState);
  }

  @override
  void dispose() {
    titleController.removeListener(updateButtonState);
    titleController.dispose();
    super.dispose();
  }

  void updateButtonState() {
    setState(() {
      isButtonEnabled = titleController.text.isNotEmpty;
    });
  }

  Future<void> selectTime() async {
    final bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF4355B9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EDIT TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours
                      Container(
                        width: 60,
                        child: ListWheelScrollView(
                          itemExtent: 50,
                          children: List.generate(24, (index) {
                            String hour = index.toString().padLeft(2, '0');
                            return Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                hour,
                                style: TextStyle(
                                  color: hour ==
                                          selectedTime.hour
                                              .toString()
                                              .padLeft(2, '0')
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 24,
                                ),
                              ),
                            );
                          }),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedTime = TimeOfDay(
                                hour: index,
                                minute: selectedTime.minute,
                              );
                            });
                          },
                        ),
                      ),
                      Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Minutes
                      Container(
                        width: 60,
                        child: ListWheelScrollView(
                          itemExtent: 50,
                          children: List.generate(60, (index) {
                            String minute = index.toString().padLeft(2, '0');
                            return Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                minute,
                                style: TextStyle(
                                  color: minute ==
                                          selectedTime.minute
                                              .toString()
                                              .padLeft(2, '0')
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 24,
                                ),
                              ),
                            );
                          }),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedTime = TimeOfDay(
                                hour: selectedTime.hour,
                                minute: index,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7B54),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      try {
        await Gal.putImage(image.path);
        setState(() {
          _selectedImage = imageFile;
          _imagePath = image.path;
        });
        print("Image path: $_imagePath");
      } catch (e) {
        print("Error saving image to gallery: $e");
      }
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> _processImage(XFile image) async {
    File imageFile = File(image.path);
    try {
      await Gal.putImage(image.path);
      setState(() {
        _selectedImage = imageFile;
        _imagePath = image.path;
      });
      print("Image path: $_imagePath");
    } catch (e) {
      print("Error saving image to gallery: $e");
    }
  }

  void _addTask() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul tugas tidak boleh kosong')),
      );
      return;
    }

    final newTask = TaskModel(
      id: DateTime.now().toString(), // Generate unique ID
      title: titleController.text,
      time:
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
      imagePath: _imagePath,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4355B9),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Judul Tugas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul tugas',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Waktu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: selectTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Color(0xFF4355B9),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          _selectedImage != null
                              ? Image.file(_selectedImage!, height: 100)
                              : Text("No image selected"),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: Text("Add Photo"),
                              ),
                              ElevatedButton(
                                onPressed: _takePhoto,
                                child: Text("Take Photo"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled ? _addTask : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF7B54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Tambah Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Tambah Tugas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}
