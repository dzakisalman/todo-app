class TaskModel {
  final String id;
  final String title;
  final String time;
  final String? imagePath;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.time,
    this.imagePath,
    this.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '', // Ambil id dari JSON
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      imagePath: json['imagePath'], // Ambil imagePath dari JSON
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imagePath': imagePath, // Sertakan imagePath dalam JSON
      'isCompleted': isCompleted,
    };
  }
}
