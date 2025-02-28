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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      imagePath: json['imagePath'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imagePath': imagePath,
      'isCompleted': isCompleted,
    };
  }

  int getTimeInMinutes() {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }
}
