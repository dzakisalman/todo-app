class TaskModel {
  final String title;
  final String time;
  bool isCompleted;

  TaskModel({required this.title, required this.time, this.isCompleted = false});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
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
