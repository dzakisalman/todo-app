class TaskModel {
  final String id;
  final String title;
  final String time;
  final String? imagePath;
  bool isCompleted;

  TaskModel({required this.id, required this.title, required this.time, this.isCompleted = false, this.imagePath});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      isCompleted: json['isCompleted'] ?? false, id: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'isCompleted': isCompleted,
    };
  }
}
